# [Backstage](https://backstage.io)

This is your newly scaffolded Backstage App, Good Luck!

To start the app, run:

```sh
yarn install
yarn start
```


# Backstage Software Catalog & TechDocs Setup Guide

## Overview

This guide explains how to:

1. Register an Angular application in Backstage
2. Create Teams and Users
3. Connect Frontend and Backend services
4. Add API relationships
5. Add Resources (MongoDB, Kafka, etc.)
6. Configure TechDocs

---

# Prerequisites

Before starting, ensure you have:

* Git installed
* GitHub account
* Backstage running locally
* Node.js installed
* Python installed (required for TechDocs)

---

# Step 1: Create a Git Repository

Create a GitHub repository for your application.

Example:

```text
backstage-angular
```

Push your application code to GitHub.

---

# Step 2: Create catalog-info.yaml

Create a file named:

```text
catalog-info.yaml
```

Place it in the root of the repository.

Example:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: backstage-angular
  description: Angular frontend application
  annotations:
    github.com/project-slug: sairam3333/backstage-angular
    backstage.io/techdocs-ref: dir:.
spec:
  type: website
  lifecycle: production
  owner: elite-frontend-team
```

### Explanation

| Property                | Description                           |
| ----------------------- | ------------------------------------- |
| name                    | Component name shown in Backstage     |
| description             | Description of the application        |
| github.com/project-slug | GitHub repository                     |
| techdocs-ref            | Location of documentation             |
| type                    | website, service, library, etc.       |
| lifecycle               | production, development, experimental |
| owner                   | Team responsible for the component    |

---

# Step 3: Create Team Definition

Create:

```text
group.yaml
```

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: elite-frontend-team
spec:
  type: team
  profile:
    displayName: Elite Frontend Team
  children: []
```

### Purpose

Groups represent teams inside Backstage.

Examples:

* Frontend Team
* Backend Team
* DevOps Team

---

# Step 4: Create User Definition

Create:

```text
user.yaml
```

```yaml
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: guest
  namespace: development
spec:
  profile:
    displayName: Guest User
  memberOf:
    - elite-frontend-team
```

### Purpose

Users can belong to one or more teams.

---

# Step 5: Install Python

TechDocs requires Python and MkDocs.

Download Python:

https://www.python.org/downloads/

During installation select:

```text
✓ Add Python to PATH
```

Verify installation:

```bash
python --version
```

Expected:

```text
Python 3.x.x
```

---

# Step 6: Install MkDocs

Install MkDocs:

```bash
python -m pip install mkdocs
```

Verify:

```bash
mkdocs --version
```

Expected:

```text
mkdocs, version 1.x.x
```

---

# Step 7: Install TechDocs Plugin

Install:

```bash
python -m pip install mkdocs-techdocs-core
```

Verify:

```bash
python -m pip show mkdocs-techdocs-core
```

---

# Step 8: Create mkdocs.yml

Create:

```text
mkdocs.yml
```

in the repository root.

```yaml
site_name: Backstage Angular

nav:
  - Home: index.md

plugins:
  - techdocs-core
```

---

# Step 9: Create Documentation Folder

Create:

```text
docs/
```

Inside docs create:

```text
docs/index.md
```

Example:

```markdown
# Backstage Angular

Angular frontend application.

## Features

- Dashboard
- User Management
- Reports

## Setup

npm install
npm start
```

Repository structure:

```text
backstage-angular
│
├── catalog-info.yaml
├── group.yaml
├── user.yaml
├── mkdocs.yml
├── docs
│   └── index.md
└── src
```

---

# Step 10: Commit and Push

```bash
git add .
git commit -m "Add Backstage catalog metadata"
git push origin main
```

---

# Step 11: Configure GitHub Integration

Create a GitHub Personal Access Token.

GitHub:

https://github.com/settings/tokens

Add token in:

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

Recommended:

```bash
set GITHUB_TOKEN=your_token_here
```

Never commit tokens into Git repositories.

---

# Step 12: Register Team

Backstage:

```text
Create → Register Existing Component
```

Register:

```text
https://github.com/<github-user>/<repo>/blob/main/group.yaml
```

---

# Step 13: Register User

Register:

```text
https://github.com/<github-user>/<repo>/blob/main/user.yaml
```

---

# Step 14: Register Component

Register:

```text
https://github.com/<github-user>/<repo>/blob/main/catalog-info.yaml
```

---

# Step 15: Verify Catalog

Open:

```text
Catalog
```

Verify:

* Component exists
* Team exists
* User exists
* Owner is resolved
* No missing entity warnings

---

# Adding a Backend Service

Create another repository.

Example:

```text
report-card-service
```

Create:

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: report-card-service
spec:
  type: service
  lifecycle: production
  owner: elite-frontend-team
```

Register it in Backstage.

---

# Connecting Frontend and Backend

Angular:

```yaml
dependsOn:
  - component:default/report-card-service
```

Result:

```text
Angular Frontend
        ↓
