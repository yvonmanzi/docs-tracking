import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mdcapp/model/model.dart';
import 'package:mdcapp/ui/docdetail.dart';
import 'package:mdcapp/util/dbhelper.dart';
import 'package:sqflite/sqflite.dart';

import '../model/model.dart';
import '../util/dbhelper.dart';

// Menu item
const menuReset = "Reset Local Data";
List<String> menuOptions = const <String>[menuReset];

class DocList extends StatefulWidget {
  @override
  _DocListState createState() => _DocListState();
}

class _DocListState extends State<DocList> {
  DbHelper dbh = DbHelper();
  List<Doc> docs;
  int count = 0;
  DateTime cDate;

  @override
  void initState() {
    super.initState();
  }

  Future getData() async {
    final Future dbFuture = dbh.db; // this might rise a prob in the future.
    dbFuture.then((result) {
      final docsFuture = result.getDocs();
      docsFuture.then((result) {
        if (result.length > 0) {
          //List<Doc> docList = List<Doc>();
          //var count = result.length;
          //for (int i = 0; i <= count - 1; i++) {
          //docList.add(Doc.fromObject(result[i]));
          //}
          List<Doc> docList =
              result.map((document) => Doc.fromObject(document)).toList();

          setState(() {
            if (this.docs.length > 0) this.docs.clear();
            this.docs = docList;
            this.count = count;
          });
        }
      });
    });
  }

  void _checkDate() {
    const secs = const Duration(seconds: 10);
    new Timer.periodic(secs, (Timer t) {
      DateTime nw = DateTime.now();
      if (cDate.day != nw.day ||
          cDate.month != nw.month ||
          cDate.year != nw.year) {
        getData();
        cDate = DateTime.now();
      }
    });
  }

  void navigateToDetail(Doc doc) async {
    bool r = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => DocDetail(doc)));

    if(r == true) getData();
  }

  void _showResetDialog(){
    showDialog(context: context,
    builder: (BuildContext context){
      return AlertDialog(
        title: Text("Do u want to delete all local data?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          FlatButton(
            child: Text("OK"),
            onPressed: (){
              Future f = _resetLocalData();
              f.then((result) => Navigator.of(context).pop();
              );
            },
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future _resetLocalData() {
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result){
      final dDocs = dbh.deleteRows((DbHelper.tblDocs));
      dDocs.then((result){
        setState(() {
          this.docs.clear();
          this.count = 0;
        });
      });
    }
    );
  }
}
