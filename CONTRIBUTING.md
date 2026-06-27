# Contributing to PureText

Thanks for contributing.

## Before You Start

- Use macOS 13 or later when testing.
- Use a recent Xcode release with Swift 6.2 support.
- Keep the app focused on plain-text editing. Avoid adding rich-text behavior unless the project direction changes explicitly.

## Development Setup

1. Clone the repository.
2. Open the package in Xcode through `Package.swift`.
3. Build and run the `PureText` scheme.

For the iOS app:

1. Open `Apps/PureTextiOS/PureTextiOS.xcodeproj`.
2. Copy `Apps/PureTextiOS/Config/Local.example.xcconfig` to `Apps/PureTextiOS/Config/Local.xcconfig`.
3. Fill in your local bundle identifier and development team in that file.
4. Select the `PureTextiOS` target and your personal signing team if needed in Xcode.
5. Install and run the app locally on your device or in the iOS Simulator.
Do not commit `Apps/PureTextiOS/Config/Local.xcconfig` or any other account-specific signing change.
The tracked `Shared.xcconfig` should stay generic and free of personal bundle identifiers or team values.
When preparing iOS distribution work, also keep App Store Connect keys, export option files, and provisioning assets outside Git-tracked paths.

The repository also contains the local shared package `Packages/PureTextCore`. Any code moved there must remain genuinely compatible with both macOS and iOS.
Before merging changes in the shared core, run `./scripts/validate_puretextcore_compatibility.sh` when the necessary local Xcode platform components are available.
The `Apps/` directory is reserved for future platform-specific apps, so new iOS UI code should land there instead of being mixed into the macOS app or the shared core.

## Pull Requests

Please keep pull requests focused and include:

- a concise summary of the change
- why the change is needed
- test steps
- screenshots or a short screen recording for visible UI changes

If the change affects supported file types, document the behavior in `README.md` and `CHANGELOG.md`.
If the change is meant to ship in the next GitHub release, also review the release publication steps in `README.md`.
If the change affects the iOS app, include whether it was validated on-device, in the Simulator, or both.
If the change affects iOS distribution or App Store readiness, also review `docs/ios-app-store-release.md`.

## Release Documentation

Before opening or merging a release-oriented change, make sure the repository documentation stays aligned with what users will download from GitHub:

- update `README.md` when install steps, supported behavior, screenshots, or release instructions change
- update `CHANGELOG.md` with the user-visible scope of the release
- confirm the version referenced in release notes matches `App/Info.plist`
- mention any required manual verification steps in the pull request description when the UI or packaging flow changes
- keep signing teams, personal bundle identifiers, provisioning choices, and other Apple account-specific values outside Git-tracked files
- keep any future App Store Connect keys, issuer IDs, and CI publishing credentials in secure local storage or CI secrets instead of the repository

## Code Style

- Follow the existing AppKit-based architecture.
- Prefer small, explicit types over broad abstractions.
- Add `///` documentation to new public or important types and functions.
- Preserve plain-text behavior and avoid introducing hidden formatting side effects.
- Do not move code into `PureTextCore` unless its imports, APIs, and runtime behavior are confirmed to be compatible across macOS and iOS.
- Keep future iOS app structure isolated under `Apps/` and preserve `PureText` as the public product name.

## Issues

When reporting a bug, include:

- macOS version
- Xcode version, if relevant
- the file type involved
- reproducible steps
- expected behavior
- actual behavior

## Discussion

For larger changes, open an issue first so scope and direction can be aligned before implementation.
