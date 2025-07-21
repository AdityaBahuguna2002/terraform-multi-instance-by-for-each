#!/bin/bash

sudo apt update -y 

# Install Apache
sudo apt install apache2 -y 
sudo systemctl enable apache2
sudo systemctl start apache2

# Install Docker
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu

# Refresh group membership 
newgrp docker

### ✅ Prompt for Flowchart and Diagram Generation:

> Create an **AWS Infrastructure Diagram and Flowchart** based on the following Terraform configuration:
>
> ### 🛠 Infrastructure Description:
>
> * **VPC** named `sample-project-vpc` with CIDR block `10.0.0.0/16`
> * 1 **Availability Zone**: `ap-south-1a`
> * **Subnets**:
>
>   * `10.0.0.0/24` (Public Subnet 1)
>   * `10.0.1.0/24` (Public Subnet 2)
>   * `10.0.2.0/24` (Private Subnet)
> * A **NAT Gateway**, **VPN Gateway**, DNS hostnames and support enabled
> * **Security Group** allowing:
>
>   * Inbound SSH (port 22) from 0.0.0.0/0
>   * Inbound HTTP (port 80) from 0.0.0.0/0
>   * All outbound traffic
> * **Key Pair** used: `my-secret-key`
> * **EC2 Instances**:
>
>   * Dynamically created using `for_each` over `ec2_instance_list`
>   * Each instance:
>
>     * Has a unique name
>     * Uses different AMI IDs and instance types
>     * Is placed in either Subnet 0 or Subnet 1 (based on `subnet_index`)
>     * Is provisioned using `user_data` to install Apache and Docker
>
> ### 🎯 Expected Diagram:
>
> Show the full AWS infrastructure layout including:
>
> * The VPC
> * Public & Private Subnets
> * EC2 instances in respective subnets
> * NAT Gateway, Internet Gateway (implicitly via public subnets)
> * Security Group applied to all EC2 instances
> * Key Pair being used
> * Script execution on instance launch (install\_apache.sh)
>
> Optional: Add arrows or annotations to show flow like:
>
> * Internet access via NAT/IGW
> * SSH/HTTP access allowed via security group
> * `for_each` loop generating EC2s dynamically

---

