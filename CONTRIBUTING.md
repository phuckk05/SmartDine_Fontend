# Contributing to SmartDine

Thank you for your interest in contributing to SmartDine! 🎉

## 📋 Table of Contents
- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Testing](#testing)

---

## 📜 Code of Conduct

By participating in this project, you agree to:
- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards other contributors

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK >= 3.7.0
- Dart SDK >= 3.0.0
- Git
- Android Studio or VS Code

### Fork and Clone
```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/SmartDine_Fontend.git
cd SmartDine_Fontend/fontend/smart_dine

# Add upstream remote
git remote add upstream https://github.com/phuckk05/SmartDine_Fontend.git

# Install dependencies
flutter pub get
```

---

## 🔄 Development Workflow

### 1. Create a Branch
```bash
# Update main branch
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# For bug fixes
git checkout -b fix/bug-description

# For documentation
git checkout -b docs/what-you-are-documenting
```

### 2. Make Changes
- Write clean, readable code
- Follow the coding standards below
- Test your changes thoroughly
- Update documentation if needed

### 3. Commit Changes
```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add your feature description"
```

### 4. Push and Create PR
```bash
# Push to your fork
git push origin feature/your-feature-name

# Create Pull Request on GitHub
```

---

## 💻 Coding Standards

### Flutter/Dart Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Format code with `dart format .`

### Naming Conventions
```dart
// Classes: PascalCase
class BranchDashboard extends StatefulWidget {}

// Variables & Functions: camelCase
String userName = 'John';
void calculateTotal() {}

// Constants: lowerCamelCase with const
const double padding = 16.0;

// Private: prefix with underscore
void _internalMethod() {}
String _privateVariable = '';

// Files: snake_case
// branch_dashboard.dart
// order_list_screen.dart
```

### Widget Structure
```dart
class MyWidget extends StatelessWidget {
  // 1. Constructor
  const MyWidget({Key? key}) : super(key: key);

  // 2. Build method
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // 3. Helper methods
  Widget _buildTitle() {
    return Text('Title');
  }
}
```

### State Management
```dart
class MyScreen extends StatefulWidget {
  const MyScreen({Key? key}) : super(key: key);

  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // State variables
  String _selectedFilter = 'Tháng';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}
```

### Comments
```dart
// Use comments for complex logic
// Explain WHY, not WHAT

/// Documentation comments for public APIs
/// 
/// This method calculates the total revenue
/// based on the selected time filter.
double calculateRevenue(String filter) {
  // Implementation
}
```

---

## 📝 Commit Guidelines

### Commit Message Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, semicolons, etc)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

### Examples
```bash
# Feature
git commit -m "feat(dashboard): add interactive revenue chart with tooltips"

# Bug fix
git commit -m "fix(orders): resolve null pointer exception in order detail"

# Documentation
git commit -m "docs(readme): update installation instructions"

# Multiple changes
git commit -m "feat: add branch management dashboard

- Add revenue and orders charts
- Implement filter functionality
- Add navigation to 6 screens
- Integrate fl_chart package"
```

---

## 🔍 Pull Request Process

### Before Creating PR
1. ✅ Code follows style guidelines
2. ✅ All tests passing (`flutter test`)
3. ✅ No analyzer warnings (`flutter analyze`)
4. ✅ Code is formatted (`dart format .`)
5. ✅ Documentation updated
6. ✅ Tested on Android/iOS

### PR Title Format
```
feat(scope): brief description
fix(scope): brief description
docs: update documentation
```

### PR Description Template
Use the provided `.github/PULL_REQUEST_TEMPLATE.md`

### Review Process
1. At least 1 approving review required
2. All CI checks must pass
3. No merge conflicts
4. Updated CHANGELOG.md if needed

---

## 🧪 Testing

### Run Tests
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Widget Testing
```dart
testWidgets('Dashboard displays charts', (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());
  
  expect(find.text('Doanh thu'), findsOneWidget);
  expect(find.text('Đơn hàng'), findsOneWidget);
});
```

### Test on Devices
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Chrome
flutter run -d chrome
```

---

## 🎨 UI/UX Guidelines

### Spacing
- Use multiples of 4: 4, 8, 12, 16, 24, 32, 48
- Padding: 16.0 (default)
- Card margin: 12.0

### Colors
```dart
// Use theme colors
Theme.of(context).primaryColor
Theme.of(context).colorScheme.secondary

// Custom colors from Style class
Style.primaryColor
Style.accentColor
```

### Dark Mode Support
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final backgroundColor = isDark ? Colors.grey[900] : Colors.white;
```

---

## 📚 Resources

### Documentation
- [Flutter Docs](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

### Project Docs
- [Branch Management Summary](BRANCH_MANAGEMENT_SUMMARY.md)
- [Order Detail Update](ORDER_DETAIL_UPDATE.md)
- [Notifications Improvement](NOTIFICATIONS_IMPROVEMENT.md)

---

## 🤝 Need Help?

- **Questions**: Open an issue with `question` label
- **Bug Reports**: Open an issue with `bug` label
- **Feature Requests**: Open an issue with `enhancement` label
- **Discussions**: Use GitHub Discussions

---

## 🎉 Recognition

Contributors will be:
- Listed in CHANGELOG.md
- Mentioned in release notes
- Added to Contributors section

---

**Thank you for contributing to SmartDine! 🚀**
