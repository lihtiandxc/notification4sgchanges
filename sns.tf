# for AccountPF notification
variable "sns_disp" {
  default {
    sns_mng = "AccountPF_Notification"
  }
}

resource "aws_sns_topic" "management" {
  name         = "${var.sns_disp["sns_mng"]}"
  display_name = "${var.sns_disp["sns_mng"]}"
  provider     = "aws.virginia"
}

locals {
  fr_email_endpoint   = "aws sns subscribe --topic-arn ${aws_sns_topic.management.id} --protocol email --notification-endpoint ${var.name["fr-aism-mailing"]}"
  dxc_email_endpoint  = "aws sns subscribe --topic-arn ${aws_sns_topic.management.id} --protocol email --notification-endpoint ${var.name["dxc-aism-mailing"]}"
}

resource "null_resource" "sns_email_subscription" {
  provisioner "local-exec" {
    command = "${local.fr_email_endpoint} ; ${local.dxc_email_endpoint}"
  }

}

#workable
/*
resource "aws_sns_topic" "management" {
  name         = "${var.sns_disp["sns_mng"]}"
  display_name = "${var.sns_disp["sns_mng"]}"
  provider     = "aws.virginia"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.name["dxc-aism-mailing"]};aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.name["fr-aism-mailing"]}"
  }
}
*/
