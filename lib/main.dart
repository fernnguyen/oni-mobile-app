import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/di/app_providers.dart';
import 'core/constants/constants.dart';
import 'core/services/database/database_service.dart';

void main() async {
  // Initialize binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  String rawUrl = Constants.supabaseUrl.trim();
  String rawAnonKey = Constants.supabaseAnonKey.trim();

  // Loại bỏ dấu nháy kép hoặc nháy đơn bao quanh nếu có (do lỗi escape khi truyền qua --dart-define)
  if (rawUrl.startsWith('"') && rawUrl.endsWith('"')) {
    rawUrl = rawUrl.substring(1, rawUrl.length - 1);
  }
  if (rawAnonKey.startsWith('"') && rawAnonKey.endsWith('"')) {
    rawAnonKey = rawAnonKey.substring(1, rawAnonKey.length - 1);
  }
  if (rawUrl.startsWith("'") && rawUrl.endsWith("'")) {
    rawUrl = rawUrl.substring(1, rawUrl.length - 1);
  }
  if (rawAnonKey.startsWith("'") && rawAnonKey.endsWith("'")) {
    rawAnonKey = rawAnonKey.substring(1, rawAnonKey.length - 1);
  }

  if (rawUrl.isNotEmpty && rawAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: rawUrl,
      anonKey: rawAnonKey,
    );
  }

  // Initialize app local db
  await DatabaseService.instance.init();

  // Initialize date formatting
  await initializeDateFormatting();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // One-time SQLite cache migration: clear out old unstable hashcode IDs
  final hasMigrated = sharedPreferences.getBool('stable_hash_migrated_v2') ?? false;
  if (!hasMigrated) {
    try {
      final db = DatabaseService.instance.database;
      await db.delete('Product');
      await db.delete('Transaction');
      await db.delete('OrderedProduct');
      await sharedPreferences.setBool('stable_hash_migrated_v2', true);
    } catch (_) {
      // In case table deletion fails on clean installs, ignore
    }
  }

  // Set/lock screen orientation
  await SystemChrome.setPreferredOrientations([]);

  // Set Default SystemUIOverlayStyle
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
      child: const App(),
    ),
  );
}
