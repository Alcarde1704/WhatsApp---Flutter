import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/ColorsKeys.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:whatsapp/views/Cadastro.dart';

import 'Home.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  GlobalKey<FormState> _formKeyLognIn = GlobalKey<FormState>();

  var _mensagemErro = "";

  _logarUsuario( Usuario usuario ) {

    FirebaseAuth auth = FirebaseAuth.instance;

    auth.signInWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
    ).then((value) {
      setState(() {
        
        Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
      });
    }).catchError( (error) {

      setState(() {
        _mensagemErro = "Erro ao autenticar o usuário, verifique e-mail e senha";
      });

    } );

  }

  Future _verificaUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    // auth.signOut();

    User? usuarioLogado = await auth.currentUser;
    
    if(usuarioLogado != null) {

      Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_HOME);
    }
  }

  @override
  void initState() {
    _verificaUsuarioLogado();
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: ColorsKey.BODY_COLOR),
        padding: EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKeyLognIn,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "images/logo.png",
                      width: 150,
                      height: 150,
                    ),
                  ),
            
                  Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _buildTextField(
                          _controllerEmail,
                          TextInputType.emailAddress,
                          "Email",
                          false,
                          false,
                          "Insira o nome corretamente"),
                    ),
            
                  Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _buildTextField(
                          _controllerSenha,
                          TextInputType.text,
                          "Senha",
                          false,
                          true,
                          "Insira a senha corretamente"),
                    ),
            
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 10),
                    child: _buildTextButton("Entrar")
                  ),
            
                  Center(
                    child: GestureDetector(
                      child: Text("Não tem conta? cadastre-se!", style: TextStyle(color: ColorsKey.TEXT_TITLE_COLOR),),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Cadastro()));
                      },
                    ),
                  ),

                  Center(
                    child: Text('$_mensagemErro'),
                  )
            
            
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
            fillColor: ColorsKey.TEXT_TITLE_COLOR,
            errorStyle: TextStyle(color: ColorsKey.TEXT_TITLE_COLOR, fontSize: 14)),
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
        if (_formKeyLognIn.currentState!.validate()) {
          var email = _controllerEmail.text;
          var senha = _controllerSenha.text;

          if(email.length >= 5 && email.contains("@")){

            if(senha.length >= 8) {

              setState(() {
                _mensagemErro ="";
              });

              Usuario usuario = Usuario();

              usuario.email = email;
              usuario.senha = senha;

              _logarUsuario( usuario ); 

            } else{
              setState(() {
              _mensagemErro = "Senha necessita ter 8 ou mais caracteres";
              });
            }

          } else{
            setState(() {
              _mensagemErro = "E-mail necessita ter mais de 5 caracteres e conter @";
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
  
