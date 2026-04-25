# AWS High Availability Route53 Failover Lab

This lab demonstrates how to architect a resilient DNS-based failover system using **Amazon Route53**. This is a core competency for the AWS SysOps Administrator Associate, focusing on maintaining high availability across endpoints.

## Architecture Overview

The system implements a **Failover Routing Policy**:

1.  **Health Monitoring:** A Route53 Health Check continuously monitors the primary endpoint (`primary.example.com`).
2.  **Primary Record:** Traffic is routed to the primary endpoint by default, provided the health check passes.
3.  **Automatic Failover:** If the health check fails, Route53 automatically stops using the Primary record and begins resolving the `app.example.com` domain to the **Secondary record**.

## Key Components

-   **Route53 Health Check:** The detection mechanism for endpoint availability.
-   **Route53 Hosted Zone:** The container for our DNS domain (`example.com`).
-   **Primary Failover Record:** Points to `1.1.1.1` and is linked to the health check.
-   **Secondary Failover Record:** Points to `8.8.8.8` (the "Plan B") and is used only when the Primary is unhealthy.

## Prerequisites

-   [Terraform](https://www.terraform.io/downloads.html)
-   [LocalStack](https://localstack.cloud/)
-   [AWS CLI / awslocal](https://github.com/localstack/awscli-local)

## Deployment

1.  **Initialize and Apply:**
    ```bash
    terraform init
    terraform apply -auto-approve
    
```

## Verification & Testing

To observe the DNS failover logic:

1.  **Check Current Records:**
    List the records in your hosted zone to see the primary and secondary entries:
    ```bash
    awslocal route53 list-resource-record-sets --hosted-zone-id <YOUR_HOSTED_ZONE_ID>
    aws route53 list-resource-record-sets --hosted-zone-id <YOUR_HOSTED_ZONE_ID>
    
```

2.  **Simulate Health Check Failure:**
    In a real scenario, Route53 would detect the endpoint is down. You can monitor the health check status:
    ```bash
    awslocal route53 get-health-check-status --health-check-id <YOUR_HEALTH_CHECK_ID>
    aws route53 get-health-check-status --health-check-id <YOUR_HEALTH_CHECK_ID>
    
```

3.  **Confirm Routing Policy:**
    Verify that both records have the `Failover` routing policy applied, with one as `PRIMARY` and the other as `SECONDARY`.

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```

---

💡 **Pro Tip: Using `aws` instead of `awslocal`**

If you prefer using the standard `aws` CLI without the `awslocal` wrapper or repeating the `--endpoint-url` flag, you can configure a dedicated profile in your AWS config files.

### 1. Configure your Profile
Add the following to your `~/.aws/config` file:
```ini
[profile localstack]
region = us-east-1
output = json
# This line redirects all commands for this profile to LocalStack
endpoint_url = http://localhost:4566
```

Add matching dummy credentials to your `~/.aws/credentials` file:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
```

### 2. Use it in your Terminal
You can now run commands in two ways:

**Option A: Pass the profile flag**
```bash
aws iam create-user --user-name DevUser --profile localstack
```

**Option B: Set an environment variable (Recommended)**
Set your profile once in your session, and all subsequent `aws` commands will automatically target LocalStack:
```bash
export AWS_PROFILE=localstack
aws iam create-user --user-name DevUser
```

### Why this works
- **Precedence**: The AWS CLI (v2) supports a global `endpoint_url` setting within a profile. When this is set, the CLI automatically redirects all API calls for that profile to your local container instead of the real AWS cloud.
- **Convenience**: This allows you to use the standard documentation commands exactly as written, which is helpful if you are copy-pasting examples from AWS labs or tutorials.
