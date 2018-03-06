resource "archive_file" "sg_event" {
  type        = "zip"
  source_file = "function/lambda_function.py"
  output_path = "./lambda_function.zip"
}

resource "aws_lambda_function" "notify_sg_event" {
  filename      = "${archive_file.sg_event.output_path}"
  function_name = "${var.name["lambda_notify_sg_event"]}"
  role          = "${aws_iam_role.lambda_notify_sg_event.arn}"
  handler       = "lambda_function.lambda_handler"
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
