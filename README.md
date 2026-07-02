# PureText

PureText is a minimal open source macOS text editor for plain and structured text files. It provides a native AppKit interface with tabbed editing, drag-and-drop opening from Finder or the Dock, and lightweight formatting helpers for TXT, MD, CSV, JSON, XML, HTML and others.

## Screenshot

<p align="center">
  <img src="docs/images/puretext-screenshot.png" alt="PureText screenshot" width="1100">
</p>

## Download

Download the latest prebuilt ZIP from the repository's **GitHub Releases** page and extract `PureText.app` to use PureText without building it locally.

**Quick steps**

1. Open the repository's **Releases** page
2. Download the latest `PureText-<version>-macOS.zip`
3. Extract the archive
4. Move `PureText.app` to `Applications`

End users do not need Xcode or a local Swift toolchain.

## Project Goal

The project aims to offer a small, focused editor for unformatted text on macOS without introducing rich text behavior, project management, or external runtime dependencies.

## Architecture

- Framework: AppKit
- Language: Swift
- Build system: Swift Package Manager for development, plus a packaging script for generating a `.app` bundle
- Shared core: local Swift package `Packages/PureTextCore` for logic intended to stay compatible with macOS and iOS

## Repository Layout

- `Sources/PureText`: current macOS app implementation and AppKit UI
- `Packages/PureTextCore`: shared logic that must remain compatible with macOS and iOS
- `Apps/PureTextiOS`: initial iOS/iPadOS app project scaffold for local Xcode development and device installation

## Current Status

- macOS remains the published app distributed through GitHub Releases.
- iOS now has a local Xcode project scaffold validated on a personal device for opening, editing, saving, reopening, formatting JSON, and restoring an unsaved session draft.
- iOS distribution is still limited to local installation through Xcode during this phase.

## Features

- Open and edit `.txt`, `.md`, `.csv`, `.yml`, `.bru`, `.pom`, `.json`, `.ljson`, `.xml`, and `.html` files
- Open files by launching the app, using the File menu, or dragging supported files onto the Dock icon
- One file per tab, with close controls directly in the tab strip
- Automatic untitled tabs named `Untitle1`, `Untitle2`, and so on
- Plain-text editing with undo support
- Native search and replace actions from the Edit menu
- Native print action for the current tab from the File menu
- Recent files list in the File menu
- Selection transforms for uppercase, lowercase, and proper case
- File-type-aware formatting for JSON, LJSON, XML, HTML, and POM
- Light and dark appearance support based on the current macOS setting
- Basic document state handling for unsaved changes

## Requirements

- macOS 13.0 or later
- Xcode 26.3 or later recommended
- Swift 6.2.4 or later recommended

The minimum macOS version is defined in `Package.swift` and `App/Info.plist`.

## Getting Started

### Download a prebuilt app

If you only want to use PureText, download the latest ZIP from the repository's **GitHub Releases** page and extract `PureText.app`.

The release workflow builds the app on GitHub-hosted macOS runners and publishes a ready-to-run archive.

### Clone the repository

```bash
git clone https://github.com/<your-account>/PureText.git
cd PureText
```

### Open in Xcode

The macOS app does not use an `.xcodeproj` file. Open the Swift package directly:

1. Open Xcode.
2. Choose **File > Open...**
3. Select the repository folder or `Package.swift`

Xcode will load the package as a macOS executable target named `PureText`, together with the local package dependency `PureTextCore`.

### Open the iOS app in Xcode

The iOS app now lives in its own Xcode project:

1. Open Xcode.
2. Choose **File > Open...**
3. Select `Apps/PureTextiOS/PureTextiOS.xcodeproj`

The project contains the `PureTextiOS` target, depends on the local package `Packages/PureTextCore`, and is intended for local device installation during this phase.
Local signing and publishing settings should stay in `Apps/PureTextiOS/Config/Local.xcconfig`, which is ignored by Git. The repository only keeps `Shared.xcconfig` and `Local.example.xcconfig`.

The current iOS MVP has already been validated locally on-device for:

- `.txt` open, edit, save, close, and reopen
- `.md` open, edit, and save
- `.json` open, edit, format, save, and reopen
- unsaved session draft recovery after backgrounding and reopening the app

### Local iOS signing

To keep personal Apple Developer settings out of GitHub:

1. Copy `Apps/PureTextiOS/Config/Local.example.xcconfig` to `Apps/PureTextiOS/Config/Local.xcconfig`
2. Set your local `PURETEXT_IOS_BUNDLE_IDENTIFIER`
3. Set your local `PURETEXT_IOS_DEVELOPMENT_TEAM`
4. Keep using Xcode automatic signing locally

`Local.xcconfig` is ignored by Git and should not be committed.
The tracked `Shared.xcconfig` intentionally keeps only safe placeholder defaults.

### Install on your iPhone

For personal use and direct device installation, this is the current recommended iOS flow:

1. Open `Apps/PureTextiOS/PureTextiOS.xcodeproj` in Xcode
2. Select your iPhone as the run destination
3. Keep local signing in `Apps/PureTextiOS/Config/Local.xcconfig`
4. Use **Product > Run**

