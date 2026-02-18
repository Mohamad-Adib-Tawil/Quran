import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/features/settings/cubit/settings_cubit.dart';
import 'package:quran_app/features/settings/presentation/pages/language_select_page.dart';
import 'package:quran_app/features/root/presentation/pages/main_shell.dart';
import 'package:quran_app/core/theme/figma_palette.dart';

class AppSplashPage extends StatefulWidget {
  const AppSplashPage({super.key});

  @override
  State<AppSplashPage> createState() => _AppSplashPageState();
}

class _AppSplashPageState extends State<AppSplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final locale = context.read<SettingsCubit>().state.localeCode;
      final next = (locale == null || locale.isEmpty)
          ? const LanguageSelectPage()
          : const MainShell();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => next),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash/Splash Screen app.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [FigmaPalette.primary, FigmaPalette.primaryDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Text(
                    'القرآن الكريم',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
