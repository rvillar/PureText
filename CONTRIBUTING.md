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
