pipeline {
  agent any

  environment {
    // AWS & ECR
    AWS_ACCOUNT_ID = '476360959449'
    AWS_REGION    = 'us-east-1'
    ECR_REPO      = 'prod/my-app'
    IMAGE_TAG     = "${BUILD_NUMBER}"
  }

  stages {

    stage('Checkout Code') {
      steps {
        // Uses same repo/branch as Pipeline from SCM
        checkout scm
      }
    }

    stage('Lint Dockerfile') {
      steps {
        sh '''
        echo "Running Dockerfile lint..."
        docker run --rm -i hadolint/hadolint < Dockerfile
        '''
      }
    }

    stage('Login to ECR') {
      steps {
        sh '''
        aws ecr get-login-password --region $AWS_REGION \
        | docker login --username AWS --password-stdin \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
        docker build -t my-app:$IMAGE_TAG .
        '''
      }
    }

    stage('Tag Docker Image') {
      steps {
        sh '''
        docker tag my-app:$IMAGE_TAG \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
        '''
      }
    }

    stage('Push Image to ECR') {
      steps {
        sh '''
        docker push \
        $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Image pushed successfully to ECR: $ECR_REPO:$IMAGE_TAG"
    }
    failure {
      echo "❌ Pipeline failed"
    }
    always {
      sh 'docker system prune -f || true'
    }
  }
}
