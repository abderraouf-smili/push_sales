import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle display = TextStyle(
    fontFamily: 'kodchasan',
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static const TextStyle title = TextStyle(
    fontFamily: 'alata',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: 'alata',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'alata',
    fontSize: 14,
    color: AppColors.ink,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'alata',
    fontSize: 12,
    color: AppColors.muted,
  );

  static const TextStyle button = TextStyle(
    fontFamily: 'alata',
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
}
