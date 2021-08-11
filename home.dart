import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Home extends StatefulWidget {
  //const Home({ Key? key }) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  TextEditingController valorcep = new TextEditingController();

  String resultado = "";

  _consultacep() async {

    //Pegando o cep digitado pelo usuário
    String cep = valorcep.text;

    //url do via cep que sera consultada com o cep que o usuário digitou
    var url = Uri.parse('https://viacep.com.br/ws/$cep/json/');

    //resposta do http

    //fazendo requisicao via get para a url
    http.Response response = await http.get(url);

    //converter json para dart

    Map<String, dynamic> retorno = json.decode(response.body);

    //campos que seram exibidos para o usuário
    String logradouro = retorno["logradouro"];
    String complemento = retorno["complemento"];
    String cidade = retorno["localidade"];
    String bairro = retorno["bairro"];
    String estado = retorno["uf"];
    String ddd = retorno["ddd"];

    //caso a cidade tenha um cep unico o logradouro e bairro ficarao vazios
    if (logradouro == "" || bairro == "") {
      logradouro = "Sem informações";
      complemento = "Sem informações";
      bairro = "Sem informações";
    }

    //carregando informações para a tela
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        //limpando campo cep ao clicar em consultar
        valorcep.clear();

        //caso o usuário digite um cep inválido
        if (logradouro == null &&
            complemento == null &&
            cidade == null &&
            bairro == null &&
            estado == null &&
            ddd == null
            
            ) {
          resultado = "\nCEP inválido\n";
        } else {
          resultado =
              "Cidade: $cidade \nLogradouro: $logradouro \nComplemento: $complemento \nBairro: $bairro \nEstado: $estado \nDDD: $ddd\n";
        }
      });
    });
  }

//limpando campos
  _limpaCep() {
    setState(() {
      valorcep.clear();
      resultado = "";
    });
  }

  //chave para validação do campo cep do formulario
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Consumindo Api Via cep"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              child: Image.asset(
                'images/busca.png',
                width: 100,
                height: 100,
              ),
            ),

            Form(
              //chave
              key: _formKey,
              child: TextFormField(
                //validando entrada do cep pelo usuário
                validator: (value) {
                  return value.length < 8
                      ? 'O cep precisa de no minímo 8 dígitos'
                      : null;
                },

                maxLength: 8,
                maxLines: 1,
                //permitindo apenas numeros
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  FilteringTextInputFormatter.deny(new RegExp(r"\s\b|\b\s"))
                ],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Digite um cep ex: 11730000",
                ),

                style: TextStyle(fontSize: 20),

                //pegando texto

                controller: valorcep,
              ),
            ),

            //variavel resultado que é exibida no Text
            Text('$resultado', style: TextStyle(color: Colors.blueAccent[700], fontWeight: FontWeight.w500,),),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    child: Text(
                      "Consultar",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                    ),

                    //color: Colors.lightGreen,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        //se o formulario for validado com sucesso o cep sera consultado
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 1000),
                            content: Text(
                              'Carregando informações...',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                              ),
                            )));
                        _consultacep();
                      }
                    } //_consultacep,
                    ),
                ElevatedButton(
                  onPressed: () {
                    _limpaCep();
                  },
                  child: Text(
                    "Limpar",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 47, vertical: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
