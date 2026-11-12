import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

/// Lightweight SQLite service for the Billu expense tracker.
///
/// Tables: categories, accounts, transactions.
/// Opens (or creates) a single database instance and exposes typed CRUD helpers
/// so the rest of the app never touches raw SQL.
class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static const _dbName = 'billu.db';
  static const _dbVersion = 1;

  // ── Table & column names ──────────────────────────────────────────────

  // Categories
  static const tableCategories = 'categories';
  static const colCatId = 'id';
  static const colCatName = 'name';
  static const colCatIcon = 'icon'; // Material icon codePoint
  static const colCatType = 'type'; // 'expense' | 'income'
  static const colCatCreatedAt = 'created_at';

  // Accounts
  static const tableAccounts = 'accounts';
  static const colAccId = 'id';
  static const colAccName = 'name';
  static const colAccSubtitle = 'subtitle';
  static const colAccBalance = 'balance';
  static const colAccBadgeText = 'badge_text';
  static const colAccIsPrimaryBadge = 'is_primary_badge'; // 0 | 1
  static const colAccIcon = 'icon';
  static const colAccFooterLeft = 'footer_left';
  static const colAccFooterRight = 'footer_right';
  static const colAccCreatedAt = 'created_at';

  // Transactions
  static const tableTransactions = 'transactions';
  static const colTxId = 'id';
  static const colTxTitle = 'title';
  static const colTxSubtitle = 'subtitle';
  static const colTxAmount = 'amount';
  static const colTxIsExpense = 'is_expense'; // 0 | 1
  static const colTxIcon = 'icon';
  static const colTxCategoryId = 'category_id'; // FK → categories.id
  static const colTxAccountId = 'account_id'; // FK → accounts.id
  static const colTxTimestamp = 'timestamp'; // ISO-8601 string
  static const colTxCreatedAt = 'created_at';

  // ── Singleton database accessor ───────────────────────────────────────

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  // ── Schema creation ───────────────────────────────────────────────────

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCategories (
        $colCatId       INTEGER PRIMARY KEY AUTOINCREMENT,
        $colCatName     TEXT    NOT NULL UNIQUE,
        $colCatIcon     INTEGER NOT NULL,
        $colCatType     TEXT    NOT NULL DEFAULT 'expense',
        $colCatCreatedAt TEXT   NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAccounts (
        $colAccId             INTEGER PRIMARY KEY AUTOINCREMENT,
        $colAccName           TEXT    NOT NULL,
        $colAccSubtitle       TEXT    NOT NULL DEFAULT '',
        $colAccBalance        REAL    NOT NULL DEFAULT 0.0,
        $colAccBadgeText      TEXT    NOT NULL DEFAULT '',
        $colAccIsPrimaryBadge INTEGER NOT NULL DEFAULT 0,
        $colAccIcon           INTEGER NOT NULL,
        $colAccFooterLeft     TEXT,
        $colAccFooterRight    TEXT,
        $colAccCreatedAt      TEXT    NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableTransactions (
        $colTxId         INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTxTitle      TEXT    NOT NULL,
        $colTxSubtitle   TEXT    NOT NULL DEFAULT '',
        $colTxAmount     REAL    NOT NULL,
        $colTxIsExpense  INTEGER NOT NULL DEFAULT 1,
        $colTxIcon       INTEGER NOT NULL,
        $colTxCategoryId INTEGER,
        $colTxAccountId  INTEGER,
        $colTxTimestamp   TEXT    NOT NULL,
        $colTxCreatedAt   TEXT    NOT NULL DEFAULT (datetime('now')),
        FOREIGN KEY ($colTxCategoryId) REFERENCES $tableCategories($colCatId)
          ON DELETE SET NULL,
        FOREIGN KEY ($colTxAccountId)  REFERENCES $tableAccounts($colAccId)
          ON DELETE SET NULL
      )
    ''');

    // Index for fast date-range queries on the transactions table.
    await db.execute('''
      CREATE INDEX idx_tx_timestamp ON $tableTransactions ($colTxTimestamp)
    ''');

    // Pre-seed default categories.
    await _seedCategories(db);
  }

  // ── Seed data ─────────────────────────────────────────────────────────

  /// Material icon codePoints for each default category.
  /// Using outlined variants to match the app's existing style.
  static const _defaultCategories = <Map<String, Object>>[
    // Expense categories
    {'name': 'General', 'icon': 0xe514, 'type': 'expense'},
    {'name': 'Groceries', 'icon': 0xe59c, 'type': 'expense'},
    {'name': 'Coffee & Drinks', 'icon': 0xe3a7, 'type': 'expense'},
    {'name': 'Dining & Food', 'icon': 0xe56c, 'type': 'expense'},
    {'name': 'Transit & Commute', 'icon': 0xe1d5, 'type': 'expense'},
    {'name': 'Shopping', 'icon': 0xe3ad, 'type': 'expense'},
    {'name': 'Rent & Utilities', 'icon': 0xe318, 'type': 'expense'},
    {'name': 'Entertainment', 'icon': 0xe3f1, 'type': 'expense'},
    {'name': 'Pet Care', 'icon': 0xe4a1, 'type': 'expense'},
    // Income categories
    {'name': 'Salary', 'icon': 0xf02ed, 'type': 'income'},
    {'name': 'Room Rent', 'icon': 0xf0118, 'type': 'income'},
    {'name': 'Coupon', 'icon': 0xe19f, 'type': 'income'},
    {'name': 'Cashback', 'icon': 0xe561, 'type': 'income'},
    {'name': 'Given', 'icon': 0xf02a6, 'type': 'income'},
    {'name': 'Investment', 'icon': 0xf44e, 'type': 'income'},
    {'name': 'Other Income', 'icon': 0xe0b2, 'type': 'income'},
  ];

  Future<void> _seedCategories(Database db) async {
    final batch = db.batch();
    for (final cat in _defaultCategories) {
      batch.insert(tableCategories, {
        colCatName: cat['name'],
        colCatIcon: cat['icon'],
        colCatType: cat['type'],
      });
    }
    await batch.commit(noResult: true);
  }

  // ════════════════════════════════════════════════════════════════════════
  //  CRUD — Categories
  // ════════════════════════════════════════════════════════════════════════

  Future<int> insertCategory(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(tableCategories, row,
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return db.query(tableCategories, orderBy: '$colCatName ASC');
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    final db = await database;
    return db.query(
      tableCategories,
      where: '$colCatType = ?',
      whereArgs: [type],
      orderBy: '$colCatName ASC',
    );
  }

  Future<Map<String, dynamic>?> getCategoryById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableCategories,
      where: '$colCatId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateCategory(int id, Map<String, dynamic> values) async {
    final db = await database;
    return db.update(
      tableCategories,
      values,
      where: '$colCatId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return db.delete(
      tableCategories,
      where: '$colCatId = ?',
      whereArgs: [id],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  CRUD — Accounts
  // ════════════════════════════════════════════════════════════════════════

  Future<int> insertAccount(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(tableAccounts, row);
  }

  Future<List<Map<String, dynamic>>> getAllAccounts() async {
    final db = await database;
    return db.query(tableAccounts, orderBy: '$colAccCreatedAt DESC');
  }

  Future<Map<String, dynamic>?> getAccountById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableAccounts,
      where: '$colAccId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateAccount(int id, Map<String, dynamic> values) async {
    final db = await database;
    return db.update(
      tableAccounts,
      values,
      where: '$colAccId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return db.delete(
      tableAccounts,
      where: '$colAccId = ?',
      whereArgs: [id],
    );
  }

  /// Sum of all account balances.
  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM($colAccBalance), 0.0) AS total FROM $tableAccounts',
    );
    return (result.first['total'] as num).toDouble();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  CRUD — Transactions
  // ════════════════════════════════════════════════════════════════════════

  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert(tableTransactions, row);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions({
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      tableTransactions,
      orderBy: '$colTxTimestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> getTransactionById(int id) async {
    final db = await database;
    final rows = await db.query(
      tableTransactions,
      where: '$colTxId = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> updateTransaction(int id, Map<String, dynamic> values) async {
    final db = await database;
    return db.update(
      tableTransactions,
      values,
      where: '$colTxId = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return db.delete(
      tableTransactions,
      where: '$colTxId = ?',
      whereArgs: [id],
    );
  }

  /// Transactions within a date range (inclusive), newest first.
  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    return db.query(
      tableTransactions,
      where: '$colTxTimestamp BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: '$colTxTimestamp DESC',
    );
  }

  /// Transactions for a single category.
  Future<List<Map<String, dynamic>>> getTransactionsByCategory(
    int categoryId,
  ) async {
    final db = await database;
    return db.query(
      tableTransactions,
      where: '$colTxCategoryId = ?',
      whereArgs: [categoryId],
      orderBy: '$colTxTimestamp DESC',
    );
  }

  /// Transactions for a single account.
  Future<List<Map<String, dynamic>>> getTransactionsByAccount(
    int accountId,
  ) async {
    final db = await database;
    return db.query(
      tableTransactions,
      where: '$colTxAccountId = ?',
      whereArgs: [accountId],
      orderBy: '$colTxTimestamp DESC',
    );
  }

  /// Total spent (expenses only) grouped by category — handy for the
  /// donut chart on the analytics screen.
  Future<List<Map<String, dynamic>>> getSpendingByCategory({
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await database;

    String whereClause = '$colTxIsExpense = 1';
    final args = <String>[];

    if (start != null && end != null) {
      whereClause += ' AND $colTxTimestamp BETWEEN ? AND ?';
      args.addAll([start.toIso8601String(), end.toIso8601String()]);
    }

    return db.rawQuery('''
      SELECT
        c.$colCatId   AS category_id,
        c.$colCatName AS category_name,
        c.$colCatIcon AS category_icon,
        COALESCE(SUM(t.$colTxAmount), 0.0) AS total
      FROM $tableTransactions t
      LEFT JOIN $tableCategories c ON t.$colTxCategoryId = c.$colCatId
      WHERE $whereClause
      GROUP BY t.$colTxCategoryId
      ORDER BY total DESC
    ''', args);
  }

  // ── Utility ───────────────────────────────────────────────────────────

  /// Delete **all** rows from every table. Useful for a "reset data" option
  /// in settings. Re-seeds default categories afterwards.
  Future<void> resetAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(tableTransactions);
      await txn.delete(tableAccounts);
      await txn.delete(tableCategories);
    });
    await _seedCategories(db);
  }

  /// Hard purge: safely closes the database, deletes the physical file from disk,
  /// re-creates the database structure, and re-seeds default categories.
  Future<void> purgeDatabase() async {
    try {
      if (_db != null && _db!.isOpen) {
        await _db!.close();
        _db = null;
      }
      final dbPath = await getDatabasesPath();
      final path = p.join(dbPath, _dbName);
      await deleteDatabase(path);
      _db = await _initDB();
    } catch (e) {
      await resetAllData();
    }
  }

  /// Close the database. Call from `dispose` if needed.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
