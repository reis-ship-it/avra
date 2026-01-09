# Quick Firebase Setup Checklist

**Firebase Project:** avrai ✅ (already created)  
**Bundle IDs Needed:** `com.avrai.app` (iOS + Android)

---

## 🎯 Quick Steps (5 minutes)

### 1. Add iOS App (2 min)
- Go to: https://console.firebase.google.com/
- Select **avrai** project
- Click **iOS** icon (or ⚙️ Settings → Project Settings → Add App → iOS)
- Enter bundle ID: **`com.avrai.app`**
- Click **Register app**
- **Download** `GoogleService-Info.plist`
- **Replace** `ios/Runner/GoogleService-Info.plist` with downloaded file

### 2. Add Android App (2 min)
- Still in **avrai** project
- Click **Android** icon (or ⚙️ Settings → Project Settings → Add App → Android)
- Enter package name: **`com.avrai.app`**
- Click **Register app**
- **Download** `google-services.json`
- **Replace** `android/app/google-services.json` with downloaded file

### 3. Verify (1 min)
```bash
./verify_firebase_configs.sh
```

Should see:
```
✅ iOS bundle ID is correct: com.avrai.app
✅ Android package name is correct: com.avrai.app
```

### 4. Install Dependencies
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### 5. Test Build
```bash
flutter build apk --debug  # Android
flutter build ios --debug --no-codesign  # iOS
```

---

## ⚠️ Common Issues

**"Config file not found"**
- Ensure exact filenames: `GoogleService-Info.plist` and `google-services.json`
- Check they're in: `ios/Runner/` and `android/app/`

**"Bundle ID mismatch"**
- Re-run `./verify_firebase_configs.sh`
- If still wrong, re-download from Firebase Console
- Make sure you selected bundle ID `com.avrai.app` when registering

**Build errors after config update**
```bash
flutter clean
cd ios && rm Podfile.lock && pod install && cd ..
flutter pub get
```

---

## ✅ What to Expect After Setup

1. **Config files** will have `com.avrai.app` instead of `com.spots.app`
2. **Firebase SDK** will initialize correctly
3. **Builds** will work with new bundle IDs
4. **Firebase services** (Auth, Firestore, etc.) will be available

---

## 📚 Full Guide

See `FIREBASE_SETUP_GUIDE.md` for detailed instructions and troubleshooting.
