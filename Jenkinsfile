pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '476360959449.dkr.ecr.us-east-1.amazonaws.com'
        IMAGE_NAME = 'prod/my-app'
        KUBE_CREDENTIALS_ID = 'kubeconfig-prod'  // Jenkins Secret File
        NAMESPACE = 'prod'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Use build number as tag
                    env.IMAGE_TAG = "${BUILD_NUMBER}"
                    sh "docker build -t my-app:${IMAGE_TAG} ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_REGION} | \
                docker login --username AWS --password-stdin ${ECR_REGISTRY}
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh """
                docker tag my-app:${IMAGE_TAG} ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                docker push ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes 🚀') {
            steps {
                withCredentials([file(credentialsId: "${KUBE_CREDENTIALS_ID}", variable: 'KUBECONFIG')]) {
                    sh """
                    export KUBECONFIG=$KUBECONFIG
                    kubectl config use-context kubernetes-admin@kubernetes

                    # Update image in deployment.yaml dynamically
                    kubectl set image -f deployment.yaml java-app=${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -n ${NAMESPACE}

                    # Apply service (if not already exists)
                    kubectl apply -f service.yaml -n ${NAMESPACE}

                    # Wait for deployment rollout
                    kubectl rollout status deployment/java-app -n ${NAMESPACE}

                    # Check pods status
                    kubectl get pods -n ${NAMESPACE}
                    """
                }
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
