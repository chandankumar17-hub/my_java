pipeline {
    agent any

    environment {
        IMAGE_NAME = "my-app"
        IMAGE_TAG = "${BUILD_NUMBER}"
        ECR_REGISTRY = "476360959449.dkr.ecr.us-east-1.amazonaws.com/prod"
        NAMESPACE = "prod"
        KUBECONFIG = credentials('kubeconfig-prod') // Add this in Jenkins credentials
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/chandankumar17-hub/my_java.git'
            }
        }

        stage('Build Java App') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region us-east-1 | \
                docker login --username AWS --password-stdin ${ECR_REGISTRY}
                docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes 🚀') {
            steps {
                sh """
                export KUBECONFIG=$KUBECONFIG
                kubectl config use-context kubernetes-admin@kubernetes

                # Update image in deployment.yaml
                sed -i "s|image: .*|image: ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}|g" k8s/deployment.yaml

                # Apply deployment and service
                kubectl apply -f k8s/deployment.yaml -n ${NAMESPACE}
                kubectl apply -f k8s/service.yaml -n ${NAMESPACE}

                # Wait for rollout
                kubectl rollout status deployment/${IMAGE_NAME} -n ${NAMESPACE}
                kubectl get pods -n ${NAMESPACE}
                """
            }
        }

    }

    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Deployment failed!"
        }
    }
}
