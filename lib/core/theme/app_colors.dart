import 'package:flutter/material.dart';

class AppColors {
  // Neutral Blue-Green Mix (Cyan-Teal-Seafoam) Palette
  static const Color primary = Color(0xFF00796B); // Neutral Blue-Green 700
  static const Color primaryDark = Color(0xFF004D40); // Deep Slate Cyan 900
  static const Color primaryLight = Color(0xFF26A69A); // Soft Seafoam Teal 400
  static const Color primaryContainer = Color(0xFFE0F2F1); // Light Soft Mint/Teal
  static const Color primarySubtle = Color(0xFFF2F9F9); // Ultra Light Seafoam

  static const Color secondary = Color(0xFF455A64); // Cool Slate Blue
  static const Color cyanAccent = Color(0xFF00ACC1);
  static const Color emeraldAccent = Color(0xFF10B981);

  // Status Tints
  static const Color statusTaken = Color(0xFF10B981);
  static const Color statusTakenContainer = Color(0xFFECFDF5);
  static const Color statusTakenText = Color(0xFF047857);

  static const Color statusPending = Color(0xFF00796B);
  static const Color statusPendingContainer = Color(0xFFE0F2F1);
  static const Color statusPendingText = Color(0xFF004D40);

  static const Color statusMissed = Color(0xFFF43F5E);
  static const Color statusMissedContainer = Color(0xFFFFF1F2);
  static const Color statusMissedText = Color(0xFFBE123C);

  static const Color statusSkipped = Color(0xFFF59E0B);
  static const Color statusSkippedContainer = Color(0xFFFEF3C7);
  static const Color statusSkippedText = Color(0xFFB45309);

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF1A2830);
  static const Color lightTextSecondary = Color(0xFF546E7A);

  // Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF121E24);
  static const Color darkSurface = Color(0xFF1A2830);
  static const Color darkCard = Color(0xFF1A2830);
  static const Color darkBorder = Color(0xFF2A3A44);
  static const Color darkTextPrimary = Color(0xFFECEFF1);
  static const Color darkTextSecondary = Color(0xFF90A4AE);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF004D40), Color(0xFF00796B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00796B), Color(0xFF26A69A)],
  );

  static const LinearGradient takenGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient pendingGradient = LinearGradient(
    colors: [Color(0xFF00796B), Color(0xFF26A69A)],
  );

  static const LinearGradient missedGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFFB7185)],
  );

  static const LinearGradient skippedGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFFBBF24)],
  );
}
