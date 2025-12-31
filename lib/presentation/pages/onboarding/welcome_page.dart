/// Welcome Page
/// 
/// First screen in onboarding flow with welcoming animated text.
/// Displays "Hi, tell me about yourself" with bubbly floating letters.
/// 
/// Features:
/// - Full-screen centered layout
/// - Floating text animation
/// - Tap anywhere to continue
/// - Subtle gradient background
/// - Skip button for returning users
/// 
/// Design inspired by Apple onboarding vibe but with SPOTS minimalist aesthetic.
library;

import 'package:flutter/material.dart';
import 'package:spots/core/theme/colors.dart';
import 'package:spots/presentation/widgets/onboarding/floating_text_widget.dart';

class WelcomePage extends StatefulWidget {
  /// Callback when user taps to continue
  final VoidCallback? onContinue;
  
  /// Callback when user taps skip
  final VoidCallback? onSkip;
  
  const WelcomePage({
    super.key,
    this.onContinue,
    this.onSkip,
  });
  
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isExiting = false;
  
  @override
  void initState() {
    super.initState();
    _initFadeAnimation();
  }
  
  void _initFadeAnimation() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }
  
  void _handleTapContinue() {
    if (_isExiting) return;
    
    setState(() {
      _isExiting = true;
    });
    
    // Fade out animation
    _fadeController.forward().then((_) {
      if (mounted) {
        widget.onContinue?.call();
      }
    });
  }
  
  void _handleSkip() {
    if (_isExiting) return;
    widget.onSkip?.call();
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 1.0 - _fadeAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: _handleTapContinue,
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.white,
                  AppColors.grey50,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Skip button (top-right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Semantics(
                      button: true,
                      label: 'Skip welcome screen',
                      child: TextButton(
                        onPressed: _handleSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Main content (centered)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Spacer to push content up slightly
                        const Spacer(flex: 2),
                        
                        // Main animated text
                        Semantics(
                          header: true,
                          label: 'Hi, tell me about yourself',
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.0),
                            child: FloatingTextWidget(
                              text: 'Hi, tell me\nabout yourself',
                              textStyle: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.4,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        
                        const Spacer(flex: 3),
                        
                        // Continue hint
                        Semantics(
                          hint: 'Tap anywhere to continue',
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 48.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  color: AppColors.textSecondary,
                                  size: 24,
                                ),
                                SizedBox(height: 8),
                                PulsingHintWidget(
                                  text: 'Tap to continue',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

