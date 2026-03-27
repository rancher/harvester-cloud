locals {
  nfs_setup_script = var.nfs_server_install ? base64encode(templatefile("${path.module}/../../../modules/harvester/workload-scripts/nfs-setup.sh.tpl", {
    nfs_export_path    = var.nfs_export_path
    nfs_export_options = var.nfs_export_options
  })) : ""

  nfs_packages = var.nfs_server_install ? ["nfs-kernel-server"] : []
  nfs_runcmd   = var.nfs_server_install ? ["sleep 60 && bash /opt/nfs-setup.sh > /var/log/nfs-setup.log 2>&1"] : []

  nfs_write_files = var.nfs_server_install ? [
    {
      path        = "/opt/nfs-setup.sh"
      permissions = "0755"
      encoding    = "b64"
      content     = local.nfs_setup_script
    }
  ] : []
}
