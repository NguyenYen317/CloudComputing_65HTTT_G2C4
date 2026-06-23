import 'dart:convert';

import 'dart:html' as html;
import 'dart:ui_web' as ui_web; // Chữ 'ui_web' là chuẩn mới của Flutter

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as web;

import 'core/core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

part 'app.dart';
part 'models/user_model.dart';
part 'models/food_model.dart';
part 'models/cart_item_model.dart';
part 'models/cart_model.dart';
part 'models/order_model.dart';
part 'models/order_status_model.dart';
part 'models/ml_prediction_model.dart';
part 'models/bigquery_event_model.dart';
part 'screens/admin/admin_best_selling_screen.dart';
part 'screens/admin/admin_bigquery_screen.dart';
part 'screens/admin/admin_dashboard_screen.dart';
part 'screens/admin/admin_food_form_screen.dart';
part 'screens/admin/admin_food_screen.dart';
part 'screens/admin/admin_layout_screen.dart';
part 'screens/admin/admin_ml_screen.dart';
part 'screens/admin/admin_order_detail_screen.dart';
part 'screens/admin/admin_order_screen.dart';
part 'screens/admin/admin_revenue_screen.dart';
part 'screens/admin/admin_suggestion_screen.dart';
part 'screens/admin/admin_user_screen.dart';
part 'screens/auth/login_screen.dart';
part 'screens/auth/register_screen.dart';
part 'screens/auth/role_check_screen.dart';
part 'screens/customer/cart_screen.dart';
part 'screens/customer/checkout_screen.dart';
part 'screens/customer/customer_home_screen.dart';
part 'screens/customer/food_detail_screen.dart';
part 'screens/customer/food_list_screen.dart';
part 'screens/customer/my_orders_screen.dart';
part 'screens/customer/order_detail_screen.dart';
part 'screens/customer/feedback_page.dart';
part 'screens/splash/splash_screen.dart';
part 'services/auth_service.dart';
part 'services/food_service.dart';
part 'services/cart_service.dart';
part 'services/order_service.dart';
part 'services/admin_service.dart';
part 'services/bigquery_service.dart';
part 'services/ml_service.dart';
part 'providers/auth_provider.dart';
part 'providers/food_provider.dart';
part 'providers/cart_provider.dart';
part 'providers/order_provider.dart';
part 'providers/admin_provider.dart';
part 'providers/ml_provider.dart';
part 'screens/home_page.dart';
part 'widgets/food/food_card.dart';
part 'widgets/food/food_image.dart';
part 'widgets/food/food_filter.dart';
part 'widgets/cart/cart_item_card.dart';
part 'widgets/cart/cart_summary.dart';
part 'widgets/cart/count_badge.dart';
part 'widgets/order/order_status_badge.dart';
part 'widgets/zoho/zoho_form_sheet.dart';
part 'widgets/admin/dashboard_stat_card.dart';
part 'widgets/admin/admin_notice.dart';
part 'widgets/admin/ml_prediction_card.dart';
part 'widgets/auth_field.dart';
part 'widgets/empty_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Platform-specific WebView initialization is handled by the plugin
  // and platform packages. No manual assignment here to avoid
  // compatibility issues across webview_flutter versions.
  runApp(const OrderFoodApp());
}
