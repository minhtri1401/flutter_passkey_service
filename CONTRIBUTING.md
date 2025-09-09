# Contributing to Flutter Passkey Service

🎉 **Thank you for your interest in contributing to Flutter Passkey Service!** 

We welcome contributions from the community and are excited to see what you'll build. This guide will help you get started with contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#-code-of-conduct)
- [Getting Started](#-getting-started)
- [Development Setup](#-development-setup)
- [How to Contribute](#-how-to-contribute)
- [Pull Request Process](#-pull-request-process)
- [Coding Standards](#-coding-standards)
- [Testing Guidelines](#-testing-guidelines)
- [Documentation](#-documentation)
- [Issue Reporting](#-issue-reporting)
- [Feature Requests](#-feature-requests)
- [Community](#-community)

## 🤝 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

### Our Standards

- **Be respectful** and inclusive in all communications
- **Be patient** with newcomers and those learning
- **Be constructive** in feedback and criticism
- **Focus on what's best** for the community and project
- **Show empathy** towards other community members

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.3.0 or higher)
- **Dart SDK** (included with Flutter)
- **Xcode** (for iOS development) - macOS only
- **Android Studio** or **Android SDK** (for Android development)
- **Git** for version control

### Quick Setup

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/flutter_passkey_service.git
   cd flutter_passkey_service
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/minhtri1401/flutter_passkey_service.git
   ```
4. **Install dependencies**:
   ```bash
   flutter pub get
   cd example && flutter pub get
   ```

## 🛠️ Development Setup

### Environment Setup

1. **Verify Flutter Installation**:
   ```bash
   flutter doctor
   ```
   Ensure all checks pass for your target platforms.

2. **IDE Setup** (recommended):
   - **VS Code** with Flutter and Dart extensions
   - **Android Studio** with Flutter plugin
   - **IntelliJ IDEA** with Flutter plugin

### Project Structure

```
flutter_passkey_service/
├── android/                 # Android platform implementation
├── ios/                     # iOS platform implementation  
├── lib/                     # Dart library code
│   ├── pigeons/            # Pigeon-generated interfaces
│   └── *.dart              # Public API files
├── example/                 # Example application
├── test/                    # Unit tests
├── .github/                 # GitHub templates and workflows
└── docs/                    # Additional documentation
```

### Running the Example

1. **Navigate to example directory**:
   ```bash
   cd example
   ```

2. **Run on iOS** (macOS only):
   ```bash
   flutter run -d ios
   ```

3. **Run on Android**:
   ```bash
   flutter run -d android
   ```

## 🎯 How to Contribute

### Types of Contributions

We welcome several types of contributions:

- 🐛 **Bug fixes** - Fix issues and improve stability
- ✨ **New features** - Add new functionality 
- 📚 **Documentation** - Improve guides, examples, and API docs
- 🧪 **Tests** - Add or improve test coverage
- 🔧 **Tooling** - Improve development workflow
- 🎨 **Examples** - Create new example implementations

### Before You Start

1. **Check existing issues** - Look for existing work on your topic
2. **Open an issue** - Discuss significant changes before starting
3. **Follow our guidelines** - Read this contributing guide thoroughly

## 🔄 Pull Request Process

### 1. Prepare Your Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Keep your branch updated**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### 2. Make Your Changes

- **Follow coding standards** (see below)
- **Add tests** for new functionality
- **Update documentation** as needed
- **Test on both platforms** when applicable

### 3. Commit Your Changes

Use conventional commit messages:

```bash
# Format: type(scope): description
git commit -m "feat(auth): add biometric fallback option"
git commit -m "fix(ios): resolve Touch ID authentication issue"
git commit -m "docs: update installation guide"
```

**Commit Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding tests
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

### 4. Submit Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub
3. **Fill out PR template** completely
4. **Link related issues** using "Fixes #123"

### 5. Review Process

- **Automated checks** must pass (CI/CD)
- **Code review** by maintainers
- **Testing** on multiple devices/platforms
- **Documentation review** if applicable

## 📋 Coding Standards

### Dart Code Style

Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart):

```dart
// Good: Use descriptive names
final authenticatorSelection = AuthenticatorSelection(
  userVerification: UserVerification.required,
);

// Good: Use proper formatting
class PasskeyService {
  Future<AuthenticationResult> authenticate({
    required String challenge,
    String? rpId,
  }) async {
    // Implementation
  }
}
```

### Code Formatting

1. **Use dart format**:
   ```bash
   dart format .
   ```

2. **Lint your code**:
   ```bash
   dart analyze
   ```

3. **Follow naming conventions**:
   - Classes: `PascalCase`
   - Methods/variables: `camelCase`
   - Constants: `lowerCamelCase`
   - Files: `snake_case.dart`

### Platform-Specific Code

#### iOS (Swift)
```swift
// Follow Swift naming conventions
class PasskeyAuthService {
    func authenticateUser(with request: AuthenticationRequest) async throws -> AuthenticationResponse {
        // Implementation
    }
}
```

#### Android (Kotlin)
```kotlin
// Follow Kotlin conventions
class PasskeyAuthService {
    suspend fun authenticateUser(request: AuthenticationRequest): AuthenticationResponse {
        // Implementation
    }
}
```

## 🧪 Testing Guidelines

### Test Types

1. **Unit Tests** - Test individual functions/classes
2. **Integration Tests** - Test platform integration
3. **Widget Tests** - Test Flutter widgets (example app)

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/flutter_passkey_service_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_passkey_service/flutter_passkey_service.dart';

void main() {
  group('FlutterPasskeyService', () {
    test('createRegistrationOptions returns valid options', () {
      final options = FlutterPasskeyService.createRegistrationOptions(
        challenge: 'test-challenge',
        rpName: 'Test App',
        rpId: 'test.com',
        userId: 'user-123',
        username: 'test@example.com',
      );
      
      expect(options.challenge, 'test-challenge');
      expect(options.rp.name, 'Test App');
    });
  });
}
```

### Test Requirements

- **New features** must include tests
- **Bug fixes** should include regression tests
- **Aim for 80%+ coverage** on new code
- **Test both success and error cases**

## 📚 Documentation

### Documentation Types

1. **API Documentation** - Dart doc comments
2. **User Guides** - README.md sections
3. **Examples** - Working code samples
4. **Platform Setup** - Installation guides

### Writing Documentation

```dart
/// Authenticates a user using their registered passkey.
/// 
/// This method initiates the WebAuthn authentication flow using the device's
/// built-in authenticator (Touch ID, Face ID, or Biometric authentication).
/// 
/// Example:
/// ```dart
/// final request = FlutterPasskeyService.createAuthenticationOptions(
///   challenge: serverChallenge,
///   rpId: 'yourdomain.com',
/// );
/// 
/// try {
///   final result = await FlutterPasskeyService.authenticate(request);
///   print('Authentication successful: ${result.id}');
/// } on PasskeyException catch (e) {
///   print('Authentication failed: ${e.message}');
/// }
/// ```
/// 
/// Throws [PasskeyException] if authentication fails or is cancelled.
/// Returns [GetPasskeyAuthenticationResponseData] on successful authentication.
Future<GetPasskeyAuthenticationResponseData> authenticate(
  AuthGenerateOptionResponseData request,
) async {
  // Implementation
}
```

### Documentation Guidelines

- **Use clear, concise language**
- **Include practical examples**
- **Document error conditions**
- **Update README.md** for significant changes
- **Include platform-specific notes** when relevant

## 🐛 Issue Reporting

### Before Reporting

1. **Search existing issues** first
2. **Check documentation** for solutions
3. **Test with latest version**
4. **Verify platform requirements**

### Creating Good Issues

Use our issue templates and include:

- **Clear description** of the problem
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (Flutter version, platform, device)
- **Code samples** when relevant
- **Error logs** if available

## ✨ Feature Requests

### Proposing Features

1. **Open a feature request issue** first
2. **Describe the use case** and problem solved
3. **Provide implementation ideas** if you have them
4. **Consider platform constraints**
5. **Discuss with maintainers** before starting work

### Feature Guidelines

- **Align with project goals** (passkey authentication)
- **Follow WebAuthn standards** 
- **Support both platforms** when possible
- **Maintain backward compatibility**
- **Consider security implications**

## 🌟 Recognition

### Contributors

We recognize contributors through:

- **GitHub contributor list**
- **Release notes mentions**
- **Special thanks** in major releases

### Types of Recognition

- 🏆 **Major Feature Contributors**
- 🐛 **Bug Hunters**
- 📚 **Documentation Heroes**
- 🧪 **Testing Champions**
- 🤝 **Community Helpers**

## 🆘 Getting Help

### Communication Channels

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Questions and community chat
- **Documentation** - Comprehensive guides and API reference

### Response Times

- **Bug reports** - Within 2-3 business days
- **Feature requests** - Within 1 week
- **Pull requests** - Within 1 week for initial review

## 📜 License

By contributing to Flutter Passkey Service, you agree that your contributions will be licensed under the [MIT License](LICENSE) that covers the project.

---

## 🙏 Thank You

Your contributions make Flutter Passkey Service better for everyone. Whether you're fixing a typo, adding a feature, or helping others in discussions, every contribution matters!

**Happy coding!** 🚀

---

*For questions about contributing, feel free to open a discussion or reach out to the maintainers.*
