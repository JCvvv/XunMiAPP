import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/digital_person.dart';
import '../models/message.dart';

class DatabaseHelper {

  static Database? _database;
  static DatabaseHelper? _instance;

  DatabaseHelper._init();  // 私有构造函数

  static DatabaseHelper get instance {  // 提供单例实例
    _instance ??= DatabaseHelper._init();
    return _instance!;
  }

  Future<Database> getDatabase() async {
    if (_database != null) return _database!;
    _database = await _initDB('digital_persons.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // 初始化所有表格并创建AI助手
  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';

    // 创建数字人标表
    await db.execute('''
    CREATE TABLE digital_persons (
      id $idType,
      role $textType,
      name $textType,
      avatarUrl $textType,
      prompt $textType  
    )
    ''');

    // 创建消息表
    await db.execute('''
    CREATE TABLE messages (
      id $idType,
      digitalPersonId $intType,
      content $textType,
      timestamp $textType,
      isSystem $intType,
      FOREIGN KEY (digitalPersonId) REFERENCES digital_persons (id) ON DELETE CASCADE
    )
    ''');

    // 创建默认的数字人
    int newPersonId = await db.insert('digital_persons', {
      'role': 'AI助手',
      'name': 'AI助手',
      'avatarUrl': 'assets/images/default.png',
      'prompt': '我是您的AI助手'
    });

    // 插入初始消息
    await db.insert('messages', {
      'digitalPersonId': newPersonId,
      'content': '我是您的AI助手，下面我将教您如何使用这个app',
      'timestamp': DateTime.now().toIso8601String(),
      'isSystem': 1
    });
  }

  // 数字人 增
  Future<int> insertDigitalPerson(DigitalPerson person) async {
    final db = await getDatabase();
    final id = await db.insert('digital_persons', person.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return id;
  }

  // 按照最后消息的时间获取数字人信息
  Future<List<DigitalPerson>> getAllDigitalPersons() async {
    final db = await getDatabase();
    final result = await db.rawQuery('''
    SELECT dp.*, m.content AS latestMessage, m.timestamp 
    FROM digital_persons dp
    LEFT JOIN messages m ON dp.id = m.digitalPersonId
    WHERE m.id IN (
      SELECT MAX(id) FROM messages GROUP BY digitalPersonId
    )
    ORDER BY m.timestamp DESC
  ''');
    List<DigitalPerson> digitalPersons = result.map((json) => DigitalPerson.fromMap(json)).toList();

    // print("All digital persons with their messages:");
    // for (DigitalPerson person in digitalPersons) {
    //   print("ID: ${person.id}, Name: ${person.name}, Role: ${person.role}, Avatar URL: ${person.avatarUrl}, Prompt: ${person.prompt}");
    //   // 获取并打印每个数字人的聊天记录
    //   List<Message> messages = await getMessagesForDigitalPerson(person.id!);
    //   print("Messages for ${person.name}:");
    //   for (Message message in messages) {
    //     print("ID: ${message.id}, Content: ${message.content}, Timestamp: ${message.timestamp}, IsSystem: ${message.isSystem}");
    //   }
    // }
    return digitalPersons;
  }

  // 首字母排序的数字人
  Future<List<DigitalPerson>> getSortedDigitalPersons() async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        'digital_persons',
        orderBy: 'name COLLATE NOCASE ASC'
    );
    return List.generate(maps.length, (i) {
      return DigitalPerson.fromMap(maps[i]);
    });
  }

  // 数字人 改
  Future<void> updateDigitalPerson(DigitalPerson person) async {
    final db = await getDatabase();
    await db.update(
      'digital_persons',
      person.toMap(),
      where: 'id = ?',
      whereArgs: [person.id],
    );
  }

  // 数字人 删
  Future<void> deleteDigitalPerson(int id) async {
    final db = await getDatabase();
    await db.delete(
      'digital_persons',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 根据数字人id查询该数字人所有的聊天信息
  Future<List<Message>> getMessagesForDigitalPerson(int digitalPersonId) async {
    final db = await getDatabase();
    final result = await db.query(
        'messages',
        where: 'digitalPersonId = ?',
        whereArgs: [digitalPersonId]
    );
    return result.map((json) => Message.fromMap(json)).toList();
  }

  // 消息 增
  Future<int> insertMessage(Message message) async {
    final db = await getDatabase();
    final id = await db.insert(
      'messages',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  // 消息 改
  Future<void> updateMessage(Message message) async {
    final db = await getDatabase();
    await db.update(
        'messages',
        message.toMap(),
        where: 'id = ?',
        whereArgs: [message.id]
    );
  }

  // 消息 删
  Future<void> deleteMessage(int messageId) async {
    final db = await getDatabase();
    await db.delete(
        'messages',
        where: 'id = ?',
        whereArgs: [messageId]
    );
  }

  // 获取所有数字人最新的消息
  Future<Message?> getLatestMessageForDigitalPerson(int digitalPersonId) async {
    final db = await getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
        'messages',
        where: 'digitalPersonId = ?',
        whereArgs: [digitalPersonId],
        orderBy: 'timestamp DESC',  // 按时间戳降序排列
        limit: 1  // 只返回一条记录
    );
    if (result.isNotEmpty) {
      return Message.fromMap(result.first);
    }
    return null;  // 如果没有消息，返回null
  }

  Future<void> close() async {
    final db = await getDatabase();
    db.close();
  }
}

