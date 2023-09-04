//in this file we are gonna read our database or link our database with flutter application
//And we create our own tables without using the testing.db or doing it manually as it not gonna present in our application
//Those tables didn't exists,we create our tables in the below code and read data from them.
//we just copy the code of our sqlite

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/service/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const dbName = 'notes.db'; //it is the doc file under which our data is saved
const userTable = 'user';
const noteTable = 'note';
// ''' is allow us to place pretty much any thing like the code of other language as we are going to do now for putting the sqlite syntax code below
//just adding if not exists so it will create the table,bcz if table is already present then sqlite will throw an error
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
	      "id"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("id" AUTOINCREMENT)
      );''';

//creating notes table
const createNoteTable = '''
        CREATE TABLE "note" (
	      "id"	INTEGER NOT NULL,
	      "user_id"	INTEGER NOT NULL,
	      "text"	TEXT,
	      "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	      FOREIGN KEY("user_id") REFERENCES "user"("id"),
	      PRIMARY KEY("id" AUTOINCREMENT),
      );''';

//create and open our DB as notesService in order to connect our app with database
class NotesService {
  Database? _db;

  //lecture 28
  // Fetching notes and working with streams
  List<DatabaseNote> _notes = [];

  // making notesservice class a singleton
  static final NotesService _shared = NotesService._shaaredInstance();
  NotesService._shaaredInstance();
  factory NotesService() => _shared;

  //controlling the stream list of database notes
  final _notesStreamController =
      StreamController<List<DatabaseNote>>.broadcast();

//when working on future builder in notes view
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  Future<DatabaseUser> getOrCreateuser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
      //if in any case it will catch any excep. then  it will rethroe it to the caller,and then it have to handle it
    }
  }

  //Reading & cache notes
  Future<void> _cachenotes() async {
    //'_' analyzer is used for private function
    final allNotes = await getAllNotes();
    _notes = allNotes
        .toList(); //as my get all notes function is iterable so we to convert it into list
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    //make sure note exists
    await getNote(id: note.id);
    //it will just return the exception couldnotfindnote so we dont need its value to be saved

    // update DB
    final updateCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote =
          await getNote(id: note.id); //we will return the note else
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(
        noteRow)); //this is iterable so we can get all the notes one by one
  }

  Future<DatabaseNote> getNote({required int id}) async {
    //for fetching the single note
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1, //fetching only 1 note
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      _notes.retainWhere((note) => note.id == id);
      _notes.add(note); //1st updt local cache
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletion = await db.delete(noteTable);
    //it will delete all the rows in the table(delete all the notes)and return the no.of rows
    _notes = []; //our local cache is update
    _notesStreamController.add(_notes); //user facing class is also update
    return numberOfDeletion;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exists in the database with the correct id
    final dbUser = await getUser(
        email: owner.email); //we have to check that the owner email exists
    if (dbUser != owner) {
      throw CouldNotFindUser(); //it will go into over covariant == function
    }
    //now creating notes
    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1, //we start syncing
    });
    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes); //adding the notes for cache lec 28
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      //in this query we are checking the uniqueness of email that the same email is already exists or not on sql layer
      userTable,
      limit: 1, //we are looking for just 1 item
      where: 'email = ?', //we are looking for email
      whereArgs: [email.toLowerCase()],
    ); //throw query exactky we are going to check that the user is already exists or not in the database
    if (results.isEmpty) {
      //it should be either 0
      throw CouldNotFindUser();
    } else {
      //or it should be 1
      return DatabaseUser.fromRow(results.first);
    }
  }

//creating user in the DB
  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      //in this query we are checking the uniqueness of email that the same email is already exists or not on sql layer
      userTable,
      limit: 1, //we are looking for just 1 item
      where: 'email = ?', //we are looking for email
      whereArgs: [email.toLowerCase()],
    ); //throw query exactky we are going to check that the user is already exists or not in the database
    if (results.isNotEmpty) {
      //if the user already exists with the email given than it will not create error
      throw UserAlreadyExists();
    }
    //insert will return the id
    final UserId = await db.insert(userTable, {
      emailColumn: email
          .toLowerCase(), //only insering through email bcz id is already primary key
    });
    return DatabaseUser(
      id: UserId,
      email: email,
    );
  }

  //it is a prrivate function that are reading and writing internal functions in this class that are going to use,in order to get current DB
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

//using email we are going to dlt the user from DB
  Future<void> deleteUser({required String email}) async {
    await _ensureDnIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      //it has 3 arguments to dlt user,table name,email? and .tolowercase
      userTable,
      where: 'email=?',
      whereArgs: [email.toLowerCase()],
    ); //if it delete the user then it will return 1,otherwise it wiill return 0
    if (deletedCount != 1) {
      //it will be 1 or 0
      throw CouldNotDeleteUser(); //it means user not exists
    }
  }

  //after creating tables ,now we close our function
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close(); //requesting sqflite to close the DB
      _db = null; //resetting local DB
    }
  }

  Future<void> _ensureDnIsOpen() async {
    try {
      await open();
    } on DatabaseeAlreadyOpenException {
      //empty
    }
  }

  //as opening db is a async task
  //this open func keep hold of..,it open the DB and gonna store it somewhere in our notesServie,so the other func in the future can read data from the DB
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseeAlreadyOpenException;
    }
    //try to getting the doc directory path
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath =
          join(docsPath.path, dbName); //putting our dbname data into docs file
      final db = await openDatabase(dbPath); //then opening docs file
      _db = db; //then assigning it to local database

      //create user table
      await db.execute(createUserTable);
      //create note table
      await db.execute(createNoteTable);
      await _cachenotes();
    } on MissingPlatformDirectoryException {
      throw UnableTogetDocumentsDirectory();
    }
  }
}

//1st step that we done during lecture
@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  //the data will be read through rows as a string
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';
  // covariant to check that the person id and emails are equal or it belongs to the same person
  // override is defined at object level
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;
  @override
  String toString() =>
      'Note : id = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  // covariant to check that the person id and emails are equal or it belongs to the same person
  // override is defined at object level
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
