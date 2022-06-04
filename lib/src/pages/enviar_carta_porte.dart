import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../prividers/providers.dart';
import '../widgets/widgets.dart';

class EnviarCartaPorte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loglogged = Provider.of<LogLoggedProvider>(context);
    final cartaporteprov = Provider.of<CartaPorteProvider>(context);
    return Scaffold(
      appBar: AdvancedAppBar(
        acciones: null,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.photo_camera),
        onPressed: () {
          cartaporteprov.tomarFoto(context, loglogged.log!);
        },
      ),
      drawer: MainDrawer(),
      body: Form(
        key: cartaporteprov.formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 20,
              ),
              Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    loglogged.log!.remision,
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
                child: Center(
                    child:
                        cartaporteprov.getImageWidget(context, loglogged.log!)),
              ),
              SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  onSaved: (value) {
                    cartaporteprov.textDescripcion = value;
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
                    if (cartaporteprov.isButtonClickable)
                      cartaporteprov.getLocation(context, loglogged.log!);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Enviar Foto y Descripcion"),
                      if (cartaporteprov.loading)
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
}
