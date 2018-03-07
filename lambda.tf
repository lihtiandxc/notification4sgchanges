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
      #service   = "${var.tags["service"]}"
      #env       = "${var.tags["env"]}"
      global_sns_topic_arn = "${aws_sns_topic.security_event.arn}"
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

resource "aws_lambda_permission" "allow_cloudwatch_sg_event" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_sg_event.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda_notify_sg_event.arn}"
}



#lambda function for Modify NW interafce event
resource "archive_file" "nwif_event" {
  type        = "zip"
  source_file = "function/${var.name["function_nwif_event"]}.py"
  output_path = "./${var.name["function_nwif_event"]}.zip"
}

resource "aws_lambda_function" "notify_nwif_event" {
  filename      = "${archive_file.nwif_event.output_path}"
  function_name = "${var.name["lambda_notify_nwif_event"]}"
  role          = "${aws_iam_role.lambda_notify_sg_event.arn}"
  handler       = "${var.name["function_nwif_event"]}.lambda_handler"
  runtime       = "${var.lambda_python["runtime"]}"
  timeout       = "300"

  environment {
    variables = {
      service   = "${var.tags["service"]}"
      env       = "${var.tags["env"]}"
      global_sns_topic_arn = "${aws_sns_topic.security_event.arn}"
      global_accountpf_sg_list = "sg-c87e38b8,sg-a8bb07d3,sg-233f485c,sg-2b7b3d5b,sg-0297c272,sg-e29dc892,sg-dcf86ca8"
      #global_accountpf_sg_name = "Prod_sg_mante,Monitor,Stag_account"
    }
  }

  tags {
    Name = "${var.name["lambda_notify_nwif_event"]}"
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

resource "aws_lambda_permission" "allow_cloudwatch_nwif_event" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_nwif_event.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.lambda_notify_nwif_event.arn}"
}