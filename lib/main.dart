// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/storage.dart';
import 'core/design_system.dart';
import 'screens/home_page.dart';
import 'screens/create_character_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await StorageService.init();
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
      title: 'DesiLife',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final data = MediaQuery.of(context);
        final bottomInset = data.viewInsets.bottom.clamp(0.0, 9999.0);
        return MediaQuery(
          data: data.copyWith(
            viewInsets: data.viewInsets.copyWith(
              bottom: bottomInset > 0 ? bottomInset : 0.0,
            ),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.scaffoldBg,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
      ),
      home: const _AppBootstrap(),
    );
  }
}

class _AppBootstrap extends StatefulWidget {
  const _AppBootstrap();

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final hasData = StorageService.hasSavedCharacter();
      if (hasData) {
        final character = StorageService.loadCharacter();
        if (character.isDead) {
          _goToCreate();
          return;
        }
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (c, a, s) => HomePage(initialCharacter: character),
            transitionsBuilder: (c, a, s, child) =>
                FadeTransition(opacity: a, child: child),
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
        transitionsBuilder: (c, a, s, child) =>
            FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🇮🇳', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('DesiLife',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 32)),
            const SizedBox(height: 4),
            Text('LIFE SIMULATOR',
                style: AppTextStyles.sectionLabel),
            const SizedBox(height: 32),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
