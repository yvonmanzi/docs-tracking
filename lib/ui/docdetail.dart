import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import '../model/model.dart';
import '../util/dbhelper.dart';
import '../util/util.dart';

const menuDelete = "Delete";
final List<String> menuOptions = const <String>[menuDelete];

class DocDetail extends StatefulWidget {
  Doc doc;
  final DbHelper dbh = DbHelper();

  DocDetail(this.doc);

  @override
  _DocDetailState createState() => _DocDetailState();
}

class _DocDetailState extends State<DocDetail> {
  final GlobalKey<FormState> _formKey = new GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  final int daysAhead = 5475; //15 years in the future

  final titleCtrl = TextEditingController();
  final expirationCtrl = MaskedTextController(mask: '2000-00-00');

  bool fqYearCtrl = true;
  bool fqHalfYearCtrl = true;
  bool fqQuarterCtrl = true;
  bool fqMonthCtrl = true;
  bool fqLessMonthCtrl = true;

//  initialization code. maybe we could use a initState callback method?

  void _initCtrls() {
    titleCtrl.text = widget.doc.title != null ? widget.doc.title : "";
    expirationCtrl.text =
        widget.doc.expiration != null ? widget.doc.expiration : "";
    fqYearCtrl =
        widget.doc.fqYear != null ? Val.IntToBool(widget.doc.fqYear) : false;
    fqHalfYearCtrl = widget.doc.fqHalfYear != null
        ? Val.IntToBool(widget.doc.fqHalfYear)
        : false;
    fqQuarterCtrl = widget.doc.fqQuarter != null
        ? Val.IntToBool(widget.doc.fqQuarter)
        : false;
    fqMonthCtrl =
        widget.doc.fqMonth != null ? Val.IntToBool(widget.doc.fqMonth) : false;
  }

//  Date Picker & Date function
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
//    this ?? checks whether sth is null, huh?
    var initialDate = DateUtils.convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= now.year && initialDate.isAfter(now)
        ? initialDate
        : now);

    Datepicker.showDatePicker(context, showTitleActions: true,
        onConfirm: (date) {
      setState(() {
        DateTime dt = date;
        String r = DateUtils.ftDateAsStr(dt);
        expirationCtrl.text = r;
      });
    }, currentTime: initialDate);
  }

  // Upper Menu
  Future<void> _selectMenu(String value) async {
    switch (value) {
      case menuDelete:
        if (widget.doc.id == -1) {
          return;
        }
        await _deleteDoc(widget.doc.id);
    }
  }

  Future<void> _deleteDoc(int id) async {
    int r = await widget.dbh.deleteDoc(widget.doc.id);
    Navigator.pop(context, true);
  }

  // Save doc
  void _saveDoc() {
    widget.doc.title = titleCtrl.text;
    widget.doc.expiration = expirationCtrl.text;
    widget.doc.fqYear = Val.BoolToInt(fqYearCtrl);
    widget.doc.fqHalfYear = Val.BoolToInt(fqHalfYearCtrl);
    widget.doc.fqQuarter = Val.BoolToInt(fqQuarterCtrl);
    widget.doc.fqMonth = Val.BoolToInt(fqMonthCtrl);
    if (widget.doc.id > -1) {
      debugPrint("_update->Doc Id: " + widget.doc.id.toString());
      widget.dbh.updateDoc(widget.doc);
      Navigator.pop(context, true);
    } else {
      Future<int> idd = widget.dbh.getMaxId();

      //this then thing is quite interesting
      idd.then((result) {
        debugPrint("_insert->Doc Id: " + widget.doc.id.toString());
        widget.doc.id = (result != null) ? result + 1 : 1;
        widget.dbh.insertDoc(widget.doc);
        Navigator.pop(context, true);
      });
    }
  }

  // Submit form
  void _submitForm() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      showMessage('Some data is invalid. Please correct.');
    } else {
      _saveDoc();
    }
  }

  void showMessage(String message, [MaterialColor color = Colors.red]) {
    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(backgroundColor: color, content: new Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    const String cStrDays = "Enter a number of days";
    TextStyle tStyle = Theme.of(context).textTheme.title;
    String ttl = widget.doc.title;

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(ttl != "" ? ttl : "New Doc"),
        actions: (ttl == "")
            ? <Widget>[]
            : <Widget>[
                PopupMenuButton(
                  onSelected: _selectMenu,
                  itemBuilder: (BuildContext context) {
                    return menuOptions.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
      ),
      body: Form(
        key: _formKey,
        autovalidate: true,
        child: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.p),
            children: <Widget>[
              TextFormField(
                inputFormatters: [
                  WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
                ],
                controller: titleCtrl,
                style: tStyle,
                validator: (val) => Val.ValidateTitle(val),
                decoration: InputDecoration(
                    hintText: "Enter document name",
                    labelText: 'Document name',
                    icon: const Icon(Icons.title)),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: expirationCtrl,
                      maxLength: 10,
                      decoration: InputDecoration(
                          hintText: "Expiry date (i.e." +
                              DateUtils.daysAheadAsStr(daysAhead) +
                              ")",
                          labelText: 'Expiry Date'),
                      keyboardType: TextInputType.number,
                      validator: (val) => DateUtils.isValidDate(val)
                          ? null
                          : "Not a valid futue date",
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    tooltip: "choose date",
                    onPressed: () {
                      _chooseDate(context, expirationCtrl.text);
                    },
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(' '),
                  )
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('a: Alert @ 1.5 & 1 year(s)'),
                  ),
                  Switch(
                    value: fqYearCtrl,
                    onChanged: (bool value) {
                      setState(() {
                        fqYearCtrl = value;
                      });
                    },
                  )
                ],
              ),
              Row(children: <Widget>[
                Expanded(child: Text('b: Alert @ 6 months')),
                Switch(
                    value: fqHalfYearCtrl,
                    onChanged: (bool value) {
                      setState(() {
                        fqHalfYearCtrl = value;
                      });
                    }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('c: Alert @ 3 months')),
                Switch(
                    value: fqQuarterCtrl,
                    onChanged: (bool value) {
                      setState(() {
                        fqQuarterCtrl = value;
                      });
                    }),
              ]),
              Row(children: <Widget>[
                Expanded(child: Text('d: Alert @ 1 month or less')),
                Switch(
                    value: fqMonthCtrl,
                    onChanged: (bool value) {
                      setState(() {
                        fqMonthCtrl = value;
                      });
                    }),
              ]),
              Container(
                padding: const EdgeInsets.only(left: 40.0, top: 20.0),
                child: RaisedButton(
                  child: Text("save"),
                  onPressed: _submitForm,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initCtrls();
  }
}
