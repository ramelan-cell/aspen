import 'package:apsen/model/api.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class InputPermit extends StatefulWidget {
  @override
  _InputPermitState createState() => _InputPermitState();
}

class _InputPermitState extends State<InputPermit> {
  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String errMessage = 'Image Empty !!!';
  String nik;
  final snackbarKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  final _key = new GlobalKey<FormState>();

  bool _isLoading = false;
  String pesan;
  String nominal;
  DateTime tanggalmulai;
  DateTime tanggalselesai;
  String tipeabsen;

  TextEditingController txtpesan = TextEditingController();

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      nik = preferences.getString("nik");
    });
  }

  void _snackbar(String str) {
    if (str.isEmpty) return;
    _scaffoldState.currentState.showSnackBar(new SnackBar(
      backgroundColor: Colors.red,
      content: new Text(str,
          style: new TextStyle(fontSize: 15.0, color: Colors.white)),
      duration: new Duration(seconds: 5),
    ));
  }

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.camera);
    });
    setStatus('');
  }

  chooseImage1() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      startUpload();
    }
  }

  startUpload() {
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    upload(tmpFile);
  }

  Future upload(File imageFile) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });
    }

    if (tanggalmulai == null) {
      setState(() {
        _isLoading = false;
      });
      _snackbar("Tanggal mulai wajib disi");
    } else if (tanggalselesai == null) {
      setState(() {
        _isLoading = false;
      });
      _snackbar("Tanggal selesai wajib disi");
    } else if (_valPermit == null) {
      setState(() {
        _isLoading = false;
      });
      _snackbar("Tipe wajib disi");
    } else {
      print(imageFile);
      print('eko');
      var stream =
          new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      var length = await imageFile.length();
      var uri = Uri.parse(BaseUrl.uploadpermit);
      var request = new http.MultipartRequest("POST", uri);

      var multipartFile = new http.MultipartFile("gambar", stream, length,
          filename: path.basename(imageFile.path));
      request.fields['nik'] = nik;
      request.fields['tgl_mulai'] = tanggalmulai.toString();
      request.fields['tgl_akhir'] = tanggalselesai.toString();
      request.fields['tipe_permit'] = _valPermit;
      request.fields['keterangan'] = pesan;
      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        _snackbar("Uploaded Sukses");
      } else {
        setState(() {
          _isLoading = false;
        });
        _snackbar("Upload Failed");
      }
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    }
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

  Future<void> _alertDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          titleTextStyle: TextStyle(color: Colors.black),
          actions: <Widget>[
            FlatButton(
              child: Text('Camera'),
              onPressed: () {
                chooseImage();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Galery'),
              onPressed: () {
                chooseImage1();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  initState() {
    super.initState();
    getPref();
    getPermit();
  }

  String _valPermit;
  List<dynamic> _dataPermit = List();
  void getPermit() async {
    final respose = await http.get(BaseUrl.getmasterpermit);
    var listData = jsonDecode(respose.body);
    if (this.mounted) {
      setState(() {
        _dataPermit = listData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldState,
      appBar: AppBar(
        title: Text(
          'Input Permit',
          style: TextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _key,
          child: ListView(
            children: <Widget>[
              DateTimePickerFormField(
                style: TextStyle(fontSize: 13.0, color: Colors.black),
                inputType: InputType.date,
                format: DateFormat("yyyy-MM-dd"),
                initialDate: DateTime.now(),
                editable: false,
                decoration: InputDecoration(
                  labelText: 'Tgl Mulai',
                  labelStyle: TextStyle(fontSize: 13.0, color: Colors.green),
                ),
                onChanged: (dt) {
                  setState(() => tanggalmulai = dt);
                  print(tanggalmulai);
                },
              ),
              DateTimePickerFormField(
                style: TextStyle(fontSize: 13.0, color: Colors.black),
                inputType: InputType.date,
                format: DateFormat("yyyy-MM-dd"),
                initialDate: DateTime.now(),
                editable: false,
                decoration: InputDecoration(
                  labelText: 'Tgl Selesai',
                  labelStyle: TextStyle(fontSize: 13.0, color: Colors.green),
                ),
                onChanged: (dt) {
                  setState(() => tanggalselesai = dt);
                  print(tanggalselesai);
                },
              ),
              DropdownButton(
                style: TextStyle(fontSize: 13.0, color: Colors.black),
                isExpanded: true,
                hint: Text("Jenis Permit"),
                value: _valPermit,
                items: _dataPermit.map((item) {
                  return DropdownMenuItem(
                    child: Text(item['nama']),
                    value: item['id'],
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _valPermit = value;
                  });
                },
              ),
              TextFormField(
                controller: txtpesan,
                onSaved: (e) => pesan = e,
                decoration: InputDecoration(labelText: 'keterangan'),
              ),
              OutlineButton(
                onPressed: () => _alertDialog(),
                child: Text(
                  'Choose Image',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              showImage(),
              SizedBox(
                height: 20.0,
              ),
              GestureDetector(
                  onTap: () {
                    check();
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.orange[900]),
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
              SizedBox(
                height: 20.0,
              ),
              Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
