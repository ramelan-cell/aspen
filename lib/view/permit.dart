import 'dart:convert';

import 'package:apsen/model/api.dart';
import 'package:apsen/view/detailpermit.dart';
import 'package:apsen/view/input_permit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Permit extends StatefulWidget {
  @override
  _PermitState createState() => _PermitState();
}

String nikpermits;

class _PermitState extends State<Permit> {
  TextEditingController searchController = TextEditingController();
  String filter;
  static int page;
  ScrollController _sc = new ScrollController();
  bool isLoading = false;
  List permits = new List();
  final dio = new Dio();

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    nikpermits = preferences.getString("nik");
    page = 0;
    this._getMoreData(page, nikpermits);

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent) {
        _getMoreData(page, nikpermits);
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
    if (this.mounted) {
      setState(() {
        super.initState();
        getPref();
      });
    }
  }

  @override
  void dispose() {
    if (this.mounted) {
      super.dispose();
      _sc.dispose();
      searchController.dispose();
    }
  }

  void _getMoreData(int index, String nik) async {
    // ini fungsi API untuk memanggil data permit
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = BaseUrl.loadpermit +
          "nik=" +
          nik +
          "&limit=5&page=" +
          index.toString();

      final response = await dio.get(url);
      final data = jsonDecode(response.data);

      List tList = new List();

      for (int i = 0; i < data['results'].length; i++) {
        tList.add(data['results'][i]);
      }

      if (this.mounted) {
        setState(() {
          isLoading = false;
          permits.addAll(tList);
          page++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pengajuan Permit',
          style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
              color:
                  Colors.white), // ini kalau di PHP atau HTML seperti CSS nya
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    style: TextStyle(fontSize: 13.0),
                    controller: searchController,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white),
                      hintText: 'Pencarian berdasarkan nama ...',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                    ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => new InputPermit()));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
        itemCount: permits.length + 1,
        itemBuilder: (BuildContext context, int i) {
          if (i == permits.length) {
            return progressIndicator();
          } else {
            return filter == null || filter == ""
                ? GestureDetector(
                    onTap: () =>
                        Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new DetailPermit(
                                  list: permits,
                                  index: i,
                                ))),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: new ListTile(
                          leading: CircleAvatar(
                              radius: 20.0,
                              backgroundImage: AssetImage('gambar/jam.png')),
                          title: Text(
                            (permits[i]['nama']),
                            style: TextStyle(color: Colors.black),
                          ),
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
                                          (permits[i]['tanggal']))),
                                      style: TextStyle(color: Colors.black)),
                                  Text((permits[i]['tipe_permit']),
                                      style: TextStyle(color: Colors.black)),
                                  Icon(
                                    Icons.arrow_right,
                                    size: 30,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text((permits[i]['keterangan']),
                                      style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : permits[i]['nama'].toLowerCase().contains(filter
                        .toLowerCase()) // fungsi ini buat filter pencarian yah
                    ? GestureDetector(
                        // onTap: () => Navigator.of(context).push(
                        //     new MaterialPageRoute(
                        //         builder: (BuildContext context) =>
                        //             new DetailPermit(
                        //               list: permits,
                        //               i: index,
                        //             ))),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: new ListTile(
                              leading: CircleAvatar(
                                  radius: 20.0,
                                  backgroundImage:
                                      AssetImage('gambar/jam.png')),
                              title: Text((permits[i]['nama']),
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
                                              (permits[i]['tanggal']))),
                                          style:
                                              TextStyle(color: Colors.black)),
                                      Text((permits[i]['tipe_permit']),
                                          style:
                                              TextStyle(color: Colors.black)),
                                      Icon(
                                        Icons.arrow_right,
                                        size: 30,
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text((permits[i]['keterangan']),
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : new Container();
          }
        });
  }

  Widget progressIndicator() {
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
