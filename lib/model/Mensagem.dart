import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class Mensagem {
  var _idUsuario;
  var _mensagem;
  var _urlImagem;
  var _tipo;
  var _time;

  Mensagem();

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "idUsuario": this.idUsuario,
      "mensagem": this.mensagem,
      "urlImagem": this.urlImagem,
      "tipo": this.tipo,
      "time": this.time
    };

    return map;
  }

  String get idUsuario => _idUsuario;

  set idUsuario(String value) {
    _idUsuario = value;
  }

  String get mensagem => _mensagem;

  set mensagem(String value) {
    _mensagem = value;
  }

  String get urlImagem => _urlImagem;

  set urlImagem(String value) {
    _urlImagem = value;
  }

  String get tipo => _tipo;

  set tipo(String value) {
    _tipo = value;
  }

  DateTime get time => _time;

  set time(DateTime value) {
    _time = value.toUtc();
  }

  
}
