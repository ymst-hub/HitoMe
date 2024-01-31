import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const _databaseName = 'memo.db';
  static const _databaseVersion = 1;

  //大元の指名テーブル
  static const _personTableName = 'person';
  static const _personColumnId = 'id';
  static const _personColumnName = 'name';
  static const _personColumnFavorite = 'favorite';

  //約束ごとなどを載せるテーブル
  static const _willTableName = 'will';
  static const _willColumnSerial = 'Serial';
  static const _willColumnId = 'id';
  static const _willColumnThings = 'things';

  //住んだことを載せるテーブル
  static const _doneTableName = 'done';
  static const _doneColumnSerial = 'Serial';
  static const _doneColumnId = 'id';
  static const _doneColumnThings = 'things';

  //性格を載せるテーブル
  static const _personalityTableName = 'personality';
  static const _personalityColumnSerial = 'Serial';
  static const _personalityColumnId = 'id';
  static const _personalityColumnThings = 'things';

  //外見を載せるテーブル
  static const _appearanceTableName = 'appearance';
  static const _appearanceColumnSerial = 'Serial';
  static const _appearanceColumnId = 'id';
  static const _appearanceColumnThings = 'things';

  //このクラスのインスタンスを作成する
  DBHelper._privateConstructor();

  static final DBHelper _instance = DBHelper._privateConstructor();

  factory DBHelper() {
    return _instance;
  }

  DBHelper._internal();
  //DBを開く
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await _initDatabase();
      return _database!;
    }
  }

  //DBの初期化を行う
  _initDatabase() async {
    //DBファイルのパスを取得する
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _databaseName);

    // openDatabaseメソッドの結果を返す
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  //DBを閉じる
  Future<void> close() async {
    final db = await database;
    db.close();
  }

  //DBを削除する　※念の為
  Future<void> deleteDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, _databaseName);
    await deleteDatabase(path);
  }

  //DBのテーブルを作成する
  _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE $_personTableName (
        $_personColumnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $_personColumnName TEXT NOT NULL,
        $_personColumnFavorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
    db.execute('''
      CREATE TABLE $_willTableName (
        $_willColumnSerial INTEGER PRIMARY KEY AUTOINCREMENT,
        $_willColumnId INTEGER NOT NULL,
        $_willColumnThings TEXT NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE $_doneTableName (
        $_doneColumnSerial INTEGER PRIMARY KEY AUTOINCREMENT,
        $_doneColumnId INTEGER NOT NULL,
        $_doneColumnThings TEXT NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE $_personalityTableName (
        $_personalityColumnSerial INTEGER PRIMARY KEY AUTOINCREMENT,
        $_personalityColumnId INTEGER NOT NULL,
        $_personalityColumnThings TEXT NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE $_appearanceTableName (
        $_appearanceColumnSerial INTEGER PRIMARY KEY AUTOINCREMENT,
        $_appearanceColumnId INTEGER NOT NULL,
        $_appearanceColumnThings TEXT NOT NULL
      )
    ''');
  }

  //DBにデータを挿入する
  /// personテーブルの操作
  //personテーブルにデータを挿入する
  Future<void> insertPerson(String name) async {
    final db = await database;
    await db.insert(
      _personTableName,
      {
        _personColumnName: name,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //personテーブルのデータを更新する
  Future<void> updatePerson(int id, String name) async {
    final db = await database;
    await db.update(
      _personTableName,
      {
        _personColumnName: name,
      },
      where: '$_personColumnId = ?',
      whereArgs: [id],
    );
  }

  //personテーブルのデータを削除する
  Future<void> deletePersonById(int id) async {
    final db = await database;
    await db.delete(
      _personTableName,
      where: '$_personColumnId = ?',
      whereArgs: [id],
    );
  }

  //personテーブルのデータを全件取得する
  Future<List<Map<String, dynamic>>> getAllPerson() async {
    final db = await database;
    return db.query(_personTableName, orderBy: "${_personColumnFavorite} DESC, id ASC");
  }

  //personテーブルのお気に入りを更新する
  Future<void> updateFavorite(int id, int favorite) async {
    final db = await database;
    await db.update(
      _personTableName,
      {
        _personColumnFavorite: favorite,
      },
      where: '$_personColumnId = ?',
      whereArgs: [id],
    );
  }

  /// willテーブルの操作
  //willテーブルにデータを挿入する
  Future<void> insertWill(int id, String things) async {
    final db = await database;
    await db.insert(
      _willTableName,
      {
        _willColumnId: id,
        _willColumnThings: things,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //willテーブルのデータを更新する
  Future<void> updateWill(int serial, int id, String things) async {
    final db = await database;
    await db.update(
      _willTableName,
      {
        _willColumnId: id,
        _willColumnThings: things,
      },
      where: '$_willColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //willテーブルのデータを削除する
  Future<void> deleteWillBySerial(int serial) async {
    final db = await database;
    await db.delete(
      _willTableName,
      where: '$_willColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //willテーブルのデータを削除する
  Future<void> deleteWillById(int id) async {
    final db = await database;
    await db.delete(
      _willTableName,
      where: '$_willColumnId = ?',
      whereArgs: [id],
    );
  }

  //willテーブルの同一人物のデータを全件取得する
  Future<List<Map<String, dynamic>>> getWillById(int id) async {
    final db = await database;
    return db.query(
      _willTableName,
      where: '$_willColumnId = ?',
      whereArgs: [id],
    );
  }

  //willテーブルのデータSerial（連番から）を単一取得する
  Future<List<Map<String, dynamic>>> getWillBySerial(int serial) async {
    final db = await database;
    return db.query(
      _willTableName,
      where: '$_willColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  /// doneテーブルの操作
  //doneテーブルにデータを挿入する
  Future<void> insertDone(int id, String things) async {
    final db = await database;
    await db.insert(
      _doneTableName,
      {
        _doneColumnId: id,
        _doneColumnThings: things,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //doneテーブルのデータを更新する
  Future<void> updateDone(int serial, int id, String things) async {
    final db = await database;
    await db.update(
      _doneTableName,
      {
        _doneColumnId: id,
        _doneColumnThings: things,
      },
      where: '$_doneColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //doneテーブルの単一のデータを削除する
  Future<void> deleteDoneBySerial(int serial) async {
    final db = await database;
    await db.delete(
      _doneTableName,
      where: '$_doneColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //doneテーブルの同一人物のデータを削除する
  Future<void> deleteDoneById(int id) async {
    final db = await database;
    await db.delete(
      _doneTableName,
      where: '$_doneColumnId = ?',
      whereArgs: [id],
    );
  }

  //doneテーブルの同一人物のデータを全件取得する
  Future<List<Map<String, dynamic>>> getDoneById(int id) async {
    final db = await database;
    return db.query(
      _doneTableName,
      where: '$_doneColumnId = ?',
      whereArgs: [id],
    );
  }

  //doneテーブルのデータSerial（連番から）を単一取得する
  Future<List<Map<String, dynamic>>> getDoneBySerial(int serial) async {
    final db = await database;
    return db.query(
      _doneTableName,
      where: '$_doneColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  /// personalityテーブルの操作
  //personalityテーブルにデータを挿入する
  Future<void> insertPersonality(int id, String things) async {
    final db = await database;
    await db.insert(
      _personalityTableName,
      {
        _personalityColumnId: id,
        _personalityColumnThings: things,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //personalityテーブルのデータを更新する
  Future<void> updatePersonality(int serial, int id, String things) async {
    final db = await database;
    await db.update(
      _personalityTableName,
      {
        _personalityColumnId: id,
        _personalityColumnThings: things,
      },
      where: '$_personalityColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //personalityテーブルのデータを削除する
  Future<void> deletePersonalityBySerial(int serial) async {
    final db = await database;
    await db.delete(
      _personalityTableName,
      where: '$_personalityColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //personalityテーブルのデータを削除する
  Future<void> deletePersonalityById(int id) async {
    final db = await database;
    await db.delete(
      _personalityTableName,
      where: '$_personalityColumnId = ?',
      whereArgs: [id],
    );
  }

  //personalityテーブルの同一人物のデータを全件取得する
  Future<List<Map<String, dynamic>>> getPersonalityById(int id) async {
    final db = await database;
    return db.query(
      _personalityTableName,
      where: '$_personalityColumnId = ?',
      whereArgs: [id],
    );
  }

  //personalityテーブルのデータSerial（連番から）を単一取得する
  Future<List<Map<String, dynamic>>> getPersonalityBySerial(int serial) async {
    final db = await database;
    return db.query(
      _personalityTableName,
      where: '$_personalityColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  /// appearanceテーブルの操作
  //appearanceテーブルにデータを挿入する
  Future<void> insertAppearance(int id, String things) async {
    final db = await database;
    await db.insert(
      _appearanceTableName,
      {
        _appearanceColumnId: id,
        _appearanceColumnThings: things,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  //appearanceテーブルのデータを更新する
  Future<void> updateAppearance(int serial, int id, String things) async {
    final db = await database;
    await db.update(
      _appearanceTableName,
      {
        _appearanceColumnId: id,
        _appearanceColumnThings: things,
      },
      where: '$_appearanceColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //appearanceテーブルのデータを削除する
  Future<void> deleteAppearanceBySerial(int serial) async {
    final db = await database;
    await db.delete(
      _appearanceTableName,
      where: '$_appearanceColumnSerial = ?',
      whereArgs: [serial],
    );
  }

  //appearanceテーブルのデータを削除する
  Future<void> deleteAppearanceById(int id) async {
    final db = await database;
    await db.delete(
      _appearanceTableName,
      where: '$_appearanceColumnId = ?',
      whereArgs: [id],
    );
  }

  //appearanceテーブルの同一人物のデータを全件取得する
  Future<List<Map<String, dynamic>>> getAppearanceById(int id) async {
    final db = await database;
    return db.query(
      _appearanceTableName,
      where: '$_appearanceColumnId = ?',
      whereArgs: [id],
    );
  }

  //appearanceテーブルのデータSerial（連番から）を単一取得する
  Future<List<Map<String, dynamic>>> getAppearanceBySerial(int serial) async {
    final db = await database;
    return db.query(
      _appearanceTableName,
      where: '$_appearanceColumnSerial = ?',
      whereArgs: [serial],
    );
  }
}
