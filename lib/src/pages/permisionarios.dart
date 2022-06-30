import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:two_way_transfer/src/widgets/appbar.dart';
import 'package:two_way_transfer/src/widgets/drawer.dart';

import '../prividers/providers.dart';

class PermisionariosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final permisionariosProvider = Provider.of<PermisionariosProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (permisionariosProvider.cambio) permisionariosProvider.tomarFoto();
        },
        child: Icon(Icons.camera_alt_rounded),
        backgroundColor:
            permisionariosProvider.cambio == false ? Colors.grey : Colors.teal,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AdvancedAppBar(acciones: [
        IconButton(
            onPressed: () {
              if (permisionariosProvider.cambio) {
                permisionariosProvider.enviarPDFImagenes(context);
              }
            },
            icon: Icon(Icons.send))
      ]),
      drawer: MainDrawer(),
      body: AbsorbPointer(
        absorbing: permisionariosProvider.loading,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Form(
                      key: permisionariosProvider.formKey,
                      child: Expanded(
                        child: TextFormField(
                          controller:
                              permisionariosProvider.textEditingController,
                          onChanged: (value) {
                            permisionariosProvider.log = value;

                            permisionariosProvider.cambio = false;
                          },
                          onEditingComplete: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            permisionariosProvider.verificar(context);
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Ingrese un valor';
                            if (value.contains(RegExp(r"[A-Z,a-z]")))
                              return 'No ingrese letras';
                            return null;
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
                          permisionariosProvider.verificar(context);
                        },
                        child: Text("Verificar")),
                    if (permisionariosProvider.loading)
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
                itemCount: permisionariosProvider.images.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  return Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          Image.file(
                            permisionariosProvider.images[index]!,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  permisionariosProvider.eliminarImagen(index);
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
                      height: 600,
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
}
