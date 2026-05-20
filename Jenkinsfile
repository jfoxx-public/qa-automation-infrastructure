pipeline {
    agent any

    parameters {
        choice(
            name: 'BRANCH',
            choices: ['main', 'automation-specs'],
            description: 'Git branch to test'
        )

        choice(
            name: 'ENV',
            choices: ['staging', 'dev'],
            description: 'Target environment'
        )
    }

    environment {
        BASE_URL = "${params.ENV == 'staging' ? 'http://staging-web:3000' : 'http://dev-web:3001'}"
    }

    stages {

        stage('Checkout') {
            steps {
                deleteDir()
                git branch: "${params.BRANCH}",
                    url: 'https://github.com/jfoxx-public/playwright-web-test-framework-demo.git'
            }
        }

        stage('Run Playwright Tests') {
            steps {
                script {
                    docker.image('mcr.microsoft.com/playwright:v1.59.1-noble')
                        .inside('--ipc=host --network qa-automation-network') {

                        sh '''
                            echo "Environment: $ENV"
                            echo "Base URL: $BASE_URL"
                            node -v
                            npm -v
                            npm ci
                            BASE_URL=$BASE_URL npx playwright test
                        '''
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'playwright-report/**', fingerprint: true

            publishHTML(target: [
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'playwright-report',
                reportFiles: 'index.html',
                reportName: 'Playwright Report'
            ])

            cleanWs()
        }
    }
}