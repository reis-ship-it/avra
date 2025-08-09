# SPOTS - Social Places & Organized Travel Spots

**Last Updated:** August 6, 2025 at 10:15 AM CDT  
**Status:** ✅ **Active Development - AI Systems Operational**

A Flutter-based mobile application for discovering, sharing, and organizing local spots and experiences with advanced AI-powered features and comprehensive testing infrastructure.

## 🎯 **Core Philosophy**

**OUR_GUTS.md is THE CORE of SPOTS** - it contains our fundamental values and philosophy. **Always reference OUR_GUTS.md for every decision** about SPOTS.

### **Key Principles:**
- **Belonging Comes First** - Helping people find places where they truly feel at home
- **No Agenda. No Politics. No Pay-to-Play** - Neutral, open platform
- **Authenticity Over Algorithms** - Real data-driven suggestions
- **Privacy and Control Are Non-Negotiable** - Your data is yours
- **Effortless, Seamless Discovery** - No check-ins, no hassle
- **Personalized, Not Prescriptive** - User control over experience
- **Community, Not Just Places** - Bringing people together

**📋 Decision Framework:** See `DECISION_FRAMEWORK.md` for how to make decisions aligned with our core values.

## 🚀 Quick Start

### Prerequisites
- Flutter 3.32.6 or higher
- Dart 3.0 or higher
- Android Studio / Xcode (for mobile development)
- VS Code / Cursor (recommended)

### Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/spots.git
cd spots

# Get dependencies
flutter pub get

# Run the app
flutter run

## 👨‍💻 Developer Quickstart (Core)

1) Get dependencies and ensure Flutter stable
```bash
flutter --version
flutter pub get
```

2) (Optional) Supabase environment for local smokes
```bash
export SUPABASE_URL=your-url
export SUPABASE_ANON_KEY=your-anon
```

3) Core tests (skips legacy noisy suites)
```bash
chmod +x scripts/test_core.sh
./scripts/test_core.sh
```

4) Supabase checks
```bash
chmod +x scripts/supabase/run_all.sh
./scripts/supabase/run_all.sh
```
```

## 📱 Features

### Core Features
- **Spot Discovery**: Find and explore local spots with AI-powered recommendations
- **List Management**: Create and organize spot lists with community validation
- **Offline Support**: Full offline functionality with intelligent caching
- **User Authentication**: Secure user management with privacy controls
- **Map Integration**: Interactive maps with location services and offline tiles
- **Social Features**: Share and respect lists with community feedback

### Advanced AI Features
- **AI-Powered List Generation**: Personalized lists based on user preferences and behavior
- **Background Agent System**: Continuous optimization and processing
- **Smart Search Suggestions**: Natural language processing and contextual recommendations
- **Personality Learning**: Adaptive AI that learns from user behavior
- **Predictive Analytics**: Pattern recognition and trend analysis
- **AI2AI Communication**: Encrypted AI collaboration and knowledge sharing

### Advanced Features
- **Role-Based Access**: Curator, Collaborator, and Follower roles
- **Age-Restricted Content**: Content moderation system
- **Real-time Sync**: Offline-first with online synchronization
- **Performance Monitoring**: Built-in performance tracking and optimization
- **Comprehensive Testing**: Automated testing suite with background processing

## 🧪 Testing

### Automated Testing
The project includes a comprehensive testing system that runs automatically:

#### Local Testing
```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/unit/
flutter test test/integration/
flutter test test/widget/

# Run with coverage
flutter test --coverage
```

#### Background Testing System
```bash
# Setup background testing
./test/testing/setup_background_testing.sh

# Check status
./test/testing/dashboard.sh

# Run tests manually
./test/testing/run_all_tests.sh
```

### GitHub Actions CI/CD
The repository includes automated workflows:

- **Background Testing**: Periodic unit/integration/widget + reports
- **Quick Tests**: Fast feedback; runs core tests and Supabase smokes
- **Deployment**: Automated builds and deployment
- **Code Quality**: Automated analysis and formatting

## 🏗️ Architecture

### Project Structure
```
spots/
├── lib/
│   ├── core/           # Core utilities, AI systems, and models
│   │   ├── ai/         # AI-powered features and learning systems
│   │   ├── ml/         # Machine learning and predictive analytics
│   │   ├── ai2ai/      # AI-to-AI communication protocols
│   │   └── services/   # Core services and utilities
│   ├── data/           # Data layer (repositories, datasources)
│   ├── domain/         # Business logic and entities
│   └── presentation/   # UI layer (pages, widgets, blocs)
├── test/
│   ├── unit/           # Unit tests
│   ├── integration/    # Integration tests
│   ├── widget/         # Widget tests
│   └── testing/        # Background testing system
├── scripts/            # Background agent scripts and automation
├── .github/            # GitHub Actions workflows
└── docs/              # Documentation
```

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **Sembast**: Local NoSQL database
- **BLoC**: State management
- **GetIt**: Dependency injection
- **Mapbox GL**: Map integration with offline support
- **Geolocator**: Location services
- **TensorFlow Lite**: On-device AI inference
- **Background Agents**: Continuous processing and optimization

## 🔧 Development

### Code Quality
```bash
# Run code analysis
flutter analyze

