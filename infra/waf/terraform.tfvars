aws_region = "us-east-1"

alb_arn = "arn:aws:elasticloadbalancing:us-east-1:349821334974:loadbalancer/app/k8s-project1-nginxing-8e2cfff3cb/021d6e920ef514ce"

name_prefix = "project1"
rate_limit  = 200

# MUST be globally unique in S3:
waf_logs_bucket_name     = "aws-waf-logs-349821334974-us-east-1-project1"
waf_logs_retention_days  = 7

