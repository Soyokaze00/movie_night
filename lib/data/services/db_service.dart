import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Local database for everything the user actually owns: favorites, status,
/// scores, episode progress, notes, dates, rewatch counts, and custom lists.
/// TMDB data (posters, overviews, etc.) is never stored here — it's fetched
/// live and only the user's personal entry is persisted.
class DbService {
  DbService._internal();
  static final DbService instance = DbService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    // On web there's no real filesystem - the "path" is just a name used
    // as the IndexedDB database key. getDatabasesPath() doesn't apply there.
    final path = kIsWeb ? 'movie_night.db' : join(await getDatabasesPath(), 'movie_night.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE library_entries (
            media_id INTEGER NOT NULL,
            media_type TEXT NOT NULL,
            status TEXT NOT NULL DEFAULT 'none',
            is_favorite INTEGER NOT NULL DEFAULT 0,
            score REAL,
            episodes_watched INTEGER NOT NULL DEFAULT 0,
            total_episodes INTEGER,
            rewatch_count INTEGER NOT NULL DEFAULT 0,
            start_date TEXT,
            finish_date TEXT,
            notes TEXT,
            updated_at TEXT NOT NULL,
            PRIMARY KEY (media_id, media_type)
          )
        ''');
        await db.execute('''
          CREATE TABLE custom_lists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE custom_list_items (
            list_id INTEGER NOT NULL,
            media_id INTEGER NOT NULL,
            media_type TEXT NOT NULL,
            added_at TEXT NOT NULL,
            PRIMARY KEY (list_id, media_id, media_type),
            FOREIGN KEY (list_id) REFERENCES custom_lists (id) ON DELETE CASCADE
          )
        ''');
        await db.execute('''
          CREATE TABLE user_profile (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            avatar TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ---------- user_profile (local only, no auth/server) ----------

  Future<Map<String, Object?>?> getProfile() async {
    final db = await database;
    final rows = await db.query('user_profile', where: 'id = 1', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> saveProfile(String name, String avatar) async {
    final db = await database;
    await db.insert(
      'user_profile',
      {
        'id': 1,
        'name': name,
        'avatar': avatar,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ---------- library_entries ----------

  Future<List<Map<String, Object?>>> getAllEntries() async {
    final db = await database;
    return db.query('library_entries');
  }

  Future<void> upsertEntry(Map<String, Object?> entry) async {
    final db = await database;
    await db.insert(
      'library_entries',
      entry,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteEntry(int mediaId, String mediaType) async {
    final db = await database;
    await db.delete(
      'library_entries',
      where: 'media_id = ? AND media_type = ?',
      whereArgs: [mediaId, mediaType],
    );
  }

  // ---------- custom_lists ----------

  Future<int> createList(String name) async {
    final db = await database;
    return db.insert('custom_lists', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> renameList(int listId, String name) async {
    final db = await database;
    await db.update('custom_lists', {'name': name}, where: 'id = ?', whereArgs: [listId]);
  }

  Future<void> deleteList(int listId) async {
    final db = await database;
    await db.delete('custom_list_items', where: 'list_id = ?', whereArgs: [listId]);
    await db.delete('custom_lists', where: 'id = ?', whereArgs: [listId]);
  }

  Future<List<Map<String, Object?>>> getLists() async {
    final db = await database;
    return db.query('custom_lists', orderBy: 'created_at ASC');
  }

  Future<void> addItemToList(int listId, int mediaId, String mediaType) async {
    final db = await database;
    await db.insert(
      'custom_list_items',
      {
        'list_id': listId,
        'media_id': mediaId,
        'media_type': mediaType,
        'added_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeItemFromList(int listId, int mediaId, String mediaType) async {
    final db = await database;
    await db.delete(
      'custom_list_items',
      where: 'list_id = ? AND media_id = ? AND media_type = ?',
      whereArgs: [listId, mediaId, mediaType],
    );
  }

  Future<List<Map<String, Object?>>> getItemsForList(int listId) async {
    final db = await database;
    return db.query('custom_list_items', where: 'list_id = ?', whereArgs: [listId]);
  }
}