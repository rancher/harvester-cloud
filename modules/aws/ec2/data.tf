data "aws_ssm_parameter" "sles" {
  name = "/aws/service/suse/sles-byos/15-sp6/x86_64/latest"
}