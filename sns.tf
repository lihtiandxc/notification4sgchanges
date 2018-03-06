# for AccountPF notification
variable "sns_disp" {
  default {
    sns_mng = "AccountPF_Notification"
  }
}

#variable "commands" {
#  default {
#    local-exec01  = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.name["fr-aism-mailing"]}"
#    local-exec02  = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.name["dxc-aism-mailing"]}"
#  }
#}

resource "aws_sns_topic" "management" {
  name         = "${var.name["sns_mng"]}"
  display_name = "${var.sns_disp["sns_mng"]}"
  provider     = "aws.virginia"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.name["fr-aism-mailing"]}"
    #command = "${var.command["local-exec01"]}"
    #command = "${var.command["local-exec02"]}"
  }
}


#aws cli create new subscription

#aws sns subscribe --topic-arn arn:aws:sns:us-west-2:0123456789012:my-topic --protocol email --notification-endpoint my-email@example.com
