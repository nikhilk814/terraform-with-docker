# Terraform Docker Project
Terraform to pull a Docker image from Docker Hub and run a Docker container on a CentOS system.

---

## 1. Install Terraform 

```bash
# Download the latest Terraform binary
wget https://releases.hashicorp.com/terraform/1.6.2/terraform_1.6.2_linux_amd64.zip

# Unzip the downloaded file
unzip terraform_1.6.2_linux_amd64.zip

# Move terraform binary to /usr/local/bin
sudo mv terraform /usr/local/bin/

## 2. Install Docker on CentOS

```bash
# Update packages
sudo yum update -y

# Install required packages
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# Set up the stable repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker CE
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
docker version
```
<img width="582" height="147" alt="Image" src="https://github.com/user-attachments/assets/b8db5f5b-77ae-488e-8a5a-3b5b220f10b6" />

<img width="561" height="471" alt="image" src="https://github.com/user-attachments/assets/16e64dab-9098-4f6a-8d5d-3d99bbc93933" />

added to the `docker` group if you want to run Docker without `sudo`:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

**main.tf**:

```hcl
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address  = "https://index.docker.io/v1/"
    username = var.docker_username
    password = var.docker_password
  }
}

# Pull nginx image
resource "docker_image" "hello-app" {
  name = "nikhilk814/hello-app:latest"
}

# Run nginx container
resource "docker_container" "hello-app_container" {
  name  = "hello-app_server"
  image = docker_image.hello-app.image_id

  ports {
    internal = 3000
    external = 3000
  }
}
```

**variables.tf**:

```hcl
variable "docker_username" {
  type        = string
  description = "DockerHub username"
}

variable "docker_password" {
  type        = string
  description = "DockerHub password or access token"
  sensitive   = true
}
```

**terraform.tfvars**:

```hcl
docker_username = "nikhilk814"
docker_password = "docker-token"
```

---

## 5. Deploy the Container

```bash
# Initialize Terraform
terraform init

<img width="935" height="486" alt="1" src="https://github.com/user-attachments/assets/0eb52f47-e45b-454d-a863-bb741d2cb7bf" />

# Preview the resources to be created
terraform plan
<img width="1147" height="762" alt="2" src="https://github.com/user-attachments/assets/de660122-55c2-446d-beb3-334094074804" />


# Apply the configuration
terraform apply
<img width="1216" height="627" alt="3" src="https://github.com/user-attachments/assets/a95a8a4b-ae1d-4add-87e7-593eeb206f40" />
<img width="1440" height="482" alt="3-1" src="https://github.com/user-attachments/assets/37be227b-57cb-42fa-b038-b52c23c3e03b" />

```
terrafrom plan


> The `hello-app` container will now be running on port `3000`.
<img width="1107" height="46" alt="4" src="https://github.com/user-attachments/assets/73b70189-4f17-45c6-9560-f80788857392" />

---

## 6. Verify Container

```bash
docker ps
docker image
```
<img width="1107" height="46" alt="4" src="https://github.com/user-attachments/assets/1ec92e60-8a2a-4e50-8882-de9e16c6db44" />

<img width="600" height="81" alt="5" src="https://github.com/user-attachments/assets/e6f70995-e009-4713-a12a-c8a015aeff79" />

---

## 7. Cleanup

To remove the container and image created by Terraform:

```bash
terraform destroy
```

<img width="1235" height="737" alt="6" src="https://github.com/user-attachments/assets/77498eae-935c-4c1a-9907-fce555b1bd84" />

<img width="1153" height="735" alt="6-1" src="https://github.com/user-attachments/assets/cc968c0f-6a86-41fa-8c95-f4c14dcc6753" />


***Question and Answer***
```
1. What is IaC (Infrastructure as Code)?
Ans: IaC means managing and provisioning IT infrastructure using code instead of doing it manually. You write a code file to create 3 virtual machines. Running the code automatically creates 3 VMs instead of creating them manually one by one.

2. How does Terraform work?
Ans: Terraform reads your code, figures out what resources you want, talks to cloud or Docker, and manages them.
Write .tf files – Define the infrastructure you want.
Run terraform init → Downloads required providers.
Run terraform plan → Shows what Terraform will do without making changes.
Run terraform apply → Creates or updates the resources as per your code.
Run terraform destroy → Deletes all the resources that Terraform created.Terraform reads your code, figures out what resources you want, talks to cloud or Docker, and manages them.

4. Difference between terraform apply and terraform plan?
Ans: terraform plan	Shows what will happen if you run apply	“I will create 1 hello-app container”
terraform apply	Actually creates or updates resources	Creates the hello-app container on Docker
Think: plan = preview, apply = execute

5. What are Terraform providers?
Ans: Providers are plugins that tell Terraform how to talk to different platforms (AWS, Azure, Docker, etc.). Docker provider → Terraform talks to Docker. AWS provider → Terraform talks to AWS to create EC2, S3, etc.

6. What is resource dependency?
Ans: Resource dependency is when one resource depends on another to be created first. You want to create a Docker container using an image. The image must exist before the container is created. Terraform automatically detects dependencies or you can specify using depends_on.

7. How do you handle secret variables?
Ans: Secrets (passwords, tokens) should not be in code. Use .tfvars file (and ignore it in Git) Use environment variables (TF_VAR_password=xyz). Use secret managers (Vault, AWS Secrets Manager)
Example:
export TF_VAR_docker_password="my-secret-token"

8. Explain the benefits of Terraform
Ans: Automation – Create/update infrastructure with a single command. Consistency – Same code creates same environment every time. Multi-cloud support – Works with AWS, Azure, Docker, and more. Dependency management – Creates resources in correct order.
Example:
Instead of manually creating 3 servers, 2 networks, and a database, Terraform can create all in one go using code.
---

