# AWS Terragrunt Landing Zone


## Prerequisites

Before you can use this Terragrunt repository, ensure you have the following tools installed:

1. **AWS CLI**
   - Version: 2.0.0 or later
   - Installation: Follow the [official AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
   - Configuration: Run `aws configure` to set up your AWS credentials

2. **Terraform**
   - Version: 1.5.0 or later (specific version may be defined in `common.hcl`)
   - Installation: Follow the [official Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
   - Verify installation: Run `terraform version`

3. **Terragrunt**
   - Version: 0.60.0 or later (check `terragrunt.hcl` for specific version requirements)
   - Installation: Follow the [official Terragrunt installation guide](https://terragrunt.gruntwork.io/docs/getting-started/install/)
   - Verify installation: Run `terragrunt --version`

4. **Git**
   - Required for version control and cloning this repository
   - Installation: [Git installation guide](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

5. **jq** (recommended)
   - Useful for processing JSON outputs from Terraform and AWS CLI
   - Installation: [jq installation guide](https://stedolan.github.io/jq/download/)

After installing these tools, ensure they are available in your system's PATH.

### AWS Account Setup

1. Ensure you have AWS account access with necessary permissions to create and manage resources.
2. Configure your AWS CLI with the appropriate credentials:
   ```
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, default region, and output format when prompted.

### Repository Setup

1. Clone this repository:
   ```
   git clone [repository-url]
   cd [repository-name]
   ```
2. Navigate to the desired service/region/environment directory before running Terragrunt commands.

# Terragrunt Infrastructure Repository

This repository contains Terragrunt configurations for managing our multi-environment, multi-region AWS infrastructure.

## Repository Structure

The repository is organized by AWS service, region, and environment:

```
.
├── <service>
│   ├── eu
│   │   ├── prod
│   │   │   └── terragrunt.hcl
│   │   └── stg
│   │       └── terragrunt.hcl
│   └── us
│       ├── dev
│       │   └── terragrunt.hcl
│       ├── prod
│       │   └── terragrunt.hcl
│       └── stg
│           └── terragrunt.hcl
```

Where `<service>` includes:
- acm (AWS Certificate Manager)
- api-gw (API Gateway)
- aurora (Amazon Aurora)
- cloudtrail
- dynamodb
- ec2
- eks (Elastic Kubernetes Service)
- rds (Relational Database Service)
- redis (ElastiCache for Redis)
- s3
- sns (Simple Notification Service)
- tgw (Transit Gateway)
- vpc
- vpn

## Shared Resources

Shared resources are located in the `shared` directory:

```
shared/
├── accounts
└── iam
    ├── groups
    ├── policies
    ├── roles
    └── users
```

## Configuration Files

- `common.hcl`: Contains common Terragrunt configurations.
- `terragrunt.hcl`: Root Terragrunt configuration file.
- `vars.yaml`: Contains variable definitions.

## Usage

To apply changes to a specific service in a particular region and environment:

1. Navigate to the desired directory, e.g., `cd s3/us/dev`
2. Run Terragrunt commands:
   ```
   terragrunt plan
   terragrunt apply
   ```

To apply changes to all services in a region or environment, navigate to the desired directory and run:

```
terragrunt run-all plan
terragrunt run-all apply
```

## Prerequisites

- Terragrunt
- AWS CLI configured with appropriate credentials
- Terraform (version specified in `common.hcl`)

## Best Practices

1. Always run `terragrunt plan` before applying changes.
2. Use consistent naming conventions across all resources.
3. Keep sensitive information out of version control. Use AWS Secrets Manager or similar services for managing secrets.
4. Regularly update Terraform and provider versions.

## Contributing

1. Create a new branch for your changes.
2. Make your changes and test them thoroughly.
3. Create a pull request with a clear description of your changes.
4. Have your changes reviewed before merging to the main branch.

## Maintenance

- Regularly review and update dependencies.
- Clean up unused resources to minimize costs.
- Keep documentation up-to-date, especially when making structural changes to the repository.

## Security

- Ensure that all S3 backends are properly secured with encryption and appropriate access controls.
- Regularly rotate AWS access keys and review IAM permissions.
- Use the principle of least privilege when assigning permissions.

## Support

For questions or issues, please contact the DevOps team or create an issue in this repository.