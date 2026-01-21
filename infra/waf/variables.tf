variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer to associate with WAF"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming WAF resources"
  type        = string
  default     = "project1"
}

variable "rate_limit" {
  description = "Requests per 5-minute period per IP before blocking"
  type        = number
  default     = 200
}

variable "waf_logs_bucket_name" {
  description = "Globally-unique S3 bucket name for WAF logs"
  type        = string
}

variable "waf_logs_retention_days" {
  description = "S3 lifecycle retention (days) for WAF logs"
  type        = number
  default     = 7
}

