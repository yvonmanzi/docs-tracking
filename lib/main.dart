import 'package:flutter/material.dart';

import './ui/doclist.dart';

void main() => runApp(DocExpiry());

class DocExpiry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DocExpiry',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: DocList(),
    );
  }
}
