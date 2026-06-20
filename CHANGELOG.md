# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions release workflow for publishing prebuilt macOS ZIP archives.
- Local release packaging script for generating a distributable archive from `PureText.app`.
- Support for opening and saving `.md`, `.yml`, `.bru`, and `.pom` files.

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
