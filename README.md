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
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── 
│
└── .github/workflows
     └── deploy.yml
```