Report Card Service
```

---

# Adding API Documentation

Create:

```text
api-info.yaml
```

```yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: report-api
spec:
  type: openapi
  lifecycle: production
  owner: elite-frontend-team
  definition: |
    openapi: 3.0.0
    info:
      title: Report API
      version: 1.0.0
    paths: {}
```

---

# Connect Components Through APIs

Backend:

```yaml
providesApis:
  - report-api
```

Frontend:

```yaml
consumesApis:
  - report-api
```

Relationship:

```text
Angular Frontend
        ↓
     Report API
        ↓
Spring Boot Backend
```

---

# Adding Resources

## MongoDB

```yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: report-mongodb
spec:
  type: database
  owner: elite-frontend-team
```

## Kafka

```yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: report-kafka
spec:
  type: messaging
  owner: elite-frontend-team
```

Backend:

```yaml
dependsOn:
  - resource:default/report-mongodb
  - resource:default/report-kafka
```

Relationship:

```text
Angular
   ↓
Spring Boot
   ↓
MongoDB

Spring Boot
   ↓
Kafka
```

---

# TechDocs Verification

Open:

```text
Catalog → backstage-angular → Docs
```

Expected:

* Documentation loads successfully
* Home page displayed
* Markdown rendered correctly

If you get:

```text
spawn mkdocs ENOENT
```

then MkDocs is not available in the PATH used by the Backstage backend process.

<!-- Authentication -->

Authentication

- Created a Okta admin account
- Generated OAuth token for testing purpose
- Configured a auth in app-config.yaml file
- Created a custom resolver for okta (Can put the condition like only the organization users can login)

Keys Needed

 - AUTH_OKTA_CLIENT_ID
 - AUTH_OKTA_CLIENT_SECRET
 - AUTH_OKTA_DOMAIN

Setup - https://backstage.io/docs/auth/okta/provider

They has three resolver in built

1. emailMatchingUserEntityProfileEmail
    
    - It will search from the catalog-info.yaml file from this location spec.profile.email, if the login email has entry in this then can login.
   
2. emailLocalPartMatchingUserEntityName

   - Takes the part before @ and matches the name from cataog-info.yaml file from this location metadata.name

3. emailMatchingUserEntityAnnotation

   - Matches the email against a catalog annotation from catalog-ingo.yaml file from the location metadata.annotations["okta.com/email"]


<!-- Software template flow -->

Backstage Software Templates allow developers to create new services (Node.js, Python, etc.) in a standardized way. A single template execution can:

Generate a service from a skeleton
Create a new GitHub repository
Configure CI/CD pipelines
Register the service in Backstage Catalog
🔁 High-Level Flow
```
Developer selects template in Backstage UI
        ↓
Fills in service details (name, description, etc.)
        ↓
Backstage Scaffolder engine runs template steps
        ↓
Skeleton code is generated from template
        ↓
New GitHub repository is created
        ↓
Code is pushed automatically
        ↓
CI/CD pipeline is configured (GitHub Actions, etc.)
        ↓
Component is registered in Backstage Catalog
        ↓
Service becomes visible in Developer Portal
```

⚙️ Step-by-Step Execution Flow
1. Template Selection
Developer opens Backstage UI
Navigates to Create → Software Template
Selects a template (e.g., Node.js Service)
2. Input Collection

The template collects parameters such as:

Service name
Description
Owner/team
Repository name
3. Template Processing (Scaffolder Engine)

Backstage executes defined steps in template.yaml:

Typical steps include:

fetch:template → Load skeleton code
publish:github → Create repository
catalog:register → Register service in catalog
4. Skeleton Generation
Template files are copied from /skeleton
Variables are replaced dynamically
Final project structure is generated

```
Example:

service-name/
 ├── src/
 ├── Dockerfile
 ├── package.json
 ├── catalog-info.yaml
 └── .github/workflows/ci.yml
```

5. GitHub Repository Creation

Backstage automatically:

Creates a new repository under the configured GitHub org
Pushes generated code
Initializes default branch (main)
6. CI/CD Setup

A default pipeline is added (example: GitHub Actions):

Install dependencies
Run tests
Build application
(Optional) Deploy to environment
7. Catalog Registration

A catalog-info.yaml file is used to register the service:

apiVersion: backstage.io/v1alpha1
kind: Component

metadata:
  name: service-name
  description: Service description

spec:
  type: service
  owner: platform-team
  lifecycle: production

Backstage automatically imports it into the Software Catalog.

8. Final Output

After execution:

GitHub repository is ready
CI/CD pipeline is active
Service appears in Backstage Catalog
Developers can start coding immediately

🧭 Architecture Summary
```
Backstage UI
     ↓
Scaffolder Plugin
     ↓
Template (template.yaml)
     ↓
Skeleton Repository
     ↓
GitHub API (repo creation)
     ↓
CI/CD Pipeline (GitHub Actions)
     ↓
Backstage Catalog Registration
```