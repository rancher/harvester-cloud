<network>
  <name>${name}</name>
  <bridge name="${nic}"/>
  <forward mode="nat"/>
  <ip address="${ip_base}.1" netmask="255.255.255.0">
    <dhcp>
      <range start="${ip_base}.2" end="${ip_base}.254">
        <lease expiry='168' unit='hours'/>
      </range>
    </dhcp>
  </ip>
</network>
