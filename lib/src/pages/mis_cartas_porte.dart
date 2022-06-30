import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../prividers/providers.dart';
import '../widgets/widgets.dart';

class MisCartasPorte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final misCartasPorteProvider = Provider.of<MisCartasPorteProvider>(context);
    return Scaffold(
      appBar: AdvancedAppBar(
        acciones: null,
      ),
      drawer: MainDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh),
        onPressed: () {
          if (misCartasPorteProvider.isButtonClickable)
            misCartasPorteProvider.ftp(context);
        },
      ),
      body: AbsorbPointer(
        absorbing: misCartasPorteProvider.loading,
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
                              if (misCartasPorteProvider.loading)
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
                        itemCount: misCartasPorteProvider.listaPDFS.length,
                        itemBuilder: (BuildContext context, int index) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Card(
                                  color: Color(0xffECF7F2),
                                  child: InkWell(
                                    onTap: () {
                                      misCartasPorteProvider.showDialogs(
                                          context,
                                          misCartasPorteProvider
                                              .listaPDFS[index],
                                          context);
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
                                                if (misCartasPorteProvider
                                                    .listaPDFS[index]
                                                    .contains('.pdf'))
                                                  Icon(
                                                    Icons.picture_as_pdf,
                                                    color: Colors.red,
                                                    size: 35,
                                                  ),
                                                if (misCartasPorteProvider
                                                    .listaPDFS[index]
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
                                                      misCartasPorteProvider
                                                          .listaPDFS[index]
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
}
