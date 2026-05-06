// lib/screens/create_character_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/engine.dart';
import '../core/storage.dart';
import 'home_page.dart';
import '../core/design_system.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _nameController = TextEditingController();
  String _selectedCity = 'Mumbai';
  String _selectedGender = 'Male';
  String _selectedPersonality = 'Balanced';

  static const List<String> _cities = [
    'Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Kolkata',
    'Hyderabad', 'Pune', 'Ahmedabad', 'Jaipur', 'Lucknow',
    'Kanpur', 'Nagpur', 'Indore', 'Surat', 'Bhopal',
    'Patna', 'Vadodara', 'Ghaziabad', 'Ludhiana', 'Agra',
  ];

  static final List<Map<String, String>> _personalities = [
    {'key': 'Balanced', 'emoji': '⚖️', 'desc': 'Well-rounded start'},
    {'key': 'Smart', 'emoji': '🧠', 'desc': '+Smarts, -Social'},
    {'key': 'Kind', 'emoji': '❤️', 'desc': '+Karma, +Happiness'},
    {'key': 'Lazy', 'emoji': '😴', 'desc': '+Happiness, -Health'},
    {'key': 'Aggressive', 'emoji': '🔥', 'desc': '+Health, -Karma'},
    {'key': 'Lucky', 'emoji': '🍀', 'desc': 'Bonus to everything!'},
  ];

  static const List<String> _namesM = ['Arjun', 'Rohan', 'Vikram', 'Aditya', 'Karan', 'Raj', 'Amit', 'Rahul'];
  static const List<String> _namesF = ['Priya', 'Ananya', 'Kavya', 'Meera', 'Shruti', 'Divya', 'Pooja', 'Nisha'];

  @override
  void initState() {
    super.initState();
    _nameController.text = _namesM[DateTime.now().millisecond % _namesM.length];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _pickRandomName() {
    HapticFeedback.lightImpact();
    final names = _selectedGender == 'Female' ? _namesF : _namesM;
    setState(() {
      _nameController.text = names[DateTime.now().millisecondsSinceEpoch % names.length];
    });
  }

  void _startLife() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.heavyImpact();

    final character = GameEngine.createNewCharacter(
      name: name,
      city: _selectedCity,
      gender: _selectedGender,
      personality: _selectedPersonality,
    );

    StorageService.saveCharacter(character);

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, animation, __) => HomePage(initialCharacter: character, isNewLife: true),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      transitionDuration: const Duration(milliseconds: 600),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          physics: const BouncingScrollPhysics(),
          children: [
            const Center(child: Text('🇮🇳', style: TextStyle(fontSize: 48))),
            const SizedBox(height: 8),
            Center(child: Text('DesiLife', style: AppTextStyles.pageTitle.copyWith(fontSize: 28))),
            const Center(child: SectionLabel(title: 'YOUR STORY BEGINS')),
            const SizedBox(height: 32),

            // Name
            const SectionLabel(title: 'FULL NAME'),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: AppTextStyles.rowTitle,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickRandomName,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('🎲', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            ),

            // Gender
            const SectionLabel(title: 'GENDER'),
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  _GenderOption(
                    label: 'Male', emoji: '👦',
                    selected: _selectedGender == 'Male',
                    onTap: () => setState(() => _selectedGender = 'Male'),
                  ),
                  Container(width: 0.5, height: 44, color: AppColors.dividerLight),
                  _GenderOption(
                    label: 'Female', emoji: '👧',
                    selected: _selectedGender == 'Female',
                    onTap: () => setState(() => _selectedGender = 'Female'),
                  ),
                ],
              ),
            ),

            // Personality
            const SectionLabel(title: 'PERSONALITY'),
            RowGroup(
              rows: _personalities.map((p) => GameRow(
                icon: p['emoji']!,
                title: p['key']!,
                subtitle: p['desc']!,
                trailing: _selectedPersonality == p['key'] 
                  ? const Text('SELECTED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.info)) 
                  : null,
                onTap: () => setState(() => _selectedPersonality = p['key']!),
              )).toList(),
            ),

            // City
            const SectionLabel(title: 'HOMETOWN'),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  style: AppTextStyles.rowTitle,
                  onChanged: (v) => setState(() => _selectedCity = v!),
                  items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Start button
            GestureDetector(
              onTap: _startLife,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'START MY LIFE',
                  style: AppTextStyles.rowTitle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: Text('Karma watches. 🙏',
                  style: AppTextStyles.caption.copyWith(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _GenderOption({required this.label, required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: 50,
          color: selected ? AppColors.info.withValues(alpha: 0.08) : Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(label, style: AppTextStyles.rowTitle.copyWith(
                color: selected ? AppColors.info : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
