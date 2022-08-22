import 'package:flutter/material.dart';
import 'package:whatsapp/views/Mensagens.dart';
import '../ColorsKeys.dart';

class TextFieldPro {

  
  static Widget buildTextField(TextEditingController controller, String hintText, IconButton suffixIcon) {
      return TextFormField(
        controller: controller,
        textAlign: TextAlign.start,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
                borderRadius: BorderRadius.circular(32)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_ERROR_COLOR, width: 2),
                borderRadius: BorderRadius.circular(32)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_PRIMARY_COLOR, width: 3),
                borderRadius: BorderRadius.circular(32)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorsKey.BORDER_TEXTFIELD_SECONDARY_COLOR, width: 3),
                borderRadius: BorderRadius.circular(32)),
            contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
            hintText: hintText,
            filled: true,
            fillColor: ColorsKey.TEXT_TITLE_COLOR,),
      );

      

        
    }
  }

