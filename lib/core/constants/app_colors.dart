import 'package:flutter/material.dart';

// ─── Brand Colors ───────────────────────────────────────────────
const kPurple = Color(0xFF7F5AF0);
const kPurpleDark = Color(0xFF6B46C1);
const kGreen = Color(0xFF2CB67D);
const kRed = Color(0xFFFF6B6B);
const kTeal = Color(0xFF4ECDC4);
const kYellow = Color(0xFFF7DC6F);

// ─── Background Colors ──────────────────────────────────────────
const kBgDark = Color(0xFF0D0B1E);
const kBgCard = Color(0xFF13102A);
const kBgSurface = Color(0xFF1A1730);

// ─── Text Colors ────────────────────────────────────────────────
const kTextPrimary = Color(0xFFFFFFFF);
const kTextSecondary = Color(0xFF8E8BAE);
const kTextMuted = Color(0xFF5C5A72);

// ─── Gradients ──────────────────────────────────────────────────
const kGradientPrimary = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
);

const kGradientCard = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [kPurple, Color(0xFF302B63)],
);

const kGradientGreen = LinearGradient(
  colors: [kGreen, Color(0xFF1A8C5C)],
);

const kGradientPurple = LinearGradient(
  colors: [kPurple, kPurpleDark],
);
