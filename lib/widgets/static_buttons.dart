// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class CustomOkButton extends StatelessWidget {
  VoidCallback onPressed;
  String text;
  CustomOkButton({super.key,  required this.onPressed,required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade100),
      child: Text(text,style:TextStyle(color: Colors.black),),
    );
  }
}

class CustomCancelButton extends StatelessWidget {
  VoidCallback onPressed;
  String text;

  CustomCancelButton({super.key,  required this.onPressed,required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
      child: Text(text,style:TextStyle(color: Colors.black),),
    );
  }
}
