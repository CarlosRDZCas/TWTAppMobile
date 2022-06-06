import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ftpconnect/ftpconnect.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../components/components.dart';
import '../models/models.dart';

class PermisionariosProvider extends ChangeNotifier {
  final picker = ImagePicker();
  List<String> datos = <String>[];
  TextEditingController textEditingController = TextEditingController();
  bool loading = false;
  final formKey = GlobalKey<FormState>();
  String? nombreimg;
  File? imagePath;
  String? nombrePDF;
  bool cambio = false;
  pw.Document pdf = pw.Document();
  String? log;
  List<File?> images = <File?>[];

  void verificar(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      cambio = await getLog(context, int.parse(log!));
      notifyListeners();
    } else {
      cambio = false;
      notifyListeners();
    }
  }

  Future<File?> tomarFoto() async {
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

      imagePath = imagePath;
      images.add(imagePath);
      notifyListeners();
    }
  }

  void enviarPDFImagenes(BuildContext context) async {
    if (images.length > 0) {
      await imageToPDF();
      final file = await savePDF();
      notifyListeners();
      sendPDFFTP(context);
    } else {
      ShowSnackBar(
          context, "Agregue las imagenes antes de enviar!", 3, Colors.orange);
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
      notifyListeners();
    }
  }

  Future<File> savePDF() async {
    try {
      final name = nombrePDF;
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/$name');
      await file.writeAsBytes(await pdf.save());
      notifyListeners();
      return file;
    } catch (e) {
      throw Exception('Error');
    }
  }

  Future<bool> getLog(BuildContext context, int log) async {
    final logResponse;

    loading = true;

    final response = await http
        .get(Uri.parse('http://192.168.1.161:8085/api/Log?log=${log}'));
    notifyListeners();
    if (response.body.length > 2) {
      final jsonresp = json.decode(response.body);

      logResponse = LogModel.fromMap(jsonresp[0]);

      if (logResponse.id == '1') {
        nombrePDF = logResponse.lugar +
            logResponse.talon.toString() +
            '_' +
            logResponse.log.toString() +
            '.pdf';

        ShowSnackBar(context, "Log correcto, ya puede enviar las fotos!", 3,
            Colors.green);

        loading = false;
        notifyListeners();
        return cambio = true;
      } else {
        loading = false;

        images.clear();
        ShowSnackBar(context, "El log no existe, verifique el log ingresado!",
            3, Colors.red);
        notifyListeners();
        return false;
      }
    } else {
      loading = false;

      images.clear();
      ShowSnackBar(context, "El log no existe, verifique el log ingresado!", 3,
          Colors.red);
      notifyListeners();
      return false;
    }
  }

  Future sendPDFFTP(BuildContext context) async {
    final FTPConnect _ftpConnect = new FTPConnect("twt.com.mx",
        user: "SoportePermisionario", pass: "twoway2408", debug: true);
    await imageToPDF();
    final file = await savePDF();
    notifyListeners();
    Future<void> _uploadStepByStep() async {
      try {
        await _ftpConnect.connect();
        await _ftpConnect.uploadFile(file);
        await _ftpConnect.disconnect();
        notifyListeners();
        ShowSnackBar(context, "Datos enviados con exito!", 3, Colors.green);
      } catch (e) {
        ShowSnackBar(context, e.toString(), 5, Colors.red);
      }
    }

    await _uploadStepByStep();
  }

  void eliminarImagen(int index) {
    images.removeAt(index);
    notifyListeners();
  }
}
