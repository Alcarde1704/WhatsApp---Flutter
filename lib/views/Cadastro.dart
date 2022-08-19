import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whatsapp/ColorsKeys.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:whatsapp/views/Home.dart';

import '../RouteGenerator.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({Key? key}) : super(key: key);

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  TextEditingController _controllerNome = TextEditingController();
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();
  var valor = 0.0;
  var forcaSenha = "";
  var _mensagemErro ="";

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  

  _validarSenha(var value) {
    valor = value.length.toDouble();

    if (value.length > 0 && value.length <= 3) {
      forcaSenha = "Senha Muito Fraca";
    } else if (value.length > 3 && value.length <= 6) {
      forcaSenha = "Senha Fraca";
    } else if (value.length > 6 && value.length <= 8) {
      forcaSenha = "Senha Intermediária";
    } else if (value.length > 8 && value.length <= 10) {
      forcaSenha = "Senha Forte";
    } else if (value.length > 10 && value.length <= 12) {
      forcaSenha = "Senha Extremamente Forte";
    }


  }

  _cadastrarUsuarios(Usuario usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.createUserWithEmailAndPassword(email: usuario.email, password: usuario.senha).then((value) {


      FirebaseFirestore db = FirebaseFirestore.instance;
      
      db.collection("usuarios").doc(value.user!.uid).set(usuario.toMap());

      Navigator.pushNamedAndRemoveUntil(context, RouteGenerator.ROTA_HOME, (route) => false);
      

    }).catchError((error) {
      print("erro app: " + error.toString());
      setState(() {
        _mensagemErro = "Erro ao cadastrar o usuario, informe todos os dados corretamente";
      });
    });

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro"),
        centerTitle: true,
        backgroundColor: ColorsKey.APPBAR_COLOR,
      ),
      body: Container(
        decoration: BoxDecoration(color: ColorsKey.BODY_COLOR),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "images/whats_logo.png",
                      width: 130,
                      height: 130,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _buildTextField(
                        _controllerNome,
                        TextInputType.emailAddress,
                        "Nome Completo",
                        false,
                        false,
                        "Insira o nome corretamente"),
                  ),

                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: _buildTextField(
                        _controllerEmail,
                        TextInputType.emailAddress,
                        "E-mail",
                        false,
                        false,
                        "Insira o email corretamente contendo @"),
                  ),

                  // _buildTextField(_controllerSenha,TextInputType.text, "Senha", false, true, "Insira a senha corretamente"),

                  TextFormField(
                    obscureText: true,
                    controller: _controllerSenha,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                    maxLength: 12,
                    decoration: InputDecoration(
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
                            borderRadius: BorderRadius.circular(32)),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
                            borderRadius: BorderRadius.circular(32)),
                        enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR, width: 2),
                            borderRadius: BorderRadius.circular(32)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR, width: 2),
                            borderRadius: BorderRadius.circular(32)),
                        contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
                        hintText: "Senha",
                        counterText: "$forcaSenha",
                        counterStyle: TextStyle(color: ColorsKey.TEXT_TITLE_COLOR),
                        filled: true,
                        fillColor: Colors.white,
                        errorStyle:
                            TextStyle(color: ColorsKey.TEXT_TITLE_COLOR, fontSize: 14)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "senha incorreta";
                      }
                    },
                    onChanged: (value) {
                      _validarSenha(value);
                      setState(() {});
                    },
                  ),

                  Slider(
                    value: valor,
                    activeColor: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR,
                    min: 0,
                    max: 12,
                    onChanged: (value) {},
                  ),

                  Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                      child: _buildTextButton("Cadastrar")),

                  Text("$_mensagemErro", style: TextStyle(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, fontSize: 18, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      TextInputType textInputType,
      String hintText,
      bool autofocus,
      bool obscureText,
      String errorText) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      autofocus: autofocus,
      keyboardType: textInputType,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
              borderRadius: BorderRadius.circular(32)),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
              borderRadius: BorderRadius.circular(32)),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR, width: 2),
              borderRadius: BorderRadius.circular(32)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR, width: 2),
              borderRadius: BorderRadius.circular(32)),
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          errorStyle: TextStyle(color: Colors.white, fontSize: 14)),
      validator: (value) {
        if (value!.isEmpty) {
          return errorText;
        }
      },
    );
  }

  Widget _buildTextButton(String title) {
    return TextButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          var nome = _controllerNome.text;
          var email = _controllerEmail.text;
          var senha = _controllerSenha.text;

          if(nome.length >= 3){

            if(email.length >= 5 && email.contains("@")){

              if(senha.length >= 8) {

                Usuario usuario = Usuario();
                usuario.nome = nome;
                usuario.email = email;
                usuario.senha = senha;


                _cadastrarUsuarios(usuario);
                

              } else{
                setState(() {
                  _mensagemErro = "A senha necessita ter 8 ou mais caracteres";
                });
              }

            } else{
              setState(() {
              _mensagemErro = "O email precisa ser maior que 5 caracteres e conter o @";
            });
              
            }

          } else {
            setState(() {
              _mensagemErro = "Nome precisa ser maior que 3";
            });
          }

          
        }
      },
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      style: TextButton.styleFrom(
          backgroundColor: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR,
          padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
    );
  }
  }
