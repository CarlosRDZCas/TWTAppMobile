import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_way_transfer/src/components/snackbar.dart';
import 'package:two_way_transfer/src/prividers/providers.dart';

class FormCard extends StatelessWidget {
  const FormCard({
    Key? key,
    required this.loginProvider,
  }) : super(key: key);

  final LoginProvider loginProvider;

  @override
  Widget build(BuildContext context) {
    final logLogged = Provider.of<LogLoggedProvider>(context);
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: loginProvider.frmKey,
      child: SingleChildScrollView(
          child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.only(left: 20, right: 30, top: 0),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Log",
                    icon: Icon(Icons.person),
                  ),
                  onChanged: (value) {
                    loginProvider.log = value;
                  },
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el LOG" : null,
                  textInputAction: TextInputAction.next,
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.teal)),
                  onPressed: () {
                    if (!loginProvider.isValidForm()) return;
                    logLogged.log = loginProvider.login();

                    if (loginProvider.isLogged) {
                      Navigator.pushNamed(context, 'enviarcartaporte');
                    } else {
                      ShowSnackBar(context, 'Log incorrecto verifique el log',
                          5, Colors.red);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Iniciar Sesion",
                        style: TextStyle(color: Colors.white),
                      ),
                      if (loginProvider.loading)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
