import 'package:flutter/material.dart';
import 'package:whatsapp/ColorsKeys.dart';
import 'package:whatsapp/model/Conversa.dart';

class TabConversas extends StatefulWidget {
  const TabConversas({Key? key}) : super(key: key);

  @override
  State<TabConversas> createState() => _TabConversasState();
}

class _TabConversasState extends State<TabConversas> {
  List<Conversa> _listaConversa = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Conversa conversa = Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá tudo bem?";
    conversa.caminhoFoto = "https://firebasestorage.googleapis.com/v0/b/whatsapp-clone-f34a0.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=b62aca51-7c2e-4995-803e-b1c8cfd60ce5";

    _listaConversa.add(conversa);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsKey.BODY_COLOR,
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaConversa.length,
                  itemBuilder: ((context, index) {
                    Conversa conversa = _listaConversa[index];

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
                      subtitle: Text(
                        conversa.mensagem,
                        style: TextStyle(color: 
                        ColorsKey.TEXT_SUBTITLE_COLOR, fontSize: 14),
                      ),
                    );
                    
                    
                  }))),
        ],
      ),
    );
  }
}
