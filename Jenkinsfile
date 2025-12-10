pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = "476360959449"
    AWS_REGION     = "us-east-1"
    ECR_REPO       = "prod/my-app"
    IMAGE_TAG      = "${BUILD_NUMBER}"

    K8S_NAMESPACE  = "prod"
    DEPLOYMENT     = "java-app"
    CONTAINER      = "java-app"

    KUBECONFIG     = "/var/lib/jenkins/.kube/config"
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
        sh '''
        docker build -t my-app:${IMAGE_TAG} .
        '''
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
        aws ecr get-login-password --region ${AWS_REGION} \
        | docker login --username AWS \
        --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
        '''
      }
    }

    stage('Push Image to ECR') {
      steps {
        sh '''
        docker tag my-app:${IMAGE_TAG} \
        ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}

        docker push \
        ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
        '''
      }
    }

    stage('Deploy to Kubernetes 🚀') {
      steps {
        sh '''
        kubectl get nodes

        kubectl set image deployment/${DEPLOYMENT} \
        ${CONTAINER}=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} \
        -n ${K8S_NAMESPACE}

        kubectl rollout status deployment/${DEPLOYMENT} -n ${K8S_NAMESPACE}
        '''
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
