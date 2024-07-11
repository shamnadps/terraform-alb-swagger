# Terraform AWS Infrastructure

This Terraform configuration sets up an AWS infrastructure including a VPC, public subnet, internet gateway, Application Load Balancer (ALB), Lambda function, and necessary IAM roles and security groups.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- An AWS account with appropriate permissions to create the resources.
- AWS CLI configured with the necessary credentials and profile.

## Configuration

1. **Clone the repository**

   ```sh
   git clone https://github.com/shamnadps/terraform-alb-swagger.git
   cd terraform-alb-swagger
   ```
## Usage
2. **Initialize the Terraform configuration**

```sh
terraform init
```

3. **Review the Terraform plan**

```sh
terraform plan
```

4. **Apply the Terraform configuration**
```sh
terraform apply
```

Terraform will prompt you for confirmation before applying the changes. Type `yes` to confirm.

5. **Destroy the Terraform-managed infrastructure**

If you need to remove all resources created by this configuration, run:

```sh
terraform destroy
```
Terraform will prompt you for confirmation before destroying the resources. Type `yes` to confirm.

## Testing

POST request
```bash
curl -X POST <alb-url>/post-data  -d '{"firstName":"Shamnad", "lastName":"Shaji"}' -H "Content-Type: application/json"  
```
GET request
```bash
curl -X GET <alb-url>/get-data
```
