import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';
enum OnboardingStepType {
  homebase,
  favoritePlaces,
  preferences,
  baselineLists,
  friends,
}

class OnboardingStep {
  final OnboardingStepType type;
  final String title;
  final String description;
  final Widget page;

  const OnboardingStep({
    required this.type,
    required this.title,
    required this.description,
    required this.page,
  });
}
