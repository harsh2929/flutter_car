# 🚗 Car Management App

An elegant **Flutter web application** for managing cars.
---

## 🌟 Features

### 🚀 Core Functionalities
- **User Authentication**: Secure login and signup system using Firebase Authentication.
- **Car Management**: 
  - Add new cars with up to 10 images.
  - View detailed car entries.
  - Edit car details, including title, description, tags, and images.
  - Delete car entries.
- **Search Functionality**: 
  - Global search for cars based on title, description, and tags.
- **Image Uploads**: 
  - Upload car images to Firebase Storage with support for multiple image uploads.
  - Displays uploaded images dynamically.

### 🎨 Design Highlights
- **Modern UI/UX**: 
  - Background video with frosted-glass login and signup forms.
  - Fully responsive design for web browsers.
- **Interactive Dashboard**: Intuitive car listing page with sorting and searching options.

### 📡 Tech Stack
- **Frontend**: Flutter (Web)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **Deployment**: Vercel

---

## 🛠️ Installation Instructions

### 1. Clone the Repository

git clone https://github.com/your-username/car-management-app.git
cd car-management-app
flutter pub get

Create a Firebase project in the Firebase Console.
Enable Authentication, Firestore Database, and Firebase Storage.
Download the google-services.json and firebase_options.dart files as per FlutterFire documentation.
Place the files in the appropriate directories.


Project structure

lib/
├── main.dart                # Application entry point
├── firebase_options.dart    # Firebase configuration (auto-generated)
├── models/
│   └── car.dart             # Car model
├── services/
│   ├── auth_service.dart    # Firebase Authentication
│   ├── firestore_service.dart # Firestore Database operations
│   └── storage_service.dart # Firebase Storage operations
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart # Login UI
│   │   └── signup_screen.dart # Signup UI
│   ├── home_screen.dart     # Dashboard for managing cars
│   └── car/
│       ├── car_create_screen.dart # Add car UI
│       ├── car_detail_screen.dart # View/edit car details
│       └── car_list_screen.dart # List all cars
├── widgets/
│   ├── custom_drawer.dart   # Reusable side navigation drawer
│   └── tag_input_field.dart # Tag input widget
└── utils/
    ├── constants.dart       # App-wide constants
    └── theme.dart           # App theme