# Format code
dart format .

# Check for outdated dependencies
flutter pub outdated
```

### Background Testing
The project includes a comprehensive background testing system:

#### Test Categories
- **Unit Tests** (every 30 min): Core functionality and AI systems
- **Integration Tests** (every 2 hours): Component interactions and AI communication
- **Widget Tests** (every 4 hours): UI behavior and user experience
- **Performance Tests** (every 6 hours): App metrics and AI inference speed
- **Quality Tests** (every hour): Code standards and OUR_GUTS.md compliance

#### Monitoring
- **Automated Reports**: Detailed test reports with AI system validation
- **Alert System**: Critical issue notifications
- **Performance Tracking**: Continuous monitoring of AI inference and user experience
- **Coverage Analysis**: Test coverage metrics with AI system coverage

## 🚀 Deployment

### GitHub Actions
The repository includes automated deployment workflows:

#### Build Targets
- **Android APK**: Automated Android builds with AI optimization
- **iOS**: Automated iOS builds (macOS runners)
- **Web**: Automated web deployment

#### Deployment Stages
- **Preview**: Automatic deployment for pull requests
- **Production**: Automatic deployment for main branch

### Manual Deployment
```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release

# Build for Web
flutter build web --release
```

## 📊 Monitoring

### Test Results
- **Coverage Reports**: Available in GitHub Actions artifacts
- **Performance Metrics**: Tracked over time with AI system performance
- **Quality Scores**: Automated quality assessment with OUR_GUTS.md compliance
- **Alert System**: Immediate notifications for issues

### GitHub Integration
- **Issue Templates**: Standardized bug reports and feature requests
- **PR Templates**: Comprehensive pull request guidelines
- **Automated Testing**: Runs on every push and PR
- **Deployment Automation**: Automatic builds and deployment

## 🤝 Contributing

### Development Workflow
1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly (unit, integration, widget tests)
5. **Submit** a pull request

### Testing Requirements
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Widget tests pass
- [ ] Code analysis clean
- [ ] Manual testing completed
- [ ] OUR_GUTS.md compliance verified

### Code Standards
- Follow Flutter/Dart style guidelines
- Write comprehensive tests
- Document new features
- Consider performance impact
- Test on multiple platforms
- Ensure OUR_GUTS.md compliance

## 📚 Documentation

### Project Documentation
- [Core Philosophy](OUR_GUTS.md): Project values and principles
- [Architecture Overview](docs/architecture_ai_federated_p2p.md): System architecture
- [Background Agent Guide](BACKGROUND_AGENT_DEVELOPMENT_GUIDE.md): AI system development
- [Testing Plan](test/testing/comprehensive_testing_plan.md): Testing strategy

### Recent Development Reports
- [Phase 4 Completion](reports/phase_4_performance_ai_completion_2025-08-04.md): Performance optimization and AI features
- [Current Status](CURRENT_PROJECT_STATUS_REPORT.md): Latest project status
- [AI Implementation](SPOTS_AI_IMPLEMENTATION_REPORT.md): AI system details

## 🐛 Known Issues

### Current Issues
- **Connectivity Test**: API compatibility issue in `spots_repository_impl_test.dart`
  - **Fix**: Update `.thenAnswer((_) async => ConnectivityResult.none);` to `.thenAnswer((_) async => [ConnectivityResult.none]);`

### Testing Issues
- **Widget Tests**: Need DI setup for full widget test suite
- **Integration Tests**: Some integration tests need implementation

## 📈 Performance

### Benchmarks
- **App Startup**: <3 seconds target
- **Memory Usage**: <100MB baseline
- **Database Operations**: <100ms average
- **Network Calls**: <2 seconds timeout
- **AI Inference**: <500ms for on-device AI features

### Monitoring
- **Continuous Performance Tracking**: Automated performance monitoring
- **Memory Leak Detection**: Built-in memory monitoring
- **Database Performance**: Query optimization tracking
- **Network Efficiency**: API call optimization
- **AI Performance**: Inference speed and accuracy monitoring

## 🔒 Security

### Security Features
- **Input Validation**: Comprehensive input sanitization
- **Data Encryption**: Local data encryption
- **Secure Authentication**: Token-based authentication
- **Content Moderation**: Age-restricted content system
- **AI Privacy**: On-device AI processing with no data transmission

### Security Monitoring
- **Automated Security Scans**: Regular vulnerability checks
- **Dependency Updates**: Automated dependency monitoring
- **Code Analysis**: Security-focused code review
- **AI Security**: Privacy-preserving AI system validation

## 📞 Support

### Getting Help
1. **Check Documentation**: Review project documentation
2. **Search Issues**: Look for existing issues
3. **Create Issue**: Use the bug report template
4. **Join Community**: Connect with other developers

### Reporting Issues
- **Bug Reports**: Use the bug report template
- **Feature Requests**: Use the feature request template
- **Security Issues**: Report security issues privately

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Sembast for local database solution
- Mapbox for map integration
- TensorFlow team for on-device AI capabilities
- All contributors and testers

---

**SPOTS - Where discovery meets organization** # Test commit
