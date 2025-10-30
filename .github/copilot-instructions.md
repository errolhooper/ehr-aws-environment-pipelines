# GitHub Copilot Instructions for ehr-aws-environment-pipelines

## Repository Overview

This repository manages AWS environment pipelines for Electronic Health Record (EHR) systems. It contains infrastructure-as-code and CI/CD pipeline configurations for deploying and managing EHR applications in AWS environments.

## Purpose

The primary purpose of this repository is to:
- Define and manage AWS infrastructure for EHR systems
- Automate deployment pipelines for different environments (dev, staging, production)
- Ensure consistent and secure infrastructure provisioning
- Maintain infrastructure compliance with healthcare regulations (HIPAA, etc.)

## Technology Stack

- **Cloud Provider**: AWS (Amazon Web Services)
- **Infrastructure as Code**: (To be determined based on repository evolution)
- **CI/CD**: GitHub Actions (expected)

## Development Guidelines

### General Principles

1. **Security First**: Healthcare data requires the highest security standards
   - Always follow HIPAA compliance requirements
   - Use encryption for data at rest and in transit
   - Implement least privilege access principles
   - Never commit credentials or sensitive information

2. **Infrastructure as Code Best Practices**
   - Use version control for all infrastructure changes
   - Write idempotent and reusable configurations
   - Document all resources and their purposes
   - Include appropriate tags for resource management

3. **Environment Management**
   - Maintain clear separation between environments
   - Use consistent naming conventions across environments
   - Document environment-specific configurations

### Code Standards

- Use clear, descriptive naming for all resources
- Include comments for complex logic or configurations
- Follow AWS best practices and Well-Architected Framework principles
- Ensure all pipelines are idempotent and can be run multiple times safely

### Documentation

- Update README.md when adding new components or changing workflows
- Document all environment variables and configuration parameters
- Include architecture diagrams for complex infrastructure setups
- Maintain up-to-date deployment and rollback procedures

### Testing

- Test infrastructure changes in non-production environments first
- Validate configurations before applying to production
- Include validation steps in CI/CD pipelines
- Document test procedures and expected outcomes

## Security Considerations

- **Sensitive Data**: Never commit AWS credentials, API keys, or other secrets
- **Access Control**: Implement proper IAM roles and policies
- **Compliance**: Ensure all infrastructure meets healthcare compliance requirements
- **Audit Logging**: Enable CloudTrail and appropriate logging for all resources
- **Encryption**: Use AWS KMS for encryption keys and enable encryption by default

## CI/CD Pipeline Guidelines

- Pipeline configurations should be version controlled
- Include automated testing and validation stages
- Implement manual approval gates for production deployments
- Ensure rollback procedures are tested and documented
- Use environment-specific variables and secrets management

## Contributing

When making changes to this repository:
1. Create feature branches for all changes
2. Test thoroughly in lower environments before promoting
3. Include clear commit messages describing the change and its purpose
4. Update documentation to reflect infrastructure changes
5. Review security implications of all changes

## Emergency Procedures

- Document rollback procedures for all pipeline changes
- Maintain contact information for on-call support
- Keep incident response procedures up-to-date
- Test disaster recovery procedures regularly

## Helpful Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [HIPAA Compliance on AWS](https://aws.amazon.com/compliance/hipaa-compliance/)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
