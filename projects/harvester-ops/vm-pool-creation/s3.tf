locals {
  s3_setup_script = var.s3_server_install ? base64encode(templatefile("${path.module}/../../../modules/harvester/workload-scripts/s3-garage-setup.sh.tpl", {
    garage_version = var.s3_garage_version
    bucket_name    = var.s3_bucket_name
    bucket_region  = var.s3_bucket_region
  })) : ""

  s3_packages = var.s3_server_install ? ["wget", "openssl"] : []
  s3_runcmd   = var.s3_server_install ? ["sleep 60 && bash /opt/s3-garage-setup.sh > /var/log/s3-garage-setup.log 2>&1"] : []

  s3_write_files = var.s3_server_install ? [
    {
      path        = "/opt/s3-garage-setup.sh"
      permissions = "0755"
      encoding    = "b64"
      content     = local.s3_setup_script
    }
  ] : []
}
