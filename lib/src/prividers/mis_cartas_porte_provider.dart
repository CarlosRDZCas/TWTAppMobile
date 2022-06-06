import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:two_way_transfer/src/prividers/providers.dart';

import '../components/components.dart';

class MisCartasPorteProvider extends ChangeNotifier {
  List<String> list = <String>[];
  List<Widget> lista = <Widget>[];

  bool connected = false;
  bool isButtonClickable = true;
  var openResult = 'Unknown';
  List<String> listaPDFS = <String>[];
  bool loading = false;
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  Future<void> ftp(BuildContext context) async {
    final FTPConnect _ftpConnect = new FTPConnect("twt.com.mx",
        user: "cartaporte", pass: "twoway2408", debug: true);

    Future<void> _downloadStepByStep() async {
      final logprovider = Provider.of<LoginProvider>(context, listen: false);
      loading = true;
      isButtonClickable = false;

      try {
        connected = await _ftpConnect.connect();
        if (connected) {
          await _ftpConnect.createFolderIfNotExist(logprovider.log.toString());
          await _ftpConnect.changeDirectory(logprovider.log.toString());
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
          notifyListeners();
          showPDFs();

          loading = false;
          isButtonClickable = true;

          ShowSnackBar(context, "Documentos descargados", 5, Colors.green);
        } else {
          loading = false;
          isButtonClickable = true;

          ShowSnackBar(
              context,
              "Error al conectar con el servidor\nVerifique la conexion a internet",
              5,
              Colors.red);
        }
      } catch (e) {
        ShowSnackBar(
            context,
            "Error al descargar los archivos\nVerifique su conexion a internet",
            5,
            Colors.red);

        loading = false;
        isButtonClickable = true;
      }
    }

    notifyListeners();
    await _downloadStepByStep();
  }

  void showPDFs() async {
    listaPDFS = <String>[];
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    Stream<FileSystemEntity> files = appDocDirectory.list();
    files.forEach((element) {
      if (element.path.contains(".pdf") || element.path.contains(".xml")) {
        if (!list.contains(element.path.substring(54))) {
          try {
            final files = File(element.path);
            files.delete();
            notifyListeners();
          } catch (e) {
            return;
          }
        } else {
          listaPDFS.add(element.path);
          notifyListeners();
        }
      }
    });
  }

  void showDialogs(
      BuildContext context, String filePath, BuildContext context2) {
    final pdfProvider = Provider.of<PDFProvider>(context, listen: false);
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
                    pdfProvider.nombre = nombre;
                    pdfProvider.path = filePath;
                    Navigator.of(context).popAndPushNamed(
                      "pdfview",
                    );
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

    openResult = "type=${_result.type}  message=${_result.message}";
    notifyListeners();
  }
}
