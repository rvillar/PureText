# iOS App Store Release

This document describes the safe local workflow for preparing and publishing the `PureText` iOS app without committing Apple account-specific data to GitHub.

This is a future or optional flow. If your goal is only to install PureText directly on your own iPhone, prefer opening the Xcode project and using **Product > Run**.

## What Must Stay Out of GitHub

Keep these items only on your machine or in secure CI secrets:

- `Apps/PureTextiOS/Config/Local.xcconfig`
- App Store Connect API keys such as `AuthKey_XXXX.p8`
- local export option files such as `ExportOptions.local.plist`
- provisioning profiles downloaded for local signing
- personal Apple team identifiers when they are stored alongside other local signing choices

The repository should only contain safe shared defaults, documentation, and placeholder examples.

## Local Prerequisites

Before creating an App Store archive:

1. Join the Apple Developer Program for the Apple ID that will publish the app.
2. Open `Apps/PureTextiOS/PureTextiOS.xcodeproj` in Xcode.
3. Copy `Apps/PureTextiOS/Config/Local.example.xcconfig` to `Apps/PureTextiOS/Config/Local.xcconfig`.
4. Set your final iOS bundle identifier and development team in `Local.xcconfig`.
5. Sign in to the same Apple account in Xcode.
6. Confirm the app icon, display name, version, and build number are ready for the release you intend to upload.

## Create the Release Archive

### Option 1: Xcode

1. Open `Apps/PureTextiOS/PureTextiOS.xcodeproj`.
2. Select the `PureTextiOS` scheme.
3. Choose a generic iOS device destination in Xcode.
4. Run **Product > Archive**.
5. Wait for Organizer to open with the generated archive.

### Option 2: Local Script

Run:

```bash
./scripts/archive_ios_app.sh
```

The script stores the archive in:

```text
.artifacts/ios/archives/
```

This script depends on your local signing setup and does not store credentials in the repository.

## Validate and Upload

Once the archive is ready:

1. Open Organizer in Xcode.
2. Select the latest `PureText` iOS archive.
3. Choose **Distribute App**.
4. Pick **App Store Connect**.
5. Use automatic signing unless you deliberately maintain a separate manual signing flow.
6. Let Xcode validate the archive and fix any reported signing, entitlement, or metadata issue before uploading.

If you prefer to use command-line export or upload later, keep those credentials and export files outside Git-tracked paths.

## Optional Future Export

If you want an export flow in addition to Organizer:

1. Copy `Apps/PureTextiOS/Config/ExportOptions.example.plist` to `Apps/PureTextiOS/Config/ExportOptions.local.plist`.
2. Fill your local `teamID` and adjust any export choice that matches your Apple workflow.
3. Run:

```bash
./scripts/export_ios_archive.sh
```

By default the script exports the most recent archive from `.artifacts/ios/archives/` into `.artifacts/ios/export/`.
The exact behavior depends on the `method` and `destination` defined in your local export options file.
If you keep the example aligned with App Store Connect upload, Xcode may need the app record to exist remotely during export.
Keep `ExportOptions.local.plist` local only.

## App Store Connect Checklist

Before submitting the build for review, confirm that App Store Connect contains:

- the iOS app record with the final public name
- release notes for the target version
- app description, keywords, category, and support URL
- privacy answers and any required data collection disclosures
- iPhone and iPad screenshots that reflect the current UI
- age rating and content rights declarations
- the correct build attached to the version you intend to submit

You can draft those fields locally with [`docs/ios-app-store-metadata-template.md`](ios-app-store-metadata-template.md).

## Safe Repository Policy

Safe to commit:

- source code
- shared xcconfig defaults with placeholders
- public documentation
- non-sensitive build scripts
- generic release checklists

Do not commit:

- personal signing files
- App Store Connect keys
- export configuration files with local publishing data
- locally downloaded provisioning assets

## Recommended Release Sequence

1. Finalize code and documentation for the release.
2. Update version and build numbers for the iOS target.
3. Validate the app locally on device when practical.
4. Archive in Xcode or with `./scripts/archive_ios_app.sh`.
5. Validate and upload through Organizer.
6. Complete metadata and submit in App Store Connect.
