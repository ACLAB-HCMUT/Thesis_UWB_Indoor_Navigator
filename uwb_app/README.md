# uwb_app

A new UWB project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

To run the mobile app:
1. Install all necessary packages: flutter clean -> flutter pub get
2. Change ip address in 'device.dart' to your ip address of device running mongoDB server 
String baseUrl = 'http://<your url>:3000/device'
3. Change user name and password at mqtt.dart
4. Run the mobile app: flutter run

