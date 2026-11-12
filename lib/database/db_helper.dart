import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'egx_portfolio.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stocks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT UNIQUE NOT NULL,
        purification_rate REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stock_symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total_amount REAL NOT NULL,
        date TEXT NOT NULL,
        month_key TEXT NOT NULL
      )
    ''');

    final initialStocks = [
      {'symbol': 'MPFC', 'rate': 0.065},
      {'symbol': 'ETEL', 'rate': 0.018},
      {'symbol': 'CPCI', 'rate': 0.01},
      {'symbol': 'MCQE', 'rate': 0.009},
      {'symbol': 'TMGH', 'rate': 0.1},
      {'symbol': 'ORHD', 'rate': 0.01},
      {'symbol': 'EGAL', 'rate': 0.0007},
      {'symbol': 'AZN', 'rate': 0.01},
      {'symbol': 'ADIB', 'rate': 0.0},
      {'symbol': 'EGX 33', 'rate': 0.0},
      {'symbol': 'EFID', 'rate': 0.026},
      {'symbol': 'ORAS', 'rate': 0.005},
      {'symbol': 'ARCC', 'rate': 0.023},
      {'symbol': 'CLDS', 'rate': 0.01},
      {'symbol': 'EGAS', 'rate': 0.01},
      {'symbol': 'OCDI', 'rate': 0.1},
      {'symbol': 'ORWE', 'rate': 0.031},
      {'symbol': 'SAUD', 'rate': 0.0},
      {'symbol': 'ZMID', 'rate': 0.142},
      {'symbol': 'ISPH', 'rate': 0.0},
      {'symbol': 'AJWA', 'rate': 0.0},
      {'symbol': 'BIOC', 'rate': 0.01},
      {'symbol': 'PHDC', 'rate': 0.1},
    ];

    Batch batch = db.batch();
    for (var stock in initialStocks) {
      batch.insert('stocks', {
        'symbol': stock['symbol'],
        'purification_rate': stock['rate'],
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List>> getAllStocks() async {
    final db = await database;
    return await db.query('stocks', orderBy: 'symbol ASC');
  }

  Future<int> addOrUpdateStock(String symbol, double rate) async {
    final db = await database;
    return await db.insert(
      'stocks',
      {'symbol': symbol.toUpperCase().trim(), 'purification_rate': rate},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> insertTransaction({
    required String stockSymbol,
    required String type,
    required int quantity,
    required double price,
    required DateTime date,
  }) async {
    final db = await database;
    String formattedDate = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    String monthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";

    return await db.insert('transactions', {
      'stock_symbol': stockSymbol,
      'type': type,
      'quantity': quantity,
      'price': price,
      'total_amount': quantity * price,
      'date': formattedDate,
      'month_key': monthKey,
    });
  }

  Future<List>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC, id DESC');
  }
}
