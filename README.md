# foo_my_food_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
// 以上是flutter官方的README
# FOO MY FOOD

FOO MY FOOD is an application that helps users automatically categorize and store purchased ingredients, track expiry dates with calendar synchronization (Google and Apple), suggest recipes based on ingredients nearing expiration, and track nutritional data for food items.

## Features
- Categorize and store user-purchased ingredients in a SQLite database.
- Provide expiry alerts and synchronize with Google and Apple calendars.
- Display recipe combinations based on ingredients that are close to expiration.
- Track nutritional data for each food item or dish.
- Store user-defined shelf life for food items.
- Multi-platform support using Flutter (iOS and Web).

## Prerequisites

Before you can run this project, you need to install and configure the following:
But I highly recommend looking for video tutorials online for all installation processes especially environment configuration. 
There are some environment configurations and settings that are not mentioned in this tutorial.

### 1. Install JDK 17
- Download JDK 17 from Oracle: [Oracle JDK 17](https://www.oracle.com/java/technologies/javase-jdk17-downloads.html)
- Follow installation instructions specific to your operating system.
- Set up the `JAVA_HOME` environment variable and add it to your system’s `PATH`.

### 2. Install Flutter SDK
- Download and install the Flutter SDK: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- Set up the environment variables for Flutter by adding the `flutter/bin` directory to your system’s `PATH`.

### 3. Install Xcode (for iOS Development)
- Download Xcode from the Mac App Store.
  
### 4. Install Android Studio (for Android Development)
- Download and install Android Studio: [Android Studio](https://developer.android.com/studio).
  
### 5. Install Flutter Plugin in VS Code
- Download and install [Visual Studio Code](https://code.visualstudio.com/).
- To install the Flutter plugin in VS Code, follow these steps:
  1. Open **VS Code**.
  2. Go to the **Extensions** 
  3. In the search bar, search `Flutter` 
  4. Click **Install** on both the **Flutter** and **Dart** extensions.
### 6. Verify Environment Setup with `flutter doctor`
- After installing all the necessary tools, use the following command to check if your environment is properly configured:
  
  ```bash
  flutter doctor
  
- If there are no errors in the installation it will show the result in the picture.
<img width="570" alt="截屏2024-09-05 下午5 34 35" src="https://github.com/user-attachments/assets/d4af7ed6-f4cd-492e-a497-abab1868ded4">

## Important: Clean Project Before Pushing to Git

Before pushing your changes to the Git repository, always run the following command to clean up build files and prevent uploading thousands of unnecessary files:

```bash
flutter clean
```
## Getting Dependencies

Before running the project, make sure to fetch all dependencies by running:

```bash
flutter pub get
```

## Running the Project

To run the project, use the following command:

```bash
flutter run
```



