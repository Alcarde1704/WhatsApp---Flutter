import 'package:flutter/material.dart';
import 'package:whatsapp/ColorsKeys.dart';

import '../model/Conversa.dart';

class TabContatos extends StatefulWidget {
  const TabContatos({Key? key}) : super(key: key);

  @override
  State<TabContatos> createState() => _TabContatosState();
}

class _TabContatosState extends State<TabContatos> {

  List<Conversa> listaConversa = [
    Conversa("Ana Clara", "Olá, tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-f34a0.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=b62aca51-7c2e-4995-803e-b1c8cfd60ce5"),
    Conversa("Pedro Silva", "me manda o nome daquela série",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-f34a0.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=21db5b58-575a-4484-82c9-bcab1a7dd0c9"),
    Conversa("Marcelo Louco", "Bora tomar umas hoje",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-f34a0.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=a627e206-1232-413e-a14c-1a8a4191922d"),
    Conversa("José Renato", "Eai vai para aula hoje",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-f34a0.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=5409574a-2dc2-4e60-acb0-75fc2573b412"),
    Conversa("Marcela Almeida", "Voce fez aquela atividade? ",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-f34a0.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=4076336d-e65d-48e5-a222-c86d09cc2f73")
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsKey.BODY_COLOR,
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: listaConversa.length,
                  itemBuilder: ((context, index) {
                    Conversa conversa = listaConversa[index];

                    return ListTile(
                      contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      leading: CircleAvatar(
                        maxRadius: 30,
                        backgroundColor: Colors.grey,
                        backgroundImage: NetworkImage(conversa.caminhoFoto),
                      ),
                      title: Text(
                        conversa.nome,
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: ColorsKey.TEXT_TITLE_COLOR),
                      ),
                    );
                  }))),
        ],
      ),
    );
  }
}