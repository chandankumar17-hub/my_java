pipeline {
    agent any
    tools {
        git 'Default'       // Git tool
        maven 'Maven'       // Maven tool from Global Tool Configuration
        jdk 'Java17'        // JDK tool
    }
    environment {
        IMAGE_NAME = "my_java_app:latest"
        DOCKER_PORT = "8081"
    }
    stages {
        stage('Checkout') {
            steps {
                echo "Checking out source code..."
                git branch: 'main',
                    url: 'https://github.com/chandankumar17-hub/my_java.git',
                    credentialsId: 'git'
            }
        }

        stage('Lint') {
            steps {
                echo "Running code quality lint checks..."
                sh 'mvn checkstyle:check || true' // fails or warns based on plugin config
            }
        }

        stage('Build & Package') {
            steps {
                echo "Building Java project and packaging jar..."
                sh 'mvn clean package'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                echo "Deploying Docker container..."
                sh """
                    if [ \$(docker ps -aq -f name=my_java_app) ]; then
                        docker rm -f my_java_app
                    fi
                    docker run -d --name my_java_app -p ${DOCKER_PORT}:8080 ${IMAGE_NAME}
                """
            }
        }
    }
    post {
        success {
            echo 'Pipeline completed successfully!'
            archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
