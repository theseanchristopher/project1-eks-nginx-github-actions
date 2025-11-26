# CI/CD Pipeline on AWS Elastic Kubernetes Service

A containerized web service is deployed to an AWS EKS cluster using a fully automated GitHub Actions continuous integration and continuous delivery pipeline.

## Introduction

This project demonstrates proficient use of a CI/CD pipeline in a cloud-based, containerized environment. Amazon EKS provides Kubernetes orchestration, AWS ECR stores container images, and GitHub Actions automates the build-and-deploy workflow into a dedicated application namespace. The pipeline builds a Docker image with a custom landing page, pushes the image to ECR, updates the Kubernetes Deployment manifest to reference the new tag, and deploys the application to the cluster. The application is namespace-isolated, horizontally scalable through a Kubernetes HPA, and supports HTTPS ingress traffic via an AWS Application Load Balancer secured with an ACM certificate. Overall, this project simulates a real-world cloud deployment workflow used in modern DevOps and platform engineering roles.

## Architecture Overview

This project combines a GitHub Actions CI/CD pipeline with an Amazon EKS cluster running on a managed node group. Application images are built and stored in Amazon ECR, then deployed to a dedicated Kubernetes namespace in EKS. At runtime, traffic flows through an AWS Application Load Balancer (when the Ingress is enabled), which terminates HTTPS using an ACM certificate and routes requests to the Nginx application running inside the cluster.

flowchart LR
    subgraph Dev["CI/CD Pipeline"]
        DevUser["Developer"]
        GitHub["GitHub Repo"]
        Actions["GitHub Actions Workflow (ci-cd.yaml)"]
        ECR["Amazon ECR (Container Registry)"]
    end

    subgraph EKS["AWS EKS Cluster (project1-eks)"]
        NS["Kubernetes Namespace: project1"]
        Deploy["Deployment: nginx-deployment"]
        HPA["HorizontalPodAutoscaler: nginx-hpa"]
        Svc["Service: nginx-service (ClusterIP)"]
        subgraph Nodes["Managed Nodegroup (EC2)"]
            Pods["Nginx Pods"]
        end
    end

    subgraph Network["Ingress & Networking (when enabled)"]
        Ingress["Kubernetes Ingress: nginx-ingress"]
        ALB["AWS Application Load Balancer"]
        ACM["AWS Certificate Manager (ACM) TLS Cert"]
        DNS["Cloudflare DNS (project1.seanxtopher.com)"]
        User["End User (HTTPS)"]
    end

    DevUser --> GitHub
    GitHub --> Actions
    Actions --> ECR
    Actions -->|"kubectl apply -n project1"| EKS

    Actions -->|"Deploys image tag\ninto Deployment manifest"| Deploy

    Deploy --> Pods
    Pods --> Svc
    HPA --> Deploy

    Svc --> Ingress
    Ingress --> ALB
    ALB --> ACM
    DNS --> User
    User -->|"HTTPS (443)"| ALB

## Features

- **Fully automated CI/CD pipeline** using GitHub Actions.
- **Containerized web application** built with Docker and stored in Amazon ECR.
- **Automated image tagging** using commit SHAs for traceable deployments.
- **Kubernetes Deployment** in a dedicated namespace for isolation.
- **Horizontal Pod Autoscaler (HPA)** for CPU-based scaling.
- **Service (ClusterIP)** for stable internal networking.
- **Ingress (ALB)** providing external HTTPS access (enabled as needed).
- **AWS Certificate Manager (ACM)** for TLS certificate management.
- **Application Load Balancer** automatically provisioned via Ingress annotations.
- **Cloudflare DNS** for domain ownership and routing.
- **Infrastructure created with eksctl** using a managed node group.
- **HTTPS smoke test** executed in the CI/CD pipeline to validate each release.
- **Scalable, production-style architecture** closely resembling real-world DevOps workflows.

## Repository Structure
.
├── app/
│   ├── Dockerfile              # Builds the container image with a custom landing page
│   └── index.html              # Custom landing page served by Nginx
│
├── k8s/
│   ├── deployment.yaml         # Kubernetes Deployment (nginx) with image placeholder
│   ├── service.yaml            # ClusterIP Service for internal networking
│   ├── hpa.yaml                # Horizontal Pod Autoscaler (CPU-based scaling)
│   └── ingress.yaml            # ALB Ingress with HTTPS termination (enabled as needed)
│
└── .github/
    └── workflows/
        └── ci-cd.yaml          # GitHub Actions CI/CD pipeline

This repository is organized into three main components:

