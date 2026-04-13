import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showNotification;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF132238), // surface
            Color(0xFF0A1628), // background
          ],
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 13,
                ),
              ),
            ]
          ],
        ),
        actions: [
          if (showNotification)
            IconButton(
              icon: const Badge(
                backgroundColor: AppTheme.accentHighRisk,
                smallSize: 8,
                child: Icon(CupertinoIcons.bell_fill),
              ),
              onPressed: () {},
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
