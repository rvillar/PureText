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

## Pull Requests

Please keep pull requests focused and include:

- a concise summary of the change
- why the change is needed
- test steps
- screenshots or a short screen recording for visible UI changes

If the change affects supported file types, document the behavior in `README.md` and `CHANGELOG.md`.
If the change is meant to ship in the next GitHub release, also review the release publication steps in `README.md`.

## Release Documentation

Before opening or merging a release-oriented change, make sure the repository documentation stays aligned with what users will download from GitHub:

- update `README.md` when install steps, supported behavior, screenshots, or release instructions change
- update `CHANGELOG.md` with the user-visible scope of the release
- confirm the version referenced in release notes matches `App/Info.plist`
- mention any required manual verification steps in the pull request description when the UI or packaging flow changes

## Code Style

- Follow the existing AppKit-based architecture.
- Prefer small, explicit types over broad abstractions.
- Add `///` documentation to new public or important types and functions.
- Preserve plain-text behavior and avoid introducing hidden formatting side effects.

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
