# Repository Guidelines

This repo contains a lightweight specification for a simple countdown timer app. Implementation is intentionally left open. The current tree includes `doc/spec.md` (core product spec), an empty `proto/` for future interfaces, and common iOS ignores in `.gitignore`.

## Project Structure & Module Organization
- Source code: place app code under `ios/` (Xcode project) or `Sources/` (SwiftPM). Keep reusable logic in `TimerXCore/`.
- Tests: put unit/UI tests under `Tests/` (SwiftPM) or `TimerXTests/` and `TimerXUITests/` (Xcode).
- Docs: `doc/spec.md` is the contract—keep changes in sync with code. Add design notes under `doc/`.
- Protos: add `.proto` files under `proto/`; do not commit generated code.

## Build, Test, and Development Commands
- Build (SwiftPM): `swift build` — builds library/app targets under `Sources/`.
- Test (SwiftPM): `swift test --parallel` — runs XCTest with parallelization.
- Build (Xcode): `xcodebuild -scheme TimerX -destination 'platform=iOS Simulator,name=iPhone 15'` — CI-friendly build.
- Run tests (Xcode): `xcodebuild -scheme TimerX -sdk iphonesimulator -enableCodeCoverage YES test` — executes unit/UI tests.

## Coding Style & Naming Conventions
- Indentation: 2 spaces, no tabs. Line length ~120.
- Swift style: UpperCamelCase for types/modules, lowerCamelCase for vars/functions, `enum` cases lowerCamelCase.
- Files: one top-level type per file; name files after the primary type (e.g., `CountdownTimer.swift`).
- Lint/format: prefer SwiftFormat and SwiftLint; run before committing if configured.

## Testing Guidelines
- Framework: XCTest (+ XCUITest for UI). Name tests `test...()` and group by feature, e.g., `CountdownTimerTests`.
- Coverage: target ≥80% for core logic (`TimerXCore`). Focus on time math and state transitions from `doc/spec.md`.
- Determinism: use fakes for timers/clock; avoid `sleep` in tests.

## Commit & Pull Request Guidelines
- Messages: imperative mood, concise summary; English or Japanese acceptable (e.g., “Add countdown state machine”).
- Reference: link issues and spec sections (e.g., “refs doc/spec.md#7”).
- PRs: include purpose, screenshots or simulator GIFs for UI changes, test plan, and checklist confirming spec alignment.
- Scope: small, reviewable changes; keep refactors separate from feature changes.

## Security & Configuration Tips
- Do not commit derived artifacts, signing materials, or secrets. Keep environment-specific config outside VCS.
- If adding generated code (protos), ensure outputs are reproducible in CI and ignored locally.
