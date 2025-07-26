# Copilot Instructions for BillMate

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview
BillMate is a Flutter-based offline billing software for shops with GST compliance, inventory management, and PDF invoice generation.

## Architecture Guidelines
- Follow **Clean Architecture** principles with clear separation of concerns
- Implement **SOLID principles** throughout the codebase
- Use **Dependency Injection** with get_it package
- Follow **Repository Pattern** for data access
- Implement **BLoC pattern** for state management
- Use **Feature-based folder structure**

## Code Standards
- Use **Dart naming conventions** (camelCase for variables, PascalCase for classes)
- Write **comprehensive unit and widget tests**
- Add **detailed documentation** for all public APIs
- Follow **Flutter best practices** for performance
- Implement **proper error handling** and logging
- Use **const constructors** where possible for performance

## Key Technologies
- **Flutter** for cross-platform development
- **SQLite** (sqflite) for offline database
- **BLoC** (flutter_bloc) for state management
- **get_it** for dependency injection
- **PDF generation** for invoices
- **GST calculations** compliance
- **Freezed** for immutable data classes
- **json_annotation** for serialization

## Business Logic
- All GST calculations must be accurate and compliant
- Ensure offline-first functionality
- Maintain data integrity across all operations
- Implement proper validation for all user inputs
- Support multiple item categories and pricing models

## Testing Strategy
- Unit tests for all business logic
- Widget tests for UI components
- Integration tests for critical user flows
- Mock external dependencies in tests
- Achieve high test coverage (>80%)
