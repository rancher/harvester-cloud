#!/bin/bash

# Starting the Virtual Network
sudo virsh net-define /srv/www/harvester/vlan1.xml
sudo virsh net-start vlan1
sudo virsh net-autostart vlan1

# HTTP server configuration
sudo chown nobody:nobody -R /srv/www
sudo systemctl enable --now nginx

# Creation of nested VMs, based on the number of data disks
if [ "${additional_disk}" == "true" ]; then
  disks_per_node=2
else
  disks_per_node=1
fi

for i in $(seq 1 ${count}); do
  base_disk_index=$(( (i - 1) * disks_per_node + 1 ))
  disk_args=""
  for d in $(seq 0 $((disks_per_node - 1))); do
    disk_number=$((base_disk_index + d))
    disk_args+=" --disk path=/mnt/datadisk$disk_number/harvester-data.qcow2,size=${harvester_default_disk_size},bus=virtio,format=qcow2"
  done
  if [ $i == 1 ]; then
    sudo sed -i "s/${hostname}/${hostname}-$i/g" /srv/www/harvester/create_cloud_config.yaml
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough $disk_args --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 30
  elif [ $i == 2 ]; then
    sudo sed -i "s/${hostname}/${hostname}-$i/g" /srv/www/harvester/join_cloud_config.yaml
    sudo sed -i "s/create_cloud_config.yaml/join_cloud_config.yaml/g" /srv/www/harvester/default.ipxe
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough $disk_args --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
    sleep 30
  else
    sudo cp /srv/www/harvester/join_cloud_config.yaml /srv/www/harvester/join_cloud_config_$((i - 1)).yaml
    sudo sed -i "s/${hostname}-$((i - 1))/${hostname}-$i/g" /srv/www/harvester/join_cloud_config_$((i - 1)).yaml
    sudo sed -i "s/join_cloud_config.yaml/join_cloud_config_$((i - 1)).yaml/g" /srv/www/harvester/default.ipxe
    sudo virt-install --name harvester-node-$i --memory ${memory} --vcpus ${cpu} --cpu host-passthrough $disk_args --os-type linux --os-variant generic --network bridge=virbr1,model=virtio --graphics vnc,listen=0.0.0.0,password=yourpass,port=$((5900 + i)) --console pty,target_type=serial --pxe --autostart &
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

# Adding GPT partition table to the additional disks if required.
if [ "${additional_disk}" == "true" ]; then
for i in $(sudo virsh net-dhcp-leases vlan1  | grep ${hostname} | grep -v "192.168.122.120" | awk '{print $5}' | awk -F "/" '{print $1}'); do sudo sshpass -p "${password}" ssh -oStrictHostKeyChecking=no "rancher@$i" "sudo parted /dev/vdb --script mklabel gpt && sudo parted /dev/vdb --script mkpart primary 0% 100%"; done
fi