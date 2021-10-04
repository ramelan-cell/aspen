import 'dart:convert';

import 'package:apsen/model/api.dart';
import 'package:apsen/view/inputabsen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class Absensi extends StatefulWidget {
  @override
  _AbsensiState createState() => _AbsensiState();
}

class _AbsensiState extends State<Absensi> {
  String nikUsers, jabatan;
  bool _isLoading = false;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nikUsers = preferences.getString("nik");
      jabatan = preferences.getString("jabatan");
    });
  }

  Future<List> getData() async {
    if (nikUsers == null) {
    } else {
      final response = await http.post(BaseUrl.absen, body: {"nik": nikUsers});
      return jsonDecode(response.body);
    }
  }

  Future<void> _alertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          titleTextStyle: TextStyle(color: Colors.black),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Apakah anda yakin !!!.',
                  style: TextStyle(fontSize: 13.0),
                ),
                // Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : callabsen();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  callabsen() async {
    if (!_isLoading) {
      //SET VALUE LOADING JADI TRUE, DAN TEMPATKAN DI DALAM SETSTATE UNTUK MEMBERITAHUKAN PADA WIDGET BAHWA TERJADI PERUBAHAN STATE
      setState(() {
        _isLoading = true;
      });

      print(BaseUrl.callabsen);
      print(nikUsers);

      final response =
          await http.post(BaseUrl.callabsen, body: {"nik": nikUsers});
      final data = jsonDecode(response.body);
      int value = data['value'];
      String pesan = data['message'];
      if (value == 1) {
        print(pesan);
        setState(() {
          _showDialogSuccess();
        });
      } else {
        print(pesan);
      }
    }
  }

  void _showDialogSuccess() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(
            "Success !!!",
            style: new TextStyle(color: Colors.green),
          ),
          content: new Text("Proses Call presensi berhasil"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                setState(() {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => Login()),
                      (route) => false);
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: new Text(
            'Absensi periode bulan ini',
            style: TextStyle(fontSize: 12),
          ),
          actions: <Widget>[
            FlatButton(
              child: _isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
              onPressed: () => {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) => Inputabsen()))
              },
            )
          ]),
      body: Container(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: DefaultTextStyle(
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Hari",
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Tanggal",
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "In",
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Out",
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Flag",
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: new FutureBuilder<List>(
                  future: getData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    return snapshot.hasData
                        ? new ItemList(
                            list: snapshot.data,
                          )
                        : new Center(
                            child: new CircularProgressIndicator(),
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.get_app),
        onPressed: () {
          _alertDialog();
        },
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;
  ItemList({this.list});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new ListView.builder(
        itemCount: list == null ? 0 : list.length,
        itemBuilder: (context, i) {
          if (list[i]['flg_hadir'] == "OFF") {
            return new GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.red[600]),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          } else if (list[i]['flg_hadir'] == "I") {
            return new GestureDetector(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => null)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          } else if (list[i]['flg_hadir'] == "AN") {
            return new GestureDetector(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => null)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.yellow),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          } else if (list[i]['flg_hadir'] == "T") {
            return new GestureDetector(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => null)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          } else if (list[i]['flg_hadir'] == "C") {
            return new GestureDetector(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => null)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.green),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          } else if (list[i]['flg_hadir'] == "S") {
            return new GestureDetector(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => null)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          } else {
            return new GestureDetector(
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => null)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    child: DefaultTextStyle(
                      style: TextStyle(fontSize: 12, color: Colors.black),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['hari'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['tgl'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['in'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              list[i]['out'] ?? '',
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              list[i]['flg_hadir'] ?? '',
                              textAlign: TextAlign.end,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
