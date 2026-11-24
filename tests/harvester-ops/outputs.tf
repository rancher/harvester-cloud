output "harvester_ops_status" {
  value = data.external.verify_harvester_ops.result.status
}
