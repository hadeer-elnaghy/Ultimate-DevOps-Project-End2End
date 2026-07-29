pipeline {
    agent any

    environment {
        // Define application metadata and image name
        APP_NAME = 'ultimate-devops-app'
        IMAGE_TAG = "v1.0.${BUILD_NUMBER}"
        SNYK_TOKEN = credentials('snyk-token')
    }

    stages {
        // Stage 1: Source Code Checkout
        stage('Checkout Source Code') {
            steps {
                echo '[INFO] Checking out latest source code from GitHub...'
                checkout scm
            }
        }

        // Stage 2: Code Quality Analysis with SonarQube
        stage('SonarQube Quality Scan') {
            steps {
                echo '[INFO] Starting Static Code Analysis via SonarQube...'
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=Ultimate-DevOps-Project \
                            -Dsonar.projectName="Ultimate DevOps Project" \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=node_modules/**,coverage/**
                        """
                    }
                }
            }
        }
        // Stage 3: Dependency Security Scan via Snyk Container
        stage('Snyk Security Scan') {
            steps {
                echo '[INFO] Scanning node dependencies using official Snyk container...'
                sh '''
                    docker run --rm \
                        --volumes-from jenkins-server \
                        -w ${WORKSPACE} \
                        -e SNYK_TOKEN=${SNYK_TOKEN} \
                        snyk/snyk:node snyk test --severity-threshold=high || true
                '''
            }
        }

        // Stage 4: Docker Image Build
        stage('Build Docker Image') {
            steps {
                echo "[INFO] Building Docker image: ${APP_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${APP_NAME}:${IMAGE_TAG} -t ${APP_NAME}:latest ."
            }
        }

        // Stage 5: Container Security Scan via Trivy Container
        stage('Trivy Image Vulnerability Scan') {
            steps {
               echo "[INFO] Scanning Docker image ${APP_NAME}:${IMAGE_TAG} with Trivy Container..."
               sh """
               docker run --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                aquasec/trivy:latest image \
                --timeout 30m \
                --severity HIGH,CRITICAL \
                ${APP_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Debug Workspace') {
    steps {
        sh '''
            echo "WORKSPACE = ${WORKSPACE}"
            echo "Current directory:"
            pwd

            echo "Workspace files:"
            find "${WORKSPACE}" -maxdepth 3 -type f | sort

            echo "Ansible directory:"
            ls -la "${WORKSPACE}/ansible" || true

            echo "Deploy playbook:"
            ls -la "${WORKSPACE}/ansible/deploy.yml" || true
        '''
    }
}       

        // Stage 6: Automated Deployment via Ansible to Kubernetes
        stage('Deploy to K8s via Ansible') {
            steps {
                echo '[INFO] Executing Ansible Playbook for Kubernetes Deployment...'
                sh """
                 docker run --rm \
                  -v ${WORKSPACE}:/apps \
                  -v ~/.kube:/root/.kube \
                  -v /var/run/docker.sock:/var/run/docker.sock \
                  -w /apps \
                  willhallonline/ansible:latest \
                  ansible-playbook ansible/deploy.yml -e "app_image_tag=${IMAGE_TAG}"
              """    
            }
        }
    }

    post {
        always {
            echo '[INFO] Cleaning up workspace artifacts...'
            cleanWs()
        }
        success {
            echo '[SUCCESS] Pipeline completed successfully! Application deployed to K8s.'
        }
        failure {
            echo '[ERROR] Pipeline failed! Check logs for errors.'
        }
    }
}
