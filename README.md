# DesiLife: Indian Life Simulator

A minimalist, text-based life simulator set in India. Make life choices, build careers, manage relationships, and shape your character's legacy.

## Features

- **Dynamic Lifepaths:** Choose from various careers, education paths, and lifestyle choices.
- **Specialized Careers:** Deep dive into specialized professions like Politics, Acting, Influencer, and Sports.
- **Events & Choices:** Hundreds of random and contextual life events that shape your character's stats.
- **Offline Play:** Fully offline, local-first architecture using Hive.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.10+)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Architecture

- `lib/core/`: Game engine, simulation data, and event definitions.
- `lib/models/`: Hive data models (Character, LifeEvent, EventChoice).
- `lib/screens/`: UI pages for the game interface.
- `lib/widgets/`: Reusable UI components.

## Building for Production

To build an APK for Android:

```bash
flutter build apk --release
```

## License

All rights reserved.
