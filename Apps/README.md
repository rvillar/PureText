# Apps

This directory is reserved for future platform-specific PureText apps that should remain separate from the current macOS package and from the shared core package.

## Intended structure

- `Apps/PureTextiOS/`: future iOS and iPadOS app project or package
- `Packages/PureTextCore/`: shared logic validated for both macOS and iOS
- `Sources/PureText/`: current macOS app target that remains the published baseline during the refactor

## Rules for new platform apps

- Keep platform UI code out of `PureTextCore`.
- Move code into `PureTextCore` only after confirming imports, APIs, and runtime behavior are compatible with both macOS and iOS.
- Preserve the public product name `PureText`; use technical names like `PureTextiOS` only for internal repository organization.
- Keep platform publication secrets out of the repository; the iOS release flow is documented in `docs/ios-app-store-release.md`.
