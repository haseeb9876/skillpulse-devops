# SkillPulse DevOps CI/CD Platform

![Docker](https://img.shields.io/badge/Docker-Containerization-2496ED?logo=docker&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-Infrastructure_as_Code-844FBA?logo=terraform&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?logo=githubactions&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-EC2-FF9900?logo=amazonaws&logoColor=white)
![Go](https://img.shields.io/badge/Go-Gin_Backend-00ADD8?logo=go&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?logo=mysql&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-Reverse_Proxy-009639?logo=nginx&logoColor=white)

## Project Overview

SkillPulse is a three-tier skill-learning tracker consisting of:

- A static HTML, CSS and JavaScript frontend
- A Go backend built with the Gin framework
- A MySQL database
- Nginx as the frontend web server and reverse proxy

The application allows users to add technical skills, organize them by category, set learning-hour targets, record learning sessions, and view progress through a dashboard.

The primary purpose of this repository is to demonstrate the DevOps engineering work required to take developer-provided source code and create a repeatable, secure, and automated software-delivery process.

The application source was used as the workload. The Docker, Docker Compose, Terraform, GitHub Actions, AWS deployment, and operational documentation were independently implemented as part of this DevOps portfolio project.

---

## Project Objective

The delivery lifecycle implemented in this project is:

```text
Developer changes code
        |
        v
GitHub repository
        |
        v
GitHub Actions CI
        |
        +-- Validate Go dependencies
        +-- Compile and test backend packages
        +-- Build Docker images
        +-- Start the integration environment
        +-- Verify health and API endpoints
        |
        v
Docker image publishing workflow
        |
        +-- Build backend image
        +-- Build frontend image
        +-- Tag images with latest and commit SHA
        +-- Push images to Docker Hub
        |
        v
Manual production deployment workflow
        |
        +-- Connect securely to AWS EC2
        +-- Copy deployment configuration
        +-- Pull tested Docker images
        +-- Start the production stack
        +-- Verify application health
```

---

## Architecture

```text
                         DEVELOPMENT AND DELIVERY

+------------------+
| Developer Laptop |
+--------+---------+
         |
         | git push
         v
+------------------+
| GitHub Repository|
+--------+---------+
         |
         v
+--------------------------------------------+
|              GitHub Actions                |
|                                            |
|  1. Continuous Integration                 |
|  2. Docker Image Publishing                |
|  3. EC2 Deployment                         |
+--------------------+-----------------------+
                     |
                     v
          +----------------------+
          |      Docker Hub      |
          |                      |
          | skillpulse-backend   |
          | skillpulse-frontend  |
          +----------+-----------+
                     |
                     | docker compose pull
                     v

                         PRODUCTION ENVIRONMENT

+-----------------------------------------------------+
|                    AWS EC2                          |
|                                                     |
|  +-----------------------------------------------+  |
|  |              Docker Compose                   |  |
|  |                                               |  |
|  |  +----------------------+                     |  |
|  |  | Frontend + Nginx    | :80                 |  |
|  |  +----------+-----------+                     |  |
|  |             | /api and /health                |  |
|  |             v                                 |  |
|  |  +----------------------+                     |  |
|  |  | Go Backend          | :8080               |  |
|  |  +----------+-----------+                     |  |
|  |             | MySQL connection                |  |
|  |             v                                 |  |
|  |  +----------------------+                     |  |
|  |  | MySQL Database      | :3306               |  |
|  |  | Persistent Volume   |                     |  |
|  |  +----------------------+                     |  |
|  +-----------------------------------------------+  |
+-----------------------------------------------------+
```

Only Nginx port `80` is exposed publicly. The backend port `8080` and MySQL port `3306` remain internal to the Docker network.

---

## Technology Stack

| Category | Technologies |
|---|---|
| Cloud | AWS EC2, Security Groups, EBS |
| Infrastructure as Code | Terraform |
| CI/CD | GitHub Actions |
| Containers | Docker, Docker Compose |
| Container Registry | Docker Hub |
| Reverse Proxy | Nginx |
| Backend | Go, Gin |
| Frontend | HTML, CSS, JavaScript |
| Database | MySQL |
| Operating System | Ubuntu Linux |
| Source Control | Git, GitHub |
| Security | GitHub Secrets, SSH keys, restricted security-group rules |

---

## Repository Structure

```text
skillpulse-devops/
|
|-- .github/
|   `-- workflows/
|       |-- ci.yml
|       |-- publish.yml
|       `-- deploy.yml
|
|-- backend/
|   |-- database/
|   |-- handlers/
|   |-- models/
|   |-- .dockerignore
|   |-- Dockerfile
|   |-- go.mod
|   |-- go.sum
|   `-- main.go
|
|-- frontend/
|   |-- css/
|   |-- js/
|   |-- .dockerignore
|   |-- Dockerfile
|   |-- index.html
|   `-- nginx.conf
|
|-- mysql/
|   `-- init.sql
|
|-- terraform/
|   |-- main.tf
|   |-- outputs.tf
|   |-- providers.tf
|   |-- terraform.tfvars.example
|   |-- user-data.sh
|   `-- variables.tf
|
|-- .env.example
|-- .env.production.example
|-- .gitignore
|-- ATTRIBUTION.md
|-- docker-compose.yml
|-- docker-compose.prod.yml
`-- README.md
```

---

## Docker Implementation

### Backend image

The backend uses a multi-stage Docker build:

1. A Go builder image downloads dependencies and compiles the application.
2. The binary is copied into a minimal `scratch` runtime.
3. The application runs as a non-root numeric user.

Benefits:

- Small runtime image
- No compiler in production
- Reduced attack surface
- Faster transfer
- Non-root process execution

### Frontend image

Nginx is used to:

- Serve static HTML, CSS, and JavaScript
- Proxy `/api/` requests to the backend
- Proxy `/health` to the backend health endpoint
- Cache static assets
- Expose the application on port `80`

---

## Docker Compose Environments

### Local development

`docker-compose.yml` builds images from local source code.

```powershell
docker compose up -d --build
```

Application URL:

```text
http://localhost:8080
```

Health check:

```powershell
Invoke-RestMethod http://localhost:8080/health
```

Stop without deleting database data:

```powershell
docker compose down
```

### Production-style deployment

`docker-compose.prod.yml` pulls tested images from Docker Hub.

```powershell
docker compose --env-file .env -f docker-compose.prod.yml pull
docker compose --env-file .env -f docker-compose.prod.yml up -d
```

The production file supports version selection:

```text
IMAGE_TAG=latest
```

or an immutable commit tag:

```text
IMAGE_TAG=abc1234
```

---

## Persistent Database Storage

MySQL uses the named volume:

```text
skillpulse-mysql-data
```

Persistence was verified by creating data, restarting the complete stack, and confirming the data remained available.

---

## Infrastructure as Code

Terraform provisions the temporary AWS deployment environment.

Managed resources:

- EC2 instance
- EC2 key pair
- Security group
- Encrypted `gp3` root EBS volume

Terraform also:

- Selects an official Ubuntu AMI dynamically
- Assigns a public IPv4 address
- Restricts SSH access
- Opens HTTP port `80`
- Installs Docker and Docker Compose through user data
- Deletes the root volume on termination
- Outputs the public IP, DNS name, and SSH command

### Provision infrastructure

```powershell
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

### Destroy infrastructure

```powershell
terraform destroy
```

All AWS resources were destroyed after testing to prevent unnecessary charges.

---

## Continuous Integration

The CI workflow runs on pushes and pull requests targeting `main`.

It performs:

1. Repository checkout
2. Go setup
3. Dependency verification
4. Backend package compilation and testing
5. CI environment creation
6. Docker Compose validation
7. Backend and frontend image builds
8. Full integration-stack startup
9. Health endpoint verification
10. Skills API verification
11. Container and volume cleanup

---

## Docker Image Publishing

After CI succeeds, the publishing workflow:

- Logs in to Docker Hub through GitHub Secrets
- Builds backend and frontend images
- Pushes both images
- Adds a `latest` tag
- Adds a seven-character Git commit SHA tag

Example:

```text
haseeb9876/skillpulse-backend:latest
haseeb9876/skillpulse-backend:abc1234
haseeb9876/skillpulse-frontend:latest
haseeb9876/skillpulse-frontend:abc1234
```

SHA tags provide traceability and support rollback to an exact version.

---

## EC2 Deployment

The deployment workflow is manually triggered and accepts an image tag.

It performs:

1. Repository checkout
2. Temporary SSH key preparation
3. EC2 host-key registration
4. Deployment-directory creation
5. Production file transfer
6. Secure `.env` creation
7. Docker image pull
8. Docker Compose deployment
9. Image cleanup
10. Public health verification
11. Temporary SSH key removal

---

## GitHub Secrets

Sensitive values are not committed.

The workflows use:

```text
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
EC2_HOST
EC2_USER
EC2_SSH_PRIVATE_KEY
MYSQL_ROOT_PASSWORD
DB_PASSWORD
```

Real `.env`, `.tfvars`, Terraform state, saved plan files, and private keys are excluded through `.gitignore`.

---

## Security Practices

- Backend runs as a non-root container user
- Database and backend ports are not exposed publicly
- Only Nginx is internet-facing
- GitHub Secrets protect credentials
- Docker Hub uses an access token
- AWS storage is encrypted
- IMDSv2 tokens are required
- SSH is restricted through Terraform
- Database credentials are not stored in Git
- Private SSH keys are not committed
- Cloud resources are destroyed after testing

GitHub-hosted runners use changing public IP addresses. During the temporary SSH deployment test, port `22` was briefly opened and then immediately restricted again. A stronger long-term design would use AWS Systems Manager or a self-hosted runner.

---

## Health Check

Endpoint:

```text
GET /health
```

Healthy response:

```json
{
  "status": "healthy"
}
```

---

## Troubleshooting Experience

Real issues solved during the project included:

- Terraform provider download interruption
- Terraform initialized from the wrong directory
- Invalid AWS security-group description
- Public IP change causing SSH timeout
- Missing `go.sum`
- Slow Alpine package installation
- Standalone Nginx DNS-resolution failure
- Docker Hub authentication failure
- GitHub-hosted runner unable to reach EC2 SSH

These issues were diagnosed through logs, validation commands, network tests, and controlled configuration changes.

---

## What I Learned

- Analyzing an unfamiliar application
- Identifying ports, dependencies, and environment variables
- Multi-stage Docker builds
- Minimal and non-root containers
- Nginx reverse proxy configuration
- Docker Compose networking and service discovery
- Persistent MySQL storage
- Terraform and AWS EC2
- GitHub Actions CI
- Integration testing
- Docker image publishing
- Commit-SHA versioning
- GitHub Secrets
- SSH-based deployment
- Health-based verification
- Cloud cost control
- Cross-environment troubleshooting

---

## Project Scope

This project deploys a containerized application to one AWS EC2 instance using Docker Compose. Kubernetes was intentionally excluded so the project could focus clearly on CI/CD, registry publishing, infrastructure automation, and single-server deployment.

---

## Future Improvements

- AWS Systems Manager instead of public SSH
- HTTPS and TLS
- Application Load Balancer
- Amazon RDS
- Remote Terraform state in S3
- Automated database backups
- Trivy image scanning
- SBOM generation
- OpenID Connect for AWS
- Prometheus and Grafana
- Loki logging
- Kubernetes
- Helm
- Argo CD
- Amazon EKS

---

## Source Attribution

The SkillPulse application source is based on an educational application by Shubham Londhe / TrainWithShubham.

The DevOps implementation in this repository—including Dockerfiles, Docker Compose configuration, Terraform infrastructure, CI/CD workflows, cloud deployment process, and documentation—was independently designed and implemented for learning and portfolio purposes.

See [`ATTRIBUTION.md`](ATTRIBUTION.md).

---

## Author

**Haseeb Ullah**

DevOps and Cloud Engineer

- GitHub: [haseeb9876](https://github.com/haseeb9876)
- Repository: [skillpulse-devops](https://github.com/haseeb9876/skillpulse-devops)

---

## Project Status

**Completed**

- Local validation: complete
- CI workflow: complete
- Docker image publishing: complete
- AWS deployment: complete
- Application update through pipeline: complete
- Infrastructure cleanup: complete
