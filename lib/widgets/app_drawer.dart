import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../screens/main_shell.dart';
import '../screens/profile_setup_screen.dart';

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
        child: Consumer<MovieProvider>(
          builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.secondary.withOpacity(0.25),
                          child: provider.profileAvatar != null
                              ? Text(provider.profileAvatar!, style: const TextStyle(fontSize: 24))
                              : const Icon(Icons.person, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.profileName ?? "Set up profile",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Times', fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
                      ],
                    ),
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 8),
                item(Icons.person, "Profile", 2),
                item(Icons.home, "Home", 0),
                item(Icons.list, "My Lists", 1),
              ],
            );
          },
        ),
      ),
    );
  }
}