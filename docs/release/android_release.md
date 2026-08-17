# Android Release

Pixel Harmony uses Google Play App Signing with a locally held upload key. Never
commit the upload keystore, passwords, or `flutter_app/android/key.properties`.

## Prerequisites

- Flutter 3.29.0 and its supported Android toolchain
- Android NDK `27.0.12077973`
- A securely backed-up upload keystore stored outside the repository
- A local `flutter_app/android/key.properties` file
- A unique build number for every Play Console upload

## Create the upload key

Create the destination directory yourself, then run this command in PowerShell.
`keytool` prompts for the passwords and certificate details; do not put passwords
on the command line.

```powershell
keytool -genkeypair -v -keystore "D:\Keys\pixel-harmony-upload-key.jks" -alias pixel-harmony-upload -keyalg RSA -keysize 2048 -validity 10000
```

Back up this keystore and its credentials securely. The same upload key is needed
for future releases.

## Configure local signing

Create `flutter_app/android/key.properties` locally with real values. This file is
ignored by Git. `storeFile` may be an absolute Windows path written with forward
slashes or escaped backslashes.

```properties
storePassword=
keyPassword=
keyAlias=
storeFile=
```

Example path syntax: `storeFile=D:/Keys/pixel-harmony-upload-key.jks`.

The release build intentionally fails with a signing-configuration message when
this file is missing, incomplete, or points to a missing keystore. It never falls
back to the debug key.

## Validate and build

From `flutter_app/`:

```powershell
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build appbundle --release
```

The signed bundle is written to:

```text
build/app/outputs/bundle/release/app-release.aab
```

Upload the AAB through Google Play Console and complete its release checks. Do not
upload APKs as the production Play artifact.

## Versioning

The version in `pubspec.yaml` uses `versionName+versionCode`. For example,
`1.0.0+1` maps to Android `versionName = 1.0.0` and `versionCode = 1`.

Before every Play upload, increment the build number after `+`; increment the
semantic version when the public release version changes. A Play Console upload
cannot reuse a previous version code.

## Secret handling

- Never commit `key.properties`, `*.jks`, `*.keystore`, or signing helper files.
- Never paste passwords into tracked documentation, scripts, or CI configuration.
- Store CI credentials only in the CI provider's encrypted secret storage.
- Keep an encrypted backup of the upload key and recovery information separately.
