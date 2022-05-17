import 'dart:convert';

import 'dart:io';

import 'package:location/location.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:two_way_transfer/args/page_args.dart';
import 'package:two_way_transfer/src/class/data_carta_porte.dart';
import 'package:two_way_transfer/src/components/appbar.dart';
import 'package:two_way_transfer/src/components/drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

class EnviarCartaPorte extends StatefulWidget {
  @override
  _EnviarCartaPorteState createState() => _EnviarCartaPorteState();
}

class _EnviarCartaPorteState extends State<EnviarCartaPorte> {
  final picker = ImagePicker();
  bool _loading = false;
  String? nombreimg;
  File? imagePath;
  String? textDescripcion;

  var location = new Location();
  LocationData? currentLocation;
  bool isButtonClickable = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  pw.Document pdf = pw.Document();
  List<String> datos = <String>[];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    datos.add(args.log);
    datos.add(args.remision);
    return Scaffold(
      appBar: AdvancedAppBar(
        datos: datos[0],
        acciones: null,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.photo_camera),
        onPressed: () {
          _tomarFoto();
        },
      ),
      drawer: MainDrawer(
        datos: datos,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    datos[1],
                    style: TextStyle(
                        fontSize: 45,
                        color: Colors.teal,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Lato"),
                  )),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 340,
                width: double.infinity,
                child: Center(child: getImageWidget()),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  onSaved: (value) {
                    textDescripcion = value;
                  },
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    hintStyle: TextStyle(fontSize: 20),
                    icon: Icon(Icons.description),
                    labelText: 'Descripcion',
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size>(
                        Size(double.infinity, 50)),
                    elevation: MaterialStateProperty.all<double>(10),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (isButtonClickable) getLocation();
                    
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Enviar Foto y Descripcion"),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String text, int time, Color? color) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 6),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget getImageWidget() {
    if (imagePath == null) {
      return IconButton(
          iconSize: 400,
          onPressed: () {
            _tomarFoto();
          },
          icon: Image.asset(
            "assets/images/take_photo.png",
          ));
    } else {
      return IconButton(
        iconSize: 400,
        onPressed: () {
          _tomarFoto();
        },
        icon: Image.file(imagePath!),
      );
    }
  }

  Future<File?> _tomarFoto() async {
    var image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 45);

    if (image != null) {
      String date;
      date = DateTime.now().year.toString() +
          DateTime.now().month.toString() +
          DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().minute.toString();
      nombreimg = date + "_" + datos[0].toString() + "_" + ".jpg";
      String dir = path.dirname(image.path);
      String newPath = path.join(dir, nombreimg);
      imagePath = await File(image.path).copy(newPath);

      setState(() {
        imagePath = imagePath;
      });
    }
  }

  Future<CartaPorteFoto> postApiEnvariCartaPorte(
      String? remision,
      int clave,
      double? latitud,
      double? longitud,
      String fechaUpdate,
      String operador,
      String ruta,
      String texto) async {
    try {
      final response = await http
          .post(
        Uri.parse('http://192.168.1.161:8089/api/recibido'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'Remision': remision,
          'Clave': clave,
          'FechaUpdate': fechaUpdate,
          'Latitud': latitud,
          'Longitud': longitud,
          'Operador': operador,
          'Ruta': ruta,
          'Texto': texto,
        }),
      )
          .timeout(Duration(seconds: 45), onTimeout: () {
        throw Exception('Error al enviar los datos.');
      });
      if (response.statusCode == 201) {
        return CartaPorteFoto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error al enviar los datos.');
      }
    } catch (e) {
      throw Exception('Error al enviar los datos.');
    }
  }

  Future getLocation() async {
    currentLocation = await location.getLocation();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    if (!_loading && imagePath != null) {
      setState(() {
        _loading = true;
        isButtonClickable = false;
      });

      var serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }
      var _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }
      currentLocation = await location.getLocation();
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
      }

      // String path =
      //     "P:\\Apps\\Proyecto\\CartaPorte\\${datos[0].toString()}\\${remision}_$nombreimg";
      try {
        // await postApiEnvariCartaPorte(
        //     remision,
        //     int.parse(datos[0]),
        //     currentLocation!.latitude,
        //     currentLocation!.longitude,
        //     DateTime.now().toIso8601String(),
        //     datos[0].toString(),
        //     path,
        //     textDescripcion!);
        await sendPDFFTP();
        setState(() {
          _loading = false;
          isButtonClickable = true;
        });
      } catch (e) {
        _showSnackBar("Error, compruebe su conexion a internet", 5, Colors.red);
        setState(() {
          _loading = false;
          isButtonClickable = true;
        });
      }
      return;
    } else {
      setState(() {
        _loading = false;
        isButtonClickable = true;
      });
      _showSnackBar('Debe tener una remision y foto!', 5, Colors.red);
    }
  }

  Future sendPDFFTP() async {
    final FTPConnect _ftpConnect = new FTPConnect("twt.com.mx",
        user: "cartaporte", pass: "twoway2408", debug: true);
    await imageToPDF();
    final file = await savePDF();
    Future<void> _uploadStepByStep() async {
      try {
        await _ftpConnect.connect();
        await _ftpConnect.createFolderIfNotExist(datos[0].toString());
        await _ftpConnect.changeDirectory(datos[0].toString());
        await _ftpConnect.createFolderIfNotExist('Recibidos');
        await _ftpConnect.changeDirectory('Recibidos');
        await _ftpConnect.uploadFile(file);
        await _ftpConnect.disconnect();
        _showSnackBar("Datos enviados con exito!", 5, Colors.green);
      } catch (e) {
        _showSnackBar(e.toString(), 5, Colors.red);
      }
    }

    await _uploadStepByStep();
  }

  imageToPDF() async {
    final image = pw.MemoryImage(imagePath!.readAsBytesSync());
    pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Expanded(child: pw.Image(image), fit: pw.FlexFit.loose);
        },
      ),
    );
  }

  Future<File> savePDF() async {
    try {
      String date;
      date = DateTime.now().year.toString() +
          DateTime.now().month.toString() +
          DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().minute.toString();
      final name = datos[0] + "_" + datos[1] + "_" + date + ".pdf";
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/$name');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      throw Exception('Error');
    }
  }
}
