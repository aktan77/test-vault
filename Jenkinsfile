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
            // steps {
            //     withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cres']]) {
            //     sh 'terraform plan'
            // }
            steps {
                withCredentials([<object of type com.cloudbees.jenkins.plugins.awscredentials.AmazonWebServicesCredentialsBinding>]) {
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
                sh 'terraform apply --auto-approve'
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
}
}