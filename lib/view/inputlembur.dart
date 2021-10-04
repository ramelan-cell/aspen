import 'dart:convert';

import 'package:apsen/model/api.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InputLembur extends StatefulWidget {
  @override
  _InputLemburState createState() => _InputLemburState();
}

class _InputLemburState extends State<InputLembur> {
  DateTime tanggal;
  TimeOfDay selectedTime1 = TimeOfDay.now();
  TimeOfDay selectedTime2 = TimeOfDay.now();
  String selama, pesan, nik;
  TextEditingController txtpesan = TextEditingController();
  bool _isLoading = false;

  final snackbarKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();
  final _key = new GlobalKey<FormState>();

  void _snackbar(String str) {
    if (str.isEmpty) return;
    _scaffoldState.currentState.showSnackBar(new SnackBar(
      backgroundColor: Colors.red,
      content: new Text(str,
          style: new TextStyle(fontSize: 15.0, color: Colors.white)),
      duration: new Duration(seconds: 5),
    ));
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nik = preferences.getString("nik");
    });
  }

  Future<Null> _selectedTime1(BuildContext context) async {
    final TimeOfDay picked_time = await showTimePicker(
        context: context,
        initialTime: selectedTime1,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        });

    if (picked_time != null && picked_time != selectedTime1)
      setState(() {
        selectedTime1 = picked_time;
        print(selectedTime1);
      });
  }

  Future<Null> _selectedTime2(BuildContext context) async {
    final TimeOfDay picked_time = await showTimePicker(
        context: context,
        initialTime: selectedTime2,
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        });

    if (picked_time != null && picked_time != selectedTime2)
      setState(() {
        selectedTime2 = picked_time;
        print(selectedTime2);
      });
  }

  check() {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      if (nik == null) {
        _snackbar('Nik tidak boleh kosong');
      } else if (selectedTime1 == null) {
        _snackbar('Kolom mulai wajib disi !');
      } else if (selectedTime2 == null) {
        _snackbar('Kolom sampai wajib disi !');
      } else if (selama == null) {
        _snackbar('Kolom selama wajib disi !');
      } else if (pesan == null) {
        _snackbar('Kolom pesan wajib disi');
      } else {
        prosessimpan();
      }
    }
  }

  prosessimpan() async {
    final response = await http.post(BaseUrl.inputlembur, body: {
      "nik": nik,
      "mulai": selectedTime1.format(context),
      "tgl": tanggal.toString(),
      "selesai": selectedTime2.format(context),
      "selama": selama,
      "keterangan": pesan
    });

    final data = jsonDecode(response.body);
    print(data);

    String message = data['message'];
    _snackbar(message);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          'Input lembur',
          style: TextStyle(fontSize: 14.0),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: _key,
              child: ListView(
                children: [
                  DateTimePickerFormField(
                    style: TextStyle(fontSize: 13.0, color: Colors.black),
                    inputType: InputType.date,
                    format: DateFormat("yyyy-MM-dd"),
                    initialDate: DateTime.now(),
                    editable: false,
                    decoration: InputDecoration(
                      labelText: 'Tanggal',
                      labelStyle:
                          TextStyle(fontSize: 13.0, color: Colors.black),
                    ),
                    onChanged: (dt) {
                      setState(() => tanggal = dt);
                      print(tanggal);
                    },
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        color: Colors.orange,
                        textColor: Colors.white,
                        onPressed: () => _selectedTime1(context),
                        child: Text('Mulai lembur'),
                      ),
                      Text(
                        "${selectedTime1.format(context)}",
                        style: TextStyle(
                          fontSize: 20,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1
                            ..color = Colors.black,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        color: Colors.orange,
                        textColor: Colors.white,
                        onPressed: () => _selectedTime2(context),
                        child: Text('Selesai lembur'),
                      ),
                      Text(
                        "${selectedTime2.format(context)}",
                        style: TextStyle(
                          fontSize: 20,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 1
                            ..color = Colors.black,
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<String>(
                    itemHeight: 100.0,
                    items: [
                      DropdownMenuItem<String>(
                        child: Text('1 Jam'),
                        value: '1',
                      ),
                      DropdownMenuItem<String>(
                        child: Text('2 jam'),
                        value: '2',
                      ),
                      DropdownMenuItem<String>(
                        child: Text('3 Jam'),
                        value: '3',
                      ),
                      DropdownMenuItem<String>(
                        child: Text('4 Jam'),
                        value: '4',
                      ),
                    ],
                    onChanged: (String value) {
                      setState(() {
                        selama = value;
                        print(selama);
                      });
                    },
                    hint: Text('Selama'),
                    value: selama,
                  ),
                  TextFormField(
                    controller: txtpesan,
                    onSaved: (e) => pesan = e,
                    decoration: InputDecoration(labelText: 'keterangan'),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  GestureDetector(
                      onTap: () {
                        check();
                      },
                      child: Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.orange[900]),
                        child: Center(
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : Text(
                                  "Proses",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      )),
                ],
              )),
        ),
      ),
    );
  }
}
