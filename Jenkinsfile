pipeline {
    agent any
    tools {
        git 'Default'
        maven 'Maven'
        jdk 'Java17'
    }

    environment {
        AWS_CREDENTIALS = credentials('aws_ecr')      // Jenkins Credentials ID
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "648696431853"
        IMAGE_NAME = "chandan/prod"
        ECR_URL = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/chandankumar17-hub/my_java.git',
                    credentialsId: 'git'
            }
        }

        stage('Lint') {
            steps {
                sh 'mvn checkstyle:check || true'
            }
        }

        stage('Build & Package') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Login to ECR') {
            steps {
                sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_URL}
                '''
            }
        }

        stage('Tag & Push to ECR') {
            steps {
                sh """
                    docker tag ${IMAGE_NAME}:latest ${ECR_URL}/${IMAGE_NAME}:latest
                    docker push ${ECR_URL}/${IMAGE_NAME}:latest
                """
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            echo '🎉 Image built and pushed to ECR successfully!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
