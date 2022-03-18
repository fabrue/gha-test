include {
  path   = find_in_parent_folders()
  expose = true
}

dependencies {
  paths = ["../../../aws/bootstrap"]
}

dependency "s3_airflow_dags" {
  config_path = "../../../aws/s3/airflow-v2-dags"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws::::mock"
  }
}

dependency "acm_certificate" {
  config_path = "../../../aws/acm_certificate/stage-env-tt-apollo-tom-tailor-com"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    acm_certificate_arn = "arn:aws:acm:eu-central-1:01234567891:certificate/mock"
  }
}

dependency "batch_submit_policy" {
  config_path = "../../../aws/iam_policy/batch_allow_submit_job"

  mock_outputs_allowed_terraform_commands = include.locals.mock_outputs_allowed_terraform_commands
  mock_outputs_merge_with_state           = true
  mock_outputs = {
    arn = "arn:aws:iam::aws:policy/mock"
  }
}

locals {
  name = {
  }
  security_group_ids = {
    lab  = ["sg-0684018ed7ff545e8"]
    prod = ["sg-08f8960f15ee4dd79"]
  }
  subnet_ids = {
    lab  = ["subnet-09e142a9d31735248", "subnet-099e04131ab4cda8e", ] # lab-data 3rd "subnet-00f47eca104e71cfc"
    prod = ["subnet-093d1ddb07e5f94e9", "subnet-00faa80ed8734fcb3", ] # data-prod 3rd "subnet-0fb5dce4bacb6f979"
  }
  role_policy_arns = {
    lab = [
      "arn:aws:iam::023296727374:policy/tt-lab-data-redshift-users-loader-admin",
      "arn:aws:iam::023296727374:policy/tt-lab-data-redshift-cluster-info",
      "arn:aws:iam::023296727374:policy/tt-lab-data-s3-deposit-assume-access",
      "arn:aws:iam::023296727374:policy/tt-lab-data-kube2iam_airflow_extended",
    ]
    prod = [
      "arn:aws:iam::680621831508:policy/tt-prod-data-redshift-users-loader-admin",
      "arn:aws:iam::680621831508:policy/tt-prod-data-redshift-cluster-info",
      "arn:aws:iam::680621831508:policy/tt-prod-data-s3-deposit-assume-access",
      "arn:aws:iam::680621831508:policy/tt-prod-data-kube2iam_airflow_extended",
    ]
  }
  min_workers = {
    prod = 10
  }

  dns_suffix = "data.${include.locals.environment}.${include.locals.root_domain}"
}

inputs = {
  create = true

  name = lookup(local.name, include.locals.environment, "airflow-v2")

  airflow_version = "2.0.2"

  airflow_configuration_options = {
    "webserver.expose_config"       = "True"
    "smtp.smtp_mail_from"           = "airflow-${include.locals.target_aws_account_name}@apollo.tom-tailor.com"
    "smtp.smtp_host"                = "ex-hh01.jedi.tom-tailor.com"
    "smtp.smtp_starttls"            = "True"
    "core.load_examples"            = "False"
    "core.load_default_connections" = "False"
    "core.dagbag_import_timeout"    = "300"
    "celery.sync_parallelism"       = "1" # optimize sync process with meta db -> mitigate connection errors
  }

  max_workers       = 10
  min_workers       = lookup(local.min_workers, include.locals.environment, 1)
  environment_class = "mw1.small"

  source_bucket_arn    = dependency.s3_airflow_dags.outputs.arn
  dag_s3_path          = "dags"
  requirements_s3_path = "requirements.txt"

  security_group_ids = lookup(local.security_group_ids, include.locals.environment) # lab-data default-vpc FIXME: read in dynamic values
  subnet_ids         = lookup(local.subnet_ids, include.locals.environment)         # max 2; FIXME: read in dynamic values

  role_policy_arns = concat(
    [
      "arn:aws:iam::aws:policy/AmazonElasticMapReduceFullAccess",
      dependency.batch_submit_policy.outputs.arn
    ],
    lookup(local.role_policy_arns, include.locals.environment)
  ) # FIXME: read dynamic policys

  dag_processing_logs_enabled   = true
  dag_processing_logs_log_level = "INFO" #  [CRITICAL ERROR WARNING INFO DEBUG]
  scheduler_logs_enabled        = true
  scheduler_logs_log_level      = "INFO" #  [CRITICAL ERROR WARNING INFO DEBUG]
  task_logs_enabled             = true
  task_logs_log_level           = "INFO" #  [CRITICAL ERROR WARNING INFO DEBUG]
  webserver_logs_enabled        = true
  webserver_logs_log_level      = "INFO" #  [CRITICAL ERROR WARNING INFO DEBUG]
  worker_logs_enabled           = true
  worker_logs_log_level         = "INFO" #  [CRITICAL ERROR WARNING INFO DEBUG]

  create_custom_url         = true
  custom_url_route53_record = "airflow-v2.${local.dns_suffix}"
  hosted_zone               = lookup(include.locals.aws_vars.locals.hosted_zone_environment_mapping, "data-${include.locals.environment}", null)
  certificate_arn           = dependency.acm_certificate.outputs.acm_certificate_arn
}
