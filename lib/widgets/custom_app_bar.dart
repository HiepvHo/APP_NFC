import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String logoPath;

  final String title;

  const CustomAppBar({super.key, required this.logoPath, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(title),

      floating: true, // AppBar will appear when scrolling down.

      pinned: true, // Keep AppBar visible when scrolling up.

      snap: true, // Snap behavior when scrolling up/down.

      expandedHeight: 200.0,

      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        background: Image.asset(
          logoPath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
