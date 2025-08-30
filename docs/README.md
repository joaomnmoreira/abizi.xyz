# Geek Stuff - Technical Knowledge Base

A comprehensive technical documentation website built with Sphinx, covering Information Technology, DevOps, frameworks, self-development, and health topics.

## 🌐 Live Website
**URL:** [geek.abizi.xyz](https://geek.abizi.xyz)

## 📋 Project Overview

**Geek Stuff** is a personal knowledge base and technical documentation website created by João Moreira. It serves as a centralized repository for technical guides, tutorials, best practices, and reference materials across multiple domains.

### 🎯 Purpose
- **Knowledge Repository**: Centralized storage of technical knowledge and best practices
- **Reference Guide**: Quick access to commands, configurations, and procedures
- **Learning Resource**: Structured documentation for various technologies and concepts
- **Personal Wiki**: Organized collection of notes and insights from professional experience

## 🏗️ Project Architecture

### Technology Stack
- **Documentation Generator**: Sphinx 3.0.1
- **Theme**: Alabaster (customized)
- **Language**: reStructuredText (.rst)
- **Deployment**: GitHub Pages via GitHub Actions
- **Domain**: Custom domain (geek.abizi.xyz)

### Project Structure
```
abizi.xyz/
├── .github/workflows/
│   └── gh-pages.yml          # GitHub Actions deployment workflow
├── docs/
│   ├── source/
│   │   ├── conf.py           # Sphinx configuration
│   │   ├── index.rst         # Main documentation index
│   │   ├── contents/         # Documentation content
│   │   │   ├── it/           # Information Technology
│   │   │   │   ├── concepts/ # Core IT concepts
│   │   │   │   ├── devops/   # DevOps tools and practices
│   │   │   │   ├── framework/# Development frameworks
│   │   │   │   ├── os/       # Operating systems
│   │   │   │   └── research/ # Research topics
│   │   │   ├── self-development/ # Personal development
│   │   │   └── he/           # Health & Exercise
│   │   ├── _static/          # Static assets (CSS, images)
│   │   └── _templates/       # Custom Sphinx templates
│   ├── build/                # Generated documentation (gitignored)
│   └── CNAME                 # Custom domain configuration
├── requirements.txt          # Python dependencies
└── .gitignore               # Git ignore rules
```

## 📚 Content Organization

### 1. Information Technology (IT)
The largest section covering technical topics organized into subcategories:

#### **Concepts**
- **Cybersecurity**: Security practices and guidelines
- **Development**: Software development methodologies
- **Hardening**: System security hardening procedures
- **Project Management**: Technical project management approaches

#### **DevOps**
Comprehensive coverage of DevOps tools and practices:
- **AI**: Artificial Intelligence tools and frameworks
- **Ansible**: Configuration management and automation
- **Docker**: Containerization and orchestration
- **Grafana**: Monitoring and visualization
- **Kubernetes**: Container orchestration
- **Terraform**: Infrastructure as Code
- **Prometheus**: Monitoring and alerting
- **Proxmox**: Virtualization platform
- **Vagrant**: Development environment management
- **WireGuard**: VPN configuration
- **Tools**: Various DevOps utilities

#### **Frameworks**
Development frameworks and technologies:
- **Django**: Python web framework
- **Flutter**: Mobile app development
- **Hugo**: Static site generator
- **Quarkus**: Java framework
- **RabbitMQ**: Message broker
- **Rasa**: Conversational AI
- **Strapi**: Headless CMS
- **Sphinx**: Documentation generator

#### **Operating Systems**
- **Linux**: Linux administration and commands
- **RedHat**: RedHat-specific configurations
- **Windows**: Windows system management

### 2. Self Development
Personal and professional development topics:
- **Skills**: Technical and soft skills development

### 3. Health & Exercise (HE)
Health and fitness related content:
- **HIIT**: High-Intensity Interval Training
- **Knowledge Base**: General health information
- **Uric Acid**: Health condition management

## 🔧 Technical Implementation

### Sphinx Configuration
The project uses Sphinx with the following key configurations:

- **Project Name**: "Geek Stuff"
- **Author**: João Moreira
- **Version**: 0.0.1
- **Theme**: Alabaster with custom styling
- **Extensions**:
  - `sphinx.ext.githubpages`: GitHub Pages integration
  - `sphinx_copybutton`: Copy code button functionality

### Custom Features
- **Fixed Sidebar**: Enhanced navigation experience
- **Custom CSS**: Personalized styling via `custom.css`
- **Copy Button**: Easy code copying functionality
- **Last Updated**: Timestamp on every page
- **Search Integration**: Built-in search functionality

### Deployment Pipeline
Automated deployment using GitHub Actions:

1. **Trigger**: Push to master branch
2. **Build**: Sphinx documentation generation
3. **Deploy**: Automatic deployment to GitHub Pages
4. **Domain**: Custom domain configuration (geek.abizi.xyz)

## 🚀 Development Workflow

### Local Development
```bash
# Clone repository
git clone <repository-url>

# Install dependencies
pip install -r requirements.txt

# Build documentation locally
cd docs
sphinx-build source _build

# Serve locally (optional)
python -m http.server 8000 -d _build/html
```

### Content Creation
1. Create new `.rst` files in appropriate `contents/` subdirectories
2. Add entries to `index.rst` toctree
3. Follow reStructuredText syntax
4. Include code examples with proper syntax highlighting
5. Add cross-references and external links

### Deployment
- **Automatic**: Push to master branch triggers GitHub Actions
- **Manual**: Can be triggered via GitHub Actions interface
- **Verification**: Check deployment at geek.abizi.xyz

## 📝 Content Guidelines

### Documentation Standards
- **Format**: reStructuredText (.rst)
- **Structure**: Hierarchical organization with clear headings
- **Code Examples**: Syntax-highlighted code blocks
- **External Links**: References to official documentation
- **Commands**: Step-by-step procedures with console examples

### Writing Style
- **Concise**: Clear and to-the-point explanations
- **Practical**: Focus on actionable information
- **Examples**: Include real-world usage examples
- **References**: Link to authoritative sources

## 🔍 Key Features

### Navigation
- **Hierarchical Structure**: Organized by topic and subtopic
- **Search Functionality**: Full-text search across all content
- **Cross-References**: Internal linking between related topics
- **External Links**: References to official documentation

### User Experience
- **Responsive Design**: Mobile-friendly layout
- **Copy Buttons**: Easy code copying
- **Fixed Sidebar**: Persistent navigation
- **Last Updated**: Content freshness indicators

### Technical Features
- **Static Site**: Fast loading and reliable hosting
- **Version Control**: Full Git history of changes
- **Automated Deployment**: Continuous integration/deployment
- **Custom Domain**: Professional web presence

## 🎯 Use Cases

### Personal Reference
- Quick lookup of commands and configurations
- Step-by-step procedures for common tasks
- Best practices and troubleshooting guides

### Learning Resource
- Structured learning paths for technologies
- Comprehensive coverage of tools and frameworks
- Real-world examples and use cases

### Knowledge Sharing
- Documented solutions to common problems
- Standardized procedures and configurations
- Team knowledge base and onboarding resource

## 📈 Maintenance

### Content Updates
- Regular review and update of technical content
- Addition of new technologies and tools
- Correction of outdated information
- Enhancement of existing documentation

### Technical Maintenance
- Dependency updates (Sphinx, themes, extensions)
- Security patches and updates
- Performance optimization
- Backup and disaster recovery

## 🤝 Contributing

While this is a personal knowledge base, the structure and approach can serve as a template for similar documentation projects. Key principles:

- **Consistency**: Follow established patterns and styles
- **Quality**: Ensure accuracy and completeness
- **Organization**: Maintain logical structure and hierarchy
- **Documentation**: Include proper metadata and references

---

**Author**: João Moreira  
**License**: Personal Knowledge Base  
**Last Updated**: 2022  
**Website**: [geek.abizi.xyz](https://geek.abizi.xyz)
