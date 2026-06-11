# Angular Application Deployment using GitHub Actions, Artifact Registry and GKE

## Overview

This document explains the complete deployment flow from source code commit to deployment in Google Kubernetes Engine (GKE)

## Architecture

```text
Developers
    |
    | Git Push
    v
GitHub Repository
    |
    v
GitHub Actions
    |
    | Build Docker Image
    v
Artifact Registry
    |
    | Pull Image
    v
Google Kubernetes Engine (GKE)
    |
    v
Kubernetes Pods
    |
    v
LoadBalancer Service
    |
    v
Public URL
```

---

# Prerequisites

## Google Cloud Project

Project ID:

```text
backstage-test-499007
```

## Required Services

Enable:

```bash
gcloud services enable container.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

## Create Artifact Registry

```bash
gcloud artifacts repositories create backstage \
  --repository-format=docker \
  --location=asia-south1
```

## Create GKE Cluster

```bash
gcloud container clusters create backstage-cluster \
  --zone asia-south1-a \
  --num-nodes 2
```

Verify:

```bash
gcloud container clusters list
```

---

# Service Account Configuration

Create Service Account:

```text
githubactions
```

Grant Roles:

* Editor (for testing)
* Artifact Registry Writer
* Kubernetes Engine Developer
* Service Account User

Generate JSON Key:

```text
IAM & Admin
→ Service Accounts
→ Keys
→ Create Key
→ JSON
```

Download the JSON file.

---

# GitHub Secret Configuration

Repository:

```text
GitHub Repository
→ Settings
→ Secrets and Variables
→ Actions
```

Create:

```text
Name: GCP_SA_KEY
```

Paste the entire Service Account JSON.

---

# Dockerfile

```dockerfile
FROM node:22 AS build

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM nginx:alpine

COPY --from=build /app/dist/catalog/browser /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

---

# Kubernetes Deployment

File:

```text
k8s/deployment.yaml
```

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: angular-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: angular-app
  template:
    metadata:
      labels:
        app: angular-app
    spec:
      containers:
        - name: angular-app
          image: IMAGE_PLACEHOLDER
          imagePullPolicy: Always
          ports:
            - containerPort: 80
```

---

# Kubernetes Service

File:

```text
k8s/service.yaml
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: angular-app-service
spec:
  selector:
    app: angular-app
  ports:
    - port: 80
      targetPort: 80
  type: LoadBalancer
```

---

# GitHub Workflow

File:

```text
.github/workflows/deploy-gke.yml
```

```yaml
name: Deploy Angular to GKE

on:
  push:
    branches:
      - main

env:
  PROJECT_ID: backstage-test-499007
  CLUSTER_NAME: backstage-cluster
  CLUSTER_LOCATION: asia-south1-a
  REPOSITORY: backstage
  IMAGE_NAME: backstage-angular

jobs:
  deploy:
    runs-on: ubuntu-latest

    permissions:
      contents: read
      id-token: write

    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v2
        with:
          credentials_json: '${{ secrets.GCP_SA_KEY }}'

      - name: Setup GCloud
        uses: google-github-actions/setup-gcloud@v2

      - name: Setup kubectl
        uses: azure/setup-kubectl@v4

      - name: Configure Docker
        run: |
          gcloud auth configure-docker asia-south1-docker.pkg.dev --quiet

      - name: Get GKE Credentials
        uses: google-github-actions/get-gke-credentials@v2
        with:
          cluster_name: ${{ env.CLUSTER_NAME }}
          location: ${{ env.CLUSTER_LOCATION }}

      - name: Build Docker Image
        run: |
          docker build \
          -t asia-south1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE_NAME:${{ github.sha }} .

      - name: Push Docker Image
        run: |
          docker push \
          asia-south1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE_NAME:${{ github.sha }}

      - name: Replace Image Tag
        run: |
          sed -i "s|IMAGE_PLACEHOLDER|asia-south1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY/$IMAGE_NAME:${{ github.sha }}|g" k8s/deployment.yaml

      - name: Deploy to Kubernetes
        run: |
          kubectl apply -f k8s/deployment.yaml
          kubectl apply -f k8s/service.yaml

      - name: Verify Deployment
        run: |
          kubectl rollout status deployment/angular-app
```

---

# Deployment Flow

## Step 1

Developer pushes code:

```bash
git add .
git commit -m "New Feature"
git push origin main
```

## Step 2

GitHub Actions starts automatically.

## Step 3

Docker image is built.

```text
Angular Source
    |
    v
Docker Image
```

## Step 4

Image is pushed to Artifact Registry.

```text
Artifact Registry
└── backstage-angular:<commit-id>
```

## Step 5

GitHub updates Kubernetes Deployment.

```bash
kubectl apply -f k8s/deployment.yaml
```

## Step 6

GKE pulls the new image.

```text
Artifact Registry
      |
      v
GKE Nodes
      |
      v
Pods
```

## Step 7

Pods restart with the latest version.

## Step 8

LoadBalancer exposes the application.

Example:

```text
http://35.244.44.66
```

---

# Useful Commands

Check Pods:

```bash
kubectl get pods
```

Check Services:

```bash
kubectl get svc
```

Check Deployments:

```bash
kubectl get deployments
```

Check Logs:

```bash
kubectl logs <pod-name>
```

Restart Deployment:

```bash
kubectl rollout restart deployment/angular-app
```

Check Rollout Status:

```bash
kubectl rollout status deployment/angular-app
```

Access Cluster:

```bash
gcloud container clusters get-credentials backstage-cluster --zone asia-south1-a
```

---

# Result

Whenever code is pushed to the main branch:

1. GitHub Actions builds a Docker image.
2. Image is stored in Artifact Registry.
3. Kubernetes Deployment is updated.
4. GKE pulls the latest image.
5. Pods restart automatically.
6. Users access the latest version through the LoadBalancer URL.
