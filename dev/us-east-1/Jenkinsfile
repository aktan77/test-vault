pipeline {
    agent any
    parameters {
        string(name: 'environment', defaultValue: 'terraform', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        booleanParam(name: 'destroy', defaultValue: false, description: 'Destroy Terraform build?')
    }
    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'jenkins', url: 'https://github.com/aktan77/test-vault'
            }
        }
        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
                sh 'pwd'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -reconfigure'
            }
        }
        stage('Terraform Plan') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            steps {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding', 
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh 'terraform plan'
                }
	        }
        }
        stage('Approval') {
            when {
               not {
                   equals expected: true, actual: params.autoApprove
               }
               not {
                    equals expected: true, actual: params.destroy
                }
            }
            steps {
               script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                    parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
               }
            }
        }
        stage('Terraform Apply') {
            when {
                not {
                    equals expected: true, actual: params.destroy
                }
            }
            steps {     
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding', 
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY',
                    credentialsId: 'aws-creds']]) {           
                    sh 'terraform apply --auto-approve'
                }
            }
        }
        stage('Destroy') {
            when {
                equals expected: true, actual: params.destroy
            } 
            steps {          
                sh 'terraform destroy --auto-approve'    
            }
        }
        stage('Run Bash Script') {
            steps {
                sh '''
                    #!/bin/bash
                    # For example:
                    echo "Hello, Jenkins!"
                    echo "This is a bash script running in a Jenkins pipeline."
                '''
            }
        }
    }
}