import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import 'main_shell.dart';

const List<String> kAvatarOptions = ['🎬', '🍿', '👾', '🐉', '🎭', '⭐', '🔥', '🌙', '🦊', '🎌', '🕵️', '👻'];

/// Simple local "profile" — a name and a pick of an emoji avatar, stored in
/// the on-device SQLite db. No accounts, no server, nothing leaves the phone.
class ProfileSetupScreen extends StatefulWidget {
  final bool isFirstRun;
  const ProfileSetupScreen({super.key, this.isFirstRun = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final TextEditingController _nameController;
  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<MovieProvider>(context, listen: false);
    _nameController = TextEditingController(text: provider.profileName ?? '');
    _selectedAvatar = provider.profileAvatar ?? kAvatarOptions.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final provider = Provider.of<MovieProvider>(context, listen: false);
    provider.saveProfile(name, _selectedAvatar);
    if (widget.isFirstRun) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.isFirstRun
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontFamily: 'Times', fontWeight: FontWeight.bold)),
            ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: widget.isFirstRun ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (widget.isFirstRun) ...[
                Text("Welcome to Movie Night",
                    style: TextStyle(color: theme.colorScheme.secondary, fontFamily: 'Times', fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Set up your local profile to get started.",
                    style: TextStyle(color: Colors.white54, fontFamily: 'Times')),
                const SizedBox(height: 32),
              ],
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.25),
                  child: Text(_selectedAvatar, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Your Name", style: TextStyle(color: Colors.white70, fontFamily: 'Times', fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontFamily: 'Times'),
                decoration: InputDecoration(
                  hintText: 'e.g. Nasim',
                  hintStyle: const TextStyle(color: Colors.white38, fontFamily: 'Times'),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),
              const Text("Pick an Avatar", style: TextStyle(color: Colors.white70, fontFamily: 'Times', fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: kAvatarOptions.map((emoji) {
                  final selected = emoji == _selectedAvatar;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatar = emoji),
                    child: Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? theme.colorScheme.secondary.withValues(alpha: 0.3) : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? theme.colorScheme.secondary : Colors.transparent, width: 2),
                      ),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(widget.isFirstRun ? "Get Started" : "Save",
                      style: const TextStyle(color: Color.fromARGB(179, 0, 0, 0), fontFamily: 'Times', fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
