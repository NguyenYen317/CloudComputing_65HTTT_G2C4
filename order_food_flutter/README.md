## DEPLOYED

# Deploy frontend
cd D:\Cloud\orderfood\order_food_flutter
dart format lib\main.dart
flutter analyze
flutter build web --dart-define=API_URL=https://flutter-orderfood-497814.as.r.appspot.com
firebase deploy --only hosting

# Deploy backend
cd D:\Cloud\orderfood\order-food-api
npm install
node --check server.js
gcloud app deploy

# Link Web 
https://flutter-orderfood-1b333.web.app