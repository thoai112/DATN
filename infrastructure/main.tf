terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.9.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }
  }


}

provider "aws" {

  profile = "localstack"
  region     = "us-east-1"


  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    ecs            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}


module "ecs_module" {
    source = "./ecs_module"
    subnet_ids = module.networking_module.ml_private_subnet_id
    task_sg_id = module.networking_module.ml_task_sg_id
    target_grp_arn = module.networking_module.ml_target_grp_arn
    task_role_arn = module.security_module.task_role_arn
    task_assume_role_arn = module.security_module.task_assume_role_arn
    depends_on = [ module.networking_module ]
}

module "networking_module" {
    source = "./networking"
}

module "security_module" {
    source = "./security"
}