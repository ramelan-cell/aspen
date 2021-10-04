import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'About',
      //     style: TextStyle(fontSize: 12.0, color: Colors.black),
      //   ),
      // ), // ini untuk membuat titel atau judul suatu halaman
      body: Container(
        child: Center(
          // center ini untuk meletakan object agar di tengah suatu halaman ya
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'gambar/logo-absen.png',
                width: 80,
                height: 80,
              ), // ini fungsinya untuk menampilkan sebuah gambar ambil dari lokal kita
              SizedBox(
                height: 5,
              ),
              Text(
                'Aplikasi Presensi',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight
                        .bold), // oh ya untuk style disini seperti hanya  CSS di HTML
              ),
              SizedBox(
                height: 5,
              ), // ini dipakai untuk buat kasih jarak aja sih misalkan jarak dari atas kebawah pakai height untuk samping pakai width
              Text(
                'Versi : 0.1',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ), //untuk body ini kalau di bahasa HTML itu element body <body> jadi wadang untuk membuat content yang akan di buat
    );
  }
}
