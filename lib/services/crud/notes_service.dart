import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:test_app/services/crud/crud_exception.dart';

class NotesService {
  //private local database
  Database? _db;  

  List<DatabaseNote> _notes = [] ;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance();
    factory NotesService() => _shared;

  final _notesStreamController = StreamController<List<DatabaseNote>>.broadcast();

  Stream<List<DatabaseNote>>get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    try{
      final user = await getUser (email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    }catch (e){
      rethrow;
    } 
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList(); //convert allNotes(type iterable) to List (like array)
    _notesStreamController.add(_notes);
  }


  Future<DatabaseNote> updateNote ({required DatabaseNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure note is exist
    await getNote(id: note.id);

    //update the database
    final updatesCounts = await db.update(noteTable, {
      textColumn: text,
      isSynedWithCloudColumn: 0,
    });

    if (updatesCounts == 0){
      throw CouldNotUpdateNote();
    }else{
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note)=>note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  //Iterable - an abstract collection of elements. It allows you to Iterate through the elements using a for-in loop.
  Future<Iterable<DatabaseNote>> getAllNotes () async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
    );

    //it means every row of the note in noteTable has created their own instance using map function
    //noteRow is a Map type value which consists a specific row's info
    return notes.map((noteRow)=>DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote ({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id =? ',
      whereArgs: [id],
    );

    if (notes.isEmpty){
      throw CouldNotFindNote();
    }else{
      final note = DatabaseNote.fromRow(notes.first);
      _notes.removeWhere((note)=>note.id == id);
      _notesStreamController.add(_notes);
      return note;
    }
   }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletion;
  }

  Future<void> deleteNote ({required int id}) async {
    await _ensureDbIsOpen();
     final db = _getDatabaseOrThrow();
     final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
     );

     if (deletedCount == 0){
      throw CouldNotDeleteNote();
     }else{
      _notes.removeWhere((note)=>note.id == id);
      _notesStreamController.add(_notes);
     }
  }

  Future<DatabaseNote> createNote ({required DatabaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    
    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) { //this one compare id, not email
      throw CouldNotFindUser();
    }

    const text = '';
    //create the note
    final noteID = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSynedWithCloudColumn: 1
    });

    final note = DatabaseNote(id: noteID, userId: owner.id, text: text, isSynedWithCloud: true);
    _notes.add(note);
    _notesStreamController.add(_notes);
    return note;
  } 

  Future<DatabaseUser> getUser ({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'email = ?',whereArgs: [email.toLowerCase()]);
    if (results.isEmpty) {
      throw CouldNotFindUser();
    }else {
      return DatabaseUser.fromRow(results.first); //.first means the first row read from the table
    }
  }

  Future<DatabaseUser> createUser ({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable, limit: 1, where: 'email = ?',whereArgs: [email.toLowerCase()]);
    if (results.isNotEmpty) {
      throw UserAlreadyExist();
    }
  
    //create the note (insert function will return the userID as interger)
    final userID = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DatabaseUser(id: userID, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }


  }

  Database _getDatabaseOrThrow() {
    final db =_db;
    if (db ==null) {
      throw DatabaseIsNotOpenException;
    }else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpenException();
    }else{
      await db.close();
      _db =null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    }on DatabaseAlreadyOpenException {
      //empty
    }
  }

  Future<void> open() async {
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }

    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath); //if database does not exist, it onCreate is called to create a database
      _db = db;

      //create user table
      //use triple quotation mark ''' to add sql code inside
      const createUserTable = '''CREATE TABLE IF NOT EXIST "user" (
        "id" INTEGER NOT NULL,
        "email" TEXT NOT NULL UNIQUE,
        PRIMARY KEY ("id" AUTOINCREMENT),
      )
      ''';
      await db.execute(createUserTable);

      //create note table
      const createNoteTable = '''CREATE TABLE IF NOT EXIST "note" (
        "id" INTEGER NOT NULL ,
        "user_id" INTEGER NOT NULL,
        "text" TEXT,
        "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY ("user_id") REFERENCES "user" ("id"),
        PRIMARY KEY ("id" AUTOINCREMENT)
      )
      ''';
      await db.execute(createNoteTable);

      await _cacheNotes();

    } on MissingPluginException {
      throw UnableToGetDocumentDirectory();
    }
  }
}


@immutable
class DatabaseUser {
  final int id;
  final String email;
  //Constructor to create an instance database user
  const DatabaseUser({required this.id, required this.email});

  //Create an instance of table's specific row in a database that already exist in the database
  DatabaseUser.fromRow(Map<String, Object?> map)  //Named constructor - create an instance from a database row (map)
    : id = map[idColumn] as int,
      email =map[emailColumn] as String;

  @override
  String toString() {
    return 'Person, ID = $id, email = $email';
  }

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSynedWithCloud;

  DatabaseNote({required this.id, required this.userId, required this.text, required this.isSynedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)  //Named constructor - create an instance from a database row (map)
    : id = map[idColumn] as int,
      userId = map[userIdColumn] as int,
      text = map[textColumn] as String,
      isSynedWithCloud = (map[isSynedWithCloudColumn] as int ) == 1? true: false;

  @override
  String toString() => 'Note, ID = $id, userId = $userId, isSynedWithCloud = $isSynedWithCloud, text = $text';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;
  
  @override
  int get hashCode => id.hashCode;

}

const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'userId';
const textColumn = 'text';
const isSynedWithCloudColumn = 'is_syned_with_cloud';


