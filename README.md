# 🚀 ECS + ECR Deployment with Terraform

This project provisions a complete containerized application infrastructure on AWS using Terraform. It builds and stores Docker images in Amazon ECR, deploys containers to AWS ECS Fargate, exposes the application through an Application Load Balancer, and securely manages secrets with AWS Secrets Manager.

## 📦 Architecture

The infrastructure provisions the following AWS resources:

- VPC with public subnets

- Internet Gateway and route tables

- Application Load Balancer

- ECS Cluster (Fargate)

- ECR Repository for container images

- ECS Task Definition

- ECS Service

- Security Groups

- IAM Roles

- AWS Secrets Manager for environment variables

- AWS KMS for encryption
### High-level flow:
```
Internet
   │
   ▼
Application Load Balancer (port 80)
   │
   ▼
Target Group
   │
   ▼
ECS Fargate Service
   │
   ▼
Docker Container (Node.js App)
   │
   ▼
MongoDB Atlas
```

## 🛠 Technologies Used

### Infrastructure as Code

- Terraform

### Containerization

- Docker

### Cloud Platform

- Amazon Web Services

- AWS Services

- Amazon ECS

- Amazon ECR

- AWS Fargate

- Application Load Balancer

- AWS Secrets Manager

- AWS KMS

### ⚙️ Prerequisites

Before deploying, ensure you have installed:

- Terraform

- Docker

- AWS CLI

Configure AWS credentials:
```
aws configure
```

### 📂 Project Structure
```
ECR_ECS_INFRA_PROVISSION/
│
├── main.tf                # root orchestration
├── variables.tf
├── outputs.tf
│
├── modules/
│   ├── vpc/
│   ├── security_group/
│   ├── ecr/
│   ├── ecs/
│   ├── alb/
│   └── secrets/
│
└── .github/workflows
     └── deploy.yml
```

### 🚀 Deployment Steps

Clone the Repo
```
git clone https://github.com/Kosisochi1/ECR_ECS_INFRA_PROVISSION.git

cd ECR_ECS_INFRA_PROVISSION
```

1️⃣ Initialize Terraform
```
terraform init
```
2️⃣ Plan Infrastructure
```
terraform plan
```
3️⃣ Deploy Infrastructure
```
terraform apply
```

### 🌐 Accessing the Application

Once deployment completes, obtain the Load Balancer DNS name:

```
terraform output
```

Then access:

```
http://<load-balancer-dns>
```

### 🧹 Destroy Infrastructure

To remove all resources:
```
terraform destroy --auto-approve
```


### 🔄 CI/CD Pipeline (GitHub Actions → ECR → ECS)

This project includes a fully automated CI/CD pipeline using GitHub Actions to:

- Provision the Infrastructure on push to the main
