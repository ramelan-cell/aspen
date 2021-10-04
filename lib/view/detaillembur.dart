import 'package:flutter/material.dart';

class DetailLembur extends StatefulWidget {
  List list;
  int index;
  DetailLembur({this.list, this.index});

  @override
  _DetailLemburState createState() => _DetailLemburState();
}

class _DetailLemburState extends State<DetailLembur> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Lembur',
          style: TextStyle(fontSize: 14.0),
        ),
      ),
      body: Container(
        child: ListView(
          children: [
            ListTile(
              title: Text('NIK'),
              subtitle: Text(widget.list[widget.index]['nik']),
            ),
            Divider(),
            ListTile(
              title: Text('Nama lengkap'),
              subtitle: Text(widget.list[widget.index]['nama']),
            ),
            Divider(),
            ListTile(
              title: Text('Tanggal'),
              subtitle: Text(widget.list[widget.index]['tanggal']),
            ),
            Divider(),
            ListTile(
              title: Text('Mulai'),
              subtitle: Text(widget.list[widget.index]['jam_awal']),
            ),
            Divider(),
            ListTile(
              title: new Text('selesai'),
              subtitle: new Text(widget.list[widget.index]['jam_akhir'] ?? ''),
            ),
            Divider(),
            ListTile(
              title: new Text('Selama'),
              subtitle:
                  new Text(widget.list[widget.index]['selama'] + 'Jam' ?? ''),
            ),
            Divider(),
            ListTile(
              title: new Text('Keterangan'),
              subtitle: new Text(widget.list[widget.index]['keterangan'] ?? ''),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
