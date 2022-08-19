import 'package:flutter/material.dart';
import 'package:whatsapp/views/Cadastro.dart';
import 'package:whatsapp/views/Home.dart';
import 'package:whatsapp/views/Login.dart';

import 'views/Configuracoes.dart';

class RouteGenerator {

  static const String ROTA_INICIAL = "/";
  static const String ROTA_LOGIN = "/login";
  static const String ROTA_CADASTRO = "/cadastro";
  static const String ROTA_HOME = "/home";
  static const String ROTA_CONFIGURACOES = "/configuracoes";

  static Route<dynamic>? generateRoute(RouteSettings settings) {

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