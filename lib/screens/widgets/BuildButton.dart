


import 'package:flutter/material.dart';

class BuildButton extends StatelessWidget {
  const BuildButton({super.key,required this.onTap,required this.text});
  final void Function()? onTap;
  final String text;
  @override
  Widget build(BuildContext context) {
    return SizedBox(

      width:

      double.infinity,

      height:56,

      child:

      ElevatedButton(

        onPressed:onTap,

        child:

        Text(

          text,

          style:

          const TextStyle(

            fontSize:16,

            fontWeight:

            FontWeight.bold,

          ),

        ),

      ),

    );
  }
}
