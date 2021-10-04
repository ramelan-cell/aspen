import 'dart:convert';

import 'package:apsen/model/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String userid, username, namalengkap, jabatan, nik, foto, urlfoto;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (this.mounted) {
      setState(() {
        nik = preferences.getString("nik");
      });
    }
  }

  Future<List> getData() async {
    if (nik == null) {
    } else {
      final response = await http.post(BaseUrl.getprofile, body: {"nik": nik});
      return jsonDecode(response.body);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    if (this.mounted) {
      super.initState();
      getPref();
      getData();
    }
  }

  @override
  void dispose() {
    if (this.mounted) {
      // TODO: implement dispose
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30))),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: new Stack(children: <Widget>[
                            Container(
                                width: 200.0,
                                height: 200.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: new AssetImage(
                                            'gambar/profile.png')))),
                          ]),
                        )
                      ],
                    ),
                  ),
                ),
              ],
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
            )
          ],
        ),
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
      child: ListView.builder(
          itemCount: list == null ? 0 : list.length,
          itemBuilder: (context, i) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Nama lengkap',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: 200.0,
                        child: Text(list[i]['nama'] ?? ''),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'Alamat',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: 200.0,
                        child: Text(list[i]['alamat'] ?? ''),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Text(
                          'HP',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        width: 200.0,
                        child: Text(list[i]['hp'] ?? ''),
                      )
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}
