pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '476360959449'
        AWS_REGION     = 'us-east-1'
        ECR_REPO       = 'prod/my-app'
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE  = 'prod'
        DEPLOYMENT     = 'web-app' // Your Kubernetes Deployment name
        CONTAINER      = 'web-app' // Container name inside Deployment
        KUBECONFIG     = '/var/lib/jenkins/.kube/config'
    }

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/chandankumar17-hub/my_java.git', branch: 'main', credentialsId: 'GIT'
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
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
