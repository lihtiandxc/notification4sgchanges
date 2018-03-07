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
    lambda_notify_sg_event                  = "mng01-vir-lambda-sns-account-sg-monitor"
    lambda_notify_nwif_event                = "mng01-vir-lambda-sns-account-nwif-monitor"
    iam_role_lambda_notify_security_event   = "mng01-lambda-account-sg-monitor"
    iam_policy_lambda_notify_security_event = "mng01-account-sg-monitor-lambda-function"
    cw_event_account_notify_sg_event        = "mng01-vir-cloudwatch-account-sg-event"
    cw_event_account_notify_nw_if_event     = "mng01-vir-cloudwatch-account-nwif-event"
    fr_aism_mailing                         = "lihtian@gmail.com"
    dxc_aism_mailing                        = "lih-tian.lim@hpe.com"
    sns_account_security_event              = "mng01-vir-notification-account-fr"
    function_sg_event                       = "function_sg_event"
    function_nwif_event                     = "function_nw_if_event"
    
  }
}

variable "lambda_python" {
  default {
    runtime = "python3.6"
  }
}



