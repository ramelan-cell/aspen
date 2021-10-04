import 'dart:convert';

import 'package:apsen/model/api.dart';
import 'package:apsen/view/detaillembur.dart';
import 'package:apsen/view/inputlembur.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Lembur extends StatefulWidget {
  @override
  _LemburState createState() => _LemburState();
}

String nikUsers;

class _LemburState extends State<Lembur> {
  bool isLoading = false;
  TextEditingController searchController = new TextEditingController();
  String filter;
  static int page;
  ScrollController _sc = new ScrollController();
  List lemburs = new List();
  final dio = new Dio();

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    nikUsers = preferences.getString("nik");
    page = 0;
    this._getMoreData(page, nikUsers);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page, nikUsers);
      }
    });

    searchController.addListener(() {
      if (this.mounted) {
        setState(() {
          filter = searchController.text;
        });
      }
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
      appBar: AppBar(
        shadowColor: Colors.transparent,
        title: Text(
          'data lembur',
          style: TextStyle(fontSize: 14),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => InputLembur()));
        },
      ),
      body: Stack(
        children: [
          Container(
            height: 70,
            decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20))),
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    style: TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.black),
                        hintText: 'Pencarian berdasarkan nama ...',
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                  ),
                ),
                new Expanded(
                  child: _buildList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _getMoreData(int index, String nik) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = BaseUrl.loadlembur +
          "nik=" +
          nik +
          "&limit=10&page=" +
          index.toString();

      final response = await dio.get(url);
      final data = jsonDecode(response.data);

      List tList = new List();

      for (int i = 0; i < data['results'].length; i++) {
        tList.add(data['results'][i]);
      }

      setState(() {
        isLoading = false;
        lemburs.addAll(tList);
        page++;
      });
    }
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: lemburs.length + 1, // Add one more item for progress indicator
      padding: EdgeInsets.symmetric(vertical: 8.0),
      itemBuilder: (BuildContext context, int index) {
        if (index == lemburs.length) {
          return _buildProgressIndicator();
        } else {
          return filter == null || filter == ""
              ? GestureDetector(
                  onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => new DetailLembur(
                            list: lemburs,
                            index: index,
                          ))),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new ListTile(
                        leading: CircleAvatar(
                            radius: 20.0,
                            backgroundImage: AssetImage('gambar/jam.png')),
                        title: Text((lemburs[index]['nama']),
                            style: TextStyle(color: Colors.black)),
                        subtitle: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    DateFormat(
                                      "dd-MM-yyyy",
                                    ).format(DateTime.parse(
                                        (lemburs[index]['tanggal']))),
                                    style: TextStyle(color: Colors.black)),
                                Text(
                                    'Selama ' +
                                        (lemburs[index]['selama']) +
                                        ' Jam',
                                    style: TextStyle(color: Colors.black)),
                                Icon(
                                  Icons.arrow_right,
                                  size: 30,
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text((lemburs[index]['keterangan']),
                                    style: TextStyle(color: Colors.black)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : lemburs[index]['nama']
                      .toLowerCase()
                      .contains(filter.toLowerCase())
                  ? GestureDetector(
                      onTap: () => Navigator.of(context).push(
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new DetailLembur(
                                    list: lemburs,
                                    index: index,
                                  ))),
                      child: Card(
                        child: new ListTile(
                          leading: CircleAvatar(
                              radius: 20.0,
                              backgroundImage: AssetImage('gambar/jam.png')),
                          title: Text((lemburs[index]['nama']),
                              style: TextStyle(color: Colors.black)),
                          subtitle: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      DateFormat(
                                        "dd-MM-yyyy",
                                      ).format(DateTime.parse(
                                          (lemburs[index]['tanggal']))),
                                      style: TextStyle(color: Colors.black)),
                                  Text(
                                      'Selama ' +
                                          (lemburs[index]['selama']) +
                                          ' Jam',
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text((lemburs[index]['keterangan']),
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : new Container();
        }
      },
      controller: _sc,
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }
}
