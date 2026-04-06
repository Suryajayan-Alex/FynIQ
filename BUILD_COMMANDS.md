# Fyniq — Build Commands

## Development
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Release APK (sideload / direct install)
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release
```
**Output:** `build/app/outputs/flutter-apk/app-release.apk`

## Release App Bundle (Play Store)
```bash
flutter build appbundle --release
```
**Output:** `build/app/outputs/bundle/release/app-release.aab`

## Generate App Icons (after placing PNG files)
```bash
dart run flutter_launcher_icons
```
*Note: Ensure assets/icons/app_icon.png and assets/icons/app_icon_fg.png are present.*

## Check for issues
```bash
flutter analyze
flutter doctor -v
```
