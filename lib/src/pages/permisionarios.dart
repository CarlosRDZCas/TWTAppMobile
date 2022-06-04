import 'dart:convert';
import 'dart:io';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:two_way_transfer/src/widgets/appbar.dart';
import 'package:two_way_transfer/src/widgets/drawer.dart';
import '../../args/page_args.dart';
import '../models/logmodel.dart';

class PermisionariosPage extends StatefulWidget {
  @override
  State<PermisionariosPage> createState() => _PermisionariosPageState();
}

class _PermisionariosPageState extends State<PermisionariosPage> {
  final picker = ImagePicker();
  List<String> datos = <String>[];
  TextEditingController textEditingController = TextEditingController();
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  String? nombreimg;
  File? imagePath;
  String? nombrePDF;
  bool cambio = false;
  pw.Document pdf = pw.Document();
  String? log;
  List<File?> images = <File?>[];

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    datos.add(args.log);
    datos.add(args.remision);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (cambio) _tomarFoto();
        },
        child: Icon(Icons.camera_alt_rounded),
        backgroundColor: cambio == false ? Colors.grey : Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AdvancedAppBar(acciones: [
        IconButton(
            onPressed: () {
              if (cambio) {
                _enviarPDFImagenes();
              }
            },
            icon: Icon(Icons.send))
      ]),
      drawer: MainDrawer(),
      body: AbsorbPointer(
        absorbing: _loading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Form(
                      key: _formKey,
                      child: Expanded(
                        child: TextFormField(
                          controller: textEditingController,
                          onChanged: (value) {
                            log = value;
                            setState(() {
                              cambio = false;
                            });
                          },
                          onEditingComplete: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            _verificar();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Ingrese un valor';
                            if (value.contains(RegExp(r"[A-Z,a-z]")))
                              return 'No ingrese letras';
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Ingrese el log",
                            label: Text("Log"),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _verificar();
                        },
                        child: Text("Verificar")),
                    if (_loading)
                      Container(
                        height: 20,
                        width: 20,
                        margin: const EdgeInsets.only(left: 20),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: images.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          Image.file(
                            images[index]!,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _eliminarImagen(index);
                                },
                                child: Row(
                                  children: [
                                    Text("Eliminar"),
                                    Icon(Icons.delete)
                                  ],
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                      width: double.infinity,
                      height: 450,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verificar() async {
    if (_formKey.currentState!.validate()) {
      cambio = await getLog(int.parse(log!));
    } else {
      cambio = false;
    }
  }

  Future<File?> _tomarFoto() async {
    var image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 60);

    if (image != null) {
      String date;
      date = DateTime.now().year.toString() +
          DateTime.now().month.toString() +
          DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().minute.toString();
      nombreimg = date + "_" + log! + "_" + images.length.toString() + ".jpg";
      String dir = path.dirname(image.path);
      String newPath = path.join(dir, nombreimg);
      imagePath = await File(image.path).copy(newPath);
      setState(() {
        imagePath = imagePath;
        images.add(imagePath);
      });
    }
  }

  void _enviarPDFImagenes() async {
    if (images.length > 0) {
      await imageToPDF();
      final file = await savePDF();
      sendPDFFTP();
    } else {
      _showSnackBar("Agregue las imagenes antes de enviar!", 3, Colors.orange);
    }
  }

  imageToPDF() async {
    pdf = pw.Document();
    for (var item in images) {
      final image = pw.MemoryImage(item!.readAsBytesSync());
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Expanded(
                child: pw.Image(image, fit: pw.BoxFit.fill),
                fit: pw.FlexFit.loose);
          },
        ),
      );
    }
  }

  Future<File> savePDF() async {
    try {
      final name = nombrePDF;
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/$name');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      throw Exception('Error');
    }
  }

  Future<bool> getLog(int log) async {
    final logResponse;
    setState(() {
      if (log != null) {
        _loading = true;
      }
    });
    final response = await http
        .get(Uri.parse('http://192.168.1.161:8085/api/Log?log=${log}'));
    if (response.body.length > 2) {
      final jsonresp = json.decode(response.body);

      logResponse = LogModel.fromMap(jsonresp[0]);

      if (logResponse.id == '1') {
        setState(() {
          nombrePDF = logResponse.lugar +
              logResponse.talon.toString() +
              '_' +
              logResponse.log.toString() +
              '.pdf';
        });

        _showSnackBar(
            "Log correcto, ya puede enviar las fotos!", 3, Colors.green);
        setState(() {
          if (log != null) {
            _loading = false;
          }
        });
        return cambio = true;
      } else {
        setState(() {
          if (log != null) {
            _loading = false;
          }
        });
        images.clear();
        _showSnackBar(
            "El log no existe, verifique el log ingresado!", 3, Colors.red);
        return false;
      }
    } else {
      setState(() {
        if (log != null) {
          _loading = false;
        }
      });
      images.clear();
      _showSnackBar(
          "El log no existe, verifique el log ingresado!", 3, Colors.red);
      return false;
    }
  }

  void _showSnackBar(String text, int time, Color? color) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: time),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future sendPDFFTP() async {
    final FTPConnect _ftpConnect = new FTPConnect("twt.com.mx",
        user: "SoportePermisionario", pass: "twoway2408", debug: true);
    await imageToPDF();
    final file = await savePDF();

    Future<void> _uploadStepByStep() async {
      try {
        await _ftpConnect.connect();
        await _ftpConnect.uploadFile(file);
        await _ftpConnect.disconnect();
        _showSnackBar("Datos enviados con exito!", 3, Colors.green);
      } catch (e) {
        _showSnackBar(e.toString(), 5, Colors.red);
      }
    }

    await _uploadStepByStep();
  }

  void _eliminarImagen(int index) {
    setState(() {
      images.removeAt(index);
    });
  }
}
