pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '476360959449'
        AWS_REGION     = 'us-east-1'
        ECR_REPO       = 'prod/my-app'
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE  = 'prod'
        DEPLOYMENT     = 'web-app' // Name of your K8s deployment
        CONTAINER      = 'web-app' // Name of container inside deployment
        KUBECONFIG     = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/chandankumar17-hub/my_java.git',
                    credentialsId: 'GIT'
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
                    docker tag my-app:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
            }
        }

        stage('Deploy to Kubernetes 🚀') {
            steps {
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
