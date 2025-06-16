#cloud-config
scheme_version: 1
token: ${token}
os:
  hostname: ${hostname}
  password: ${password}
  ntp_servers:
  %{ if harvester_airgapped }
    - 192.168.122.1
  %{ else }
    - 0.suse.pool.ntp.org
    - 1.suse.pool.ntp.org
  %{ endif }
install:
  mode: create
  management_interface:
    interfaces:
      - name: ens3
    default_route: true
    method: dhcp
    bond_options:
      mode: active-backup
      miimon: 100
  device: /dev/vda
  iso_url: http://192.168.122.1/harvester-${version}-amd64.iso
  tty: tty1,115200n8
  vip: 192.168.122.120
  vip_mode: static
%{ if cluster_registration_url != "" }
system_settings:
  cluster-registration-url: ${cluster_registration_url}
%{ endif }
