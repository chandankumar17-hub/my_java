pipeline {
    agent { label 'linux_git' }

    tools {
        jdk 'JDK 11'             // Match your Jenkins JDK name
        maven 'Maven 3.8.1'      // Match your Maven installation in Jenkins
    }

    environment {
        MAVEN_OPTS = "-Dmaven.test.failure.ignore=false"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                git 'https://github.com/chandankumar17-hub/my_java.git' 
            }
        }

        stage('Lint (Checkstyle)') {
            steps {
                echo '🔍 Running Checkstyle...'
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                always {
                    recordIssues(
                        tool: checkStyle(pattern: 'target/checkstyle-result.xml'),
                        qualityGates: [[threshold: 1, type: 'TOTAL', unstable: true]]
                    )
                }
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Archive JAR') {
            steps {
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Publish Test Results') {
            steps {
                junit 'target/surefire-reports/*.xml'
            }
        }
    }

    post {
        success {
            echo '✅ Build, tests, and linting completed successfully.'
        }
        failure {
            echo '❌ Something failed. Check logs and reports.'
        }
    }
}
