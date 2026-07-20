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

        stage('Approval') {
            options {
                timeout(time: 30, unit: 'MINUTES')
            }
            steps {
                emailext(
                    to: 'zubairmd797@gmail.com',
                    subject: "⏳ APPROVAL REQUIRED - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                    mimeType: 'text/html',
                    body: """
                        <html>
                        <body style="font-family: Arial, sans-serif; padding: 20px;">
                            <h2 style="color: #ff9800;">⏳ Deployment Approval Required</h2>
                            <hr/>
                            <table style="width:100%; border-collapse: collapse;">
                                <tr style="background:#f2f2f2;">
                                    <td style="padding:8px; font-weight:bold;">Project</td>
                                    <td style="padding:8px;">${env.JOB_NAME}</td>
                                </tr>
                                <tr>
                                    <td style="padding:8px; font-weight:bold;">Build Number</td>
                                    <td style="padding:8px;">#${env.BUILD_NUMBER}</td>
                                </tr>
                                <tr style="background:#f2f2f2;">
                                    <td style="padding:8px; font-weight:bold;">Docker Image</td>
                                    <td style="padding:8px;">fariyajs/go-app:${env.BUILD_NUMBER}</td>
                                </tr>
                                <tr>
                                    <td style="padding:8px; font-weight:bold;">Timeout</td>
                                    <td style="padding:8px;">30 minutes</td>
                                </tr>
                            </table>
                            

                            <p style="font-size:16px;">Please allow or deny the deployment:</p>
                            <p>
                                <a href="${env.BUILD_URL}input/" style="background-color:#28a745; color:white; padding:12px 24px; text-decoration:none; border-radius:5px; font-weight:bold; margin-right:10px;">✅ Allow</a>
                                <a href="${env.BUILD_URL}input/" style="background-color:#dc3545; color:white; padding:12px 24px; text-decoration:none; border-radius:5px; font-weight:bold;">❌ Deny</a>
                            </p>
                            

                            <p style="color:#888; font-size:12px;">This approval will timeout in 30 minutes. If not approved, the build will be aborted.</p>
                            <p style="color:#888; font-size:12px;">This is an automated notification from Jenkins.</p>
                        </body>
                        </html>
                    """
                )
                input message: 'Do you approve deployment to production?', ok: 'Allow'
            }
        }

        stage('Checkout K8S Manifest SCM') {
            steps {
                git url: 'https://github.com/Mfariyaj/Go-project.git', branch: 'main', credentialsId: 'GITHUB'
            }
        }

        stage('Update Deployment Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'GITHUB', usernameVariable: 'GIT_USER', passwordVariable: 'GITHUB_TOKEN')]) {
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
                            sed -i "s|^[[:space:]]*image:.*|        image: ${NEW_IMAGE}|" "$FILE"
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
        success {
          emailext(
              to: 'zubairmd797@gmail.com',
              subject: "✅ BUILD SUCCESS - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
              mimeType: 'text/html',
              body: """
                  <html>
                  <body style="font-family: Arial, sans-serif; padding: 20px;">
                      <h2 style="color: #28a745;">✅ Build Successful</h2>
                      <hr/>
                      <table style="width:100%; border-collapse: collapse;">
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Project</td>
                              <td style="padding:8px;">${env.JOB_NAME}</td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Build Number</td>
                              <td style="padding:8px;">#${env.BUILD_NUMBER}</td>
                          </tr>
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Status</td>
                              <td style="padding:8px; color:#28a745;"><b>SUCCESS</b></td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Duration</td>
                              <td style="padding:8px;">${currentBuild.durationString}</td>
                          </tr>
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Branch</td>
                              <td style="padding:8px;">${env.GIT_BRANCH ?: 'main'}</td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Triggered By</td>
                              <td style="padding:8px;">${currentBuild.getBuildCauses()[0]?.shortDescription ?: 'Unknown'}</td>
                          </tr>
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Docker Image</td>
                              <td style="padding:8px;">fariyajs/go-app:${env.BUILD_NUMBER}</td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Build URL</td>
                              <td style="padding:8px;"><a href="${env.BUILD_URL}">${env.BUILD_URL}</a></td>
                          </tr>
                      </table>
                      

                      <p style="color:#555;">The Docker image has been built and pushed to Docker Hub successfully.</p>
                      <p style="color:#888; font-size:12px;">This is an automated notification from Jenkins.</p>
                  </body>
                  </html>
              """
          )
      }

      failure {
          emailext(
              to: 'zubairmd797@gmail.com',
              subject: "❌ BUILD FAILED - ${env.JOB_NAME} #${env.BUILD_NUMBER}",
              mimeType: 'text/html',
              attachLog: true,
              body: """
                  <html>
                  <body style="font-family: Arial, sans-serif; padding: 20px;">
                      <h2 style="color: #dc3545;">❌ Build Failed</h2>
                      <hr/>
                      <table style="width:100%; border-collapse: collapse;">
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Project</td>
                              <td style="padding:8px;">${env.JOB_NAME}</td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Build Number</td>
                              <td style="padding:8px;">#${env.BUILD_NUMBER}</td>
                          </tr>
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Status</td>
                              <td style="padding:8px; color:#dc3545;"><b>FAILED</b></td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Duration</td>
                              <td style="padding:8px;">${currentBuild.durationString}</td>
                          </tr>
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Branch</td>
                              <td style="padding:8px;">${env.GIT_BRANCH ?: 'main'}</td>
                          </tr>
                          <tr>
                              <td style="padding:8px; font-weight:bold;">Triggered By</td>
                              <td style="padding:8px;">${currentBuild.getBuildCauses()[0]?.shortDescription ?: 'Unknown'}</td>
                          </tr>
                          <tr style="background:#f2f2f2;">
                              <td style="padding:8px; font-weight:bold;">Build URL</td>
                              <td style="padding:8px;"><a href="${env.BUILD_URL}">${env.BUILD_URL}</a></td>
                          </tr>
                      </table>
                      

                      <p>👉 <a href="${env.BUILD_URL}console">Click here for full console output</a></p>
                      <p style="color:#555;">📎 Full build log is attached to this email.</p>
                      <p style="color:#888; font-size:12px;">This is an automated notification from Jenkins.</p>
                  </body>
                  </html>
              """
          )
      }

        always {
            echo "Pipeline finished with status: ${currentBuild.currentResult}"
        }
    }
}