- **app/** contains the Dockerfile and the custom `index.html` landing page used to build the web application image.
- **k8s/** contains the Kubernetes manifests deployed to the `project1` namespace in EKS.
- **.github/workflows/** includes the CI/CD pipeline (`ci-cd.yaml`) that automates build, push, and deployment.

## CI/CD Pipeline Overview

This project includes a GitHub Actions workflow (`ci-cd.yaml`) that automates the full build-and-deploy process:

1. **Source code changes** trigger the workflow on pushes to the `main` branch.
2. The pipeline **builds a Docker image** from the contents of the `app/` directory.
3. The image is **tagged with the commit SHA** to ensure traceability.
4. The image is **pushed to Amazon ECR**, which serves as the container registry.
5. The Kubernetes Deployment manifest is **updated to reference the new image tag**.
6. The manifests in the `k8s/` directory are **applied to the `project1` namespace** in the EKS cluster.
7. The pipeline waits for the **Kubernetes rollout to complete**.
8. A final **HTTPS smoke test** verifies the application is reachable (when the Ingress is enabled).

This automated workflow demonstrates a production-style CI/CD pipeline that builds, packages, and deploys a containerized application to Amazon EKS with no manual steps.

## Kubernetes Deployment Overview

The application is deployed into a dedicated Kubernetes namespace (`project1`) inside the EKS cluster. 
The deployment consists of the following key components:

- **Deployment (`nginx-deployment`)**  
  Manages the desired number of application replicas and ensures new versions are rolled out using the updated image tag from the CI/CD pipeline.

- **Service (`nginx-service`)**  
  A ClusterIP service that provides stable internal networking for the pods and acts as the backend target for the Ingress.

- **Horizontal Pod Autoscaler (`nginx-hpa`)**  
  Automatically scales the number of pod replicas based on CPU utilization, increasing capacity during load and reducing it when idle.

- **Ingress (`nginx-ingress`)** *(enabled when needed)*  
  Creates an AWS Application Load Balancer (ALB) using AWS Load Balancer Controller annotations.  
  When active, it enables secure HTTPS access to the application using an ACM certificate and routes external traffic to the service.

This deployment structure mirrors production practices where workloads are isolated by namespace, scaled automatically, and exposed securely over HTTPS.


## AWS Infrastructure Overview

This project runs on Amazon Web Services and uses several AWS-managed services to support the Kubernetes environment:

- **Amazon EKS (Elastic Kubernetes Service)**  
  Hosts the Kubernetes control plane and provides a managed, highly available API server.

- **Managed Node Group (EC2)**  
  A set of EC2 instances created and maintained by AWS through `eksctl`.  
  These nodes run the Nginx application pods and scale based on cluster requirements.

- **Amazon ECR (Elastic Container Registry)**  
  Stores versioned container images built by the CI/CD pipeline.  
  Images are tagged using commit SHAs for full traceability.

- **AWS Application Load Balancer (ALB)** *(enabled when Ingress is applied)*  
  Handles external HTTPS traffic and forwards it to the Kubernetes Service.  
  The ALB is fully managed and configured through Kubernetes annotations.

- **AWS Certificate Manager (ACM)**  
  Issues and manages the TLS certificate used for secure HTTPS access.

- **Cloudflare DNS**  
  Manages the domain (`project1.seanxtopher.com`) and performs CNAME routing to the ALB when Ingress is active.

Together, these services provide a realistic cloud-based environment that mirrors modern production deployments.


## Deployment Instructions

These steps outline how to deploy this project into a fresh AWS environment.  
They assume the user has AWS CLI, kubectl, and eksctl installed and configured.

### 1. Create the EKS Cluster and Node Group
```bash
eksctl create cluster --name project1-eks --region us-east-1 --nodegroup-name project1-ng
```

### 2. Create the Project Namespace
```bash
kubectl create namespace project1
```

### 3. Configure Container Registry (ECR)

Create an ECR repository (only needed once):

```bash
aws ecr create-repository --repository-name project1-nginx
```

### 4. Push Application Code to GitHub

Commit the application code, Kubernetes manifests, and CI/CD workflow:

- `app/`
- `k8s/`
- `.github/workflows/ci-cd.yaml`

Pushing changes to the `main` branch triggers the automated pipeline.

### 5. The CI/CD Pipeline Builds and Deploys

The GitHub Actions workflow automatically:

1. Builds the Docker image  
2. Tags it with the commit SHA  
3. Pushes the image to Amazon ECR  
4. Updates the Deployment manifest  
5. Applies Kubernetes manifests to the cluster  
6. Waits for the rollout to complete  
7. Runs an HTTPS smoke test (when Ingress is enabled)

No manual steps are required.

### 6. Enable HTTPS Access (Optional)

To deploy the public HTTPS endpoint:

```bash
kubectl apply -f k8s/ingress.yaml -n project1
```

To delete the Ingress and remove ALB costs:

```bash
kubectl delete ingress nginx-ingress -n project1
```

## Future Improvements

Several enhancements can extend this project toward a full production-grade platform:

- **Terraform IaC** for provisioning EKS, node groups, VPC resources, and ECR.
- **GitOps with Argo CD or Flux** for continuous delivery based on repository state.
- **Helm or Kustomize** for templated, reusable Kubernetes manifests.
- **Observability stack** (Prometheus, Grafana, Loki) for metrics and logging.
- **Pod Security and OPA/Gatekeeper** for enforcing cluster policies.
- **Multi-environment deployment** (dev, stage, prod) with environment-specific pipelines.
- **Blue/Green or Canary deployments** for safer application rollout.
- **Automated cleanup workflows** for ALB removal and cost management.

These additions would align the project even more closely with enterprise DevOps patterns.


## Project Summary (Resume Ready)

Built a full CI/CD pipeline that deploys a containerized web application to Amazon EKS using GitHub Actions, Amazon ECR, and Kubernetes best practices. The solution includes namespace isolation, automated image tagging, rolling updates, horizontal pod autoscaling (HPA), and optional HTTPS ingress through an AWS Application Load Balancer secured with ACM. This project demonstrates practical experience with cloud-based infrastructure, Kubernetes orchestration, deployment automation, and end-to-end delivery workflows commonly used in modern DevOps and platform engineering roles.
