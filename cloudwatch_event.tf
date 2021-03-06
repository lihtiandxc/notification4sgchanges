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

#Cloudwatch event for Modify NW Interface attribute event 
resource "aws_cloudwatch_event_rule" "lambda_notify_nwif_event" {
  name                = "${var.name["cw_event_account_notify_nw_if_event"]}"
  description         = "${var.name["cw_event_account_notify_nw_if_event"]}"

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
      "ModifyNetworkInterfaceAttribute"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "lambda_notify_nwif_event" {
  rule = "${aws_cloudwatch_event_rule.lambda_notify_nwif_event.name}"
  arn  = "${aws_lambda_function.notify_nwif_event.arn}"
}
