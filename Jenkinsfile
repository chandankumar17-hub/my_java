pipeline {
    agent any

    environment {
        // Use your Jenkins secret credentials for kubeconfig
        KUBECONFIG = credentials('kubeconfig-prod')
        IMAGE_TAG = "13" // Update dynamically if needed
        ECR_REPO = "476360959449.dkr.ecr.us-east-1.amazonaws.com/prod/my-app"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t my-app:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    echo "Logging in to ECR..."
                    aws ecr get-login-password --region us-east-1 | \
                        docker login --username AWS --password-stdin 476360959449.dkr.ecr.us-east-1.amazonaws.com

                    echo "Tagging and pushing image..."
                    docker tag my-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to Kubernetes 🚀') {
            steps {
                sh '''
                    echo "Deploying to Kubernetes..."
                    kubectl config use-context kubernetes-admin@kubernetes
                    # Update the deployment YAML image
                    sed -i "s|image: .*|image: ${ECR_REPO}:${IMAGE_TAG}|g" deployment.yaml

                    # Apply deployment and service YAMLs
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml
                '''
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
            echo "Pipeline finished"
        }
        failure {
            echo "❌ Deployment failed!"
        }
        success {
            echo "✅ Deployment succeeded!"
        }
    }
}
