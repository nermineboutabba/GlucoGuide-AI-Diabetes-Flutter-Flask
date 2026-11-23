# GlucoGuide AI — Smart Diabetes Predictor (Flutter + Flask ML)

Cross-platform mobile health companion built with **Flutter (Riverpod + fl_chart)** connected to a **Python Flask + SQLAlchemy + Scikit-Learn** REST API predicting post-meal blood glucose trends from carbohydrate intake and insulin dosage.

## Features
- **Patient Authentication & Auto-Seeded Demo**: Secure password hashing (`werkzeug.security`), persistent Riverpod session state, and an automatically seeded demo patient (`demo@glucoguide.tn` / `Demo1234!`) with chronological sample readings.
- **ML Glucose Prediction (`/predict`)**: Linear regression model trained on physiological carb/insulin response features (`0.8 * carbs - 10 * insulin`) returning predicted `mg/dL` readings and risk triage (`LOW`, `NORMAL`, `HIGH`).
- **Interactive Trend Charts (`fl_chart`)**: Smooth gradient spline chart tracking predicted readings alongside min/max/average telemetry cards.
- **Reading History & Advice Log**: Scrollable entry log with risk badges, dietary/clinical tips, and automatic local cache fallback.

## Project Structure
```
GlucoGuide-AI-Diabetes-Flutter-Flask/
├── glucoguide_app/             # Flutter Riverpod mobile & web client
│   ├── lib/
│   │   ├── core/               # AuthGate & SharedPreferences local storage
│   │   ├── models/             # GlucoseEntry & UserModel
│   │   ├── providers/          # Auth, Prediction & GlucoseHistory Riverpod state
│   │   ├── screens/            # Login, Register, Entry, History, Chart, Profile
│   │   └── services/           # ApiService & AuthService
│   └── pubspec.yaml
├── glucoguide_backend/         # Flask + SQLAlchemy + Scikit-Learn API
│   ├── app.py                  # REST routes + startup demo data seeder
│   ├── models.py               # SQLAlchemy schemas + LinearRegression predictor
│   └── requirements.txt
└── docs/
    ├── Rapport_de_Projet_Flutter.pdf
    └── screenshots/
```

## Quick Start

1. **Start the Flask ML backend** (listens on port `5000`, auto-creates SQLite DB & demo user):
   ```bash
   cd glucoguide_backend
   pip install -r requirements.txt
   python app.py
   ```

2. **Launch the Flutter app** (connects to `10.0.2.2:5000` on Android Emulator or `127.0.0.1:5000` on Web):
   ```bash
   cd glucoguide_app
   flutter pub get
   flutter run
   ```
   Tap **Try Demo Patient** on the login screen to sign in with preloaded glucose history and charts.
