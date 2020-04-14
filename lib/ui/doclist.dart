import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdcapp/model/model.dart';
import 'package:mdcapp/util/dbhelper.dart';

import '../model/model.dart';
import '../util/dbhelper.dart';
import '../util/utils.dart';
import './docdetail.dart'

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
    final dbFuture = dbh.initializeDb();
    dbFuture.then((result) {
      final docsFuture = dbh.getDocs();
      docsFuture.then((result) {
        if (result.length > 0) {
          List<Doc> docList = List<Doc>();
          var count = result.length;
          for (int i = 0; i <= count - 1; i++) {
            docList.add(Doc.fromObject(result[i]));
          }
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

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
