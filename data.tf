#IAM role lambda
data "template_file" "lambda_role_notify_sg_event" {
  template = "${file("policy/iam_policy_lambda_notify_sg_event.json")}"

  vars {
    sns_topic = "${aws_sns_topic.management.arn}"
  }
}