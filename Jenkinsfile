// https://github.com/jenkinsci/pipeline-model-definition-plugin/wiki/Syntax-Reference
// https://jenkins.io/doc/book/pipeline/syntax/#parallel
// https://jenkins.io/doc/book/pipeline/syntax/#post
pipeline {
    agent any
    environment {
        REPO = 'fjudith/alfresco'
        PRIVATE_REPO = "${PRIVATE_REGISTRY}/${REPO}"
        DOCKER_PRIVATE = credentials('docker-private-registry')
    }
    stages {
        stage ('Checkout') {
            steps {
                script {
                    if ("${BRANCH_NAME}" == "master"){
                        TAG = "latest"
                    }
                    else {
                        TAG = "${BRANCH_NAME}"
                    }
                }
                sh 'printenv'
            }
        }
        stage ('Build Alfresco add-ons'){
            stage ("Build Manual Manager add-on"){
                parallel {
                    agent { label 'maven' }
                    steps {
                        git url: 'git://github.com/loftuxab/manual-manager.git',
                            branch: 'master'
                        sh 'tree -sh'
                        sh 'ant package'
                        stash name: 'manual-manager',
                            includes: 'build/**'
                    }
                }
            }
        }
        stage ('Docker build'){
            parallel {
                stage ('Alfresco Web & Application server') {
                    agent { label 'docker'}
                    steps {
                        unstash  'manual-manager'
                        sh 'tree -sh'
                        sh "docker build -f Dockerfile -t ${REPO}:${GIT_COMMIT} ."
                        sh "docker run -d --name 'alfresco-${BUILD_NUMBER}' -p 55080:8080 -p 55443:8443 ${REPO}:${GIT_COMMIT}"
                        sh "docker ps -a"
                        sleep 300
                        sh "docker logs alfresco-${BUILD_NUMBER}"
                        sh 'docker run --rm --link alfresco-${BUILD_NUMBER}:alfresco blitznote/debootstrap-amd64:17.04 bash -c "curl -i -X GET -u admin:admin http://alfresco:8080/alfresco/service/api/audit/control"'
                    }
                    post {
                        always {
                           sh 'docker rm -f alfresco-${BUILD_NUMBER}'
                        }
                        success {
                            echo 'Tag and Push to private registry'
                            sh "docker tag ${REPO}:${GIT_COMMIT} ${REPO}:${TAG}"
                            sh "docker tag ${REPO}:${GIT_COMMIT} ${PRIVATE_REPO}:${TAG}"
                            sh "docker login -u ${DOCKER_PRIVATE_USR} -p ${DOCKER_PRIVATE_PSW} ${PRIVATE_REGISTRY}"
                            sh "docker push ${PRIVATE_REPO}"
                        }
                    }
                }
            }
        }
    }
    post {
        always {
            echo 'Run regardless of the completion status of the Pipeline run.'
        }
        changed {
            echo 'Only run if the current Pipeline run has a different status from the previously completed Pipeline.'
        }
        success {
            echo 'Only run if the current Pipeline has a "success" status, typically denoted in the web UI with a blue or green indication.'
            archive "**/*"
        }
        unstable {
            echo 'Only run if the current Pipeline has an "unstable" status, usually caused by test failures, code violations, etc. Typically denoted in the web UI with a yellow indication.'
        }
        aborted {
            echo 'Only run if the current Pipeline has an "aborted" status, usually due to the Pipeline being manually aborted. Typically denoted in the web UI with a gray indication.'
        }
    }
}