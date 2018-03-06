# for AccountPF notification
variable "sns_disp" {
  default {
    sns_account_sg_event = "mng01accountnotifysgeventSNS"
  }
}

resource "aws_sns_topic" "sg_event" {
  name         = "${var.name["sns_account_sg_event"]}"
  display_name = "${var.sns_disp["sns_account_sg_event"]}"
  provider     = "aws.virginia"
}

#locals being used to replace Variable
#due to variable not able to accept interpolation, this making code hardly maintenance
#locals accept interpolation, so the it is reusable and accept references value
locals {
  fr_email_endpoint   = "aws sns subscribe --topic-arn ${aws_sns_topic.sg_event.arn} --protocol email --notification-endpoint ${var.name["fr_aism_mailing"]}"
  dxc_email_endpoint  = "aws sns subscribe --topic-arn ${aws_sns_topic.sg_event.arn} --protocol email --notification-endpoint ${var.name["dxc_aism_mailing"]}"
}

#null_resource used for local aws cli command
#due to the email endpoint need confirmation, terraform does not support email endpoint in sns_topic_subcription resource
#workaround is using provisioner with local-exec method
resource "null_resource" "sns_email_subscription" {
  provisioner "local-exec" {
    command = "${local.fr_email_endpoint} ; ${local.dxc_email_endpoint}"
  }
}

#provisioner of local-exec can be written in the resource "aws_sns_topic" "sg_event{} code block
#however, it returns error with cycle msg when doing resource reference such as ${aws_sns_topic.sg_event.arn}
#workaround is to use null_resource to carry the provisioner seperately
