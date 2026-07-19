import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'discover_tab.dart';
import 'lists_tab.dart';
import 'profile_tab.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;

  final List<Widget> _tabs = const [
    HomeTab(),
    DiscoverTab(),
    ListsTab(),
    ProfileTab(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_rounded, "Home"),
    _NavItem(Icons.explore_rounded, "Discover"),
    _NavItem(Icons.list_alt_rounded, "My Lists"),
    _NavItem(Icons.person_rounded, "Profile"),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xFF141018),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: Row(
              children: List.generate(_navItems.length, (i) {
                final selected = i == _currentIndex;
                final item = _navItems[i];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _currentIndex = i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? theme.colorScheme.secondary.withValues(alpha: 0.18) : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.icon,
                            color: selected ? theme.colorScheme.secondary : Colors.white54,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Times',
                            fontSize: 11,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? theme.colorScheme.secondary : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
