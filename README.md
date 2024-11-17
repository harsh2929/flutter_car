🚗 Car Management App
An elegant Flutter web application for managing cars

🌟 Features
🚀 Core Functionalities
User Authentication: Secure login and signup system using Firebase Authentication.
Car Management:
Add new cars with up to 10 images.
View detailed car entries.
Edit car details, including title, description, tags, and images.
Delete car entries.
Search Functionality:
Global search for cars based on title, description, and tags.
Image Uploads:
Upload car images to Firebase Storage with support for multiple image uploads.
Displays uploaded images dynamically.
🎨 Design Highlights
Modern UI/UX:
Background video with frosted-glass login and signup forms.
Fully responsive design for web browsers.
Interactive Dashboard: Intuitive car listing page with sorting and searching options.
📡 Tech Stack
Frontend: Flutter (Web)
Backend: Firebase (Authentication, Firestore, Storage)
Deployment: Vercel
🛠️ Installation Instructions
1. Clone the Repository
git clone https://github.com/your-username/car-management-app.git
cd car-management-app
2. Install Dependencies
Ensure you have Flutter installed. Then, run:

flutter pub get
3. Set Up Firebase
Create a Firebase project in the Firebase Console.
Enable Authentication, Firestore Database, and Firebase Storage.
Download the google-services.json and firebase_options.dart files as per FlutterFire documentation.
Place the files in the appropriate directories.
4. Run the Application
For development:

flutter run -d chrome
To build for production:

flutter build web



📂 Project Structure
lib/
├── main.dart                # Application entry point
├── firebase_options.dart     
├── models/
│   └── car.dart             
├── services/
│   ├── auth_service.dart    
│   ├── firestore_service.dart  
│   └── storage_service.dart  
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart 
│   │   └── signup_screen.dart 
│   ├── home_screen.dart    
│   └── car/
│       ├── car_create_screen.dart # Add car UI
│       ├── car_detail_screen.dart # View/edit car details
│       └── car_list_screen.dart # List all cars
├── widgets/
│   ├── custom_drawer.dart   
│   └── tag_input_field.dart 
└── utils/
    ├── constants.dart       
    └── theme.dart           
🛡️ Security Rules
Set up Firebase security rules to restrict access to authenticated users only.

🔮 Future Enhancements
Add real-time notifications for car-related updates.
Implement advanced filters and sorting for car listings.
Add support for more file types (e.g., car-related documents).
🤝 Contributing
Contributions are welcome! To get started:

Fork this repository.
Create a new branch:
git checkout -b feature-branch-name
Commit your changes:
git commit -m "Added a new feature"
Push to your branch:
git push origin feature-branch-name
Submit a pull request.
