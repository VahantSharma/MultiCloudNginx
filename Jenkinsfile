pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Environment to deploy')
        choice(name: 'ACTION', choices: ['plan', 'apply', 'destroy'], description: 'Terraform action')
    }

    environment {
        ARM_CLIENT_ID         = credentials('azure-client-id')
        ARM_CLIENT_SECRET     = credentials('azure-client-secret')
        ARM_SUBSCRIPTION_ID   = credentials('azure-subscription-id')
        ARM_TENANT_ID         = credentials('azure-tenant-id')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/VahantSharma/MultiCloudNginx.git'
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'terraform init -backend-config="resource_group_name=terraform-state-vs" -backend-config="storage_account_name=terraformersprime" -backend-config="container_name=tfstate" -backend-config="key=terraform-${params.ENVIRONMENT}.tfstate"'
            }
        }

        stage('Select Workspace') {
            steps {
                sh "terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}"
            }
        }

        stage('Terraform Plan') {
            steps {
                sh "terraform plan -var-file=${params.ENVIRONMENT}.tfvars -out=tfplan"
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh 'terraform apply tfplan'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                sh "terraform destroy -var-file=${params.ENVIRONMENT}.tfvars -auto-approve"
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}