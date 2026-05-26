import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../utilities/console_logger.dart';
import 'database_config.dart';
import 'web_database_mock.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();

  static DatabaseService get instance => _instance;

  late Database database;

  Future<void> init() async {
    if (kIsWeb) {
      // Use zero-setup pure-Dart in-memory Database Mock for Web/Chrome testing
      database = FakeWebDatabase();
    } else {
      if (Platform.isWindows || Platform.isLinux) {
        // Initialize FFI for desktop platforms
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      // Get the path to the database
      final path = join(await getDatabasesPath(), DatabaseConfig.dbPath);

      // Create database if not exists
      File databaseFile = File(path);
      if (!await databaseFile.exists()) {
        await databaseFile.create();
      }

      // Open database
      database = await openDatabase(path);
    }

    // Create tables
    await Future.wait([
      database.execute(DatabaseConfig.createUserTable),
      database.execute(DatabaseConfig.createProductTable),
      database.execute(DatabaseConfig.createTransactionTable),
      database.execute(DatabaseConfig.createOrderedProductTable),
      database.execute(DatabaseConfig.createQueuedActionTable),
    ]);

    // Apply any schema modifications (e.g. adding columns to existing tables)
    try {
      await database.execute("ALTER TABLE '${DatabaseConfig.transactionTableName}' ADD COLUMN 'orderNo' TEXT;");
    } catch (_) {}
    try {
      await database.execute("ALTER TABLE '${DatabaseConfig.transactionTableName}' ADD COLUMN 'remoteId' TEXT;");
    } catch (_) {}
  }

  @visibleForTesting
  Future<void> initTestDatabase({required Database testDatabase}) async {
    database = testDatabase;

    // Create tables
    await Future.wait([
      database.execute(DatabaseConfig.createUserTable),
      database.execute(DatabaseConfig.createProductTable),
      database.execute(DatabaseConfig.createTransactionTable),
      database.execute(DatabaseConfig.createOrderedProductTable),
      database.execute(DatabaseConfig.createQueuedActionTable),
    ]);

    // Apply any schema modifications (e.g. adding columns to existing tables)
    try {
      await database.execute("ALTER TABLE '${DatabaseConfig.transactionTableName}' ADD COLUMN 'orderNo' TEXT;");
    } catch (_) {}
    try {
      await database.execute("ALTER TABLE '${DatabaseConfig.transactionTableName}' ADD COLUMN 'remoteId' TEXT;");
    } catch (_) {}
  }

  Future<void> dropDatabase(String path) async {
    // Check if the database file exists
    File databaseFile = File(path);

    if (await databaseFile.exists()) {
      // Delete the database file
      await databaseFile.delete();

      cw('Database deleted successfully!');
    } else {
      ce('Database does not exist!');
    }
  }
}
