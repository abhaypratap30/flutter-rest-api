# Contributing Guidelines

Thank you for considering contributing to `flutter-rest-api`! We welcome contributions to improve the architecture, add new networking patterns, or enhance test coverage.

## Code Standards & Guidelines

1. **Clean Architecture**:
   - Keep domain entities independent of UI framework elements.
   - Place feature-specific widgets inside their corresponding feature presentation package.
   - Place cross-cutting UI components under `lib/shared/widgets/`.

2. **Code Formatting & Lints**:
   - Ensure all code conforms to the standard Dart style.
   - Run `flutter analyze` before committing. There should be 0 lint errors or warnings.

3. **Testing**:
   - Write unit tests for new repository or service methods in the `test/` directory.
   - Ensure all tests pass via `flutter test`.

## Pull Request Process

1. Fork the repository and create your feature branch: `git checkout -b feature/my-new-feature`.
2. Commit your changes with clear, descriptive messages.
3. Push to your fork and submit a Pull Request targeting the `main` branch.
4. Describe the changes made and include any verification steps.
