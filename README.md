# AWS Terraform Web Deployment (IaC)

A foundational Infrastructure as Code (IaC) project designed to provision a loosely coupled, highly secure, and automated web deployment infrastructure on Amazon Web Services (AWS) using Terraform.

##  Architecture Overview

This project bypasses default settings to build a **fully custom network top-to-bottom**. All decoupled application components communicate smoothly through modern cloud-native practices.

###  1. Custom VPC & Networking Infrastructure
*   **Custom VPC:** A dedicated, isolated Virtual Private Cloud network space.
*   **Internet Gateway (IGW):** Enables communication between resources in your VPC and the public internet.
*   **Route Table:** Custom routing definitions mapping internal traffic flows out to the IGW.
*   **Security Groups (SG):** Strict firewall rules controlling inbound and outbound server traffic (restricting access to specific protocol ports like HTTP and SSH).

###  2. EC2 Web Layer
*   **EC2 Instance:** A compute instance executing within your custom subnet.
*   **Decoupled Provisioning:** The infrastructure provisioning (Terraform) remains isolated from the application-level logic.

### 3. Automated Configuration Script
*   **user_data.sh:** A standalone shell script passed directly into the EC2 runtime configuration during initialization. This script cleanly automates your system updates, engine dependencies, and web service boot routines without requiring any manual SSH administration.

---

##  Project Structure

```text
├── main.tf           # Primary Terraform file containing custom VPC, SG, and EC2 resources
├── variables.tf      # Configurable environment input parameters 
├── outputs.tf        # Exposed endpoint details (such as the Public IP and Web URL)
└── user_data.sh      # Bash script handles package injection & runtime bootstrapping
```

---

##  Prerequisites

Before executing deployment blueprints, ensure your workspace has the following tools initialized:
*   [Terraform CLI](https://hashicorp.com) (v1.0.0+)
*   [AWS CLI](https://amazon.com) configured with deployment administrative credentials.

---

##  Quick Start & Deployment Guide

Follow these steps to spin up the infrastructure:

1. **Clone the Repository**
   ```bash
   git clone https://github.com
   cd aws-terraform-web-deployment
   ```

2. **Initialize Workspace Providers**
   ```bash
   terraform init
   ```

3. **Review Execution Blueprints**
   ```bash
   terraform plan
   ```

4. **Provision Cloud Resources**
   ```bash
   terraform apply --auto-approve
   ```

5. **Verify and Access**
   Once deployment concludes successfully, the terminal outputs will print your live **Web Server URL**. Copy and paste it straight into your browser to view your live index landing page.

---

##  Tearing Down Resources

To avoid incurring ongoing charges for active cloud resources, destroy the entire stack seamlessly with a single command:
```bash
terraform destroy --auto-approve
```
