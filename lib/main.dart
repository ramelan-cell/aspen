import 'dart:async';
import 'dart:convert';
import 'package:apsen/constant/constant.dart';
import 'package:apsen/launcher.dart';
import 'package:apsen/model/api.dart';
import 'package:apsen/view/about.dart';
import 'package:apsen/view/home.dart';
import 'package:apsen/view/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  OneSignal.shared
      .init("9c1a698f-3f93-439f-b2ed-890624451631", iOSSettings: null);
  OneSignal.shared
      .setInFocusDisplayType(OSNotificationDisplayType.notification);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Aplikasi presensi",
    home: Launcher(),
    theme: ThemeData(primaryColor: Colors.orange[500]),
    routes: <String, WidgetBuilder>{
      SPLASH_SCREEN: (BuildContext context) => Launcher(),
      HOME_SCREEN: (BuildContext context) => Login(),
    },
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;
  String username, password;
  final _key = new GlobalKey<FormState>();
  String msg = "";
  bool _secureText = true;
  bool _apiCall = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      setState(() {
        _apiCall = true;
      });
      login();
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldState =
      new GlobalKey<ScaffoldState>();

  void _snackbar(String str) {
    if (str.isEmpty) return;
    _scaffoldState.currentState.showSnackBar(new SnackBar(
      backgroundColor: Colors.red,
      content: new Text(str,
          style: new TextStyle(fontSize: 15.0, color: Colors.white)),
      duration: new Duration(seconds: 5),
    ));
  }

  login() async {
    final response = await http.post(BaseUrl.login,
        body: {"username": username, "password": password});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    String usernameAPI = data['user'];
    String namaAPI = data['nama'];
    String id = data['user_id'];
    String jabatan = data['jabatan'];
    String nik = data['nik'];
    String foto = data['foto'];

    if (value == 1) {
      // if(this.mounted){
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(value, usernameAPI, namaAPI, id, jabatan, foto, nik);
      });
      // }
      _snackbar(pesan);
    } else {
      _snackbar(pesan);
      setState(() {
        _apiCall = false;
      });
    }
  }

  savePref(int value, String username, String nama, String id, String jabatan,
      String foto, String nik) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", value);
      preferences.setString("nama", nama);
      preferences.setString("username", username);
      preferences.setString("id", id);
      preferences.setString("jabatan", jabatan);
      preferences.setString("nik", nik);
      preferences.setString("foto", foto);
      preferences.commit();
    });
  }

  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");
      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      _apiCall = false;
      preferences.setInt("value", 0);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if (this.mounted) {
      super.initState();
      getPref();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          // appBar: AppBar(title: new Text("Login"),),
          key: _scaffoldState,
          body: Form(
            key: _key,
            child: new Container(
              padding: EdgeInsets.only(top: 50.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.orange[900],
                Colors.orange[700],
                Colors.orange[500]
              ])),
              child: new Center(
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Login",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 40),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "Aplikasi Presensi",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    )
                                  ],
                                ),
                              ),
                              Flexible(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: new Image.asset(
                                      "gambar/logo-absen.png",
                                      width: 150,
                                      height: 100,
                                    ),
                                  )
                                ],
                              ))
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Expanded(
                        child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              bottomRight: Radius.circular(50))),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color.fromRGBO(225, 95, 27, 3),
                                        blurRadius: 5,
                                        offset: Offset(0, 2))
                                  ]),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextFormField(
                                      validator: (e) {
                                        if (e.isEmpty) {
                                          return "Please insert username";
                                        }
                                      },
                                      onSaved: (e) => username = e,
                                      decoration: InputDecoration(
                                          hintText: "Username",
                                          hintStyle:
                                              TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey[200]))),
                                    child: TextFormField(
                                      obscureText: _secureText,
                                      validator: (e) {
                                        if (e.isEmpty) {
                                          return "Please insert password";
                                        }
                                      },
                                      onSaved: (e) => password = e,
                                      decoration: InputDecoration(
                                        hintText: "Password",
                                        hintStyle:
                                            TextStyle(color: Colors.grey),
                                        suffixIcon: IconButton(
                                          onPressed: showHide,
                                          icon: Icon(_secureText
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
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
                                    child: _apiCall
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : Text(
                                            "Login",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ),
        );
        break;
      case LoginStatus.signIn:
        return MainMenu(signOut);
        break;
    }
  }
}

class MainMenu extends StatefulWidget {
  final VoidCallback signOut;
  MainMenu(this.signOut);
  @override
  _MainMenuState createState() => _MainMenuState();
}

String notifikasi;

class _MainMenuState extends State<MainMenu> {
  signOut() {
    if (this.mounted) {
      setState(() {
        widget.signOut();
      });
    }
  }

  String username = "", nama = "", userid = "";
  TabController tabController;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      username = preferences.getString("user");
      nama = preferences.getString("nama");
      userid = preferences.getString("id");
    });
  }

  @override
  initState() {
    if (this.mounted) {
      super.initState();
      getPref();
    }
  }

  @override
  void dispose() {
    // sub.dispose();
    if (mounted) {
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              new Image.asset(
                "gambar/logo-absen.png",
                width: 30,
                height: 30,
              ),
              SizedBox(
                width: 20.0,
              ),
              new Text(
                "Aplikasi presensi",
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
                color: Colors.white,
                icon: _buildIconBadge(
                    Icons.notifications, notifikasi ?? '', Colors.red),
                onPressed: null),
            IconButton(
              onPressed: () {
                signOut();
              },
              color: Colors.white,
              icon: Icon(Icons.exit_to_app),
            ),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            Home(),
            Profile(),
            About(),
          ],
        ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.red,
          unselectedLabelColor: Colors.amber[900],
          indicatorColor: Colors.redAccent,
          tabs: <Widget>[
            Tab(
              icon: Icon(Icons.home),
              child: new Text(
                "Home",
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Tab(
              icon: Icon(Icons.person),
              child: new Text(
                "Profile",
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Tab(
              icon: Icon(Icons.person),
              child: new Text(
                "About",
                style: TextStyle(fontSize: 12.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildIconBadge(
  IconData icon,
  String badgeText,
  Color badgeColor,
) {
  return Stack(
    children: <Widget>[
      Icon(
        icon,
        size: 30.0,
      ),
      Positioned(
        top: 2.0,
        right: 4.0,
        child: Container(
          padding: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
          ),
          constraints: BoxConstraints(
            minWidth: 18.0,
            minHeight: 18.0,
          ),
          child: Center(
            child: Text(
              badgeText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
