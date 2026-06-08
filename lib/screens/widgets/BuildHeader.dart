


import 'package:al_madar_bridge/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BuildHeader extends StatelessWidget {
  const BuildHeader({super.key,required this.icon , required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) {
      return Column(

        children:[

          Container(

            width:90,

            height:90,

            decoration:

            BoxDecoration(

              shape: BoxShape.circle,

              color:

              AppTheme.primaryBlue
                  .withOpacity(.12),

            ),

            child:

            Icon(

              icon,

              size:42,

              color:

              AppTheme.primaryBlue,

            ),

          ),

          const SizedBox(height:20),

          Text(

            title,

            style:

            Theme.of(context)

                .textTheme

                .headlineMedium,

          ),

          const SizedBox(height:8),

          Text(

            subtitle,

            style: TextStyle(

              color:

              AppTheme.textMedium,

            ),

          ),

          const SizedBox(height:28),

        ],

      );
  }
}
