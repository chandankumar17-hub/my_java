pipeline {
  agent any

  environment {
    AWS_ACCOUNT_ID = '476360959449'
    AWS_REGION    = 'us-east-1'
    ECR_REPO      = 'prod/java-app'
    IMAGE_TAG     = "${BUILD_NUMBER}"
    K8S_NAMESPACE = 'prod'
    DEPLOYMENT    = 'java-app'
    CONTAINER     = 'java-app'
  }

  stages {

    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build JAR') {
      steps {
        sh 'mvn clean package -DskipTests'
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
        aws ecr get-login-password --region $AWS_REGION |
        docker login --username AWS --password-stdin \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t java-app:$IMAGE_TAG .'
      }
    }

    stage('Push Image') {
      steps {
        sh '''
        docker tag java-app:$IMAGE_TAG \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

        docker push \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Deploy to Kubernetes 🚀') {
      steps {
        sh '''
        kubectl config use-context kubernetes-admin@kubernetes

        kubectl set image deployment/$DEPLOYMENT \
        $CONTAINER=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG \
        -n $K8S_NAMESPACE

        kubectl rollout status deployment/$DEPLOYMENT -n $K8S_NAMESPACE
        '''
      }
    }
  }

  post {
    success { echo '✅ Java App Deployed Successfully' }
    failure { echo '❌ Deployment Failed' }
    always  { sh 'docker system prune -f || true' }
  }
}
