#IAM role lambda
data "template_file" "lambda_role_notify_security_event" {
  template = "${file("policy/iam_policy_lambda_notify_security_event.json")}"

  vars {
    sns_topic = "${aws_sns_topic.security_event.arn}"
  }
}