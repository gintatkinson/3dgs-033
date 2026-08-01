---
title: "Implementation Profile — Flutter"
project: "Digital Systems Engineering Pipeline"
tier: implementation
platform: flutter
created: "2026-06-29"
last_updated: "2026-06-29"
---

# Implementation Profile: Flutter

> This document governs feature implementation on Flutter only.
> Read alongside `.pipeline/constitution.md` (functional layer).

## Platform & Stack
- Framework: Flutter SDK 3.44.0 (stable channel)
- Language: Dart 3.12.0
- Forbidden dependencies: None explicitly prohibited. Evaluate each dependency for maintenance status and license compatibility.
- Required dependencies: `sqflite_common_ffi` (desktop SQLite), `firebase_core` + `cloud_firestore` (when targeting Firebase), `path_provider`, `http` (REST transport).

## Coding Standards
- Type safety: Use strict null safety. All variables must have explicit types; avoid `var` in public API signatures. Use `final` for immutable declarations.
- Naming conventions: Files — `snake_case.dart`. Directories — `snake_case`. Classes — `PascalCase`. Constants — `camelCase` with `const` keyword. Private members prefixed with `_`.
- Architecture pattern: MVVM (Model-View-ViewModel). Views are stateless widgets that consume ViewModels via dependency injection. ViewModels hold business logic and state. Models are data classes with serialization support.
- State management: Use `ChangeNotifier` + `ListenableBuilder` or `ValueListenableBuilder`. Avoid global state libraries unless justified by cross-cutting concerns.
- Dependency injection: Use constructor injection. Repository and DataSource instances are resolved at bootstrap via `RepositoryResolver`.

## Testing Mandates
- Unit tests: Required for all ViewModels, domain models, and data source adapters. Command: `flutter test`. Framework: `flutter_test`.
- Integration tests: Required for all user flows. Command: `flutter test -d macos integration_test/`. Framework: `integration_test` package.
- Widget tests: Required for custom widgets with non-trivial rendering logic.
- Benchmark thresholds: <10% regression against baseline for all performance metrics.
- TDD enforcement: Test-first approach required for all data layer and domain logic. UI tests may follow implementation.

## Build & Deployment
- Build command: `cd app_flutter && flutter build <platform>` where `<platform>` is `macos`, `linux`, `windows`, `web`, `android`, or `ios`.
- Lint command: `cd app_flutter && flutter analyze` (must pass with zero errors and zero warnings).
- CI/CD: Configured per repository settings. All pushes to integration branches trigger lint + unit test + integration test pipeline.
- Deployment target: Desktop (macOS, Linux, Windows) via direct bundle. Mobile (Android, iOS) via respective app stores when configured.

## Platform Audit Gates

These are the platform-specific constraints the parity auditor enforces against a
Flutter workspace. They live here rather than in `rules/` because each one names the
Flutter source tree, a Flutter widget, or Flutter UI directories, and would be
meaningless on another platform — see `rules/platform-independence.md`
§ *Where platform-specific details belong*. Enforced offline by
`parity_auditor/validators/profile_scoping_validator.py` and
`parity_auditor/validators/schema_mapping_validator.py`.

- **Profile Scoping Requires Platform Sources**: profile-compliance auditing runs over
  the Flutter source tree named by `target_directories.flutter`. A workspace with no
  matching source files is reported rather than passed. A silent pass would be
  indistinguishable from full compliance, and across a corpus of downstream projects an
  empty codebase is itself the finding worth aggregating.
- **Splitter Widgets Require Pointer Gesture Listeners**: any Dart source implementing a
  splitter — by filename or by containing `Splitter` — MUST attach pointer gesture event
  handling via `Listener` or `GestureDetector`. A splitter without one renders as a
  divider that cannot be dragged, so the layout requirement is met visually and not
  functionally.
- **Schema Mapping Requires Platform Sources**: schema-to-codebase mapping likewise runs
  over the Flutter source tree, and reports an empty codebase rather than reporting that
  every schema field is unmapped. Stated separately from the profile-scoping precondition
  above because the two gates fail independently and a grouped multi-workspace report
  must say which one fired.
- **Schema Fields Must Be Realised In The Codebase**: every container, list, grouping,
  typedef, identity, RPC, action, notification and leaf defined in the workspace schema
  modules MUST appear in the Flutter sources as a declaration of the corresponding kind.
  A schema node with no realisation is specified and unimplemented, which the schema is
  the source of truth for.
- **Schema Fields Must Be Bound To A UI Component**: a schema field realised in the
  codebase but absent from every file under `flutter_rules.ui_directories` is reachable
  in the data layer and invisible to the operator. Where the workspace declares UI
  directories at all, realisation without a UI binding is reported.

## Security & Ops
- API key management: API keys and secrets MUST NOT be committed to the repository. Use platform-specific secure storage (e.g., macOS Keychain, Android Keystore) or environment variables resolved at build time via `--dart-define`.
- Auth provider: Authentication is injected at the DataSource layer. The abstract `DataSource` interface does not prescribe an auth mechanism. Concrete implementations may use token-based, certificate-based, or unauthenticated access as appropriate.
- Data protection: All database files stored in the platform's application support directory. No sensitive data stored without encryption. Transport security (TLS) enforced for all remote data source connections.
- Logging: Structured logging via `dart:developer` in debug builds only. No personally identifiable information (PII) may be logged.
