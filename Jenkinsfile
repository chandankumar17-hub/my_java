pipeline {
    agent any

    environment {
        SSH_CREDENTIALS_ID = 'ec2-ssh-key-id'          // Jenkins stored SSH private key ID
        EC2_USER = 'ec2-user'                          // SSH user on EC2
        EC2_HOST = '18.212.93.247'                // EC2 public IP or DNS
        TOMCAT_WEBAPPS_PATH = '/opt/tomcat/webapps'   // Tomcat WAR deploy folder
    }

    stages {
        stage('Checkout') {
            steps {
                // Clone your GitHub repo
                git url: 'https://github.com/chandankumar17-hub/my_java.git', branch: 'main'
            }
        }

        stage('Build') {
            steps {
                // Use Maven to build the project and create WAR file
                sh 'mvn clean package'
            }
        }

        stage('Deploy') {
            steps {
                sshagent([SSH_CREDENTIALS_ID]) {
                    // Copy the WAR file to EC2 Tomcat webapps folder
                    sh """
                        scp target/*.war ${EC2_USER}@${EC2_HOST}:${TOMCAT_WEBAPPS_PATH}/
                    """

                    // Restart Tomcat to deploy the new WAR
                    sh """
                        ssh ${EC2_USER}@${EC2_HOST} '/opt/tomcat9/bin/shutdown.sh'
                        ssh ${EC2_USER}@${EC2_HOST} '/opt/tomcat9/bin/startup.sh'
                    """
                }
            }
        }
    }
}

