# AWS provider configuration for LocalStack
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    route53        = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    s3             = "http://s3.localhost.localstack.cloud:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
    elb            = "http://localhost:4566"
    elbv2          = "http://localhost:4566"
    rds            = "http://localhost:4566"
    autoscaling    = "http://localhost:4566"
    events         = "http://localhost:4566"
  }
}

# Route53 Health Check: Monitors the primary endpoint's availability
resource "aws_route53_health_check" "primary_health_check" {
  fqdn              = "primary.example.com"
  port              = 80
  type              = "HTTP"
  resource_path     = "/health"
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "primary-endpoint-health-check"
  }
}

# Route53 Hosted Zone: The DNS container for our failover domain
resource "aws_route53_zone" "lab_zone" {
  name = "example.com"

  tags = {
    Name        = "lab-failover-zone"
    Environment = "SysOps-Lab"
  }
}

# Primary Record: The main destination for user traffic
resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.lab_zone.zone_id
  name    = "app.example.com"
  type    = "A"
  ttl     = "60"

  # Failover Routing Policy: Sets this record as the Primary
  failover_routing_policy {
    type = "PRIMARY"
  }

  # Health Check: Route53 will monitor this to decide if it's healthy
  set_identifier  = "primary-endpoint"
  records         = ["1.1.1.1"] # Simulated Primary IP
  health_check_id = aws_route53_health_check.primary_health_check.id
}

# Secondary Record: The backup destination if primary fails
resource "aws_route53_record" "secondary" {
  zone_id = aws_route53_zone.lab_zone.zone_id
  name    = "app.example.com"
  type    = "A"
  ttl     = "60"

  # Failover Routing Policy: Sets this record as the Secondary
  failover_routing_policy {
    type = "SECONDARY"
  }

  set_identifier = "secondary-endpoint"
  records        = ["8.8.8.8"] # Simulated Secondary IP
}

# Outputs: Key identifiers for testing the HA failover workflow
output "hosted_zone_id" {
  value = aws_route53_zone.lab_zone.zone_id
}

output "primary_endpoint" {
  value = aws_route53_record.primary.name
}

output "health_check_status_id" {
  value = aws_route53_health_check.primary_health_check.id
}
