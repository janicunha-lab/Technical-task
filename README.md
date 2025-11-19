# TechnicalTask - Business Central AL Extension

A Microsoft Dynamics 365 Business Central AL extension that demonstrates user and post management functionality through external API integration. This project showcases modern AL development practices including HTTP client patterns, unit testing, and data synchronization.

## Overview

The **TechnicalTask** extension provides a complete solution for managing users and posts by integrating with the JSONPlaceholder API (https://jsonplaceholder.typicode.com). It demonstrates proper AL architecture patterns, including dependency injection for HTTP clients, comprehensive error handling, and unit testing with mocking.

## Features

### 🔗 API Integration
- **User Synchronization**: Fetches user data from external REST API
- **Post Management**: Retrieves and displays user posts
- **HTTP Client Architecture**: Robust HTTP handling with proper error management
- **JSON Processing**: Parse and map JSON responses to Business Central tables

### 📊 Data Management
- **User Records**: Store and manage user information (ID, Name, Username, Email)
- **Post Records**: Handle post data with proper user relationships
- **Calculated Fields**: Automatic post count calculation per user
- **Data Validation**: Comprehensive field validation and error handling

### 🎯 User Interface
- **User List Page**: Browse and manage users with synchronization actions
- **Post List Page**: View posts with body content display
- **Post Entry Card**: Create new posts through API integration
- **User Card**: Detailed user information display

### ⚡ Advanced Features
- **Dependency Injection**: Interface-based HTTP client for testability
- **Background Processing**: Non-blocking API operations
- **Cascade Operations**: Automatic post cleanup on user deletion
- **Notification System**: User feedback for completed operations

## Project Structure

```
TechnicalTask/                    # Main Extension
├── src/
│   ├── Table/
│   │   ├── TT User.table.al     # User data table
│   │   └── TT Post.table.al     # Post data table
│   ├── Page/
│   │   ├── TT User List.page.al      # User management interface
│   │   ├── TT User Card.page.al      # User details page
│   │   ├── TT Post List.page.al      # Post browsing interface
│   │   └── TT Post Entry Card.page.al # Post creation form
│   └── Codeunit/
│       ├── UserManagement/
│       │   └── TT User Management.codeunit.al # Core business logic
│       └── HttpHandler/
│           ├── TT Http Handler.codeunit.al              # HTTP client implementation
│           └── TT Http Client Controller.Interface.al   # HTTP client interface
└── Translations/
    └── TechnicalTask.g.xlf      # Generated translation file

TechnicalTask_Tests/             # Test Extension
├── src/
│   └── Codeunit/
│       ├── HttpHandler/
│       │   ├── Mocks/
│       │   │   └── TT Http Handler.mock.codeunit.al     # HTTP client mock
│       │   └── UnitTests/
│       │       └── TT Http Handler UT.codeunit.al       # HTTP handler tests
│       └── UserManagement/
│           └── UnitTests/
│               └── TT User Management UT.codeunit.al    # User management tests
└── Translations/
    └── TechnicalTask_Tests.g.xlf # Test app translations
```

## Technical Architecture

### Core Components

1. **TT User Management** (`Codeunit 1000000`)
   - Central orchestrator for user and post operations
   - API integration and data synchronization
   - JSON parsing and data mapping
   - Error handling and user notifications

2. **TT Http Handler** (`Codeunit 1000001`)
   - HTTP client implementation with interface support
   - GET and POST request handling
   - Comprehensive HTTP status code error handling
   - Support for dependency injection through interfaces

3. **TT IHttpClientController** (`Interface`)
   - Abstraction layer for HTTP operations
   - Enables unit testing through mock implementations
   - Supports different HTTP client strategies

### Data Model

- **TT User Table** (ID: 1000000)
  - Primary fields: ID, Name, UserName, Email
  - Calculated field: Posts count (FlowField)
  - Proper data classification and relationships

- **TT Post Table** (ID: 1000001)  
  - Fields: ID, UserID, Title, Body (Blob)
  - Foreign key relationship to User table
  - BLOB storage for post content

### Testing Strategy

The project includes comprehensive unit tests with:
- **Mock Framework**: HTTP client mocking for isolated testing
- **Test Coverage**: Core business logic and HTTP operations
- **Test Patterns**: Proper test setup, execution, and assertions
- **Dependencies**: Microsoft test libraries integration

## Getting Started

### Prerequisites
- Microsoft Dynamics 365 Business Central (Cloud)
- AL Development Environment
- Business Central AL Extension Development license

### Installation
1. Clone this repository
2. Open the workspace in VS Code with AL Language extension
3. Download symbols for your Business Central environment
4. Build and publish the extension

### Usage
1. Navigate to **User List** page in Business Central
2. Use **Get Users** action to synchronize user data from API
3. Browse users and their associated posts
4. Create new posts using the **Post Entry** functionality

## API Endpoints Used

- **GET** `https://jsonplaceholder.typicode.com/users` - Fetch user data
- **GET** `https://jsonplaceholder.typicode.com/posts` - Fetch post data  
- **POST** `https://jsonplaceholder.typicode.com/posts` - Create new posts

## Development Notes

### Object ID Ranges
- **Main Extension**: 1000000 - 1000049
- **Test Extension**: 1000000 - 1000049 (shared range for test objects)

### AL Language Features
- Target: **Business Central Cloud**
- Platform: **1.0.0.0**
- Application: **27.0.0.0**
- Runtime: **16.0**
- Translation support enabled

### Code Quality
- Follows AL coding standards and best practices
- Implements proper error handling patterns
- Uses modern AL language features (interfaces, proper data classification)
- Comprehensive unit test coverage with mocking

## Contributing

When contributing to this project:
1. Follow AL coding conventions
2. Include unit tests for new functionality
3. Update documentation as needed
4. Ensure all tests pass before submitting

## CI/CD Pipeline

This project uses **AL-Go for GitHub** based on the **AppSource App Template** for automated build, test, and deployment processes. The AL-Go framework provides enterprise-grade DevOps capabilities specifically designed for Business Central AL extensions targeting AppSource.

### Pipeline Features

- **Automated Builds**: Triggered on every push and pull request
- **Code Quality**: Integrated CodeCop, AppSourceCop, and UICop analysis
- **Unit Testing**: Automatic test execution with coverage reporting  
- **AppSource Compliance**: Built-in validation for AppSource requirements
- **Multi-Environment Support**: Staging and production deployment workflows
- **Version Management**: Semantic versioning with automatic increments
- **Artifact Publishing**: Automatic .app file generation and storage

### Workflows

#### CI Workflow
- **Triggers**: Push to `main`/`develop` branches, pull requests
- **Actions**: 
  - AL compilation with dependency resolution
  - Static code analysis (CodeCop, AppSourceCop, UICop)
  - Unit test execution with Microsoft test framework
  - App validation against Business Central compatibility

#### CD Workflow  
- **Triggers**: Manual deployment, release tags
- **Actions**:
  - Build validation and signing
  - AppSource readiness verification
  - Environment-specific deployments
  - Release artifact creation

### AppSource Template Benefits

The AL-Go AppSource App Template provides:
- **Compliance Validation**: Ensures adherence to Microsoft AppSource guidelines
- **Quality Gates**: Automated checks for performance, security, and compatibility
- **Release Management**: Streamlined process for AppSource submissions
- **Documentation**: Auto-generated release notes and change logs
- **Security**: Code signing and security scanning integration

### Configuration

Pipeline configuration is managed through `.AL-Go/settings.json` with AppSource-specific settings:
- **Type**: PTE (Per-Tenant Extension) ready for AppSource
- **Mandatory Prefixes**: `TT` prefix enforced by AppSourceCop
- **ID Ranges**: Controlled object ID allocation
- **Dependencies**: Managed symbol downloads and version control

For more information about AL-Go and the AppSource template, visit the [AL-Go for GitHub documentation](https://github.com/microsoft/AL-Go).

## License

This project is part of a technical demonstration and follows standard AL extension licensing.