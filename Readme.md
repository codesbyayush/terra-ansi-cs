
# Devops
```mermaid
graph LR
    A((git push)) --> CI[CI Pipeline]
    
    subgraph CI["CI Pipeline"]
        direction LR
        B[OIDC<br/>Auth] --> C[Terraform<br/>Validate + Plan]
        B --> D[.NET<br/>Build]
        C --> E[S3<br/>Plan Artifact]
        D --> F[S3<br/>App Artifact]
    end
    
    CI --> CD[CD Pipeline]
    
    subgraph CD["CD Pipeline"]
        direction LR
        G[Download<br/>Plan] --> H[Terraform<br/>Apply]
        I[Fetch<br/>tfstate] --> J[Bun Script<br/>Inventory]
        H --> K[EC2 + RDS<br/>Created]
        K --> J
        F --> L[Ansible<br/>Deploy]
        J --> L
        L --> M((App Live))
    end
```
<img width="100%" height="auto" alt="image" src="https://github.com/user-attachments/assets/e9e08928-6c42-42ac-b55e-c330d146cb1f" />



Automated infra and config with deployment setup using Terraform for Infra provisioning, Ansible for configuration and deployment and Github actions as the automated runner for these two pipelines
    
## Terraform local setup
> Before starting make sure to install and configure aws cli and terraform locally

Clone the project

```bash
  git clone https://github.com/codesbyayush/terra-ansi-cs
```

Go to the project directory

```bash
  cd terra-ansi-cs
```

Initialize terraform

```bash
  cd terraform-01
  terraform init
```
> Before running apply we need to create a s3 backend store for the build file
> `terraform apply --target=module.s3_build_files`
Provision infra

```bash
  terraform apply -auto-approve
```

## Deploy 

- Read this [blog](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/) before moving forward for initial setup 

- Setup the OpenId connect identity provider for github actions to automate infra on aws, attach a new role to this and copy the arn we will need it in envs.

- Add these required env variables in the github repository secrets to be used in action workflow, 

- Env required:
  > `AWS_GH_ACTION_ROLE_ARN` : Role we created earlier for github to assume
  > `AWS_BACKEND_BUCKET` : State bucket for storing terraform state
  > `AWS_SSH_KEY_NAME` : Aws key-pair used in login or sshing into the machine
  > `DB_NAME` : Name of the database we are creating using rds module
