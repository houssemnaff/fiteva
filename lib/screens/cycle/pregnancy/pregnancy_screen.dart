// lib/screens/cycle/pregnancy/pregnancy_screen.dart

import 'package:fiteva/screens/cycle/pregnancy/baby.dart';

import 'package:fiteva/screens/cycle/pregnancy/pregnancy_data.dart';
import 'package:fiteva/screens/cycle/pregnancy/pregnancy_header.dart';
import 'package:fiteva/screens/cycle/pregnancy/pregnancy_symptoms_card.dart';

import 'package:fiteva/screens/cycle/pregnancy/pregnancy_wheel.dart';
import 'package:fiteva/screens/cycle/pregnancy/tips.dart';
import 'package:flutter/material.dart';

class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  int _currentWeek = 12;
  final Set<int> _selectedSymptoms = {};

  @override
  Widget build(BuildContext context) {
    final week = getPregnancyWeek(_currentWeek);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ── HEADER ──────────────────────────────────
              PregnancyHeader(
                currentWeek: _currentWeek,
                isPregnancyMode: true,
                onToggleMode: () => Navigator.maybePop(context),
                onClose: () => Navigator.maybePop(context),
              ),

              const SizedBox(height: 8),

              // ── WHEEL ────────────────────────────────────
              SizedBox(
                width: screenWidth * 0.88,
                height: screenWidth * 0.88,
                child: PregnancyWheel(
                  currentWeek: _currentWeek,
                  onWeekSelected: (w) => setState(() => _currentWeek = w),
                ),
              ),

              const SizedBox(height: 16),

              // ── BABY DEVELOPMENT CARD ────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BabyDevelopmentCard(week: week),
              ),

              const SizedBox(height: 10),

              // ── TIPS CARD ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PregnancyTipsCard(week: week),
              ),

              const SizedBox(height: 10),

              // ── SYMPTOMS CARD ────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PregnancySymptomsCard(
                  week: week,
                  selectedSymptoms: _selectedSymptoms,
                  onToggle: (i) => setState(() {
                    if (_selectedSymptoms.contains(i)) {
                      _selectedSymptoms.remove(i);
                    } else {
                      _selectedSymptoms.add(i);
                    }
                  }),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}