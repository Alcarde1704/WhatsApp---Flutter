import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatsapp/ColorsKeys.dart';

class Configuracoes extends StatefulWidget {
  const Configuracoes({Key? key}) : super(key: key);

  @override
  State<Configuracoes> createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<Configuracoes>
    with TickerProviderStateMixin {
  TextEditingController _controllerNome = TextEditingController();

  GlobalKey<FormState> _formKeyConfig = GlobalKey<FormState>();

  late AnimationController _controller;
  Duration duration = Duration(milliseconds: 5);

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String? _idUsuarioLogado;
  bool _subindoImagem = false;
  String? _urlImagemRecuperada;
  var _nomeRecuperado;
  var _emailRecuperado;

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
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    Reference arquivo =
        pastaRaiz.child("perfil").child(_idUsuarioLogado! + ".jpg");

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
    _atualizarUrlImagemFirestore( url );

    setState(() {
      _urlImagemRecuperada = url;
    });

  }

  _atualizarUrlImagemFirestore(String url) {

    FirebaseFirestore db = FirebaseFirestore.instance;

    Map<String, dynamic> dadosAtualizar = {
      "urlImagem": url
    };

    db.collection("usuarios")
      .doc(_idUsuarioLogado)
      .update( dadosAtualizar );

  }

  _recuperarDadosUsuarios() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    
    User? usuarioLogado = await auth.currentUser;

    _idUsuarioLogado = usuarioLogado!.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;

    DocumentSnapshot<Map<String, dynamic>> querySnapshot = await db.collection("usuarios").doc(_idUsuarioLogado).get();

    var dados = querySnapshot.data();

    setState(() {
      _nomeRecuperado = dados!["nome"];
      _emailRecuperado = dados["email"];
    });

    if(dados!["urlImagem"] != null){
      _urlImagemRecuperada = dados["urlImagem"];
    }
    

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

  void _exibirDialogo() {
    showDialog(
       context:  context,
       builder:  (BuildContext context) {
         return AlertDialog();
    },
   );
}

  @override
  Widget build(BuildContext context) {

    double altura = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Meu perfil"),
        centerTitle: true,
        backgroundColor: ColorsKey.APPBAR_COLOR,
      ),
      // backgroundColor: ColorsKey.BODY_COLOR,
      body: Container(
        height: altura,
        decoration: BoxDecoration(color: ColorsKey.BODY_COLOR),
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKeyConfig,
            child: Column(
              
              children: [
                    _subindoImagem 
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(ColorsKey.ICONS_COLOR),),
                    )
                    : Container(),

                CircleAvatar(
                  radius: 80,
                  backgroundImage: _urlImagemRecuperada != null 
                  ? NetworkImage(_urlImagemRecuperada!)
                  : null,
                  backgroundColor: Colors.grey,
                  child: Container(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: CircleAvatar(
                      backgroundColor: Color(0xff075E54),
                      radius: 25,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt_rounded),
                        color: Colors.white,
                        onPressed: () {
                          _showOption(context);
                        },
                      ),
                    ),
                  ),
                ),

                ListTile(
                  title: Text("Nome", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorsKey.TEXT_TITLE_COLOR),),
                  subtitle: Text("$_nomeRecuperado",style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsKey.TEXT_SUBTITLE_COLOR)),
                  leading: Icon(Icons.person, color: ColorsKey.ICONS_COLOR,),
                  onTap: () {
                    _showEditName(context);
                  },
                  trailing: Icon(Icons.edit, color: ColorsKey.ICONS_COLOR),
                ),

                ListTile(
                  title: Text("Recado",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorsKey.TEXT_TITLE_COLOR)),
                  subtitle: Text("Status",style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsKey.TEXT_SUBTITLE_COLOR)),
                  leading: Icon(Icons.info_outline, color: ColorsKey.ICONS_COLOR,),
                  onTap: () {},
                  trailing: Icon(Icons.edit, color: ColorsKey.ICONS_COLOR,),
                ),

                ListTile(
                  title: Text("E-mail",style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: ColorsKey.TEXT_TITLE_COLOR)),
                  subtitle: Text("$_emailRecuperado",style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsKey.TEXT_SUBTITLE_COLOR)),
                  leading: Icon(Icons.email, color: ColorsKey.ICONS_COLOR,),
                  onTap: () {
                    
                  },
                )

                
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      TextInputType textInputType,
      bool autofocus,
      bool obscureText,
      String errorText) {
    return TextFormField(
      obscureText: obscureText,
      controller: controller,
      autofocus: autofocus,
      keyboardType: textInputType,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, color: ColorsKey.TEXT_TITLE_COLOR),
      decoration: InputDecoration(
          errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),),
          focusedErrorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
             ),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color:  ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR, width: 2),
             ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR, width: 2),
             ),
          contentPadding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          errorStyle: TextStyle(color: Colors.red, fontSize: 16)),
      validator: (value) {
        if (value!.isEmpty) {
          return errorText;
        }
      },
      onFieldSubmitted: (value) {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTextButton(String title) {
    return TextButton(
      onPressed: () {
        if (_formKeyConfig.currentState!.validate()) {
          var nome = _controllerNome.text;

          if (nome.length >= 3) {
          } else {}
        }
      },
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      style: TextButton.styleFrom(
          backgroundColor: Color(0xff075E54),
          padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))),
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
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.delete),
                                color: Colors.grey,
                              )
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


  void _showEditName(BuildContext context) {
    _controllerNome.text = _nomeRecuperado;

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return BottomSheet(
              animationController: _controller,
              backgroundColor: Colors.grey[800],
              onClosing: () {},
              builder: (context) {
                return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        border: Border.all(
                            width: 1, color: Color.fromARGB(255, 99, 98, 98)),
                        borderRadius: BorderRadius.circular(6)),
                    child: Center(
                        heightFactor: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Insira seu nome", style: TextStyle(fontSize: 18, color: ColorsKey.TEXT_TITLE_COLOR),),

                            SizedBox(height: 8,),
                
                            _buildTextField(_controllerNome, TextInputType.name, true, false, "Insira um nome válido")
                          ],
                        )),
                  ),
                );
              });
        });
  }
}
