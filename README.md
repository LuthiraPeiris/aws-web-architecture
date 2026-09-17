# AWS Web Architecture

A production-style web application architecture built on AWS using a multi-tier network design, private compute, managed PostgreSQL, load balancing, IAM, Secrets Manager, CloudWatch, and Terraform.

## Architecture

```text
                         Internet
                            |
                            v
                    Application Load Balancer
                         Port 80
                            |
              +-------------+-------------+
              |                           |
         Public Subnet A             Public Subnet B
              |                           |
              +-------------+-------------+
                            |
                            v
                    Private EC2 Instance
                      Node.js Application
                            |
                            v
                    Private RDS PostgreSQL
                      Port 5432
```

Supporting AWS services:

```text
NAT Gateway
VPC Interface Endpoints
IAM
AWS Secrets Manager
Amazon CloudWatch
```

## Project Objectives

The project demonstrates how to:

* Design a custom AWS VPC
* Separate public and private resources
* Deploy an application on a private EC2 instance
* Expose the application through an Application Load Balancer
* Deploy PostgreSQL using Amazon RDS
* Secure communication using security groups
* Access database credentials through AWS Secrets Manager
* Manage EC2 access using IAM
* Provide private AWS service connectivity using VPC endpoints
* Provide outbound internet access from private resources using NAT Gateway
* Monitor EC2 using CloudWatch
* Reproduce the infrastructure using Terraform

## AWS Services Used

| Service                   | Purpose                                         |
| ------------------------- | ----------------------------------------------- |
| Amazon VPC                | Network isolation                               |
| Internet Gateway          | Internet connectivity for public subnets        |
| Public Subnets            | ALB and NAT Gateway                             |
| Private Subnets           | EC2 and RDS                                     |
| NAT Gateway               | Outbound internet access from private resources |
| Application Load Balancer | Public application entry point                  |
| Amazon EC2                | Application server                              |
| Amazon RDS PostgreSQL     | Managed relational database                     |
| AWS Secrets Manager       | Database credential management                  |
| AWS IAM                   | Access control                                  |
| VPC Interface Endpoints   | Private access to AWS Systems Manager services  |
| Amazon CloudWatch         | EC2 monitoring and CPU alarm                    |
| Terraform                 | Infrastructure as Code                          |

## Network Design

The VPC uses the CIDR block:

```text
10.0.0.0/16
```

Four subnets are used across two Availability Zones.

### Public Subnets

```text
10.0.1.0/24
10.0.2.0/24
```

The public subnets contain the Application Load Balancer and NAT Gateway.

They use a route to the Internet Gateway:

```text
0.0.0.0/0 -> Internet Gateway
```

### Private Subnets

```text
10.0.11.0/24
10.0.12.0/24
```

The EC2 application server and RDS database are placed in private subnets.

Private subnet outbound traffic uses:

```text
0.0.0.0/0 -> NAT Gateway
```

This allows private resources to access the internet for required outbound operations without assigning public IP addresses.

## Security Architecture

The architecture uses separate security groups for the major components.

### ALB Security Group

Allows:

```text
HTTP :80
Source: 0.0.0.0/0
```

The ALB is therefore the public entry point.

### EC2 Security Group

Allows:

```text
TCP :3000
Source: ALB Security Group
```

The EC2 instance does not accept application traffic directly from the internet.

### RDS Security Group

Allows:

```text
TCP :5432
Source: EC2 Security Group
```

The database can therefore only receive PostgreSQL traffic from the application server.

This creates the traffic flow:

```text
Internet
   |
   v
ALB :80
   |
   v
EC2 :3000
   |
   v
RDS :5432
```

## Application

The application is a simple Node.js application using:

* Express
* PostgreSQL (`pg`)
* AWS SDK for JavaScript
* AWS Secrets Manager

The application retrieves database credentials from Secrets Manager and connects to the private RDS PostgreSQL instance.

The application verifies the database connection by executing:

```sql
SELECT NOW();
```

The resulting database timestamp is displayed by the application.

## Secrets Management

