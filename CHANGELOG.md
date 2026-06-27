# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Local shared package `Packages/PureTextCore` for document state, file types, and formatting logic intended to stay compatible with macOS and iOS.
- Initial iOS/iPadOS app scaffold in `Apps/PureTextiOS`, including a SwiftUI shell, `UITextView`-based editor, file import/export flow, and session draft recovery.
- Core compatibility validation script and GitHub Actions workflow for checking `PureTextCore` on macOS and on iOS-capable environments.
- iOS App Store preparation guide and a local archive helper script that keep publication credentials outside the repository.
- Local App Store Connect metadata template for organizing the iOS listing before submission.
- Local export helper script and example export options template for moving from `.xcarchive` to a local iOS distribution export without committing sensitive settings.

### Changed
- The repository now separates macOS app code, shared core code, and the future iOS app structure explicitly.
- The iOS app currently targets local Xcode installation on a personal device instead of external distribution.
- The iOS project now reads local signing settings from an ignored `Local.xcconfig`, keeping Apple account-specific values out of GitHub.
- The iOS documentation now treats direct installation on a personal iPhone as the primary current workflow, while keeping App Store publication as optional future guidance.

### Fixed
- iOS document opening now declares supported content types explicitly, preventing `.txt` files from appearing unavailable in the Files picker.
- iOS saving now preserves the original security-scoped file URL, fixing save failures in iCloud Drive (`com-apple-CloudDocs`).
- The initial iOS layout was compacted and the app icon catalog was populated so the app installs with a visible icon and a cleaner editor presentation.
- Recovered iOS drafts now avoid suggesting duplicate filename extensions when the user saves them again.

### Removed

## [0.3.2] - 2026-06-27

### Added
- Recent files submenu in File, with dynamic entries and a clear-history action.

### Changed
- The tab close button now appears on the right side of each custom tab.
- The tab close button is now pushed closer to the right edge of the tab, independent of the title width.
- The main window header now uses a more compact visual height.
- The unsupported View-menu toggle for showing tabs, enters, and linefeeds was removed to preserve the plain-text editing behavior.
- Release publication documentation was expanded to cover preflight review, GitHub workflow execution, and post-publication verification.

### Fixed

### Removed

## [0.2.0] - 2026-06-23

### Added
- GitHub Actions release workflow for publishing prebuilt macOS ZIP archives.
- Local release packaging script for generating a distributable archive from `PureText.app`.
- Support for opening and saving `.md`, `.yml`, `.bru`, and `.pom` files.
- Text search and replace actions in the Edit menu using the native AppKit find flow.
- Selection transforms for uppercase, lowercase, and proper case in the Edit menu.

### Changed
- The release workflow now publishes a GitHub Release for both tag-based and manually triggered runs.
- POM formatting now follows the same tag-based indentation flow used for HTML.
- YML and BRU are now treated as plain-text files without formatting.

### Fixed

### Removed

## [0.1.0] - 2026-06-20

### Added
- Native macOS AppKit editor window with a custom tab strip.
- Plain-text editing for TXT, CSV, JSON, LJSON, XML, and HTML files.
- Opening files from Finder, Dock file drops, and the standard Open panel.
- Untitled document creation when the app launches without input files.
- Save, Save As, and close-with-unsaved-changes confirmation flows.
- File-type-aware formatting helpers for JSON, LJSON, XML, and HTML.
- Light and dark appearance support following the active macOS appearance.
- App bundle packaging script and bundled application icon asset.

### Changed
- Public repository documentation and contribution guidance were added for open source publishing.
- User-facing strings now follow the active macOS language preference for English and Brazilian Portuguese.

### Fixed
- Main window startup behavior was stabilized by enforcing a visible minimum window size and restoring a valid on-screen frame.

### Removed
