#!/bin/bash
# setup-budfin.sh - Script to initialize the Budfin platform project structure

set -e  # Exit on error

# Create the main project directory
mkdir -p budfin
cd budfin

# Create directories for shared libraries and configurations
mkdir -p shared/config shared/lib

# Create service directories
mkdir -p services/user-management services/model-service services/calculation-engine services/integration-service services/collaboration-service services/analytics-service services/export-service

# Create infrastructure directory
mkdir -p infrastructure/docker infrastructure/k8s

# Initialize user management service with NestJS
cd services/user-management
npx @nestjs/cli new user-management-service --package-manager npm
cd user-management-service

# Configure user management service package.json
cat > package.json << 'EOL'
{
  "name": "budfin-user-management-service",
  "version": "0.1.0",
  "description": "User Management Service for Budfin Platform",
  "author": "",
  "private": true,
  "license": "UNLICENSED",
  "scripts": {
    "build": "nest build",
    "format": "prettier --write \"src/**/*.ts\" \"test/**/*.ts\"",
    "start": "nest start",
    "start:dev": "nest start --watch",
    "start:debug": "nest start --debug --watch",
    "start:prod": "node dist/main",
    "lint": "eslint \"{src,apps,libs,test}/**/*.ts\" --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:cov": "jest --coverage",
    "test:debug": "node --inspect-brk -r tsconfig-paths/register -r ts-node/register node_modules/.bin/jest --runInBand",
    "test:e2e": "jest --config ./test/jest-e2e.json"
  },
  "dependencies": {
    "@nestjs/common": "^10.0.0",
    "@nestjs/config": "^3.0.0",
    "@nestjs/core": "^10.0.0",
    "@nestjs/jwt": "^10.1.0",
    "@nestjs/passport": "^10.0.0",
    "@nestjs/platform-express": "^10.0.0",
    "@nestjs/typeorm": "^10.0.0",
    "bcrypt": "^5.1.0",
    "class-transformer": "^0.5.1",
    "class-validator": "^0.14.0",
    "passport": "^0.6.0",
    "passport-jwt": "^4.0.1",
    "passport-local": "^1.0.0",
    "pg": "^8.11.1",
    "reflect-metadata": "^0.1.13",
    "rxjs": "^7.8.1",
    "typeorm": "^0.3.17"
  },
  "devDependencies": {
    "@nestjs/cli": "^10.0.0",
    "@nestjs/schematics": "^10.0.0",
    "@nestjs/testing": "^10.0.0",
    "@types/bcrypt": "^5.0.0",
    "@types/express": "^4.17.17",
    "@types/jest": "^29.5.2",
    "@types/node": "^20.3.1",
    "@types/passport-jwt": "^3.0.9",
    "@types/passport-local": "^1.0.35",
    "@types/supertest": "^2.0.12",
    "@typescript-eslint/eslint-plugin": "^5.59.11",
    "@typescript-eslint/parser": "^5.59.11",
    "eslint": "^8.42.0",
    "eslint-config-prettier": "^8.8.0",
    "eslint-plugin-prettier": "^4.2.1",
    "jest": "^29.5.0",
    "prettier": "^2.8.8",
    "source-map-support": "^0.5.21",
    "supertest": "^6.3.3",
    "ts-jest": "^29.1.0",
    "ts-loader": "^9.4.3",
    "ts-node": "^10.9.1",
    "tsconfig-paths": "^4.2.0",
    "typescript": "^5.1.3"
  },
  "jest": {
    "moduleFileExtensions": [
      "js",
      "json",
      "ts"
    ],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": {
      "^.+\\.(t|j)s$": "ts-jest"
    },
    "collectCoverageFrom": [
      "**/*.(t|j)s"
    ],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node"
  }
}
EOL

# Create a Docker Compose file for local development
cd ../../../
cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  postgres:
    image: postgres:14
    container_name: budfin-postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_USER: budfin
      POSTGRES_PASSWORD: budfin_password
      POSTGRES_DB: budfin_users
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - budfin-network

  user-management-service:
    build:
      context: ./services/user-management/user-management-service
      dockerfile: Dockerfile
    container_name: budfin-user-service
    ports:
      - "3001:3000"
    environment:
      - DATABASE_HOST=postgres
      - DATABASE_PORT=5432
      - DATABASE_USER=budfin
      - DATABASE_PASSWORD=budfin_password
      - DATABASE_NAME=budfin_users
      - JWT_SECRET=change_this_in_production
      - NODE_ENV=development
    depends_on:
      - postgres
    networks:
      - budfin-network
    volumes:
      - ./services/user-management/user-management-service:/app
      - /app/node_modules

networks:
  budfin-network:
    driver: bridge

volumes:
  postgres_data:
EOL

# Create a Dockerfile for user management service
cd services/user-management/user-management-service
cat > Dockerfile << 'EOL'
FROM node:18-alpine As development

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

RUN npm run build

FROM node:18-alpine As production

ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

COPY --from=development /app/dist ./dist

CMD ["node", "dist/main"]
EOL

# Create .env file for user management service
cat > .env << 'EOL'
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=budfin
DATABASE_PASSWORD=budfin_password
DATABASE_NAME=budfin_users
JWT_SECRET=change_this_in_production
PORT=3000
EOL

# Create .dockerignore
cat > .dockerignore << 'EOL'
node_modules
npm-debug.log
dist
.git
.env
.dockerignore
.gitignore
README.md
EOL

# Create initial README file
cd ../../../
cat > README.md << 'EOL'
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
EOL

echo "Budfin platform project initialized successfully!"
echo "To start development, run:"
echo "cd budfin"
echo "docker-compose up -d"
echo "cd services/user-management/user-management-service"
echo "npm run start:dev"