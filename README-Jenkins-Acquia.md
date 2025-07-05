# Jenkins Pipeline for Acquia Deployment

This Jenkins pipeline automates the deployment of web applications (primarily Drupal) to Acquia Cloud Platform.

## Features

- **Multi-environment deployment** (dev, test, prod)
- **Code quality checks** (PHP CodeSniffer, PHP Mess Detector)
- **Security scanning** (Composer audit, Drush security checks)
- **Automated testing** (PHPUnit, Behat)
- **Database backup** before deployment
- **Asset building** (npm, SCSS/SASS compilation)
- **Post-deployment tasks** (cache clearing, database updates)
- **Smoke testing** to verify deployment success
- **Notifications** (Slack integration ready)

## Prerequisites

### Jenkins Setup
1. Jenkins with Pipeline plugin installed
2. PHP 8.1+ installed on Jenkins agent
3. Composer installed globally
4. Node.js/npm installed (if frontend assets need building)
5. Git configured with SSH keys

### Acquia Setup
1. Acquia Cloud account with application created
2. Acquia CLI installed (optional but recommended)
3. SSH keys configured for Git deployment
4. Drush aliases configured (for post-deployment tasks)

## Required Jenkins Credentials

Configure these credentials in Jenkins (Manage Jenkins → Credentials):

| Credential ID | Type | Description |
|---------------|------|-------------|
| `acquia-api-key` | Secret text | Acquia API key |
| `acquia-api-secret` | Secret text | Acquia API secret |
| `acquia-application-uuid` | Secret text | Acquia application UUID |
| `acquia-git-repo-url` | Secret text | Acquia Git repository URL |

### Finding Your Acquia Credentials

1. **API Key & Secret**: 
   - Go to https://cloud.acquia.com/a/profile/tokens
   - Create a new API token

2. **Application UUID**:
   - Go to your Acquia Cloud application
   - Find the UUID in the URL: `https://cloud.acquia.com/a/applications/[UUID]`

3. **Git Repository URL**:
   - In your Acquia application, go to "Application Info"
   - Copy the Git repository URL (format: `sitename@svn-xxxxx.prod.hosting.acquia.com:sitename.git`)

## Pipeline Configuration

### Environment Variables
The pipeline uses these environment variables that you can customize:

```groovy
environment {
    PHP_VERSION = '8.1'          // PHP version to use
    ACQUIA_GIT_BRANCH = 'master' // Default branch for deployment
    COMPOSER_HOME = '/tmp/composer'
}
```

### Parameters
The pipeline accepts these parameters:

- **DEPLOY_ENVIRONMENT**: Target environment (dev/test/prod)
- **RUN_TESTS**: Whether to run automated tests
- **BACKUP_DATABASE**: Whether to backup database before deployment

## Pipeline Stages

### 1. Checkout
- Checks out source code from SCM
- Sets up build metadata (commit hash, timestamp)

### 2. Environment Setup
- Configures PHP environment
- Installs Composer dependencies
- Installs Node.js dependencies (if applicable)

### 3. Code Quality & Security
- **PHP Code Standards**: Runs PHP CodeSniffer with Drupal standards
- **Security Scan**: Checks for security vulnerabilities

### 4. Build Assets
- Builds frontend assets using npm
- Compiles SCSS/SASS files

### 5. Tests
- **Unit Tests**: Runs PHPUnit tests
- **Functional Tests**: Runs Behat tests

### 6. Database Backup
- Creates database backup (skipped for dev environment)
- Uses Acquia CLI or API

### 7. Deploy to Acquia
- Deploys code using Git push to Acquia
- Alternative: Uses Acquia CLI for artifact deployment

### 8. Post-Deploy Tasks
- Clears Drupal caches
- Runs database updates (non-prod environments)

### 9. Smoke Tests
- Verifies site accessibility
- Basic health checks

## Usage

### Running the Pipeline

1. **Manual Trigger**:
   - Go to your Jenkins job
   - Click "Build with Parameters"
   - Select desired environment and options
   - Click "Build"

2. **Automated Trigger**:
   - Configure webhooks in your Git repository
   - Pipeline will trigger on push to specified branches

### Deployment Flow

```
dev → test → prod
```

1. **Development**: Automatic deployment on push to `develop` branch
2. **Testing**: Manual deployment after dev testing
3. **Production**: Manual deployment after test approval

## Customization

### Project-Specific Modifications

1. **Update Git Configuration**:
   ```groovy
   git config user.email "jenkins@yourdomain.com"
   git config user.name "Jenkins CI"
   ```

2. **Modify Site URL Pattern**:
   ```groovy
   SITE_URL="https://${ACQUIA_APPLICATION_UUID}.${ACQUIA_ENV}.acquia-sites.com"
   ```

3. **Add Custom Build Steps**:
   ```groovy
   stage('Custom Build') {
       steps {
           sh 'your-custom-build-command'
       }
   }
   ```

### Adding Notifications

Uncomment and configure Slack notifications:

```groovy
// Install Slack Notification plugin
slackSend(message: message, color: 'good', channel: '#deployments')
```

## Troubleshooting

### Common Issues

1. **Composer Install Fails**:
   - Check PHP version compatibility
   - Verify Composer is installed globally
   - Check memory limits

2. **Git Push Fails**:
   - Verify SSH keys are configured correctly
   - Check Git repository URL format
   - Ensure proper permissions

3. **Acquia CLI Not Found**:
   - Install Acquia CLI on Jenkins agent
   - Alternative: Use Git-based deployment only

4. **Database Backup Fails**:
   - Check Acquia API credentials
   - Verify application UUID
   - Ensure proper permissions

### Debug Mode

Enable debug output by adding:

```groovy
environment {
    DEBUG = 'true'
}
```

## Best Practices

1. **Environment Isolation**:
   - Use separate Jenkins jobs for each environment
   - Implement proper approval gates for production

2. **Testing Strategy**:
   - Always run tests before deployment
   - Use feature flags for gradual rollouts

3. **Monitoring**:
   - Set up monitoring for deployed applications
   - Configure alerts for deployment failures

4. **Rollback Plan**:
   - Keep database backups
   - Maintain ability to rollback deployments

## Security Considerations

1. **Credentials Management**:
   - Store all sensitive data in Jenkins credentials
   - Use principle of least privilege

2. **Branch Protection**:
   - Protect main branches from direct pushes
   - Require PR reviews for production deployments

3. **Audit Trail**:
   - Log all deployment activities
   - Maintain deployment history

## Support

For issues and questions:
1. Check Jenkins build logs
2. Review Acquia Cloud logs
3. Consult Acquia documentation
4. Contact your DevOps team

---

**Note**: This pipeline is designed for typical Drupal applications on Acquia. Customize the stages and commands based on your specific application requirements.