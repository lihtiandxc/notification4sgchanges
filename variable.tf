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



