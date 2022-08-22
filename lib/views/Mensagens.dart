import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/ColorsKeys.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/widgets/TextFieldPro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../model/Usuario.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  State<Mensagens> createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Duration duration = Duration(milliseconds: 5);

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _subindoImagem = false;
  String? _urlImagemRecuperada;

  var _idUsuarioLogado;
  var _idUsuarioDestinatario;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final _msgController = TextEditingController();

  Future _recuperarImagem(String origemImagem) async {
    XFile? _imagemSelecionada;

    switch (origemImagem) {
      case "camera":
        _imagemSelecionada =
            await _picker.pickImage(source: ImageSource.camera);

        break;
      case "galeria":
        _imagemSelecionada =
            await _picker.pickImage(source: ImageSource.gallery);
        break;
    }

    setState(() {
      _image = _imagemSelecionada;

      if (_image != null) {
        _subindoImagem = true;
        _uploadImage();
      }

      Navigator.pop(context);
    });
  }

  Future _uploadImage() async {
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpg");

    // fazer upload da imagem
    UploadTask task = arquivo.putFile(File(_image!.path));

    // controlar processo de upload

    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (taskSnapshot.state == TaskState.success) {
        _recuperarUrlImagem(taskSnapshot);
        setState(() {
          _subindoImagem = false;
        });
      }
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.tipo = "imagem";
    mensagem.time = DateTime.now().toUtc();

    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    //salvar mensagem para o destinatario
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

  _enviarMensagem() {
    String textoMensagem = _msgController.text;

    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";
      mensagem.time = DateTime.now().toUtc();

      //salvar mensagem para o remetente
      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      //salvar mensagem para o destinatario
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      _salvarConversa(mensagem);


    }
  }

  _salvarConversa(Mensagem msg) {

    //Salvar conversa remetente
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();
   
    //Salvar conversa destinatario
    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .doc(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    _msgController.clear();
  }

  _enviarFoto() {}

  _recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    User? usuarioLogado = await auth.currentUser;

    setState(() {
      _idUsuarioLogado = usuarioLogado!.uid;
      _idUsuarioDestinatario = widget.contato.idUsuario;
    });

    // FirebaseFirestore db = FirebaseFirestore.instance;

    // DocumentSnapshot<Map<String, dynamic>> querySnapshot = await db.collection("usuarios").doc(_idUsuarioLogado).get();

    // var dados = querySnapshot.data();

    // setState(() {
    //   _nomeRecuperado = dados!["nome"];
    //   _emailRecuperado = dados["email"];
    // });

    // if(dados!["urlImagem"] != null){
    //   _urlImagemRecuperada = dados["urlImagem"];
    // }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _recuperarDadosUsuarios();
    _controller = AnimationController(
        vsync: this, // the SingleTickerProviderStateMixin
        duration: duration);
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(right: 8),
            child: buildTextField(_msgController, "Digite a mensagem..."),
          )),
          FloatingActionButton(
            backgroundColor: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR,
            onPressed: _enviarMensagem,
            child: Icon(
              Icons.send,
              color: ColorsKey.ICONS_COLOR,
            ),
            mini: true,
          )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: db
          .collection("mensagens")
          .doc("$_idUsuarioLogado")
          .collection("$_idUsuarioDestinatario")
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Flexible(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR))),
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot querySnapshot = snapshot.data;

            if (snapshot.hasError) {
              return Expanded(
                  child: Text("Erro ao carregar dados, tente novamente"));
            } else {
              if (snapshot.hasData) {
                return Expanded(
                    child: ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (context, index) {
                    //recupera mensagem
                    List<DocumentSnapshot> mensagens =
                        querySnapshot.docs.toList();
                    DocumentSnapshot item = mensagens[index];

                    double larguraContainer =
                        MediaQuery.of(context).size.width * 0.8;

                    Alignment alignment = Alignment.centerRight;
                    Color color = ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR;
                    if (_idUsuarioLogado != item["idUsuario"]) {
                      //par
                      color = ColorsKey.BODY_COLOR;
                      alignment = Alignment.centerLeft;
                    }

                    return Align(
                      alignment: alignment,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: Container(
                          width: larguraContainer,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: item["tipo"] == "texto"
                              ? Text(
                                  item["mensagem"],
                                  style: TextStyle(
                                      color: ColorsKey.TEXT_TITLE_COLOR,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                )
                              : Image.network(item["urlImagem"]),
                        ),
                      ),
                    );
                  },
                ));
                ;
              } else {
                return Expanded(
                    child: Text("Você ainda não iniciou uma conversa"));
              }
            }
            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              maxRadius: 20,
              backgroundColor: Colors.grey,
              backgroundImage: widget.contato.urlImagem != null
                  ? NetworkImage(widget.contato.urlImagem)
                  : null,
            ),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            )
          ],
        ),
        backgroundColor: ColorsKey.APPBAR_COLOR,
      ),
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.png"), fit: BoxFit.cover)),
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                // Text("$_idUsuarioLogado"),
                // Text("$_idUsuarioDestinatario"),
                stream,
                caixaMensagem
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOption(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              animationController: _controller,
              backgroundColor: Colors.grey[800],
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 1, color: Color.fromARGB(255, 99, 98, 98)),
                      borderRadius: BorderRadius.circular(6)),
                  child: Center(
                      heightFactor: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Foto do perfil",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                255, 99, 98, 98))),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.transparent,
                                      child: IconButton(
                                        onPressed: () {
                                          _recuperarImagem("camera");
                                        },
                                        icon: Icon(
                                          Icons.camera_alt_rounded,
                                        ),
                                        iconSize: 25,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Câmera",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[400]),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 30,
                              ),
                              Column(
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Color.fromARGB(
                                                255, 99, 98, 98))),
                                    child: CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.transparent,
                                      child: IconButton(
                                        onPressed: () {
                                          _recuperarImagem("galeria");
                                        },
                                        icon: Icon(
                                          Icons.image,
                                        ),
                                        iconSize: 25,
                                        color: Colors.greenAccent,
                                        splashColor: Colors.white,
                                        splashRadius: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Text(
                                    "Galeria",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[400]),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ],
                      )),
                );
              });
        });
  }

  Widget buildTextField(TextEditingController controller, String hintText) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 18),
      decoration: InputDecoration(
        suffixIcon: _subindoImagem
            ? Container(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR)),
              )
            : IconButton(
                icon: Icon(Icons.camera_alt_rounded),
                onPressed: () {
                  _showOption(context);
                },
                color: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR,
                focusColor: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR,
              ),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
            borderRadius: BorderRadius.circular(32)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
            borderRadius: BorderRadius.circular(32)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR, width: 3),
            borderRadius: BorderRadius.circular(32)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR, width: 3),
            borderRadius: BorderRadius.circular(32)),
        contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
        hintText: hintText,
        filled: true,
        fillColor: ColorsKey.TEXT_TITLE_COLOR,
      ),
    );
  }
}
