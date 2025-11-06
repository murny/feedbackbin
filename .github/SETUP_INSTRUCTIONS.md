# GitHub Actions CI/CD Setup Instructions

This guide will help you set up the new split workflow architecture for FeedbackBin.

## Overview

The workflow has been split into two separate jobs:

1. **publish-image.yml** - Builds and publishes Docker images to GitHub Container Registry
2. **deploy.yml** - Deploys the application to production using Kamal

## Changes Summary

### What Changed
- ✅ Split single workflow into two separate workflows
- ✅ Migrated from Docker Hub to GitHub Container Registry (GHCR)
- ✅ Added build caching for faster builds
- ✅ Added build attestations for supply chain security
- ✅ Smart image tagging (branch names, SHAs, latest)
- ✅ PR builds without pushing (validation only)
- ✅ GitHub Environment integration for deployment protection
- ✅ Manual deployment triggers via `workflow_dispatch`

### What Was Removed
- ❌ Docker Hub credentials (`KAMAL_REGISTRY_PASSWORD` for Docker Hub)
- ❌ Building and deploying in single workflow
- ❌ Docker Buildx setup in deployment workflow (not needed)

### What Stays the Same
- ✅ `RAILS_MASTER_KEY` secret (still required)
- ✅ `SSH_PRIVATE_KEY` secret (still required)
- ✅ Ruby setup and SSH agent configuration
- ✅ Kamal deployment process

## Step 1: GitHub Repository Secrets

### Secrets to Keep
These secrets should already exist. Verify they are present:

1. **RAILS_MASTER_KEY**
   - Location: Settings → Secrets and variables → Actions → Repository secrets
   - Purpose: Decrypts Rails credentials
   - Value: Your Rails master key from `config/master.key`

2. **SSH_PRIVATE_KEY**
   - Location: Settings → Secrets and variables → Actions → Repository secrets
   - Purpose: SSH access to deployment servers
   - Value: Your private SSH key for server access

### Secrets to Remove (Optional Cleanup)
If you have a Docker Hub-specific `KAMAL_REGISTRY_PASSWORD` secret:
- You can safely delete it from repository secrets
- The deployment workflow now uses `GITHUB_TOKEN` which is automatically provided

### Note on GITHUB_TOKEN
- `GITHUB_TOKEN` is automatically provided by GitHub Actions
- No setup required - it's available in all workflows
- The deployment workflow uses it for GHCR authentication

## Step 2: Create GitHub Environment

GitHub Environments enable deployment protection rules and better visibility.

### Create the Production Environment

1. Go to your repository on GitHub
2. Navigate to: **Settings → Environments**
3. Click **New environment**
4. Name it: `production`
5. Click **Configure environment**

### Optional: Add Deployment Protection Rules

You can add protection rules for extra safety:

#### Option A: Required Reviewers
- Click **Add reviewer**
- Select team members who must approve deployments
- Deployments will pause and wait for approval

#### Option B: Wait Timer
- Set a delay before deployment starts
- Useful for giving time to cancel accidental deployments
- Example: 5 minutes

#### Option C: Deployment Branches
- Already configured to only allow `main` branch
- The workflow includes: `if: github.ref == 'refs/heads/main'`

### Environment Variables (Optional)
If you want to store production-specific environment variables:
- You can add them in the Environment configuration
- They will only be available during production deployments

## Step 3: Update Local Kamal Secrets (for Local Deploys)

If you deploy from your local machine using `bin/kamal deploy`, update your secrets:

1. Create or edit `.kamal/secrets`:
   ```bash
   # Required for Kamal deployments
   KAMAL_REGISTRY_PASSWORD=$(gh auth token)
   RAILS_MASTER_KEY=your_rails_master_key_here
   ```

2. Install GitHub CLI if not already installed:
   ```bash
   # macOS
   brew install gh

   # Ubuntu/Debian
   sudo apt install gh

   # Authenticate
   gh auth login
   ```

3. The `$(gh auth token)` command dynamically generates a token with the right permissions

**Alternative for `.kamal/secrets`:**
```bash
# Use a GitHub Personal Access Token instead
KAMAL_REGISTRY_PASSWORD=ghp_your_personal_access_token_here
RAILS_MASTER_KEY=your_rails_master_key_here
```

To create a Personal Access Token:
1. Go to: GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Name it: "Kamal GHCR Access"
4. Select scope: `read:packages` (to pull images)
5. Copy the token and add it to `.kamal/secrets`

