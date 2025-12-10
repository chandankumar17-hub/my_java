pipeline {
    agent any

    environment {
        APP_NAME = "my-app"
        IMAGE_TAG = "1"
        ECR_URI = "476360959449.dkr.ecr.us-east-1.amazonaws.com/prod/${APP_NAME}:${IMAGE_TAG}"
        AWS_REGION = "us-east-1"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Java App') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${APP_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Login to ECR') {
            steps {
                withEnv(["AWS_REGION=${AWS_REGION}"]) {
                    sh '''
                        echo "Logging in to ECR..."
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin 476360959449.dkr.ecr.us-east-1.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh """
                    echo "Tagging and pushing image to ECR..."
                    docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_URI}
                    docker push ${ECR_URI}
                """
            }
        }

        stage('Deploy to Kubernetes 🚀') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-prod', variable: 'KUBECONFIG')]) {
                    sh '''
                        echo "Deploying to Kubernetes..."
                        export KUBECONFIG=$KUBECONFIG
                        kubectl config use-context kubernetes-admin@kubernetes
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo "✅ Deployment succeeded!"
        }
        failure {
            echo "❌ Deployment failed"
        }
    }
}
