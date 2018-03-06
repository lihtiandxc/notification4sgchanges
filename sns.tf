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

module "sns_topic_arn" {
  sns_topic_arn = "${aws_sns_topic.management.id}"
}

locals {
  local-exec01  = "aws sns subscribe --topic-arn ${module.sns_topic_arn.sns_topic_arn} --protocol email --notification-endpoint ${var.name["fr-aism-mailing"]}"
  #local-exec02  = "aws sns subscribe --topic-arn ${aws_sns_topic.management.arn} --protocol email --notification-endpoint ${var.name["dxc-aism-mailing"]}"
}

resource "null_resource" "subscription" {
  provisioner "local-exec" {
    command = "${local.local-exec01}"
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
