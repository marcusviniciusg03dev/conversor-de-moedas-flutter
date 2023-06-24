import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dotenv/dotenv.dart';

void main() async {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        hintColor: Colors.orange,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
          hintStyle: TextStyle(color: Colors.orange),
        )),
    home: Home(),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(Uri.https(
      'api.hgbrasil.com', '/finance', {'key': DotEnv()['HGBRASIL_API_KEY']}));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  late double dolar;
  late double euro;

  void _clearFields() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChanged(String value) {
    if (value.isEmpty) {
      _clearFields();
      return;
    }
    final real = double.parse(value);
    dolarController.text = (real / dolar).toStringAsPrecision(2);
    euroController.text = (real / euro).toStringAsPrecision(2);
  }

  void _dolarChanged(String value) {
    if (value.isEmpty) {
      _clearFields();
      return;
    }
    final dolar = double.parse(value);
    realController.text = (dolar * this.dolar).toStringAsPrecision(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsPrecision(2);
  }

  void _euroChanged(String value) {
    if (value.isEmpty) {
      _clearFields();
      return;
    }
    final euro = double.parse(value);
    realController.text = (euro * this.euro).toStringAsPrecision(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsPrecision(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('conversor de moedas'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando Dados...',
                  style: TextStyle(color: Colors.orange, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao Carregar Dados :(',
                    style: TextStyle(color: Colors.orange, fontSize: 25),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dolar = snapshot.data?['results']['currencies']['USD']['buy'];
                euro = snapshot.data?['results']['currencies']['EUR']['buy'];

                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Icon(
                        Icons.monetization_on,
                        size: 150,
                        color: Colors.orange,
                      ),
                      TextField(
                        controller: realController,
                        keyboardType: TextInputType.number,
                        onChanged: _realChanged,
                        decoration: InputDecoration(
                            labelText: 'Reais',
                            labelStyle:
                                TextStyle(color: Colors.orange, fontSize: 25),
                            border: OutlineInputBorder(),
                            prefixText: "R\$"),
                        style: TextStyle(color: Colors.orange),
                      ),
                      Divider(),
                      TextField(
                        controller: dolarController,
                        keyboardType: TextInputType.number,
                        onChanged: _dolarChanged,
                        decoration: InputDecoration(
                            labelText: 'Dólares',
                            labelStyle:
                                TextStyle(color: Colors.orange, fontSize: 25),
                            border: OutlineInputBorder(),
                            prefixText: "\$"),
                        style: TextStyle(color: Colors.orange),
                      ),
                      Divider(),
                      TextField(
                        controller: euroController,
                        onChanged: _euroChanged,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Euros',
                            labelStyle:
                                TextStyle(color: Colors.orange, fontSize: 25),
                            border: OutlineInputBorder(),
                            prefixText: "€"),
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}
