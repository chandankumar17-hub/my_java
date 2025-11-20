pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'Java17'
    }

    environment {
        AWS_ACCOUNT_ID = "648696431853"
        AWS_REGION     = "us-east-1"
        ECR_REPO       = "chandan/prod"
        IMAGE_TAG      = "v${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                echo "Cloning Source Code..."
                git url: 'https://github.com/chandankumar17-hub/my_java.git', branch: 'main'
                // If repo is private then use:
                // git url: 'https://github.com/chandankumar17-hub/my_java.git', branch: 'main', credentialsId: 'git'
            }
        }

        stage('Build & Package') {
            steps {
                echo "Building Java project..."
                sh 'mvn clean package'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    fullImage = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
                }
                echo "Building Docker image..."
                sh "docker build -t ${fullImage} ."
            }
        }

        stage('Docker Login to ECR') {
            steps {
                echo "Authenticating Docker with AWS ECR..."
                sh '''
                aws ecr get-login-password --region ${AWS_REGION} \
                | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                echo "Pushing Docker Image to ECR..."
                sh "docker push ${fullImage}"
            }
        }

        stage('Run Docker Locally') {
            steps {
                echo "Running docker container locally..."
                sh '''
                docker stop myapp || true
                docker rm myapp || true
                docker run -d --name myapp -p 8081:8080 ${fullImage}
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! Image pushed: ${fullImage}"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
