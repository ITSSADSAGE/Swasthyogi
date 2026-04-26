---
description: How to build the Swasthyogi APK
---

To build the APK for Swasthyogi, follow these steps in your terminal:

1. **Check for errors**:
   Run `flutter analyze` to ensure there are no syntax errors.

2. **Clean the build cache** (recommended):
   ```powershell
   flutter clean
   ```

3. **Get dependencies**:
   ```powershell
   flutter pub get
   ```

4. **Build the Release APK**:
   Run the following command to generate a production-ready APK:
   ```powershell
   flutter build apk --release
   ```

   *Optional*: If you want to create smaller APKs for specific phone architectures (32-bit vs 64-bit), use:
   ```powershell
   flutter build apk --split-per-abi
   ```

5. **Locate the APK**:
   Once the build is finished, you can find the file at:
   `e:\Projects\Swasthyogi\swasthyogi\build\app\outputs\flutter-apk\app-release.apk`

6. **Install on Phone**:
   Copy this `app-release.apk` file to your Android phone and install it.
