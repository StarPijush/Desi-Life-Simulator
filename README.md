# 🇮🇳 DesiLife: Indian Life Simulator

A minimalist BitLife-style text-based life simulator set in India.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10+
- Android Studio or VS Code with Flutter extension
- Android device or emulator (API 21+)

### Run
```bash
flutter pub get
flutter run
```

### Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## 📁 Project Structure
```
lib/
├── main.dart                        # App entry point + bootstrap
├── core/
│   ├── engine.dart                  # Core ageUp() game engine
│   ├── event_data.dart              # 30+ Indian life events + choice events
│   └── storage.dart                 # Hive offline persistence
├── models/
│   ├── character.dart               # Character model (Hive)
│   ├── character.g.dart             # Hive adapter (pre-generated)
│   └── event_choice.dart            # EventChoice + StatEffect models
├── screens/
│   ├── create_character_screen.dart # Name/city/gender selection
│   ├── home_page.dart               # Main game screen
│   └── legacy_page.dart             # Death/legacy screen
└── widgets/
    ├── pill_button.dart             # Reusable rounded button
    ├── status_bars.dart             # Animated stat progress bars
    └── event_dialog.dart            # Choice popup dialog
```

## 🎮 Gameplay
1. Create your character (name, city, gender)
2. Tap **Age +** to advance one year
3. Events appear in a live feed
4. Occasionally a **Life Decision** popup appears — choose wisely!
5. Your choices affect Happiness, Health, Smarts, Social & Karma
6. At death → Legacy Screen shows your life summary + karma verdict
7. Start a new life with karma bonus!

## ⚙️ Tech Stack
- Flutter 3.10+ / Dart 3
- Hive (offline local storage)
- Pure Flutter animations (no heavy animation libraries)
- 100% offline — no internet required

## 🏪 Play Store Metadata
**Title:** DesiLife: Indian Life Simulator  
**Short Desc:** Live your life your way! A minimalist Indian life simulator where your choices shape your Karma.  
**Keywords:** life simulator, indian game, bitlife india, offline game, text simulator, career simulator, karma game
