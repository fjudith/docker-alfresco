// 
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
                    COMMIT = "${GIT_COMMIT.substring(0,8)}"

                    if ("${BRANCH_NAME}" == "master"){
                        TAG = "latest"
                        ALF_OOO = "libreoffice"
                        ALF_REPO = "repository"
                        ALF_SHA = "share"
                        ALF_SEARCH = "search"
                    }
                    else {
                        TAG = "${BRANCH_NAME}"
                        ALF_OOO = "${BRANCH_NAME}-libreoffice"
                        ALF_REPO = "${BRANCH_NAME}-repository"
                        ALF_SHA = "${BRANCH_NAME}-share"
                        ALF_SEARCH = "${BRANCH_NAME}-search"                        
                    }
                }
                sh 'printenv'
            }
        }
        stage ('Build Alfresco add-ons'){
            parallel {
                stage ("Build Manual Manager add-on"){
                    agent { label 'maven' }
                    steps {
                        git url: 'git://github.com/loftuxab/manual-manager.git',
                            branch: 'master'
                        sh 'tree -sh'
                        sh 'ant package'
                        stash name: 'manual-manager',
                            includes: 'build/dist/**'
                    }
                }
                stage ("Build Markdown Preview add-on"){
                    agent { label 'maven' }
                    steps {
                        // https://bitbucket.org/parashift/alfresco-amp-plugin
                        git url: 'git://github.com/yeyan/alfresco-amp-plugin.git',
                            branch: 'master'
                        sh 'tree -sh'
                        sh 'gradle publish'
                        git url: 'git://github.com/fjudith/md-preview.git',
                            branch: '1.7.2'
                        sh 'tree -sh'
                        sh 'cd share/ && gradle amp && cd ../'
                        sh 'cd repo/ && gradle amp && cd ../'
                        stash name: 'md-preview',
                            includes: 'repo/build/amp/**,share/build/amp/**'
                    }
                }
            }
        }
        stage ('Alfresco Web & Application server') {
            agent { label 'docker'}
            steps {
                sh "docker build -f slim/Dockerfile -t ${REPO}:${COMMIT} slim/"
            }
            post {
                success {
                    echo 'Tag and Push to private registry'
                    sh "docker tag ${REPO}:${COMMIT} ${PRIVATE_REPO}:${TAG}"
                }
            }
        }
        stage ('Docker build Micro-Service') {
            parallel {
                stage ('Alfresco LibreOffice'){
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f libreoffice/Dockerfile -t ${REPO}:${COMMIT}-libreoffice libreoffice/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-libreoffice ${PRIVATE_REPO}:${ALF_OOO}"
                        }
                    }
                }
                stage ('Alfresco Search Services') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f search/Dockerfile -t ${REPO}:${COMMIT}-search search/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-search ${PRIVATE_REPO}:${ALF_SEARCH}"
                        }
                    }
                }
                stage ('Alfresco Content Repository Services') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f repository/Dockerfile -t ${REPO}:${COMMIT}-repository repository/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-repository ${PRIVATE_REPO}:${ALF_REPO}"
                        }
                    }
                }
                stage ('Alfresco Share') {
                    agent { label 'docker'}
                    steps {
                        sh "docker build -f share/Dockerfile -t ${REPO}:${COMMIT}-share share/"
                    }
                    post {
                        success {
                            echo 'Tag for private registry'
                            sh "docker tag ${REPO}:${COMMIT}-share ${PRIVATE_REPO}:${ALF_SHA}"
                        }
                    }
                }
            }
        }
        stage ('Run'){
            parallel {
                stage ('Slim'){
                    agent { label 'docker' }
                    steps {
                        // Create Network
                        sh "docker network create alfresco-slim-${BUILD_NUMBER}"
                        // Start database
                        sh "docker run -d --name 'mysql-${BUILD_NUMBER}' -e MYSQL_ROOT_PASSWORD=alfresco -e MYSQL_USER=alfresco -e MYSQL_PASSWORD=alfresco -e MYSQL_DATABASE=alfresco --network alfresco-slim-${BUILD_NUMBER} amd64/mysql:5.6"
                        sleep 15
                        // Start application
                        sh "docker run -d --name 'alfresco-${BUILD_NUMBER}' --link mysql-${BUILD_NUMBER}:mysql --network alfresco-slim-${BUILD_NUMBER} ${REPO}:${COMMIT}"
                        // Get container ID
                        script{
                            DOCKER_ALF    = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}", returnStdout: true).trim()
                        }
                    }
                }
                stage ('Micro-Services'){
                    agent { label 'docker'}
                    steps {
                        // Create Network
                        sh "docker network create alfresco-micro-${BUILD_NUMBER}"
                        // Start database
                        sh "docker run -d --name 'postgres-${BUILD_NUMBER}' -e POSTGRES_USER=alfresco -e POSTGRES_PASSWORD=alfresco -e POSTGRES_DB=alfresco --network alfresco-micro-${BUILD_NUMBER} amd64/postgres:9.4"
                        sleep 15
                        //Start application micro-services
                        sh "docker run -d --name 'libreoffice-${BUILD_NUMBER}' --network alfresco-micro-${BUILD_NUMBER} ${REPO}:${COMMIT}-libreoffice"
                        sh "docker run -d --name 'search-${BUILD_NUMBER}' --network alfresco-micro-${BUILD_NUMBER} ${REPO}:${COMMIT}-search"
                        sh "docker run -d --name 'repository-${BUILD_NUMBER}' --link postgres-${BUILD_NUMBER}:postgres --link libreoffice-${BUILD_NUMBER}:libreoffice --link search-${BUILD_NUMBER}:search --network alfresco-micro-${BUILD_NUMBER} ${REPO}:${COMMIT}-repository"
                        sh "docker run -d --name share-${BUILD_NUMBER} --link repository-${BUILD_NUMBER}:repository --network alfresco-micro-${BUILD_NUMBER} ${REPO}:${COMMIT}-share"
                        // Get container IDs
                        script {
                            DOCKER_OOO    = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-libreoffice", returnStdout: true).trim()
                            DOCKER_SEARCH = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-search", returnStdout: true).trim()
                            DOCKER_REPO   = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-repository", returnStdout: true).trim()
                            DOCKER_SHA    = sh(script: "docker ps -qa -f ancestor=${REPO}:${COMMIT}-share", returnStdout: true).trim()
                        }
                    }
                }
            }
        }
        stage ('Test'){
            parallel {
                stage ('Slim'){
                    agent { label 'docker' }
                    steps {
                        sleep 180 
                        // internal
                        sh "docker exec 'alfresco-${BUILD_NUMBER}' /bin/bash -c 'curl -i -X GET -u admin:admin http://localhost:8080/alfresco/service/api/audit/control'"
                        // External
                        sh "docker run --rm --network alfresco-slim-${BUILD_NUMBER} blitznote/debootstrap-amd64:17.04 bash -c 'curl -i -X GET -u admin:admin http://${DOCKER_ALF}:8080/share/page'"
                    }
                    post {
                        always {
                            echo 'Remove slim stack'
                            sh "docker rm -f mysql-${BUILD_NUMBER}"
                            sh "docker rm -f alfresco-${BUILD_NUMBER}"
                            sh "docker network rm alfresco-slim-${BUILD_NUMBER}"
                        }
                        success {
                            sh "docker login -u ${DOCKER_PRIVATE_USR} -p ${DOCKER_PRIVATE_PSW} ${PRIVATE_REGISTRY}"
                            sh "docker push ${PRIVATE_REPO}:${TAG}"
                        }
                    }
                }
                stage ('Micro-Services'){
                    agent { label 'docker'}
                    steps {
                        sleep 180
                        // Internal
                        sh "docker exec libreoffice-${BUILD_NUMBER} /bin/bash -c 'nc -zv -w 5 localhost 8100'"
                        sh "docker exec search-${BUILD_NUMBER} /bin/bash -c 'curl -i -X GET http://localhost:8983/solr/admin/cores'"
                        sh "docker exec repository-${BUILD_NUMBER} /bin/bash -c 'curl -i -X GET -u admin:admin http://localhost:8080/alfresco/service/api/audit/control'"
                        sh "docker exec share-${BUILD_NUMBER} /bin/bash -c 'curl -i -X GET -u admin:admin http://localhost:8080/share/page'"
                        // Cross Container
                        sh "docker exec ${DOCKER_REPO} /bin/bash -c 'nc -zv -w 5 ${DOCKER_OOO} 8100'"
                        sh "docker exec ${DOCKER_REPO} /bin/bash -c 'curl -i -X GET http://${DOCKER_SEARCH}:8983/solr/admin/cores'"
                        sh "docker exec ${DOCKER_SEARCH} /bin/bash -c 'curl -i -X GET -u admin:admin http://${DOCKER_REPO}:8080/alfresco/service/api/audit/control'"
                        sh "docker exec ${DOCKER_SHA} /bin/bash -c 'curl -i -X GET -u admin:admin http://${DOCKER_SHA}:8080/alfresco/service/api/audit/control'"
                        // External
                        sh "docker run --rm --network alfresco-micro-${BUILD_NUMBER} blitznote/debootstrap-amd64:17.04 bash -c 'curl -i -X GET -u admin:admin http://${DOCKER_SHA}:8080/share/page'"
                    }
                    post {
                        always {
                            echo 'Remove micro-services stack'

                            sh "docker rm -f postgres-${BUILD_NUMBER}"
                            sh "docker rm -f share-${BUILD_NUMBER}"
                            sh "docker rm -f repository-${BUILD_NUMBER}"
                            sh "docker rm -f search-${BUILD_NUMBER}"
                            sh "docker rm -f libreoffice-${BUILD_NUMBER}"
                            sh "docker network rm alfresco-micro-${BUILD_NUMBER}"
                        }
                        success {
                            sh "docker login -u ${DOCKER_PRIVATE_USR} -p ${DOCKER_PRIVATE_PSW} ${PRIVATE_REGISTRY}"
                            sh "docker push ${PRIVATE_REPO}:${ALF_OOO}"
                            sh "docker push ${PRIVATE_REPO}:${ALF_SEARCH}"
                            sh "docker push ${PRIVATE_REPO}:${ALF_REPO}"
                            sh "docker push ${PRIVATE_REPO}:${ALF_SHA}"
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

        }
        unstable {
            echo 'Only run if the current Pipeline has an "unstable" status, usually caused by test failures, code violations, etc. Typically denoted in the web UI with a yellow indication.'
        }
        aborted {
            echo 'Only run if the current Pipeline has an "aborted" status, usually due to the Pipeline being manually aborted. Typically denoted in the web UI with a gray indication.'
        }
    }
}