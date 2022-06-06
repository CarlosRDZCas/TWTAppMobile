import 'dart:io';

import 'package:ftpconnect/ftpconnect.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../components/components.dart';
import '../models/models.dart';

class CartaPorteProvider extends ChangeNotifier {
  bool loading = false;
  String? nombreimg;
  File? imagePath;
  String? textDescripcion;
  LocationData? currentLocation;
  bool isButtonClickable = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  pw.Document pdf = pw.Document();
  final picker = ImagePicker();
  var location = new Location();

  Widget getImageWidget(BuildContext context, Log? log) {
    if (imagePath == null) {
      return IconButton(
          iconSize: 400,
          onPressed: () {
            tomarFoto(context, log!);
          },
          icon: Image.asset(
            "assets/images/take_photo.png",
          ));
    } else {
      return IconButton(
        iconSize: 400,
        onPressed: () {
          tomarFoto(context, log!);
        },
        icon: Image.file(imagePath!),
      );
    }
  }

  tomarFoto(BuildContext context, Log? log) async {
    var image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 45);

    if (image != null) {
      String date;
      date = DateTime.now().year.toString() +
          DateTime.now().month.toString() +
          DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().minute.toString();
      nombreimg = date + "_" + log!.log.toString() + "_" + ".jpg";
      String dir = path.dirname(image.path);
      String newPath = path.join(dir, nombreimg);
      imagePath = await File(image.path).copy(newPath);
    }
    notifyListeners();
  }

  Future getLocation(BuildContext context, Log? log) async {
    currentLocation = await location.getLocation();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
    }
    if (!loading && imagePath != null) {
      loading = true;
      isButtonClickable = false;

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
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
      }

      try {
        await sendPDFFTP(context, log!);

        loading = false;
        isButtonClickable = true;
      } catch (e) {
        ShowSnackBar(
            context, "Error, compruebe su conexion a internet", 5, Colors.red);

        loading = false;
        isButtonClickable = true;
      }
      return;
    } else {
      loading = false;
      isButtonClickable = true;

      ShowSnackBar(context, 'Debe tener una remision y foto!', 5, Colors.red);
    }
    notifyListeners();
  }

  Future sendPDFFTP(BuildContext context, Log log) async {
    final FTPConnect _ftpConnect = new FTPConnect("twt.com.mx",
        user: "cartaporte", pass: "twoway2408", debug: true);
    await imageToPDF();
    final file = await savePDF(log);
    Future<void> _uploadStepByStep() async {
      try {
        await _ftpConnect.connect();
        await _ftpConnect.createFolderIfNotExist(log.log.toString());
        await _ftpConnect.changeDirectory(log.log.toString());
        await _ftpConnect.createFolderIfNotExist('Recibidos');
        await _ftpConnect.changeDirectory('Recibidos');
        await _ftpConnect.uploadFile(file);
        await _ftpConnect.disconnect();
        ShowSnackBar(context, "Datos enviados con exito!", 5, Colors.green);
      } catch (e) {
        ShowSnackBar(context, e.toString(), 5, Colors.red);
      }
    }

    await _uploadStepByStep();
    notifyListeners();
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

  Future<File> savePDF(Log log) async {
    try {
      String date;
      date = DateTime.now().year.toString() +
          DateTime.now().month.toString() +
          DateTime.now().day.toString() +
          DateTime.now().hour.toString() +
          DateTime.now().minute.toString();
      final name =
          log.log.toString() + "_" + log.remision + "_" + date + ".pdf";
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/$name');
      await file.writeAsBytes(await pdf.save());
      notifyListeners();
      return file;
    } catch (e) {
      throw Exception('Error');
    }
  }
}
