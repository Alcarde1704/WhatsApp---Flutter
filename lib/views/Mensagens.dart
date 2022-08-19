import 'package:flutter/material.dart';
import 'package:whatsapp/ColorsKeys.dart';

import '../model/Usuario.dart';

class Mensagens extends StatefulWidget {

  Usuario contato;

  Mensagens( this.contato);

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contato.nome),
        centerTitle: true,
        backgroundColor: ColorsKey.APPBAR_COLOR,
      ),

      body: Container(
        color: ColorsKey.BODY_COLOR,
      ),
    );
  }
}

