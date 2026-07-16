pipeline {

    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/Mfariyaj/Go-project.git', branch: 'main', credentialsId: 'GITHUB'
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'Docker',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''echo "${DOCKER_PASSWORD}" | docker login --username "${DOCKER_USERNAME}" --password-stdin'''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker Image..."
                    docker build -t fariyajs/go-app:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    echo "Pushing Docker Image..."
                    docker push fariyajs/go-app:${BUILD_NUMBER}
                '''
            }
        }

        stage('Checkout K8S Manifest SCM') {
            steps {
                git url: 'https://github.com/Mfariyaj/Go-project.git', branch: 'main', credentialsId: 'GITHUB'
            }
        }

        stage('Update Deployment Image') {
            steps {
                withCredentials([string(credentialsId: 'GITHUB', variable: 'GITHUB_TOKEN')]) {
                    sh '''
                        #!/bin/bash
                        set -e

                        REPO_URL="https://${GITHUB_TOKEN}@github.com/Mfariyaj/Go-project.git"
                        WORKDIR="Go-project"
                        MANIFEST_DIR="Kubernetes-manifest"
                        FILE="Deployment.yaml"

                        # Clone repository
                        rm -rf "$WORKDIR"
                        git clone --depth 1 "$REPO_URL" "$WORKDIR"

                        cd "$WORKDIR/$MANIFEST_DIR"

                        # Configure Git
                        git config user.email "fariyajshaikh86@gmail.com"
                        git config user.name "Mfariyaj"

                        # Update image
                        NEW_IMAGE="fariyajs/go-app:${BUILD_NUMBER}"
                        echo "Updating image to: $NEW_IMAGE"

                        if [ -f "$FILE" ]; then
                            sed -i "0,/^[[:space:]]*image:/s|^[[:space:]]*image:.*|image: ${NEW_IMAGE}|" "$FILE"
                        else
                            echo "$FILE not found"
                            exit 1
                        fi

                        echo "Updated Deployment.yaml:"
                        cat "$FILE"

                        git add "$FILE"

                        if git diff --cached --quiet; then
                            echo "No changes to commit."
                        else
                            git commit -m "Update deployment image to ${BUILD_NUMBER}"
                            git push origin HEAD:main
                            echo "Changes pushed successfully."
                        fi
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed."
        }

        success {
            echo "Pipeline completed successfully."
        }

        failure {
            echo "Pipeline failed."
        }
    }
}
