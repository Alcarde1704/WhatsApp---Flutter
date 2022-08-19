import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/views/Login.dart';
import 'package:whatsapp/views_tab/TabContatos.dart';
import 'package:whatsapp/views_tab/TabConversas.dart';
import 'package:whatsapp/ColorsKeys.dart';

import '../RouteGenerator.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{

  TabController? _tabController;
  List<String> itensMenu = [
    "Configurações",
    "Deslogar"
  ];

  var _emailUsuario;

  // Future _recuperarDadosUsuarios() async {

  //   FirebaseAuth auth = FirebaseAuth.instance;
  //   //auth.signOut();
  //   // User? usuarioLogado = await auth.currentUser;

  //   // setState(() {
  //   //   _emailUsuario = usuarioLogado!.email;
  //   // });

    

  // }

  @override
  void initState() {
    super.initState();

    // _recuperarDadosUsuarios();

    _tabController = TabController(length: 2, vsync: this);
  }

  _escolhaMenuItem(String itemEscolhido){

    switch(itemEscolhido) {

      case "Configurações":
        Navigator.pushNamed(context, RouteGenerator.ROTA_CONFIGURACOES);
        break;
      case "Deslogar":
        _deslogarUsuario();
        break;

    }

  }

  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();

    Navigator.pushReplacementNamed(context, RouteGenerator.ROTA_LOGIN);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("WhatsApp"),
        centerTitle: true,
        backgroundColor: ColorsKey.APPBAR_COLOR,
        bottom: TabBar(
          indicatorWeight: 4,
          labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Conversas',),
            Tab(text: 'Contatos',),
          ],
        ),

        actions: [
          PopupMenuButton<String>(
            onSelected: _escolhaMenuItem,
            itemBuilder: (context) {
              return itensMenu.map((String item) {
                return PopupMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
          )
        ],
      ),

      

      body: TabBarView(
        controller: _tabController,
        children: [
          TabConversas(),

          TabContatos()
        ],
      )

      

    );
  }
}