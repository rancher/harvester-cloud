#!/bin/bash

# Starting the Virtual Network
sudo virsh net-define /srv/www/harvester/vlan1.xml
sudo virsh net-start vlan1
sudo virsh net-autostart vlan1

# HTTP server configuration
sudo chown nobody:nobody -R /srv/www
sudo systemctl enable --now nginx

# Creation of nested VMs
for i in $(seq 1 ${count}); do
  if [ $i == 1 ]; then
    sudo sed -i "s/${hostname}/${hostname}-$i/g" /srv/www/harvester/create_cloud_config.yaml
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough --disk path=/mnt/datadisk$i/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2 --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 30
  elif [ $i == 2 ]; then
    sudo sed -i "s/${hostname}/${hostname}-$i/g" /srv/www/harvester/join_cloud_config.yaml
    sudo sed -i "s/create_cloud_config.yaml/join_cloud_config.yaml/g" /srv/www/harvester/default.ipxe
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough --disk path=/mnt/datadisk$i/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2 --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 30
  else
    sudo cp /srv/www/harvester/join_cloud_config.yaml /srv/www/harvester/join_cloud_config_$((i - 1)).yaml
    sudo sed -i "s/  hostname:.*/  hostname: ${hostname}-$i/" /srv/www/harvester/join_cloud_config_$((i - 1)).yaml
    sudo sed -i "s|join_cloud_config[^ ]*\.yaml|join_cloud_config_$((i - 1)).yaml|" /srv/www/harvester/default.ipxe
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough --disk path=/mnt/datadisk$i/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2 --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 30
  fi
done

# Monitoring nested VM states and restarting them when all are 'shut off'
sudo chmod +x  /usr/local/bin/restart_harvester_vms_script.sh
(sudo crontab -l 2>/dev/null; echo "*/2 * * * * /usr/local/bin/restart_harvester_vms_script.sh") | sudo crontab -

# Expose the Harvester nested VM via the VM's public IP
sudo chmod 755 /etc/systemd/system/socat-proxy.service
sudo systemctl daemon-reload
sudo systemctl enable --now socat-proxy.service

# Restrict internet access to Harvester nodes when harvester_airgapped variable is true
if [ ${harvester_airgapped} == true ]; then
  sudo iptables -D LIBVIRT_FWO -s 192.168.122.0/24 -i virbr1 -j ACCEPT
  sudo iptables -I LIBVIRT_FWO 1 -s 192.168.122.0/16 -d 192.168.122.0/16 -j ACCEPT
fi

# Wait for the Harvester services to start
attempts=0
while [ "$attempts" -lt 15 ]; do
  ip=${public_ip}
  response=$(curl -k -s "https://$ip/ping")
  if [ "$response" == "pong" ]; then
    echo "Waiting for https://$ip/ping - response: $response"
    ((attempts++))
  else
    echo "Waiting for https://$ip/ping - response is not 'pong', retrying in 2 seconds..."
  fi
  sleep 2
done

# Copying the KUBECONFIG file from the RKE2 cluster under the hood of Harvester
sudo sshpass -p "${password}" ssh -oStrictHostKeyChecking=no "rancher@192.168.122.120" "sudo cat /etc/rancher/rke2/rke2.yaml" > /tmp/rke2.yaml
sudo sed -i "/certificate-authority-data:/c\\    insecure-skip-tls-verify: true" /tmp/rke2.yaml

# Creating additional disks if `data_disk_count` variable is > 1
if [ ${data_disk_count} -gt 1 ]; then
  disk_index=$(( ${count} + 1 ))  # Start indexing additional disks after the default disk
  for i in $(seq 1 ${count}); do
    for j in $(seq 1 $((${data_disk_count} - 1))); do
      # Create a new raw disk for each additional disk
      disk_path="/mnt/datadisk$disk_index/harvester-data.raw"
      sudo qemu-img create -f raw "$disk_path" ${harvester_default_disk_size}G

      # Generate a unique WWN for each disk
      wwn="0x5000c50015$(date +%N | sha512sum | head -c 6)"
      target_letter=$(echo $((disk_index + 1)) | awk '{printf "%c", 96 + $1}')
      target_dev="sd$target_letter"

      # Generate XML to attach the disk with unique WWN
      xml_file="/tmp/disk-$i-$j.xml"
      cat > "$xml_file" <<EOF
<disk type='file' device='disk'>
  <driver name='qemu' type='raw'/>
  <source file='$disk_path'/>
  <target dev='$target_dev' bus='scsi'/>
  <wwn>$wwn</wwn>
</disk>
EOF

      # Attach the disk to the VM live
      sudo virsh attach-device harvester-node-$i --file "$xml_file" --live
      disk_index=$((disk_index + 1))
    done
  done
fi
