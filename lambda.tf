resource "archive_file" "mng" {
  type        = "zip"
  source_file = "code/notification4SGChanges/lambda_function.py"
  output_path = "./lambda.zip"
}

resource "aws_lambda_function" "notify_sg_event" {
  filename      = "${archive_file.mng.output_path}"
  function_name = "${var.name["lambda_notify_sg_event"]}"
  role          = "${aws_iam_role.lambda.arn}"
  handler       = "index.handler"
  runtime       = "${var.lambda_python["runtime"]}"
  timeout       = "300"

  environment {
    variables = {
      service   = "${var.tags["service"]}"
      env       = "${var.tags["env"]}"
      sns_topic = "${aws_sns.topic.mng}"

    }
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
