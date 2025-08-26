locals {
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  instance_count       = 1
  instance_os_type     = "opensuse"
  os_image_publisher   = "suse"
  os_image_offer       = "opensuse-leap-15-6"
  os_image_sku         = "gen1"
  os_image_version     = "latest"
  ssh_username         = local.instance_os_type
}

resource "tls_private_key" "ssh_private_key" {
  count     = var.create_ssh_key_pair ? 1 : 0
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.private_ssh_key_path
  content         = tls_private_key.ssh_private_key[0].private_key_openssh
  file_permission = "0600"
}

resource "local_file" "public_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.public_ssh_key_path
  content         = tls_private_key.ssh_private_key[0].public_key_openssh
  file_permission = "0600"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  count               = var.create_vnet ? 1 : 0
  name                = "${var.prefix}-vnet"
  address_space       = [var.ip_cidr_range]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  count                = var.create_vnet ? 1 : 0
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet[0].name
  address_prefixes     = [var.ip_cidr_range]
}

resource "azurerm_public_ip" "vm_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_inbound" {
  for_each = toset([
    "22", "68", "443", "2379", "2380", "2381", "10010", "2112", "30000-32767",
    "3260", "5900", "6080", "6443", "6444", "8181", "8443", "8444", "8472",
    "9091", "9099", "9345", "9796", "10245", "10246-10249", "10250", "10251",
    "10252", "10256", "10257", "10258", "10259"
  ])

  name = "${var.prefix}-allow-inbound-${each.key}"
  priority = 100 + index([
    "22", "68", "443", "2379", "2380", "2381", "10010", "2112", "30000-32767",
    "3260", "5900", "6080", "6443", "6444", "8181", "8443", "8444", "8472",
    "9091", "9099", "9345", "9796", "10245", "10246-10249", "10250", "10251",
    "10252", "10256", "10257", "10258", "10259"
  ], each.key)
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = each.key
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_security_rule" "allow_outbound" {
  name                        = "${var.prefix}-allow-outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = local.instance_count
  name                = "${var.prefix}-vm-${count.index + 1}-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.instance_type
  admin_username      = local.ssh_username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]
  priority        = var.spot_instance ? "Spot" : "Regular"
  eviction_policy = var.spot_instance ? "Deallocate" : null
  admin_ssh_key {
    username   = local.ssh_username
    public_key = tls_private_key.ssh_private_key[0].public_key_openssh
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size
  }
  source_image_reference {
    publisher = local.os_image_publisher
    offer     = local.os_image_offer
    sku       = local.os_image_sku
    version   = local.os_image_version
  }
  custom_data = var.startup_script != null ? base64encode(var.startup_script) : null
}

resource "azurerm_managed_disk" "data_disk" {
  count                = var.data_disk_count
  name                 = "${var.prefix}-data-disk-${count.index + 1}-${random_string.random.result}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = var.data_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  count              = var.data_disk_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[0].id
  lun                = count.index
  caching            = "ReadWrite"
}