This path does not require App Store Connect.

### Optional local iOS archive

To generate a local iOS release archive from Terminal:

```bash
./scripts/archive_ios_app.sh
```

This is useful for internal validation, but not required for day-to-day installation on your own iPhone.

### Future App Store preparation

For the safe local workflow to archive, validate, and upload the iOS app without committing Apple-specific data, see [`docs/ios-app-store-release.md`](docs/ios-app-store-release.md).
For a simple checklist/template of App Store Connect listing fields, see [`docs/ios-app-store-metadata-template.md`](docs/ios-app-store-metadata-template.md).

To run the future App Store Connect-oriented export flow after you prepare your local export options:

```bash
./scripts/export_ios_archive.sh
```

This export path depends on the method configured in `ExportOptions.local.plist` and may contact Apple services.

### Build and run in Xcode

1. Select the `PureText` scheme.
2. Choose **Product > Run**.
3. The app launches as a standard macOS app window.

### Build from Terminal

To compile and package the app bundle used in local testing:

```bash
./scripts/build_app.sh
```

The generated app bundle is placed in:

```text
.artifacts/PureText.app
```

To validate the shared core package compatibility:

```bash
./scripts/validate_puretextcore_compatibility.sh
```

The script always validates `PureTextCore` on macOS and attempts an iOS Simulator validation when the required Xcode platform components are installed locally.
The repository now includes an initial iOS app scaffold in `Apps/PureTextiOS/`, but iOS distribution still remains outside the current macOS release flow.

## Release Build

At the moment, release-style packaging is handled by [`scripts/build_app.sh`](scripts/build_app.sh), [`scripts/package_release.sh`](scripts/package_release.sh), and the GitHub Actions workflow [`.github/workflows/release.yml`](.github/workflows/release.yml). The local scripts:

- compiles the Swift package and its local dependencies with `swift build`
- generates icon assets from `Assets/PureTextIcon.png`
- assembles `PureText.app` in `.artifacts/`
- packages `PureText.app` into a distributable ZIP archive in `.artifacts/release/`

To create the archive locally:

```bash
./scripts/package_release.sh
```

## GitHub Release Publication

Before publishing a new release on GitHub:

1. Update the user-facing documentation affected by the release.
2. Review `CHANGELOG.md` and move the shipped items out of `Unreleased`.
3. Confirm `App/Info.plist` contains the version that should be published.
4. Optionally refresh screenshots if the interface changed.
5. Validate the package locally with `./scripts/package_release.sh` when practical.

To publish a prebuilt app for users without requiring a local build:

1. Push a tag such as `v0.3.3`
2. Let GitHub Actions run the `Release App` workflow
3. Download or share the generated ZIP from the GitHub Release page

The workflow also supports manual execution through **Actions > Release App > Run workflow**, and manual runs now create or update a GitHub Release using the provided version label or the current `Info.plist` version.

After the workflow finishes:

1. Verify the release title matches the app version.
2. Confirm the asset name follows `PureText-<version>-macOS.zip`.
3. Check that the generated notes or manual summary match the shipped features.
4. Download the ZIP once to confirm the archive expands into `PureText.app`.

If you plan to distribute signed builds outside your machine, you will still need to add your own code signing, notarization, and release automation.
For the iOS app, the current repository is prepared for local installation first; App Store or TestFlight publication should happen only after you set final local signing values and distribution metadata outside Git-tracked files.
If you later automate iOS distribution, keep App Store Connect credentials, API keys, provisioning details, and signing values in local machine settings or CI secrets, never in committed files.

## Initial Configuration

No external packages, environment variables, secrets, or service credentials are required.

The project currently depends only on:

- Xcode or the Xcode Command Line Tools
- macOS system frameworks such as `AppKit` and `UniformTypeIdentifiers`
- the local shared package `Packages/PureTextCore`

## Usage Examples

- Create a new untitled tab and start typing plain text
- Find and replace repeated text using the native macOS find interface
- Reopen a recently used file from the File menu
- Convert a selected snippet to uppercase, lowercase, or proper case from the Edit menu
- Open a JSON file and use the Format action to pretty-print objects and keys
- Open an XML or HTML file and normalize indentation by tag structure
- Drag a supported file onto the PureText Dock icon to open it in a new tab
- Work with multiple files in parallel using the custom tab strip

## Supported File Types

| Extension | Open | Save | Format |
| --- | --- | --- | --- |
| `.txt` | Yes | Yes | No |
| `.md` | Yes | Yes | No |
| `.csv` | Yes | Yes | No |
| `.yml` | Yes | Yes | No |
| `.bru` | Yes | Yes | No |
| `.pom` | Yes | Yes | Yes |
| `.json` | Yes | Yes | Yes |
| `.ljson` | Yes | Yes | Yes |
| `.xml` | Yes | Yes | Yes |
| `.html` | Yes | Yes | Yes |

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

For changes that affect behavior, include:

- a short explanation of the user impact
- the macOS and Xcode version used for testing
- screenshots or short recordings when the UI changes
- updates to `README.md` and `CHANGELOG.md` when release-facing behavior changes

## License

This repository includes an MIT license in [LICENSE](LICENSE).
