import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/model.dart';

class DbHelper {
  //table name
  static String tblDocs = "docs";

  //fields of the table
  String docId = "id";
  String docTitle = "title";
  String docExpiration = "expiration";

  String fqYear = "fqYear";
  String fqHalfYear = "fqHalfYear";
  String fqQuarter = "fqQuarter";
  String fqMonth = "fqMonth";

  //singleton
  static final DbHelper _dbHelper = DbHelper._internal();

  //factory constructor
  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

//  Database entry point
  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  Future<Database> initializeDb() async {
    Directory d = await getApplicationDocumentsDirectory();
    Stirng p = d.path + "/docexpire.db";
    var db = await openDatabase(p, verion: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $tblDocs($docId INTEGER PRIMARY KEY, $docTitle TEXT NOT NULL, $docExpiration TEXT NOT NULL, $fqYear INTEGER, $fqHalfYear INTEGER, $fqQuarter INTEGER, $fqMonth INTEGER)");
  }

  //insert a new doc
  Future<int> insertDoc(Doc doc) async {
    var r;

    Database db = await this.db;
    try {
      r = await db.insert(tblDocs, doc.toMap());
    } catch (e) {
      debugPrint("insertDoc: " + e.toString());
    }
    return r;
  }

  Future<List<Map<String, dynamic>>> getDocs() async {
    Database db = await this.db;
    var r =
        await db.rawquery("SELECT * FROM $tblDocs ORDER BY $docExpiration ASC");
    return r;
  }

//  Get doc based on the id
  Future<List> getDoc(int id) async {
    Database db = await this.db;
    var r = await db.rawQuery(
        "SELECT * FROM $tblDocs WHERE $docId = " + id.toString() + "");
    return r;
  }

// Gets a Doc based on a String payload
  Future<List> getDocFromStr(String payload) async {
    List<String> p = payload.split("|");
    if (p.length == 2) {
      Database db = await this.db;
      var r = await db.rawQuery("SELECT * FROM $tblDocs WHERE $docId = " +
          p[0] +
          " AND $docExpiration = '" +
          p[1] +
          "'");
      return r;
    } else
      return null;
  }

  // Get the number of docs.
  Future<int> getDocsCount() async {
    Database db = await this.db;
    int result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tblDocs"));
    return result;
  }

// Get the max document id av on the db
  Future<int> getMaxId() async {
    Database db = await this.sb;
    var r = Sqflite.firstIntValue(
        await db.rawQuery("SELECT MAX(id) FROM $tblDocs"));
    return r;
  }

  // Update a doc.
  Future<int> updateDoc(Doc doc) async {
    var db = await this.db;
    var r = await db
        .update(tblDocs, doc.toMap(), where: "$docId = ?", whereArgs: [doc.id]);
    return r;
  }

  // Delete a doc.
  Future<int> deleteDoc(int id) async {
    var db = await this.db;
    int r = await db.rawDelete("DELETE FROM $tblDocs WHERE $docId = $id");
    return r;
  }

  // Delete all docs.
  Future<int> deleteRows(String tbl) async {
    var db = await this.db;
    int r = await db.rawDelete("DELETE FROM $tbl");
    return r;
  }
}
