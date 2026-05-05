<network xmlns:dnsmasq='http://libvirt.org/schemas/network/dnsmasq/1.0'>
  <name>vlan1</name>
  <bridge name="virbr1"/>
  <forward mode="nat"/>
  <ip address="192.168.122.1" netmask="255.255.255.0">
      <tftp root='/srv/www/harvester'/>
      <dhcp>
      <range start="192.168.122.2" end="192.168.122.254">
        <lease expiry='168' unit='hours'/>
      </range>
    </dhcp>
  </ip>
  <dnsmasq:options>
    <dnsmasq:option value='dhcp-match=set:is_ipxe,175'/>
    <dnsmasq:option value='dhcp-boot=tag:!is_ipxe,ipxe.efi'/>
    <dnsmasq:option value='dhcp-boot=tag:is_ipxe,http://192.168.122.1/default.ipxe'/>
  </dnsmasq:options>
</network>