## Step 4: Test the Workflows

### Test 1: Build Workflow (PR)
1. Create a test branch:
   ```bash
   git checkout -b test-new-workflows
   git push origin test-new-workflows
   ```

2. Create a Pull Request to `main`

3. Watch the **publish-image.yml** workflow:
   - Should trigger automatically
   - Will build the Docker image
   - Will NOT push to GHCR (PR builds are validation only)
   - Check: Actions tab → "Build and Publish Docker Image"

### Test 2: Build Workflow (Main Branch)
1. Merge your PR to `main` (or push directly):
   ```bash
   git checkout main
   git merge test-new-workflows
   git push origin main
   ```

2. Watch the **publish-image.yml** workflow:
   - Should trigger automatically
   - Will build AND push to GHCR
   - Check the image: https://github.com/murny/feedbackbin/pkgs/container/feedbackbin

### Test 3: Deployment Workflow
This will trigger automatically after pushing to `main`:

1. Navigate to: Actions tab → "Deploy to Production"

2. You'll see:
   - Waiting for approval (if you configured reviewers)
   - Or deployment proceeding directly
   - Environment shows as "production"

3. Monitor the Kamal deployment in real-time

### Test 4: Manual Deployment
Test the manual trigger:

1. Go to: Actions → Deploy to Production
2. Click "Run workflow"
3. Select branch: `main`
4. Click "Run workflow"

**Note:** Manual deployments from non-main branches will be skipped due to the branch protection check.

## Step 5: Verify Image Visibility

After your first successful build, verify the container image:

1. Go to: https://github.com/murny/feedbackbin/pkgs/container/feedbackbin

2. Make the package public (recommended):
   - Click on the package
   - Package settings → Change visibility
   - Make public (allows pulling without authentication)
   - This is optional but recommended for easier deployments

## Troubleshooting

### Issue: "Permission denied" when pushing to GHCR
**Solution:**
- Verify the workflow has `packages: write` permission (already configured)
- Check repository settings → Actions → General → Workflow permissions
- Ensure "Read and write permissions" is selected

### Issue: Kamal can't pull image from GHCR
**Solution:**
- Check that `GITHUB_TOKEN` is being passed correctly in deploy.yml
- Verify the image name is lowercase in config/deploy.yml
- Make the package public (easier) or configure imagePullSecrets

### Issue: Deployment workflow doesn't run
**Solution:**
- Verify the "production" environment exists
- Check that you're pushing to the `main` branch
- Look for the branch protection check: `if: github.ref == 'refs/heads/main'`

### Issue: Build is slow
**Solution:**
- The first build will be slower as it populates the cache
- Subsequent builds should be significantly faster due to `cache-from: type=gha`
- Check Actions → Build workflow → Build step for cache hit rates

### Issue: Want to build/deploy from a different branch
**Solution:**
- For testing, you can modify the branch in the workflow files
- Production deployments should only come from `main` for safety
- Use PR builds for validation on feature branches

## Architecture Benefits

### Before
- ❌ Single monolithic workflow doing everything
- ❌ Can't test builds without deploying
- ❌ Docker Hub costs and limitations
- ❌ No build attestations
- ❌ Limited caching strategy

### After
- ✅ Separated concerns: build vs deploy
- ✅ Validate Docker builds in PRs without pushing
- ✅ Free container hosting with GHCR
- ✅ Supply chain security with attestations
- ✅ Faster builds with GitHub Actions cache
- ✅ Smart tagging (branch, SHA, latest)
- ✅ Deployment protection via Environments
- ✅ Manual deployment capability
- ✅ Better visibility and debugging

## Next Steps

1. ✅ Complete the setup steps above
2. ✅ Test all three workflows (PR build, main build, deployment)
3. ✅ Configure deployment protection rules (optional but recommended)
4. ✅ Update any documentation referencing Docker Hub
5. ✅ Consider setting up branch protection rules on `main`
6. ✅ Monitor your first few deployments closely

## Additional Resources

- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [GitHub Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment)
- [Kamal Documentation](https://kamal-deploy.org/)
- [Docker Build Attestations](https://docs.docker.com/build/attestations/)

## Questions?

If you encounter issues:
1. Check the Actions tab for detailed logs
2. Review the troubleshooting section above
3. Verify all secrets are configured correctly
4. Ensure the "production" environment exists
