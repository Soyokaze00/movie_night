import 'package:flutter/material.dart';
import '../screens/main_shell.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  const AppDrawer({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget item(IconData icon, String label, int index) {
      final active = index == currentIndex;
      return ListTile(
        leading: Icon(icon, color: active ? theme.colorScheme.secondary : Colors.white70),
        title: Text(label, style: TextStyle(color: active ? theme.colorScheme.secondary : Colors.white70, fontFamily: 'Times')),
        onTap: () {
          Navigator.pop(context);
          if (!active) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(initialIndex: index)));
          }
        },
      );
    }

    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                text: TextSpan(children: [
                  const TextSpan(text: 'Movie', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Times')),
                  TextSpan(text: 'Night', style: TextStyle(color: theme.colorScheme.secondary, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Times')),
                ]),
              ),
            ),
            const Divider(color: Colors.white24),
            item(Icons.home, "Home", 0),
            item(Icons.movie, "Movies", 1),
            item(Icons.explore, "Discover", 2),
            item(Icons.list, "Lists", 3),
            item(Icons.person, "Profile", 4),
          ],
        ),
      ),
    );
  }
}