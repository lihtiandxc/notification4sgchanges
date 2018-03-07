variable "tags" {
  default = {
    # format: two uppercase letters
    # e.g. JP
    country = "US"

    # should not include pf or platform
    # accountpf -> account
    service = "account"

    # format: lowercase
    # domain means vpc
    domain = "production"

    # format: two lowercase letters
    # e.g. uq
    brand = "fr"

    # format: lowercase
    env = "production"
  }
}

variable "name" {
  default {
    lambda_notify_sg_event            = "mng01-vir-lambda-sns-account-sg-monitor"
    iam_role_lambda_notify_sg_event   = "mng01-lambda-account-sg-monitor"
    iam_policy_lambda_notify_sg_event = "mng01-account-sg-monitor-lambda-function"
    cw_event_account_notify_sg_event  = "mng01-vir-cloudwatch-account-sg-event"
    fr_aism_mailing       = "lihtian@gmail.com"
    dxc_aism_mailing      = "lih-tian.lim@hpe.com"
    sns_account_sg_event  = "mng01-vir-notification-account-fr"
    function_sg_event     = "function_sg_event"
    
  }
}

variable "lambda_python" {
  default {
    runtime = "python3.6"
  }
}

provider "aws" {
  alias  = "virginia"
  region = "${var.region}"
}

variable "region" {
  default     = "us-east-1"
}

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
#due to variable not able to accept interpolation, this making code hardly maintain
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

resource "archive_file" "sg_event" {
  type        = "zip"
  source_file = "function/${var.name["function_sg_event"]}.py"
  output_path = "./${var.name["function_sg_event"]}.zip"
}

resource "aws_lambda_function" "notify_sg_event" {
  filename      = "${archive_file.sg_event.output_path}"
  function_name = "${var.name["lambda_notify_sg_event"]}"
  role          = "${aws_iam_role.lambda_notify_sg_event.arn}"
  handler       = "${var.name["function_sg_event"]}.lambda_handler"
  runtime       = "${var.lambda_python["runtime"]}"
  timeout       = "300"

  environment {
    variables = {
      service   = "${var.tags["service"]}"
      env       = "${var.tags["env"]}"
      global_sns_topic_arn = "${aws_sns_topic.sg_event.arn}"
      global_accountpf_sg_list = "sg-48aa5a3e,sg-9ba7c2ec,sg-352d1542"
      global_accountpf_sg_name = "Prod_sg_mante,Monitor,Stag_account"
    }
  }

  tags {
    Name = "${var.name["lambda_notify_sg_event"]}"
    Service = "${var.tags["service"]}"
    Brand   = "${var.tags["brand"]}"
    Domain  = "${var.tags["domain"]}"
    Env     = "${var.tags["env"]}"
    Country = "${var.tags["country"]}"
    Role    = "function"
    Maintainer = "DXC"
  }

  lifecycle {
    ignore_changes = [
      "filename",
      "description",
      "handler",
    ]
  }
}

resource "aws_lambda_permission" "allow_cloudwatch_mng" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_sg_event.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda_notify_sg_event.arn}"
}

resource "aws_iam_role" "lambda_notify_sg_event" {
  name = "${var.name["iam_role_lambda_notify_sg_event"]}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_sg_monitor_sns" {
  name   = "${var.name["iam_policy_lambda_notify_sg_event"]}"
  #role   = "${aws_iam_role.lambda_notify_sg_event.id}"
  policy = "${data.template_file.lambda_role_notify_sg_event.rendered}"
}

resource "aws_iam_role_policy_attachment" "lambda_sg_monitor_sns" {
  role       = "${aws_iam_role.lambda_notify_sg_event.name}"
  policy_arn = "${aws_iam_policy.lambda_sg_monitor_sns.arn}"
}

#IAM role lambda
data "template_file" "lambda_role_notify_sg_event" {
  template = "${file("policy/iam_policy_lambda_notify_sg_event.json")}"

  vars {
    sns_topic = "${aws_sns_topic.sg_event.arn}"
  }
}

resource "aws_cloudwatch_event_rule" "lambda_notify_sg_event" {
  name                = "${var.name["cw_event_account_notify_sg_event"]}"
  description         = "${var.name["cw_event_account_notify_sg_event"]}"

  event_pattern = <<PATTERN
{
  "detail-type": [
  "AWS API Call via CloudTrail"
  ],
  "source": [
    "aws.ec2"
  ],
  "detail": {
    "eventSource": [
      "ec2.amazonaws.com"
    ],
    "eventName": [
      "AuthorizeSecurityGroupEgress",
      "AuthorizeSecurityGroupIngress",
      "DeleteSecurityGroup",
      "RevokeSecurityGroupEgress",
      "RevokeSecurityGroupIngress"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda_notify_sg_event" {
  rule = "${aws_cloudwatch_event_rule.lambda_notify_sg_event.name}"
  arn  = "${aws_lambda_function.notify_sg_event.arn}"
}

