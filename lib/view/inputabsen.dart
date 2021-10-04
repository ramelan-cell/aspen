import 'dart:async';
import 'dart:io';
import 'package:async/async.dart';

import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:apsen/model/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'package:path/path.dart' as path;

class Inputabsen extends StatefulWidget {
  @override
  _InputabsenState createState() => _InputabsenState();
}

String userid;
String nik;
DateTime date1;
String _flagvalue;
String waktu;
double jarak, jarakapi;

class _InputabsenState extends State<Inputabsen> {
  FocusNode flagNode = FocusNode();
  bool _isLoading = false;
  bool isloading = false;
  final snackbarKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  final Set<Marker> _markers = {};

  Position _currentPosition;
  String _currentAddress;
  LatLng _position;

  var lat, lng;

  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.camera);
    });
    setStatus('');
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Center(
            child: Image.file(
              snapshot.data,
              fit: BoxFit.fill,
              width: 250,
              height: 250,
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          );
        }
      },
    );
  }

  //==========

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
      userid = preferences.getString("id");
    });
  }

  getjarak() async {
    final respose = await http.get(BaseUrl.getjarak);
    jarakapi = double.parse(jsonDecode(respose.body));
  }

  void submit(BuildContext context) async {
    if (!isloading) {
      //SET VALUE LOADING JADI TRUE, DAN TEMPATKAN DI DALAM SETSTATE UNTUK MEMBERITAHUKAN PADA WIDGET BAHWA TERJADI PERUBAHAN STATE
      setState(() {
        isloading = true;
      });

      if (_flagvalue == null) {
        _snackbar('Flag absen wajib di isi');
        setState(() {
          isloading = false;
        });
      } else if (tmpFile == null) {
        _snackbar('Ambil foto terlebih dahulu');
        setState(() {
          isloading = false;
        });
      } else {
        final response1 =
            await http.post(BaseUrl.lokasikantor, body: {"user_id": userid});
        final data1 = jsonDecode(response1.body);

        int values = data1['value'];
        String pesans = data1['message'];

        if (values == 0) {
          _snackbar(pesans);
          setState(() {
            isloading = false;
          });
        } else {
          upload(tmpFile);
        }
      }
    } else {
      _snackbar('Ops, Error. Hubungi Admin');
      setState(() {
        isloading = false;
      });
    }
  }

  Future upload(File imageFile) async {
    print(jarakapi);
    for (int i = 0; i < _dataLokasi.length; i++) {
      double latkantor = double.parse(_dataLokasi[i]['latitude']);
      double longkantor = double.parse(_dataLokasi[i]['longitude']);
      jarak =
          await Geolocator().distanceBetween(lat, lng, latkantor, longkantor);

      if (jarak <= jarakapi) {
        break;
      }
    }

    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    if (jarak >= jarakapi) {
      _snackbar('Area lokasi anda diluar jangkuan kantor anda. ');
      setState(() {
        isloading = false;
        _isLoading = false;
      });
    } else {
      if (imageFile == null) {
        _snackbar('Gambar wajib di isi');
        setState(() {
          isloading = false;
          _isLoading = false;
        });
      } else {
        var stream =
            new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
        var length = await imageFile.length();
        var uri = Uri.parse(BaseUrl.inputabsen);
        var request = new http.MultipartRequest("POST", uri);

        var multipartFile = new http.MultipartFile("gambar", stream, length,
            filename: path.basename(imageFile.path));
        request.fields['flag'] = _flagvalue;
        request.fields['nik'] = nik;
        request.files.add(multipartFile);

        var response = await request.send();

        response.stream.transform(utf8.decoder).listen((value) {
          final data = jsonDecode(value);
          // print(data);
          String pesan = data['message'];

          _snackbar(pesan);
          setState(() {
            isloading = false;
            _isLoading = false;
          });
        });
      }
    }
  }

  var jam = '';
  void startJam() {
    Timer.periodic(new Duration(seconds: 1), (_) {
      var tgl = new DateTime.now();
      var formatedjam = new DateFormat.Hms().format(tgl);
      setState(() {
        jam = formatedjam;
      });
    });
  }

  @override
  initState() {
    super.initState();
    if (this.mounted) {
      startJam();
      getPref();
      getjarak();
      getLokasiKantor();
      _getCurrentLocation();
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
            style: new TextStyle(color: Colors.blue),
          ),
          content: new Text("Proses  berhasil"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
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
                submit(context);
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

  String _valLokasi;
  List<dynamic> _dataLokasi = List();
  void getLokasiKantor() async {
    final respose = await http.get(BaseUrl.getlokasi);
    var listData = jsonDecode(respose.body);
    if (mounted) {
      setState(() {
        _dataLokasi = listData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: new Text(
          'Input Absen',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
        actions: <Widget>[
          FlatButton(
            child: isloading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                : Icon(
                    Icons.save,
                    color: Colors.white,
                  ),
            onPressed: () => _alertDialog(),
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        margin: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Container(
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'gambar/jam.png',
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          'Pukul : ' + jam + ' WIB',
                          style: TextStyle(color: Colors.black, fontSize: 20.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            OutlineButton(
              padding: EdgeInsets.all(10.0),
              color: Colors.blue,
              onPressed: () => chooseImage(),
              child: Text(
                'Ambil Foto',
                style: TextStyle(color: Colors.black),
              ),
            ),
            showImage(),
            new Padding(padding: EdgeInsets.only(bottom: 10.0)),
            DropdownButton<String>(
              items: [
                DropdownMenuItem<String>(
                  child: Text('Masuk Kerja'),
                  value: 'MASUK',
                ),
                DropdownMenuItem<String>(
                  child: Text('Pulang Kerja'),
                  value: 'PULANG',
                ),
              ],
              onChanged: (String value) {
                setState(() {
                  _flagvalue = value;
                  print(_flagvalue);
                });
              },
              hint: Text('Pilih Tipe'),
              value: _flagvalue,
            ),
            FlatButton(
              child: Text(
                "Ketuk Lokasi anda saat ini ",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                _getCurrentLocation();
              },
            ),
            new Container(
              padding: EdgeInsets.all(8.0),
              height: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              child: lat == null || lng == null
                  ? Container()
                  : GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _position,
                        zoom: 18.0,
                      ),
                      markers: _markers,
                    ),
            ),
            if (_currentPosition != null)
              new Container(
                  padding: EdgeInsets.all(8.0),
                  child: Text(_currentAddress ?? '')),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() async {
        _position =
            LatLng(_currentPosition.latitude, _currentPosition.longitude);
        lat = _position.latitude;
        lng = _position.longitude;

        _currentAddress =
            "${place.locality}, ${place.postalCode},${place.subAdministrativeArea},${place.administrativeArea}, ${place.country}";

        _markers.add(
          Marker(
            markerId: MarkerId("${_position.latitude}, ${_position.longitude}"),
            position: _position,
            icon: BitmapDescriptor.defaultMarker,
          ),
        );
      });
    } catch (e) {
      print(e);
    }
  }
}
