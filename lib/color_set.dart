import 'package:flutter/material.dart';

List<Color> getColorSet(String color) {
  if (color.contains('White')) {
    return [
      Color(0xFFEAEAEA),
      Color(0xFFB8B8B8),
      Color(0xFF5C5C5C),
    ];
  } else if (color.contains('Red')) {
    return [
      Color(0xFFFF3B30),
      Color(0xFF8B0000),
      Color(0xFF1A1A1A),
    ];
  } else if (color.contains('Blue')) {
    return [
      Color(0xFF2563EB),
      Color(0xFF0F172A),
      Color(0xFF000000),
    ];
  } else if (color.contains('Black')) {
    return [
      Color(0xFF4B5563),
      Color(0xFF111827),
      Color(0xFF000000),
    ];
  } else if (color.contains('Green')) {
    return [
      Color(0xFF10B981),
      Color(0xFF064E3B),
      Color(0xFF000000),
    ];
  } else if (color.contains('Yellow')) {
    return [
      Color(0xFFFACC15),
      Color(0xFFCA8A04),
      Color(0xFF1C1917),
    ];
  } else if (color.contains('Purple')) {
    return [
      Color(0xFF9333EA),
      Color(0xFF4C1D95),
      Color(0xFF000000),
    ];
  } else if (color.contains('Pink')) {
    return [
      Color(0xFFFF4FA3),
      Color(0xFF831843),
      Color(0xFF000000),
    ];
  } else if (color.contains('Brown')) {
    return [
      Color(0xFFB45309),
      Color(0xFF451A03),
      Color(0xFF000000),
    ];
  } else if (
      color.contains('Grey') ||
      color.contains('Gray')) {
    return [
      Color(0xFF9CA3AF),
      Color(0xFF374151),
      Color(0xFF111827),
    ];
  } else if (color.contains('Orange')) {
    return [
      Color(0xFFFF7A00),
      Color(0xFF7C2D12),
      Color(0xFF000000),
    ];
  } else {
    return [
      Color(0xFF3B82F6),
      Color(0xFF1E1B4B),
      Color(0xFF000000),
    ];
  }
}