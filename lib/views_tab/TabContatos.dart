import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/ColorsKeys.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/Conversa.dart';

class TabContatos extends StatefulWidget {
  const TabContatos({Key? key}) : super(key: key);

  @override
  State<TabContatos> createState() => _TabContatosState();
}

class _TabContatosState extends State<TabContatos> {

  var _emailRecuperado;
  var _idUsuarioLogado;
  

  Future<List<Usuario>> _recuperarContatos() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await db.collection("usuarios").get();

    List<Usuario> listaUsuarios = <Usuario>[];

    for (DocumentSnapshot<Map<String, dynamic>> item in querySnapshot.docs) {
      var dados = item.data();

      if (dados!["email"] == _emailRecuperado) continue;

      Usuario usuario = Usuario();
      usuario.idUsuario = item.id;
      usuario.email = dados["email"];
      usuario.nome = dados["nome"];

      if(dados["urlImagem"] != null) {
        usuario.urlImagem = dados["urlImagem"];
      } else{
        usuario.urlImagem = "";
      }

      listaUsuarios.add(usuario);
    }

    return listaUsuarios;
  }

  _recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    
    User? usuarioLogado = await auth.currentUser;

    _idUsuarioLogado = usuarioLogado!.uid;
    _emailRecuperado = usuarioLogado.email;

   
    

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuarios();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Usuario>>(
      future: _recuperarContatos(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Container(
              color: ColorsKey.BODY_COLOR,
              child: Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ColorsKey.ICONS_COLOR))
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            return Container(
              color: ColorsKey.BODY_COLOR,
              child: Column(
                children: [
                  Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: ((_, index) {

                            List<Usuario> listaItens = snapshot.data!;

                            Usuario usuario = listaItens[index];

                            return ListTile(
                              onTap: () {
                                Navigator.pushNamed(context, "/mensagens", arguments: usuario);
                              },
                              contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              leading: CircleAvatar(
                                maxRadius: 30,
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    usuario.urlImagem == ""
                                    ? null
                                    : NetworkImage(usuario.urlImagem)
                              ),
                              title: Text(
                                usuario.nome,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: ColorsKey.TEXT_TITLE_COLOR),
                              ),
                            );
                          }))),
                ],
              ),
            );
            break;
        }
      },
    );
  }
}
