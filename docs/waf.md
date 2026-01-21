# AWS WAF for Project 1

## 1. Purpose
This project adds AWS Web Application Firewall (WAF) protection in front of the Project 1 Nginx service by attaching a WAFv2 Web ACL to the Application Load Balancer (ALB) created by the Kubernetes Ingress. The goal is to demonstrate edge-layer security controls (managed protections + rate limiting) and security logging without changing the application workload.

## 2. Architecture
1. Kubernetes Ingress (AWS Load Balancer Controller) provisions an internet-facing ALB with HTTPS (ACM certificate).
2. AWS WAFv2 Web ACL is associated with the ALB.
3. Web ACL rules include:
   - AWS Managed Rule Groups (baseline protections)
   - A custom IP rate-based rule (abuse/throttle protection)
4. WAF logging is enabled:
   - WAF → Kinesis Data Firehose → Amazon S3 (bucket name prefixed with `aws-waf-logs-`)
5. The application (Nginx) remains unchanged; only the ingress edge is protected.

## 3. Implementation
### 3.1 Kubernetes (ALB creation)
- The existing `Ingress` manifest in the `project1` namespace is applied to recreate the ALB when needed (TLS on 443 with ACM).
- When cost-saving mode is desired, the Ingress is deleted to remove the ALB.

### 3.2 Terraform (WAF + logging)
Terraform module location:
- `infra/waf/`

Resources created:
1. `aws_wafv2_web_acl` (REGIONAL) with managed rules + rate-based rule
2. `aws_wafv2_web_acl_association` attaching the Web ACL to the ALB ARN
3. `aws_kinesis_firehose_delivery_stream` delivering WAF logs to S3
4. `aws_s3_bucket` for WAF logs (with lifecycle expiration)

## 4. Verification
### 4.1 Routing works via ALB
Because DNS for `project1.seanxtopher.com` may be disabled to save costs, validation can be performed by sending the Host header directly to the ALB DNS name:

```bash
curl -vk "https://<ALB_DNS_NAME>/" -H "Host: project1.seanxtopher.com"
```

Expected: `200 OK` from Nginx.

### 4.2 WAF rate-based blocking
Generate a burst of requests, then re-check headers:

```bash
for i in $(seq 1 400); do
  curl -sk "https://<ALB_DNS_NAME>/" -H "Host: project1.seanxtopher.com" > /dev/null
done
curl -Ik "https://<ALB_DNS_NAME>/" -H "Host: project1.seanxtopher.com"
```

Expected: `403 Forbidden` once the rate-based threshold is exceeded.

### 4.3 Logs delivered to S3
Logs are written to S3 under date-based prefixes:

```bash
aws s3 ls s3://<WAF_LOG_BUCKET>/waf/ --region us-east-1
```

Expected: date prefixes (e.g., `2026/`) and log objects beneath them.

## 5. Cost controls
1. ALB costs are avoided by deleting the Ingress when not actively testing.
2. S3 lifecycle retention is configured to expire WAF logs after a short retention period (default: 7 days).
3. WAF resources are low-cost and can remain enabled even when the ALB is removed.

## 6. Notes and pitfalls
1. WAF logging does not support CloudWatch Logs directly as a destination for WAFv2 logging in this setup; logging is delivered via Kinesis Data Firehose to S3.
2. WAF logging destination naming must be prefixed with `aws-waf-logs-` (Firehose stream and S3 bucket) or WAF will reject the destination.
3. When DNS is disabled, validate host-based routing using explicit `Host:` headers as shown above.
