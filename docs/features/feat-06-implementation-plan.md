---
title: "Implementation Plan — Feature #6: Address and String Utility Types"
issue_id: 6
platform: flutter
created: "2026-08-02"
---

## Micro-Tasks

### Task 1: Write failing tests (RED)
- **File**: `app_flutter/test/domain/address_string_test.dart`
- **Changes**: Create 12 tests covering all 8 value objects + validation
- **Driving test**: N/A (test-first)
- **Verification**: `flutter test test/domain/address_string_test.dart` — all 12 FAIL (classes don't exist yet)

### Task 2: Implement domain model (GREEN)
- **File**: `app_flutter/lib/domain/address_string.dart`
- **Changes**: 8 value object classes with pattern validation + exception class
- **Driving test**: Task 1 tests
- **Verification**: `flutter test test/domain/address_string_test.dart` — all 12 PASS

### Task 3: Integrate into validateFields (GREEN)
- **File**: `app_flutter/lib/domain/validation.dart`
- **Changes**: Add `physAddress`, `macAddress`, `uuid`, `dottedQuad` type handlers
- **File**: `app_flutter/test/domain/validation_test.dart`
- **Changes**: Add 4 validation integration tests
- **Driving test**: Validation integration tests
- **Verification**: `flutter test test/domain/address_string_test.dart test/domain/validation_test.dart` — ALL pass
- **Verification**: `flutter analyze` — zero new errors
