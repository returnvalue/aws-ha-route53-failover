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
    ```

2.  **Simulate Health Check Failure:**
    In a real scenario, Route53 would detect the endpoint is down. You can monitor the health check status:
    ```bash
    awslocal route53 get-health-check-status --health-check-id <YOUR_HEALTH_CHECK_ID>
    ```

3.  **Confirm Routing Policy:**
    Verify that both records have the `Failover` routing policy applied, with one as `PRIMARY` and the other as `SECONDARY`.

## Cleanup

To tear down the infrastructure:
```bash
terraform destroy -auto-approve
```