Database credentials are not stored directly in the application source code.

The EC2 instance uses an IAM role that allows:

```text
secretsmanager:GetSecretValue
```

for the required database secret.

The application retrieves the credentials through the AWS SDK.

The real secret ARN and credentials are intentionally excluded from this repository.

## IAM

The EC2 instance uses an IAM instance profile.

The role provides:

* AWS Systems Manager access
* Access to the required Secrets Manager secret

The Secrets Manager permission is restricted to the configured secret rather than granting access to all secrets.

## VPC Endpoints

The private EC2 environment uses VPC interface endpoints for:

```text
SSM
SSMMessages
EC2Messages
```

Private DNS is enabled for the endpoints.

This allows Systems Manager communication without requiring the EC2 instance to have a public IP address.

## Monitoring

Amazon CloudWatch is used to monitor the EC2 instance.

A CPU alarm is configured with:

```text
Metric: CPUUtilization
Threshold: > 80%
Period: 5 minutes
Statistic: Average
```

The alarm helps identify unusually high CPU utilization.

## Infrastructure as Code

The infrastructure is also represented using Terraform.

Terraform configuration is located in:

```text
terraform/
```

The Terraform configuration defines:

* VPC
* Subnets
* Internet Gateway
* Route tables
* NAT Gateway
* Security groups
* IAM
* EC2
* Application Load Balancer
* Target group
* RDS PostgreSQL
* VPC endpoints
* CloudWatch alarm

The configuration was validated using:

```bash
terraform validate
```

and tested with:

```bash
terraform plan
```

The Terraform configuration was intentionally not applied as a second environment after the manual AWS deployment, in order to avoid unnecessary AWS resource duplication and cost.

## Testing

The deployed architecture was tested through the Application Load Balancer.

The application successfully demonstrated:

```text
Node.js application: SUCCESS
EC2 server: SUCCESS
RDS PostgreSQL connection: SUCCESS
Database query: SUCCESS
```

The private EC2 instance was also tested for connectivity to PostgreSQL on:

```text
Port 5432
```

The EC2 instance successfully connected to the RDS endpoint.

AWS Secrets Manager access was also verified from the EC2 instance using its IAM role.

## Repository Structure

```text
aws-web-architecture/
│
├── app/
│   ├── server.js
│   ├── package.json
│   └── package-lock.json
│
├── terraform/
│   ├── provider.tf
│   ├── variables.tf
│   ├── vpc.tf
│   ├── subnets.tf
│   ├── routes.tf
│   ├── security-groups.tf
│   ├── endpoints.tf
│   ├── iam.tf
│   ├── ec2.tf
│   ├── alb.tf
│   ├── rds.tf
│   ├── monitoring.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   └── .terraform.lock.hcl
│
├── docs/
│   └── architecture.png
│
├── screenshots/
│
├── .gitignore
└── README.md
```

## Cost Considerations

The architecture uses several AWS resources that can incur charges, particularly:

* NAT Gateway
* Application Load Balancer
* RDS
* EC2
* VPC interface endpoints

For this reason, the deployed resources were used for testing and demonstration and should be removed when the project is no longer running.

The Terraform configuration is retained so the architecture can be reproduced when required.

## What I Learned

This project provided practical experience with:

* AWS VPC architecture
* Public and private subnet design
* AWS routing
* Security group design
* Private EC2 deployment
* Application Load Balancing
* RDS networking
* IAM roles and policies
* Secrets Manager
* VPC interface endpoints
* NAT Gateway
* CloudWatch monitoring
* Terraform Infrastructure as Code
* Troubleshooting AWS networking and service connectivity

## Future Improvements

Potential improvements include:

* HTTPS using ACM
* Route 53 custom domain
* Auto Scaling Group
* HTTPS listener on the ALB
* CI/CD deployment pipeline
* Terraform remote state
* Automated application deployment
* Blue/green deployment
* Centralized logging

## Author

**Luthira Peiris**

AWS Cloud & DevOps enthusiast building practical cloud infrastructure and automation projects.
