pipeline {
    agent any
    tools {
        git 'Default' // Use name configured in Global Tool Configuration
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/chandankumar17-hub/my_java.git', 
                    credentialsId: 'git'
            }
        }
    }
}
