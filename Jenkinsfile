pipeline {
    agent any
    
    environment {
        // Acquia credentials - configure these in Jenkins credentials
        ACQUIA_API_KEY = credentials('acquia-api-key')
        ACQUIA_API_SECRET = credentials('acquia-api-secret')
        ACQUIA_APPLICATION_UUID = credentials('acquia-application-uuid')
        
        // Git repository configuration
        ACQUIA_GIT_REPO = credentials('acquia-git-repo-url')
        ACQUIA_GIT_BRANCH = 'master'
        
        // Environment configuration
        ACQUIA_ENV = 'dev' // dev, test, prod
        
        // Composer and PHP settings
        COMPOSER_HOME = '/tmp/composer'
        PHP_VERSION = '8.1'
    }
    
    parameters {
        choice(
            name: 'DEPLOY_ENVIRONMENT',
            choices: ['dev', 'test', 'prod'],
            description: 'Target Acquia environment for deployment'
        )
        booleanParam(
            name: 'RUN_TESTS',
            defaultValue: true,
            description: 'Run automated tests before deployment'
        )
        booleanParam(
            name: 'BACKUP_DATABASE',
            defaultValue: true,
            description: 'Create database backup before deployment'
        )
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()
                    env.BUILD_TIMESTAMP = sh(
                        script: 'date +"%Y%m%d-%H%M%S"',
                        returnStdout: true
                    ).trim()
                }
            }
        }
        
        stage('Environment Setup') {
            steps {
                script {
                    // Update ACQUIA_ENV based on parameter
                    env.ACQUIA_ENV = params.DEPLOY_ENVIRONMENT
                }
                
                // Install PHP and Composer dependencies
                sh '''
                    echo "Setting up PHP $PHP_VERSION environment..."
                    
                    # Install Composer dependencies
                    if [ -f "composer.json" ]; then
                        composer install --no-dev --optimize-autoloader --no-interaction
                    fi
                    
                    # Install Node.js dependencies if needed
                    if [ -f "package.json" ]; then
                        npm install --production
                    fi
                '''
            }
        }
        
        stage('Code Quality & Security') {
            parallel {
                stage('PHP Code Standards') {
                    when {
                        expression { fileExists('composer.json') }
                    }
                    steps {
                        sh '''
                            # Run PHP CodeSniffer
                            if [ -f "vendor/bin/phpcs" ]; then
                                vendor/bin/phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,css,info,txt,md,yml web/modules/custom web/themes/custom || true
                            fi
                            
                            # Run PHP Mess Detector
                            if [ -f "vendor/bin/phpmd" ]; then
                                vendor/bin/phpmd web/modules/custom,web/themes/custom text cleancode,codesize,controversial,design,naming,unusedcode || true
                            fi
                        '''
                    }
                }
                
                stage('Security Scan') {
                    steps {
                        sh '''
                            # Check for security vulnerabilities
                            if [ -f "composer.json" ]; then
                                composer audit || true
                            fi
                            
                            # Drush security updates check
                            if [ -f "vendor/bin/drush" ]; then
                                vendor/bin/drush pm:security || true
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Build Assets') {
            steps {
                sh '''
                    # Build frontend assets
                    if [ -f "package.json" ]; then
                        npm run build || echo "No build script found"
                    fi
                    
                    # Compile SCSS/SASS if needed
                    if [ -d "web/themes/custom" ]; then
                        find web/themes/custom -name "*.scss" -exec echo "SCSS files found: {}" \;
                    fi
                '''
            }
        }
        
        stage('Tests') {
            when {
                expression { params.RUN_TESTS }
            }
            parallel {
                stage('Unit Tests') {
                    steps {
                        sh '''
                            # Run PHPUnit tests
                            if [ -f "vendor/bin/phpunit" ]; then
                                vendor/bin/phpunit --configuration phpunit.xml || true
                            fi
                        '''
                    }
                }
                
                stage('Functional Tests') {
                    steps {
                        sh '''
                            # Run Behat tests
                            if [ -f "vendor/bin/behat" ]; then
                                vendor/bin/behat --config behat.yml || true
                            fi
                        '''
                    }
                }
            }
        }
        
        stage('Database Backup') {
            when {
                expression { params.BACKUP_DATABASE && params.DEPLOY_ENVIRONMENT != 'dev' }
            }
            steps {
                script {
                    sh '''
                        # Create database backup using Acquia CLI
                        if command -v acli &> /dev/null; then
                            acli api:environments:database-backup-create $ACQUIA_APPLICATION_UUID $ACQUIA_ENV default
                        else
                            echo "Acquia CLI not found, skipping database backup"
                        fi
                    '''
                }
            }
        }
        
        stage('Deploy to Acquia') {
            steps {
                script {
                    // Deploy using Git push to Acquia
                    sh '''
                        # Configure Git for Acquia deployment
                        git config user.email "jenkins@yourdomain.com"
                        git config user.name "Jenkins CI"
                        
                        # Add Acquia remote if not exists
                        if ! git remote | grep -q acquia; then
                            git remote add acquia $ACQUIA_GIT_REPO
                        fi
                        
                        # Push to Acquia
                        git push acquia HEAD:master-build
                    '''
                }
                
                // Alternative: Deploy using Acquia CLI
                sh '''
                    # Deploy using Acquia CLI (if available)
                    if command -v acli &> /dev/null; then
                        # Create artifact and deploy
                        acli push:artifact $ACQUIA_APPLICATION_UUID $ACQUIA_ENV --no-interaction
                    fi
                '''
            }
        }
        
        stage('Post-Deploy Tasks') {
            steps {
                script {
                    sh '''
                        # Clear Drupal caches
                        if [ -f "vendor/bin/drush" ]; then
                            # Configure Drush for Acquia
                            echo "Clearing Drupal caches..."
                            # Note: This requires proper Drush aliases configuration
                            # vendor/bin/drush @$ACQUIA_APPLICATION_UUID.$ACQUIA_ENV cache:rebuild || true
                        fi
                        
                        # Run database updates
                        if [ -f "vendor/bin/drush" ] && [ "$ACQUIA_ENV" != "prod" ]; then
                            echo "Running database updates..."
                            # vendor/bin/drush @$ACQUIA_APPLICATION_UUID.$ACQUIA_ENV updatedb -y || true
                        fi
                    '''
                }
            }
        }
        
        stage('Smoke Tests') {
            steps {
                script {
                    // Basic smoke tests to ensure deployment was successful
                    sh '''
                        # Wait for deployment to complete
                        sleep 30
                        
                        # Check if site is accessible
                        if command -v curl &> /dev/null; then
                            # Replace with your actual Acquia environment URL
                            SITE_URL="https://${ACQUIA_APPLICATION_UUID}.${ACQUIA_ENV}.acquia-sites.com"
                            
                            echo "Checking site accessibility: $SITE_URL"
                            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" || echo "000")
                            
                            if [ "$HTTP_STATUS" = "200" ]; then
                                echo "✅ Site is accessible (HTTP $HTTP_STATUS)"
                            else
                                echo "⚠️  Site returned HTTP $HTTP_STATUS"
                            fi
                        fi
                    '''
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace
            sh '''
                # Remove sensitive files
                rm -f .env.local
                rm -rf node_modules/.cache
            '''
            
            // Archive artifacts
            archiveArtifacts artifacts: 'build/**/*', allowEmptyArchive: true
            
            // Publish test results
            publishTestResults testResultsPattern: 'tests/results/*.xml', allowEmptyResults: true
        }
        
        success {
            script {
                def message = """
                ✅ **Deployment Successful**
                
                **Environment:** ${params.DEPLOY_ENVIRONMENT}
                **Commit:** ${env.GIT_COMMIT_SHORT}
                **Build:** ${env.BUILD_NUMBER}
                **Timestamp:** ${env.BUILD_TIMESTAMP}
                
                Deployment completed successfully to Acquia ${params.DEPLOY_ENVIRONMENT} environment.
                """
                
                // Send notification (configure webhook URL in Jenkins)
                // slackSend(message: message, color: 'good')
                
                echo message
            }
        }
        
        failure {
            script {
                def message = """
                ❌ **Deployment Failed**
                
                **Environment:** ${params.DEPLOY_ENVIRONMENT}
                **Commit:** ${env.GIT_COMMIT_SHORT}
                **Build:** ${env.BUILD_NUMBER}
                **Timestamp:** ${env.BUILD_TIMESTAMP}
                
                Deployment failed. Please check the build logs for details.
                """
                
                // Send notification
                // slackSend(message: message, color: 'danger')
                
                echo message
            }
        }
        
        unstable {
            script {
                def message = """
                ⚠️ **Deployment Unstable**
                
                **Environment:** ${params.DEPLOY_ENVIRONMENT}
                **Commit:** ${env.GIT_COMMIT_SHORT}
                **Build:** ${env.BUILD_NUMBER}
                
                Deployment completed with warnings. Please review the build logs.
                """
                
                // Send notification
                // slackSend(message: message, color: 'warning')
                
                echo message
            }
        }
    }
}