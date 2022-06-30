import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:provider/provider.dart';

import 'package:two_way_transfer/src/prividers/providers.dart';

class PDFViewPage extends StatefulWidget {
  @override
  _PDFViewPageState createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  String? nombre;
  String? path;

  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();

  @override
  Widget build(BuildContext context) {
    final PDFProvider pdfProvider = Provider.of<PDFProvider>(context);
    nombre = pdfProvider.nombre;
    path = pdfProvider.path;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.transparent,
        elevation: 0.1,
        onPressed: () {},
        label: Text(
          "Pagina $currentPage/$pages",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(nombre!),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: path,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              print('goto uri: $uri');
            },
            onPageChanged: (int? page, int? total) {
              print('page change: $page/$total');
              setState(() {
                currentPage = page! + 1;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
