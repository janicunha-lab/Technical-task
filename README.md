# Technical-task

Business Central AL extension project with automated CI/CD pipelines using AL-Go for GitHub.

## Project Structure

- **TechnicalTask**: Main application extension
- **TechnicalTask_Tests**: Test application for the main extension

## AL-Go CI/CD Setup

This repository uses [AL-Go for GitHub](https://github.com/microsoft/AL-Go-PTE) to automate builds, tests, and deployments.

### Workflows

#### CI Workflow (`.github/workflows/CI.yml`)
- Runs on pushes and pull requests to `main` and `develop` branches
- Performs:
  - Code compilation
  - Code analysis (CodeCop, AppSourceCop, UICop)
  - Test execution
  - App validation

#### CI/CD Workflow (`.github/workflows/CI-CD.yml`)
- Runs on pushes to `main` branch
- Can be manually triggered for deployments
- Performs all CI checks plus:
  - App packaging
  - Deployment to specified environments

### Configuration

The AL-Go configuration is stored in `.AL-Go/settings.json`:
- **Type**: PTE (Per-Tenant Extension)
- **App Folders**: `TechnicalTask`
- **Test Folders**: `TechnicalTask_Tests`
- **Code Analysis**: Enabled (CodeCop, AppSourceCop, UICop)
- **AppSourceCop Mandatory Prefix**: `TT`

### Getting Started

1. **Push to GitHub**: The workflows will automatically run on push/PR
2. **Manual Trigger**: Go to Actions tab in GitHub to manually trigger workflows
3. **Monitor Results**: Check the Actions tab for build and test results

### Requirements

- GitHub repository with Actions enabled
- AL-Go Actions will automatically handle:
  - Business Central container setup
  - App compilation
  - Test execution
  - Code analysis

### Secrets (Optional)

If you need to configure additional features, you may need to set up GitHub Secrets:
- `LicenseFileUrlSecretName`: For license file URL
- `InsiderSasTokenSecretName`: For insider builds
- Certificate secrets for code signing (if required)

For more information, visit the [AL-Go for GitHub documentation](https://github.com/microsoft/AL-Go-PTE).