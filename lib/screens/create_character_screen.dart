import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/engine.dart';
import '../core/storage.dart';
import '../core/design_system.dart';
import '../widgets/game/game_card.dart';
import '../widgets/game/section_header.dart';
import 'home_page.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          physics: const BouncingScrollPhysics(),
          children: [
            const Center(child: Text('🇮🇳', style: TextStyle(fontSize: 48))),
            const SizedBox(height: AppSpacing.sm),
            Center(child: Text('DesiLife', style: AppTextStyles.displayMd.copyWith(fontSize: 28))),
            const Center(child: SectionHeader(title: 'YOUR STORY BEGINS')),
            const SizedBox(height: AppSpacing.xl),

            // Name
            const SectionHeader(title: 'FULL NAME'),
            GameCard(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding, vertical: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickRandomName,
                    child: const Padding(
                      padding: EdgeInsets.all(AppSpacing.cardGap),
                      child: Text('🎲', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ],
              ),
            ),

            // Gender
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(title: 'GENDER'),
            GameCard(
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  _GenderOption(
                    label: 'Male', emoji: '👦',
                    selected: _selectedGender == 'Male',
                    onTap: () => setState(() => _selectedGender = 'Male'),
                  ),
                  Container(width: 0.5, height: 44, color: AppColors.divider),
                  _GenderOption(
                    label: 'Female', emoji: '👧',
                    selected: _selectedGender == 'Female',
                    onTap: () => setState(() => _selectedGender = 'Female'),
                  ),
                ],
              ),
            ),

            // Personality
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(title: 'PERSONALITY'),
            GameCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: _personalities.asMap().entries.map((entry) {
                  final i = entry.key;
                  final p = entry.value;
                  final isSelected = _selectedPersonality == p['key'];
                  final isLast = i == _personalities.length - 1;
                  return Column(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _selectedPersonality = p['key']!),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.containerPadding,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Text(p['emoji']!, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: AppSpacing.cardGap),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['key']!,
                                      style: AppTextStyles.bodyMd.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      p['desc']!,
                                      style: AppTextStyles.labelSm.copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Text(
                                  'SELECTED',
                                  style: AppTextStyles.labelBold.copyWith(
                                    fontSize: 10,
                                    color: AppColors.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1, color: AppColors.divider),
                    ],
                  );
                }).toList(),
              ),
            ),

            // City
            const SizedBox(height: AppSpacing.sm),
            const SectionHeader(title: 'HOMETOWN'),
            GameCard(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerPadding,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  onChanged: (v) => setState(() => _selectedCity = v!),
                  items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            GestureDetector(
              onTap: _startLife,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.containerPadding),
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  'START MY LIFE',
                  style: AppTextStyles.labelBold.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),
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
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: AppTextStyles.bodyMd.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
