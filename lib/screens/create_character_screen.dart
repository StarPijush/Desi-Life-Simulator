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

class _CreateCharacterScreenState extends State<CreateCharacterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  String _selectedCity = 'Mumbai';
  String _selectedGender = 'Male';
  String _selectedPersonality = 'Balanced';
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _nameController.text = _namesM[DateTime.now().millisecond % _namesM.length];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ctrl.dispose();
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black, // Dark pillarbox backgrounds for wide screens
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.mainBgGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 60, AppSpacing.s24, 60),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Logo Section ──
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: AppColors.primaryGradient,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(32),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryGradient.first.withValues(alpha: 0.35),
                                          blurRadius: 28,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: const Center(child: Text('🇮🇳', style: TextStyle(fontSize: 52))),
                                  ),
                                  const SizedBox(height: AppSpacing.s32),
                                  Text('DesiLife', style: AppTextStyles.h1.copyWith(fontSize: 42, letterSpacing: -2)),
                                  const SizedBox(height: AppSpacing.s8),
                                  Text(
                                    'YOUR INDIAN STORY BEGINS',
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s48),

                            // ── Name Input ──
                            _buildSectionLabel('FULL NAME'),
                            const SizedBox(height: AppSpacing.s12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: AppDecoration.card,
                                    child: TextField(
                                      controller: _nameController,
                                      style: AppTextStyles.bodyBold.copyWith(fontSize: 18),
                                      decoration: InputDecoration(
                                        hintText: 'Who are you?',
                                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                GestureDetector(
                                  onTap: _pickRandomName,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: AppShadows.soft,
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                                    ),
                                    child: const Center(child: Text('🎲', style: TextStyle(fontSize: 28))),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s32),

                            // ── Gender Selection ──
                            _buildSectionLabel('GENDER'),
                            const SizedBox(height: AppSpacing.s12),
                            Row(
                              children: [
                                _buildGenderChip('Male', '👦'),
                                const SizedBox(width: AppSpacing.s16),
                                _buildGenderChip('Female', '👧'),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s32),

                            // ── Personality Selection ──
                            _buildSectionLabel('PERSONALITY'),
                            const SizedBox(height: AppSpacing.s16),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.4,
                              ),
                              itemCount: _personalities.length,
                              itemBuilder: (_, i) {
                                final p = _personalities[i];
                                final isSelected = _selectedPersonality == p['key'];
                                return GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedPersonality = p['key']!);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? const LinearGradient(
                                              colors: AppColors.primaryGradient,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected ? null : Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                      boxShadow: isSelected ? AppShadows.premium : AppShadows.soft,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        children: [
                                          Text(p['emoji']!, style: const TextStyle(fontSize: 24)),
                                          const SizedBox(width: AppSpacing.s12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  p['key']!,
                                                  style: AppTextStyles.bodyBold.copyWith(
                                                    fontSize: 14,
                                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                                  ),
                                                ),
                                                Text(
                                                  p['desc']!,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTextStyles.caption.copyWith(
                                                    fontSize: 10,
                                                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.s32),

                            // ── Hometown Selection ──
                            _buildSectionLabel('HOMETOWN'),
                            const SizedBox(height: AppSpacing.s12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              decoration: AppDecoration.card,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCity,
                                  isExpanded: true,
                                  icon: Icon(Icons.location_on_rounded, color: AppColors.primaryGradient.last),
                                  borderRadius: BorderRadius.circular(24),
                                  dropdownColor: Colors.white,
                                  style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
                                  onChanged: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _selectedCity = v!);
                                  },
                                  items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s48),

                            // ── Start Living Button ──
                            GestureDetector(
                              onTap: _startLife,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.primaryGradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: AppShadows.fab,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🌱', style: TextStyle(fontSize: 26)),
                                    const SizedBox(width: AppSpacing.s12),
                                    Text(
                                      'START MY LIFE',
                                      style: AppTextStyles.bodyBold.copyWith(color: Colors.white, letterSpacing: 2, fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s32),
                            Center(
                              child: Text(
                                'Decisions matter. Karma watches. 🙏',
                                style: AppTextStyles.subtitle.copyWith(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  Widget _buildSectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, letterSpacing: 1.5),
        ),
      );

  Widget _buildGenderChip(String gender, String emoji) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedGender = gender;
            _pickRandomName();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGradient.last : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.textMuted.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: isSelected ? AppShadows.premium : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                gender,
                style: AppTextStyles.bodyBold.copyWith(
                  fontSize: 15,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
