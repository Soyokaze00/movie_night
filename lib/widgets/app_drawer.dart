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
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.pop(context);
              if (!active) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainShell(initialIndex: index)));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: active
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.secondary.withValues(alpha: 0.22),
                          theme.colorScheme.primary.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                border: active
                    ? Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.5))
                    : Border.all(color: Colors.transparent),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.secondary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(icon, color: active ? theme.colorScheme.secondary : Colors.white54, size: 22),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white70,
                      fontFamily: 'Times',
                      fontSize: 15,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (active) ...[
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.8), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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
                // Header with gradient background + glowing avatar
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.28),
                        theme.colorScheme.secondary.withValues(alpha: 0.14),
                        Colors.black,
                      ],
                    ),
                    border: Border.all(color: theme.colorScheme.secondary.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Movie',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Times'),
                            ),
                            TextSpan(
                              text: 'Night',
                              style: TextStyle(color: theme.colorScheme.secondary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Times'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [theme.colorScheme.secondary, theme.colorScheme.primary, Colors.orangeAccent],
                                ),
                                boxShadow: [
                                  BoxShadow(color: theme.colorScheme.secondary.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 1),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF1E1E1E),
                                child: provider.profileAvatar != null
                                    ? Text(provider.profileAvatar!, style: const TextStyle(fontSize: 24))
                                    : const Icon(Icons.person, color: Colors.white, size: 24),
                              ),
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
                            Icon(Icons.chevron_right, color: theme.colorScheme.secondary.withValues(alpha: 0.8), size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                item(Icons.person, "Profile", 3),
                item(Icons.home, "Home", 0),
                item(Icons.explore, "Discover", 1),
                item(Icons.list, "My Lists", 2),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 16),
                  child: Text(
                    "MovieNight v1.0",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontFamily: 'Times', fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}