# GADS Site Manager Flutter App - Build APK

## Files included
- `lib/main.dart` - full app source
- `assets/gads_logo.png` - app logo
- `pubspec.yaml` - Flutter dependencies
- `.github/workflows/flutter_build_apk.yml` - GitHub Actions APK builder
- `SUPABASE_POLICIES_RUN_THIS.sql` - Supabase RLS policies for testing

## GitHub upload
Upload all files/folders to GitHub repository:
- lib
- assets
- .github
- pubspec.yaml
- README_BUILD_APK.md
- SUPABASE_POLICIES_RUN_THIS.sql

## Build APK
1. Go to GitHub → Actions
2. Open `Flutter Build APK`
3. Click `Run workflow`
4. Wait 5–15 minutes
5. Open completed build
6. Download artifact `app-release-apk`
7. Extract ZIP to get `app-release.apk`
8. Install APK in Android phone

## App first login
1. Open app
2. Click `Cloud Settings`
3. Enter Supabase Project URL
4. Enter Publishable Key only (`sb_publishable_...`)
5. Test connection
6. Login using:
   - Username: SUP001
   - Password: 1234