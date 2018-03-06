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
    elb_api               = "prd01-vir-web-account-fr"
    ec2_api               = "prd01-vir-web-account-fr"
    elb_spa               = "prd01-vir-spa-account-fr"
    ec2_spa               = "prd01-vir-spa-account-fr"
    ec2_batch             = "prd01-b-vir-batch-account-fr"
    elb_logaggregator     = "prd01-vir-log-account-fr"
    ec2_logaggregator_az1 = "prd01-a-vir-logaggregator-account-fr"
    ec2_logaggregator_az2 = "prd01-b-vir-logaggregator-account-fr"
    elb_jenkins           = "prd01-vir-job-account-fr"
    elb_jenkins_admin_sg  = "prd01-vir-admin-sg-account-fr"
    elb_jenkins_admin_th  = "prd01-vir-admin-th-account-fr"
    elb_jenkins_admin_au  = "prd01-vir-admin-au-account-fr"
    elb_cms               = "prd01-vir-cms-account-fr"
    elb_admin             = "prd01-vir-admin-account-fr"
    ec2_jenkins           = "prd01-b-vir-jenkins-account-fr"
    ec2_jenkins_dxc       = "mng01-b-vir-jenkins-account-aism"
    ec2_jenkins_aism      = "mng01-b-vir-jenkins-account-aism"
    ec2_bastion           = "mng01-b-vir-bastion-account-fr"
    rds_master            = "prd01-vir-account-fr"
    rds_rep_mysql         = "prd02-vir-account-fr"
    kms                   = "prd01-vir-account-fr"
    rds_spa               = "prd01-vir-spa-account-fr"
    param_master          = "prd01-account-master-mysql57"
    param_replica         = "prd01-account-replica-mysql57"
    param_spa             = "prd01-account-spa-postgres96"
    iam_role              = "prd01-vir-account-fr"
    iam_role_log          = "prd01-vir-logaggregator-account-fr"
    iam_role_batch        = "prd01-vir-batch-account-fr"
    iam_role_bastion      = "mng01-b-vir-bastion-account-fr"
    sg                    = "prd01-vir-account-fr"
    sg_spa                = "prd01-vir-spa-account-fr"
    sg_cms                = "prd01-vir-cms-account-fr"
    sg_logaggregator      = "prd01-vir-logaggregator-account-fr"
    sg_mainte             = "prd01-vir-mainte-account-fr"
    sg_bastion            = "prd01-vir-bastion-account-fr"
    sg_jenkins            = "prd01-vir-jenkins-account-fr"
    sg_jenkins_aism       = "mng01-vir-jenkins-account-aism"
    cache_az1             = "prd01-vir-account"
    cache_az2             = "prd02-vir-account"
    s3                    = "fr-production-vir-mse"
    ec2_role_policy_log   = "s3-access"
    ec2_role_policy_batch = "s3-access-readonly"
    ec2_role_policy_bastion = "account-bastion-sendlogs"
    lambda_notify_sg_event = "mng01-account-lambda-sg-monitor"
    iam_role_lambda_notify_sg_event   = "mng01-lambda-account-sg-monitor"
    iam_policy_lambda_notify_sg_event = "mng01-lambda-account-sg-monitor-sns"
    cw_event_account_notify_sg_event = "mng01-account-notify-sg-event"
    fr-aism-mailing       = "lih-tian.lim@gmail.com"
    dxc-aism-mailing      = "lih-tian.lim@hpe.com"
    
  }
}

variable "domain" {
  default = {
    zone_api          = "org.api.fastretailing.com"
    zone_fr           = "fastretailing.com"
    zone_orgfr        = "org.fastretailing.com"
    elb_api           = "vir-account"
    elb_spa           = "vir-account-spa"
    elb_logaggregator = "vir-logaggregator-account"
    elb_jenkins       = "vir-jenkins-account"
    elb_jenkins_admin_sg = "vir-sgp-admin-account"
    elb_jenkins_admin_th = "vir-th-admin-account"
    elb_jenkins_admin_au = "vir-au-admin-account"
    elb_cms           = "vir-cms-account"
    elb_admin         = "vir-admin-account"
    rds_master        = "vir-db-account"
    rds_rep_mysql     = "vir-db-read-account"
    rds_spa           = "vir-db-account-spa"
    cache_az1         = "vir-a-cache-account"
    cache_az2         = "vir-b-cache-account"
  }
}

variable "mysql_master" {
  default = {
    storage            = 50
    engine             = "MySQL"
    version            = "5.7.17"
    backup_window      = "18:00-19:00"
    maintenance_window = "Sat:19:00-Sat:20:00"
  }
}

variable "mysql_replica" {
  default = {
    backup_window      = "18:00-19:00"
    maintenance_window = "Sat:19:00-Sat:20:00"
  }
}

variable "spa" {
  default = {
    engine             = "postgres"
    version            = "9.6.2"
    storage            = 10
    maintenance_window = "Sat:19:00-Sat:20:00"
    backup_window      = "18:00-19:00"
  }
}

variable "cache" {
  default = {
    nodes           = "1"
    parameter_group = "default.memcached1.4"
  }
}

variable "s3_access_log" {
  default = "fr-production-vir-access-log"
}

variable "sg" {
  default = {
    monitor = "sg-233f485c"
  }
}

variable "lambda_python" {
  default {
    runtime = "python3.6"
  }
}
