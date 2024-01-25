import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:veritabani/task.dart';

// bu sınıf Task türünden nesneleri veritabanına eklemek için bir controller sınıfır
class TaskDataBase {
  // Database nesnesi
  Database? _con;
  // birden fazla bağlantı kurulamaması için bir singleton nesne oluşturulur
  Future<Database> get _database async {
    if (_con != null) return _con!;
    _con = await connect();
    return _con!;
  }

  // veritabanına bağlantı kurulur
  Future<Database> connect() async {
    print("connect tetiklendi...");
    // yol ayarı, uygulamanın klasörü+task.db şeklinde bir yol üretir
    String path = join(await getDatabasesPath(), "task.db");
    print("Database yolu: $path");
    // bağlantı açar ve ilk oluşumda gerekn metotu belirler
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

// tablo oluşturur
  _createDb(Database db, int newVersion) async {
    await db.execute("""CREATE TABLE IF NOT EXISTS task
          (id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT)""");
  }
  // yukarıdaki 3 fonksiyon sabit olması gereken fonksiyonlardır

// veritabanından task adlı tablodan verileri getirir
  Future<List<Task>> getTasks(String kelime) async {
    Database db = await _database;

    var res = kelime.length > 1 ? await db.query("task",where: "title like ?", whereArgs: ['%$kelime%']) : await db.query("task");


    // db.rawQuery("SELECT * FROM task"); aynı işi yapar üstteki ile
    List<Task> list = res.isNotEmpty ? res.map((c) => Task.fromJson(c)).toList() : [];
    // üstteki satır ise veritabanından gelen dataları json olarak paketleyip bir list(dizi) olusturur
    print(list.length.toString() + " kayıt bulundu");
    return list;
  }
/*
  // veritabanından task adlı tablodan verileri getirir
  Future<List<Task>> getTasks(String kelime) async {
    Database db = await _database;

    var res = kelime.length >= 2 ? await db.query("task", where: "title like ?", whereArgs: ["%$kelime%"]) : await db.query("task");
    // db.rawQuery("SELECT * FROM task"); aynı işi yapar üstteki ile
    List<Task> list = res.isNotEmpty ? res.map((c) => Task.fromJson(c)).toList() : [];
    // üstteki satır ise veritabanından gelen dataları json olarak paketleyip bir list(dizi) olusturur
    print(list.length.toString() + " kayıt bulundu");
    return list;
  }
*/
  Future<int> addTask(Task task) async {
    print("ekle tetiklendi...");
    Database db = await _database!;
    // veritabanına Task türünden bir nesneyi ekler
    // dikkat ederseniz son aşamadan json a çeviriyor
    // çünkü sqlite json data alabiliyor
    return db.insert("task", task.toJson());
    // alternatifi ise
    //db.rawQuery("INSERT INTO task (title,description) VALUES ('${task.title}','${task.description}')");
  }

  Future<int> updateTask(Task task) async {
    print("güncelle tetiklendi...");
    Database db = await _database!;
    return db
        .update("task", task.toJson(), where: "id = ?", whereArgs: [task.id]);
    // güncelleme yapan fonksiyon, parametre olarak yine Task alıyor
    //db.rawQuery("UPDATE task SET title = '${task.title}', description = '${task.description}' WHERE id = ${task.id}");
  }

  Future<int> deleteTask(int id) async {
    print("sil tetiklendi...");
    Database db = await _database!;
    // veritabanından veri siliyor, altta alternatifi var
    return db.delete("task", where: "id = ?", whereArgs: [id]);
    //eşdeğeri => db.rawQuery("DELETE FROM task WHERE id=$id");
  }
}
