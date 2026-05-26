import 'package:sqflite/sqflite.dart';

class FakeWebDatabase implements Database {
  // Store tables in memory: Map<tableName, List<rowData>>
  final Map<String, List<Map<String, dynamic>>> _tables = {};

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    // Parse table name from SQL (e.g. CREATE TABLE IF NOT EXISTS User ...)
    final matches = RegExp(
      r'CREATE\s+TABLE(?:\s+IF\s+NOT\s+EXISTS)?\s+(\w+)',
      caseSensitive: false,
    ).firstMatch(sql);
    if (matches != null) {
      final tableName = matches.group(1)!;
      _tables[tableName] = _tables[tableName] ?? [];
    }
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final list = _tables[table] ??= [];
    final row = Map<String, dynamic>.from(values);

    // If id is not specified or is null, auto-increment
    if (row['id'] == null) {
      int maxId = 0;
      for (final r in list) {
        final rid = r['id'];
        if (rid is int && rid > maxId) maxId = rid;
      }
      row['id'] = maxId + 1;
    }

    list.add(row);
    return row['id'] is int ? row['id'] as int : 1;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final list = _tables[table] ?? [];
    var result = list;

    // Handle simple local queries
    if (where != null) {
      if (where.contains('id = ?') &&
          whereArgs != null &&
          whereArgs.isNotEmpty) {
        final queryId = whereArgs.first;
        result = list
            .where((r) => r['id'].toString() == queryId.toString())
            .toList();
      } else if (where.contains('userId = ?') &&
          whereArgs != null &&
          whereArgs.isNotEmpty) {
        final queryUserId = whereArgs.first;
        result = list
            .where((r) => r['userId'].toString() == queryUserId.toString())
            .toList();
      }
    }

    // Apply basic offset and limit
    if (offset != null && offset < result.length) {
      result = result.sublist(offset);
    }
    if (limit != null && limit < result.length) {
      result = result.sublist(0, limit);
    }

    return result.map((r) => Map<String, Object?>.from(r)).toList();
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final list = _tables[table] ?? [];
    int count = 0;

    if (where != null &&
        where.contains('id = ?') &&
        whereArgs != null &&
        whereArgs.isNotEmpty) {
      final queryId = whereArgs.first;
      for (final r in list) {
        if (r['id'].toString() == queryId.toString()) {
          r.addAll(values);
          count++;
        }
      }
    } else {
      for (final r in list) {
        r.addAll(values);
        count++;
      }
    }
    return count;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final list = _tables[table] ?? [];
    int count = 0;

    if (where != null &&
        where.contains('id = ?') &&
        whereArgs != null &&
        whereArgs.isNotEmpty) {
      final queryId = whereArgs.first;
      final toRemove = list
          .where((r) => r['id'].toString() == queryId.toString())
          .toList();
      for (final r in toRemove) {
        list.remove(r);
        count++;
      }
    } else if (where != null &&
        where.contains('userId = ?') &&
        whereArgs != null &&
        whereArgs.isNotEmpty) {
      final queryUserId = whereArgs.first;
      final toRemove = list
          .where((r) => r['userId'].toString() == queryUserId.toString())
          .toList();
      for (final r in toRemove) {
        list.remove(r);
        count++;
      }
    } else {
      count = list.length;
      list.clear();
    }
    return count;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    final fakeTrx = FakeTransaction(this);
    return await action(fakeTrx);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #isOpen) return true;
    if (invocation.memberName == #close) return Future.value();
    return null;
  }
}

class FakeTransaction implements Transaction {
  final FakeWebDatabase _db;

  FakeTransaction(this._db);

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) =>
      _db.execute(sql, arguments);

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) => _db.insert(
    table,
    values,
    nullColumnHack: nullColumnHack,
    conflictAlgorithm: conflictAlgorithm,
  );

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) => _db.query(
    table,
    distinct: distinct,
    columns: columns,
    where: where,
    whereArgs: whereArgs,
    groupBy: groupBy,
    having: having,
    orderBy: orderBy,
    limit: limit,
    offset: offset,
  );

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) => _db.update(
    table,
    values,
    where: where,
    whereArgs: whereArgs,
    conflictAlgorithm: conflictAlgorithm,
  );

  @override
  Future<int> delete(String table, {String? where, List<Object?>? whereArgs}) =>
      _db.delete(table, where: where, whereArgs: whereArgs);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
