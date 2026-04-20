// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/storage.dart';
import 'core/design_system.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';
import 'screens/create_character_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize Hive storage
  await StorageService.init();

  // Style the status bar for a clean transparent look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const DesiLifeApp());
}

class DesiLifeApp extends StatelessWidget {
  const DesiLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DesiLife: Premium Indian Life Simulator',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const _AppBootstrap(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGradient[1],
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBg,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.subtitle,
        titleLarge: AppTextStyles.h1,
        titleMedium: AppTextStyles.h2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBg,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.bodyBold.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}

/// Bootstraps the app by checking if a saved character exists
class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasData = StorageService.hasSavedCharacter();
      if (!mounted) return;

      if (hasData) {
        final character = StorageService.loadCharacter();
        if (character.isDead) {
          _goToCreate();
          return;
        }
        
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (c, a, s) => HomePage(initialCharacter: character),
            transitionsBuilder: (c, a, s, child) => FadeTransition(opacity: a, child: child),
          ),
        );
      } else {
        _goToCreate();
      }
    });
  }

  void _goToCreate() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (c, a, s) => const CreateCharacterScreen(),
        transitionsBuilder: (c, a, s, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: Colors.black,
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.mainBgGradient,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: AppShadows.premium,
                        ),
                        child: const Text('🇮🇳', style: TextStyle(fontSize: 54)),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'DesiLife',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 42,
                          color: AppColors.darkBg,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PREMIUM LIFE SIMULATOR',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 48),
                      const CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Color(0xFFEA580C),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

