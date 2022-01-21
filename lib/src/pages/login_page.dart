import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:two_way_transfer/args/page_args.dart';


class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  bool bandera = false;
  late Map data;
  GlobalKey<FormState> _frmKey = GlobalKey<FormState>();
  String? _log;
  String? _remision;

  late FocusNode nombre = FocusNode();
  late FocusNode clave = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            width: double.infinity,
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Transform.translate(
                  offset: Offset(-20, 10),
                  child: Image.asset("assets/images/twt.png", scale: 1.8),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, 0),
            child: Center(
              child: Form(
                key: _frmKey,
                child: SingleChildScrollView(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    margin: EdgeInsets.only(left: 20, right: 30, top: 0),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: "Log",
                              icon: Icon(Icons.person),
                            ),
                            onSaved: (value) {
                              _log = value;
                            },
                            validator: (value) =>
                                value!.isEmpty ? "Ingrese el LOG" : null,
                            focusNode: this.nombre,
                            onEditingComplete: () {
                              requestFocusNode(context, clave);
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.teal)),
                            onPressed: () => _login(context),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Iniciar Sesion",
                                  style: TextStyle(color: Colors.white),
                                ),
                                if (_loading)
                                  Container(
                                    height: 20,
                                    width: 20,
                                    margin: const EdgeInsets.only(left: 20),
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void requestFocusNode(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  void _login(BuildContext context) {
    if (!_loading) {
      if (_frmKey.currentState!.validate()) {
        _frmKey.currentState!.save();
        setState(() {
          _loading = true;
          FirebaseFirestore.instance
              .collection('Log')
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              _log = _log!;
              if (doc["LogNo"].toString() == _log) {
                setState(() {
                  _loading = false;
                  bandera = true;
                  Navigator.pushReplacementNamed(context, "miscartasporte",
                      arguments: ScreenArguments(_log!, doc["Remision"]));
                });
              } else {
                print("Error log");
                setState(() {
                  _loading = false;
                });
              }
            });
            if (bandera == false) {
              _showSnackBar(
                  "No se pudo iniciar sesion, Verifique sus datos y/o conexion a internet. ",
                  6,
                  Colors.red);
            }
          });
        });
      }
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showSnackBar(String text, int time, Color? color) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 6),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    super.dispose();
    nombre.dispose();
    clave.dispose();
  }

  @override
  void initState() {
    super.initState();
    nombre = FocusNode();
    clave = FocusNode();
  }
}
