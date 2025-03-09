# Budfin Platform

A next-generation financial modeling platform that emphasizes intuitive from-scratch model building rather than relying on templates.

## Project Structure

- services/ - Contains all microservices
  - user-management/ - User authentication and authorization
  - model-service/ - Manages financial model structure
  - calculation-engine/ - Executes financial calculations
  - integration-service/ - Connects to external data sources
  - collaboration-service/ - Enables real-time multi-user editing
  - analytics-service/ - Provides insights and reporting
  - export-service/ - Generates outputs in various formats

- shared/ - Common libraries and configurations
  - config/ - Configuration files
  - lib/ - Shared libraries and utilities

- infrastructure/ - Infrastructure configurations
  - docker/ - Docker configurations
  - k8s/ - Kubernetes configurations

## Getting Started

### Prerequisites

- Node.js (v18 or later)
- Docker and Docker Compose
- PostgreSQL (or use the containerized version)

### Local Development

1. Clone the repository
2. Run `docker-compose up -d` to start the PostgreSQL database
3. Navigate to the specific service directory you want to work on
4. Run `npm install` (if not using Docker for development)
5. Run `npm run start:dev` to start the service in development mode

## Services

### User Management Service

Handles:
- User authentication and authorization
- User registration and profile management
- Role-based access control
- Organization management

For more details, see the README in the user-management service directory.
