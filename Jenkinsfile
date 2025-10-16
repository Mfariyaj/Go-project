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

        stage('Build Docker') {
            steps {
                script {
                    sh '''
                        echo 'Build Docker Image'
                        docker build -t fariyajs/go-app:${BUILD_NUMBER} .
                    '''
                }
            }
        }

        stage('Push the artifacts') {
            steps {
                script {
                    sh '''
                        echo 'Push to Repo'
                        docker push fariyajs/go-app:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Checkout K8S manifest SCM') {
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

                        # Clone (shallow)
                        rm -rf "$WORKDIR"
                        git clone --depth 1 "$REPO_URL" "$WORKDIR"

                        cd "$WORKDIR/$MANIFEST_DIR"

                        # Set git user for commit
                        git config user.email "fariyajshaikh86@gmail.com"
                        git config user.name "Mfariyaj"

                        # New image
                        NEW_IMAGE="fariyajs/go-app:${BUILD_NUMBER}"
                        echo "Updating image to: $NEW_IMAGE"

                        # Replace image line
                        if [ -f "$FILE" ]; then
                            sed -i "0,/^[[:space:]]*image:/s|^[[:space:]]*image:.*|image: ${NEW_IMAGE}|" "$FILE"
                        else
                            echo "$FILE not found"
                            exit 1
                        fi

                        echo "File after update:"
                        cat "$FILE"
                        echo "----"

                        # Commit only if changes
                        git add "$FILE"
                        if git diff --quiet --cached; then
                            echo "No changes to commit"
                        else
                            git commit -m "Update deployment image to ${BUILD_NUMBER}"
                            git push origin HEAD:main
                            echo "Pushed changes to main"
                        fi
                    '''
                }
            }
        }
    }
}
