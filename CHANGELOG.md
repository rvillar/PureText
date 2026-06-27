# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

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
