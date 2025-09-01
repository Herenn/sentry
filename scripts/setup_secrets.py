#!/usr/bin/env python3
"""
Helper script to guide users through setting up CI/CD secrets
"""

import sys
from typing import Dict, List

def print_github_secrets_guide(provider: str):
    """Print GitHub Actions secrets setup guide"""
    print("🔐 GitHub Actions Secrets Setup")
    print("=" * 40)
    print()
    print("Navigate to your repository settings:")
    print("Repository → Settings → Secrets and variables → Actions")
    print()
    print("Add the following repository secrets:")
    print()
    
    if provider == 'aws':
        secrets = {
            'AWS_ACCESS_KEY_ID': 'Your AWS access key ID',
            'AWS_SECRET_ACCESS_KEY': 'Your AWS secret access key',
            'AWS_DEFAULT_REGION': 'Your preferred AWS region (e.g., us-east-1)'
        }
    elif provider == 'gcp':
        secrets = {
            'GOOGLE_CREDENTIALS': 'Service account JSON key (base64 encoded)',
            'GOOGLE_PROJECT': 'Your GCP project ID'
        }
    elif provider == 'azure':
        secrets = {
            'ARM_CLIENT_ID': 'Azure service principal client ID',
            'ARM_CLIENT_SECRET': 'Azure service principal client secret',
            'ARM_SUBSCRIPTION_ID': 'Azure subscription ID',
            'ARM_TENANT_ID': 'Azure tenant ID'
        }
    elif provider == 'digitalocean':
        secrets = {
            'SPACES_ACCESS_KEY_ID': 'DigitalOcean Spaces access key',
            'SPACES_SECRET_ACCESS_KEY': 'DigitalOcean Spaces secret key',
            'SPACES_REGION': 'DigitalOcean Spaces region',
            'SPACES_ENDPOINT': 'DigitalOcean Spaces endpoint URL'
        }
    else:
        print(f"Unknown provider: {provider}")
        return
    
    for secret_name, description in secrets.items():
        print(f"• {secret_name}")
        print(f"  {description}")
        print()

def print_gitlab_secrets_guide(provider: str):
    """Print GitLab CI/CD variables setup guide"""
    print("🔐 GitLab CI/CD Variables Setup")
    print("=" * 40)
    print()
    print("Navigate to your project settings:")
    print("Project → Settings → CI/CD → Variables")
    print()
    print("Add the following variables (mark sensitive ones as 'Masked'):")
    print()
    
    # Similar structure as GitHub but with GitLab-specific guidance
    if provider == 'aws':
        variables = {
            'AWS_ACCESS_KEY_ID': 'Your AWS access key ID (Masked)',
            'AWS_SECRET_ACCESS_KEY': 'Your AWS secret access key (Masked)',
            'AWS_DEFAULT_REGION': 'Your preferred AWS region'
        }
    # ... (similar for other providers)
    
    for var_name, description in variables.items():
        print(f"• {var_name}")
        print(f"  {description}")
        print()

def main():
    """Main function"""
    if len(sys.argv) < 3:
        print("Usage: python3 setup_secrets.py <git_provider> <cloud_provider>")
        print()
        print("Git providers: github, gitlab, bitbucket, azure_devops")
        print("Cloud providers: aws, gcp, azure, digitalocean")
        sys.exit(1)
    
    git_provider = sys.argv[1].lower()
    cloud_provider = sys.argv[2].lower()
    
    print(f"Setting up secrets for {git_provider} + {cloud_provider}")
    print()
    
    if git_provider == 'github':
        print_github_secrets_guide(cloud_provider)
    elif git_provider == 'gitlab':
        print_gitlab_secrets_guide(cloud_provider)
    else:
        print(f"Guide for {git_provider} not yet implemented")
    
    print("💡 Security Best Practices:")
    print("- Use least-privilege IAM policies")
    print("- Consider using OIDC federation instead of long-lived keys")
    print("- Rotate secrets regularly")
    print("- Monitor secret usage in your cloud provider's audit logs")

if __name__ == '__main__':
    main()
