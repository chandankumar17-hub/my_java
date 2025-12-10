pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '476360959449'               // replace with your AWS account ID
        AWS_REGION     = 'us-east-1'                  // your region
        ECR_REPO       = 'prod/my-app'               // your ECR repo
        IMAGE_TAG      = "1"                           // image tag, you can also use Git commit hash
        DEPLOYMENT     = 'web-app'                    // Kubernetes deployment name
        CONTAINER      = 'web-app'                    // container name in deployment
        K8S_NAMESPACE  = 'prod'                        // target namespace
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/chandankumar17-hub/my_java.git',
                    credentialsId: 'GIT'   // your Jenkins Git credentials
            }
        }

        stage('Build Java App') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t my-app:${IMAGE_TAG} .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                    echo 'Logging in to ECR...'
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh """
                    echo 'Tagging and pushing image to ECR...'
                    docker tag my-app:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes 🚀') {
            steps {
                echo 'Deploying to Kubernetes...'
                
                // Use the Jenkins secret file for kubeconfig
                withCredentials([file(credentialsId: 'kubeconfig-prod', variable: 'KUBECONFIG')]) {
                    sh """
                        kubectl config use-context kubernetes-admin@kubernetes
                        kubectl set image deployment/${DEPLOYMENT} \
                        ${CONTAINER}=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} \
                        -n ${K8S_NAMESPACE}
                        
                        kubectl rollout status deployment/${DEPLOYMENT} -n ${K8S_NAMESPACE}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful to PROD"
        }
        failure {
            echo "❌ Deployment failed"
        }
        always {
            sh 'docker system prune -f || true'
        }
    }
}
