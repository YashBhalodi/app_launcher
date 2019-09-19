# app_launcher

An Application that lists all the installed application in the system and provide an option to launch it.

# Update
Now you can also create amazing application launcher with just copy pasting and addding few lines to your "pubspec.yaml" files.
Here is the list of steps:
  1. Download the file [apps_list_card.dart](https://github.com/YashBhalodi/app_launcher/blob/master/lib/apps_list_card.dart)
  2. Place the downloaded file in your project directory anywhere.
  3. Import the file by adding following to your dart file where you want the application list to appear.
  
      `import 'package:<path of the file in your project directory>/apps_list_card.dart';`
  4. Next, you will need to add following dependency to your pubspec.yaml file
      ```
      device_apps: ^1.0.8
      fluttertoast: ^3.1.3
      vibrate: ^0.0.4
      ```
  5. The widget uses vibration to notify the user of launching an application. For that, you will need to following permission to your Android Manifest.
      
      `<uses-permission android:name="android.permission.VIBRATE"/>`
  6. Now you are all set to use the class `AppsCardList()`.
### Class AppsCardList definition
```
AppsCardList({Key key, 
      bool includeSystemApps = true, 
      bool onlyAppsWithLaunchIntent = true, 
      double cardHeight = 80.0, 
      double cardMarginBottom = 10.0, 
      bool getIcons = true, 
      TextStyle appNameStyle = const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600), 
      bool sortAlphabetically = true})
```
  7. Glory to Flutter!
## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
