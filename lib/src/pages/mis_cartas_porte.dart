import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:two_way_transfer/args/args_pdf.dart';
import 'package:two_way_transfer/args/page_args.dart';
import 'package:open_file/open_file.dart';
import 'package:two_way_transfer/src/components/appbar.dart';
import 'package:two_way_transfer/src/components/drawer.dart';
import 'package:path_provider/path_provider.dart';

class MisCartasPorte extends StatefulWidget {
  @override
  _MisCartasPorteState createState() => _MisCartasPorteState();
}

class _MisCartasPorteState extends State<MisCartasPorte> {
  List<String> datos = <String>[];
  List<String> list = <String>[];
  List<Widget> lista = <Widget>[];

  bool connected = false;
  bool isButtonClickable = true;
  var _openResult = 'Unknown';
  List<String> listaPDFS = <String>[];
  bool _loading = false;
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ScreenArguments;
    datos.add(args.log);
    datos.add(args.remision);
    return Scaffold(
      appBar: AdvancedAppBar(
        datos: datos[0],
      ),
      drawer: MainDrawer(
        datos: datos,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          if (isButtonClickable) ftp();
        },
      ),
      body: AbsorbPointer(
        absorbing: _loading,
        child: Container(
          color: Color(0xfffffffE),
          child: Stack(
            children: [
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Text(
                                    "Mis Cartas Porte",
                                    style: TextStyle(
                                        fontSize: 45,
                                        color: Colors.teal,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Lato"),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              if (_loading)
                                Center(
                                    child: Image(
                                  image:
                                      AssetImage("assets/images/delivery.gif"),
                                  width: double.infinity,
                                  height: 60,
                                  fit: BoxFit.fill,
                                )),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listaPDFS.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Card(
                                  color: Color(0xffECF7F2),
                                  child: InkWell(
                                    onTap: () {
                                      _showDialog(listaPDFS[index], context);
                                    },
                                    child: Container(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0, vertical: 8),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                if (listaPDFS[index]
                                                    .contains('.pdf'))
                                                  Icon(
                                                    Icons.picture_as_pdf,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                if (listaPDFS[index]
                                                    .contains('.xml'))
                                                  Icon(
                                                    Icons.file_copy,
                                                    color: Colors.teal,
                                                    size: 35,
                                                  ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 25),
                                                    child: Text(
                                                      listaPDFS[index]
                                                          .substring(54),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  margin: EdgeInsets.symmetric(horizontal: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // _showPDFsInit();
  }

  void _showSnackBar(String text, int time, Color? color) {
    SnackBar snackBar = SnackBar(
      content: Text(text),
      backgroundColor: color,
      duration: Duration(seconds: time),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> ftp() async {
    final FTPConnect _ftpConnect = new FTPConnect("twt.com.mx",
        user: "cartaporte", pass: "twoway2408", debug: true);

    Future<void> _downloadStepByStep() async {
      setState(() {
        _loading = true;
        isButtonClickable = false;
      });
      try {
        connected = await _ftpConnect.connect();
        if (connected) {
          await _ftpConnect.createFolderIfNotExist(datos[0].toString());
          await _ftpConnect.changeDirectory(datos[0].toString());
          await _ftpConnect.createFolderIfNotExist('Enviados');
          await _ftpConnect.changeDirectory('Enviados');
          List<String> ftpfiles =
              await _ftpConnect.listDirectoryContentOnlyNames();
          list = ftpfiles;
          for (var file in ftpfiles) {
            if (file.toString().contains(".pdf") ||
                file.toString().contains(".xml")) {
              String fileNames = file.toString();
              Directory appDocDirectory =
                  await getApplicationDocumentsDirectory();

              Future<File> _fileMock({fileName = '', content = ''}) async {
                final File file = File('${appDocDirectory.path}/$fileNames');
                await file.writeAsString(content);
                return file;
              }

              File downloadedFile = await _fileMock(fileName: fileNames);
              await _ftpConnect.downloadFile(fileNames, downloadedFile);
            }
          }
          _showPDFs();
          setState(() {
            _loading = false;
            isButtonClickable = true;
          });
          _showSnackBar("Documentos descargados", 5, Colors.green);
        } else {
          setState(() {
            _loading = false;
            isButtonClickable = true;
          });
          _showSnackBar(
              "Error al conectar con el servidor\nVerifique la conexion a internet",
              5,
              Colors.red);
        }
      } catch (e) {
        _showSnackBar(
            "Error al descargar los archivos\nVerifique su conexion a internet",
            5,
            Colors.red);
        setState(() {
          _loading = false;
          isButtonClickable = true;
        });
      }
    }

    await _downloadStepByStep();
  }

  void _showPDFs() async {
    listaPDFS = <String>[];
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    Stream<FileSystemEntity> files = appDocDirectory.list();
    files.forEach((element) {
      if (element.path.contains(".pdf") || element.path.contains(".xml")) {
        setState(() {
          if (!list.contains(element.path.substring(54))) {
            try {
              final files = File(element.path);
              files.delete();
            } catch (e) {
              return;
            }
          } else {
            listaPDFS.add(element.path);
          }
        });
      }
    });
  }

  void _showPDFsInit() async {
    setState(() {
      _loading = true;
      isButtonClickable = false;
    });
    listaPDFS = <String>[];
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    Stream<FileSystemEntity> files = appDocDirectory.list();
    files.forEach((element) {
      if (element.path.contains(".pdf") || element.path.contains(".xml")) {
        setState(() {
          listaPDFS.add(element.path);
        });
      }
    });
    setState(() {
      _loading = false;
      isButtonClickable = true;
    });
  }

  void _showDialog(String filePath, BuildContext context2) {
    String nombre = filePath.substring(54);
    if (nombre.contains(".pdf")) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Desea abrir el archivo $nombre ?"),
              content: Text("Esta seguro que quiere abrir el archivo $nombre?"),
              actions: [
                TextButton(
                  child: Text("Abrir"),
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed("pdfview",
                        arguments: PdfArguments(nombre, filePath));
                  },
                ),
                TextButton(
                  child: Text("Salir"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else if (nombre.contains('.xml')) {
      openFile(filePath);
    }
  }

  Future<void> openFile(String filePath) async {
    final _result = await OpenFile.open(filePath);
    print(_result.message);
    setState(() {
      _openResult = "type=${_result.type}  message=${_result.message}";
    });
  }
}
