# Test Suite

This directory contains unit and integration tests for the ASR Data Record Mobile App.

## Test Structure

```
test/
├── models/
│   └── submission_test.dart          # Submission model tests
├── services/
│   ├── auth_service_test.dart         # Authentication service tests
│   ├── encryption_service_test.dart   # Encryption service tests (requires platform channels)
│   ├── logging_service_test.dart      # Logging service tests
│   └── submission_service_test.dart   # Submission service tests
└── integration/
    └── submission_flow_test.dart      # End-to-end flow tests
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/models/submission_test.dart
```

### Run tests with coverage
```bash
flutter test --coverage
```

## Test Coverage

### ✅ Unit Tests (Passing)

- **Submission Model** (6 tests)
  - Model creation and serialization
  - JSON serialization/deserialization
  - Type handling (auto/manual)
  - copyWith functionality
  - Optional fields handling

- **Logging Service** (9 tests)
  - Info/warn/error logging
  - Log filtering (category, time range, severity)
  - Log bundle creation
  - Stack trace sanitization
  - Log clearing

- **Auth Service** (10 tests)
  - User registration
  - User login
  - Token storage and retrieval
  - Authentication status checking
  - Logout functionality
  - Error handling

- **Submission Service** (6 tests)
  - Submission creation
  - Metadata inclusion (timings, client info, logs)
  - Upload functionality
  - Error handling
  - Authentication checks

### ⚠️ Platform-Dependent Tests

Some tests require platform channels and may fail in unit test environment:

- **Encryption Service**: Requires `FlutterSecureStorage` platform channels
  - These tests are marked as skipped
  - Encryption functionality is verified in integration tests

- **Submission Service Queue**: Requires `path_provider` platform channels
  - Queue operations log warnings but don't fail tests
  - Core submission logic is tested independently

## Integration Tests

Integration tests verify end-to-end flows:

- **Submission Flow**: Register → Create Submission → Upload
- **Offline Queue**: Create submission without immediate upload
- **Retry Logic**: Failed upload retry mechanism
- **Metadata Collection**: Full metadata inclusion in submissions

## Notes

- Tests use `mockito` for mocking dependencies
- Mock files are generated using `build_runner`
- Some tests require platform channels (better tested in widget/integration tests)
- All critical business logic is covered by unit tests

## Generating Mocks

If you modify service interfaces, regenerate mocks:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
