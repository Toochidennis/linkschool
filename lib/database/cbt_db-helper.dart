import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CbtDbHelper {
  static final CbtDbHelper instance = CbtDbHelper._internal();
  static Database? _database;

  CbtDbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'cbt_local.db');

    return await openDatabase(
      path,
      version: 2,           // ✅ bumped from 1 → 2
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // ✅ handles existing installs
    );
  }

  // ─────────────────────────────────────────
  // Fresh install — create all tables at once
  // ─────────────────────────────────────────
  Future<void> _onCreate(Database db, int version) async {
    await _createAllTables(db);
    print('✅ CBT local database created (v$version)');
  }

  // ─────────────────────────────────────────
  // Existing install — add tables that are missing
  // ─────────────────────────────────────────
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Upgrading CBT DB from v$oldVersion → v$newVersion');

    if (oldVersion < 2) {
      // Version 1 was missing: images, questions, options tables
      await db.execute('PRAGMA foreign_keys = ON;');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS images (
          id TEXT PRIMARY KEY,
          local_path TEXT NOT NULL,
          mime_type TEXT,
          checksum TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS questions (
          id INTEGER PRIMARY KEY,
          exam_id INTEGER NOT NULL,
          text TEXT NOT NULL,
          image_id TEXT,
          explanation TEXT,
          instruction TEXT,
          passage TEXT,
          type TEXT NOT NULL DEFAULT 'multiple_choice',
          topic TEXT,
          year INTEGER,
          FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL,
          FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS options (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          question_id INTEGER NOT NULL,
          label TEXT,
          text TEXT NOT NULL,
          image_id TEXT,
          is_correct INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
          FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL
        )
      ''');

      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_questions_exam ON questions(exam_id)'
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_options_question ON options(question_id)'
      );

      print('✅ Upgrade v1→v2: added images, questions, options tables');
    }
  }

  // ─────────────────────────────────────────
  // All tables — used by _onCreate
  // ─────────────────────────────────────────
  Future<void> _createAllTables(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS exam_types (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        difficulty TEXT,
        shortname TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        display_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS courses (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS exam_type_courses (
        exam_type_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        PRIMARY KEY (exam_type_id, course_id),
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id) ON DELETE CASCADE,
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS images (
        id TEXT PRIMARY KEY,
        local_path TEXT NOT NULL,
        mime_type TEXT,
        checksum TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS exams (
        id INTEGER PRIMARY KEY,
        exam_type_id INTEGER NOT NULL,
        course_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL DEFAULT 60,
        total_questions INTEGER NOT NULL DEFAULT 0,
        year INTEGER,
        version INTEGER NOT NULL DEFAULT 1,
        checksum TEXT,
        downloaded_at TEXT,
        FOREIGN KEY (exam_type_id) REFERENCES exam_types(id),
        FOREIGN KEY (course_id) REFERENCES courses(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS questions (
        id INTEGER PRIMARY KEY,
        exam_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        image_id TEXT,
        explanation TEXT,
        instruction TEXT,
        passage TEXT,
        type TEXT NOT NULL DEFAULT 'multiple_choice',
        topic TEXT,
        year INTEGER,
        FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL,
        FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        label TEXT,
        text TEXT NOT NULL,
        image_id TEXT,
        is_correct INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
        FOREIGN KEY (image_id) REFERENCES images(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS seed_meta (
        name TEXT PRIMARY KEY,
        version INTEGER NOT NULL,
        seeded_at TEXT NOT NULL
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_exam_type_courses_exam ON exam_type_courses(exam_type_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_exam_type_courses_course ON exam_type_courses(course_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_exams_type_course ON exams(exam_type_id, course_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_questions_exam ON questions(exam_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_options_question ON options(question_id)');
  }

  // ─────────────────────────────────────────
  // SEED META
  // ─────────────────────────────────────────

  Future<bool> isSeedDone(String name) async {
    final db = await database;
    try {
      final result = await db.query(
        'seed_meta',
        where: 'name = ?',
        whereArgs: [name],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> markSeedDone(String name) async {
    final db = await database;
    await db.insert(
      'seed_meta',
      {
        'name': name,
        'version': 1,
        'seeded_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─────────────────────────────────────────
  // SAVE BOARDS
  // ─────────────────────────────────────────

  Future<void> saveExamTypesAndCourses(
      List<Map<String, dynamic>> rawData) async {
    final db = await database;

    await db.transaction((txn) async {
      for (int i = 0; i < rawData.length; i++) {
        final item = rawData[i];

        final int examTypeId = item['id'] is int
            ? item['id']
            : int.parse(item['id'].toString());

        await txn.insert(
          'exam_types',
          {
            'id': examTypeId,
            'name': item['title'] ?? '',
            'description': item['desc'],
            'shortname': item['short'] ?? '',
            'is_active': 1,
            'display_order': item['display_order'] ?? i,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        final courses = item['courses'] as List<dynamic>? ?? [];
        for (final course in courses) {
          final int courseId = course['id'] is int
              ? course['id']
              : int.parse(course['id'].toString());

          await txn.insert(
            'courses',
            {
              'id': courseId,
              'name': course['course_name'] ?? '',
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          await txn.insert(
            'exam_type_courses',
            {
              'exam_type_id': examTypeId,
              'course_id': courseId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });

    print('✅ Saved ${rawData.length} exam types with courses to local DB');
  }

  // ─────────────────────────────────────────
  // READ BOARDS
  // ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getExamTypes() async {
    final db = await database;
    return await db.query(
      'exam_types',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'display_order ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getCoursesForExamType(
      int examTypeId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.id, c.name as course_name
      FROM courses c
      INNER JOIN exam_type_courses etc ON c.id = etc.course_id
      WHERE etc.exam_type_id = ?
    ''', [examTypeId]);
  }

  // ─────────────────────────────────────────
  // READ YEARS (from downloaded exams)
  // ─────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getYearsForCourse({
    required int examTypeId,
    required int courseId,
  }) async {
    final db = await database;
    return await db.query(
      'exams',
      columns: ['id', 'year'],
      where: 'exam_type_id = ? AND course_id = ?',
      whereArgs: [examTypeId, courseId],
      orderBy: 'year DESC',
    );
  }

  // ─────────────────────────────────────────
  // CHECK IF SUBJECT DOWNLOADED
  // ─────────────────────────────────────────

  Future<bool> isSubjectDownloaded({
    required int examTypeId,
    required int courseId,
  }) async {
    final db = await database;
    final result = await db.query(
      'exams',
      where: 'exam_type_id = ? AND course_id = ?',
      whereArgs: [examTypeId, courseId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // ─────────────────────────────────────────
  // UTILITY
  // ─────────────────────────────────────────

  Future<void> clearAll() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('options');
      await txn.delete('questions');
      await txn.delete('images');
      await txn.delete('exam_type_courses');
      await txn.delete('courses');
      await txn.delete('exam_types');
      await txn.delete('exams');
      await txn.delete('seed_meta');
    });
    print('🗑️ All CBT local data cleared');
  }
}