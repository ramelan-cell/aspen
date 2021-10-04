import 'package:apsen/model/api.dart';
import 'package:flutter/material.dart';

class DetailPermit extends StatefulWidget {
  List list;
  int index;
  DetailPermit({this.list, this.index});

  @override
  _DetailPermitState createState() => _DetailPermitState();
}

class _DetailPermitState extends State<DetailPermit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pengajuan Permit',
          style: TextStyle(fontSize: 13),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('tanggal'),
                  subtitle: Text(widget.list[widget.index]['tanggal']),
                ),
                Divider(),
                ListTile(
                  title: Text('Nama'),
                  subtitle: Text(widget.list[widget.index]['nama']),
                ),
                Divider(),
                ListTile(
                  title: Text('Jenis Pengajuan'),
                  subtitle: Text(widget.list[widget.index]['tipe_permit']),
                ),
                Divider(),
                ListTile(
                  title: Text('keterangan'),
                  subtitle: Text(widget.list[widget.index]['keterangan']),
                ),
                Divider(),
                ListTile(
                  title: new Text('File'),
                  subtitle: new Image.network(BaseUrl.urlfilepermit +
                      widget.list[widget.index]['file']),
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
