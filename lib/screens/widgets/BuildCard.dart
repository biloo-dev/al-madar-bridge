


import 'package:flutter/material.dart';

class BuildCard extends StatelessWidget {
  const BuildCard({super.key,required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    return Container(

      padding:

      const EdgeInsets.all(24),

      decoration:

      BoxDecoration(

        color: Colors.white,

        borderRadius:

        BorderRadius.circular(28),

        boxShadow:[

          BoxShadow(

            blurRadius:25,

            offset:

            const Offset(0,10),

            color:

            Colors.black

                .withOpacity(.05),

          )

        ],

      ),

      child:

      Column(

        children:

        children,

      ),

    );
  }
}
