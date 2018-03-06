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
