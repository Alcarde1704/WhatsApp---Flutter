import 'package:flutter/material.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:whatsapp/views/Cadastro.dart';
import 'package:whatsapp/views/Home.dart';
import 'package:whatsapp/views/Login.dart';
import 'package:whatsapp/views/Mensagens.dart';

import 'views/Configuracoes.dart';

class RouteGenerator {

  static const String ROTA_INICIAL = "/";
  static const String ROTA_LOGIN = "/login";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_HOME = "/home";
  static const String ROTA_CONFIGURACOES = "/configuracoes";
  static const String ROTA_MENSAGENS = "/mensagens";

  static var args;

  static Route<dynamic>? generateRoute(RouteSettings settings) {

    args = settings.arguments;

    switch( settings.name ) {
      case ROTA_INICIAL:
        return MaterialPageRoute(builder: (context) => Login(),);
      case ROTA_LOGIN:
        return MaterialPageRoute(builder: (context) => Login(),);
      case ROTA_CADASTRO:
        return MaterialPageRoute(builder: (context) => Cadastro(),);
      case ROTA_HOME:
        return MaterialPageRoute(builder: (context) => Home(),);
      case ROTA_CONFIGURACOES:
        return MaterialPageRoute(builder: (context) => Configuracoes(),);
      case ROTA_MENSAGENS:
        return MaterialPageRoute(builder: (context) => Mensagens(args),);
      default:
        _erroRota();
      
        
    }

  }

  static Route<dynamic> _erroRota() {

    return MaterialPageRoute(builder: (_) {

      return Scaffold(
        appBar: AppBar(
          title: Text("Tela não encontrada!"),
        ),

        body: Center(
          child: Text("Tela não encontrada!"),
        ),
      );

    });

  }

}