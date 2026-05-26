import 'package:flutter/material.dart';
import 'baby_story_repository.dart';
import '../theme.dart';

class BabyStoryScreen extends StatefulWidget {
  final int currentWeek;

  const BabyStoryScreen({
    super.key,
    required this.currentWeek,
  });

  @override
  State<BabyStoryScreen> createState() => _BabyStoryScreenState();
}

class _BabyStoryScreenState extends State<BabyStoryScreen> {
  late int week;

  @override
  void initState() {
    super.initState();
    week = widget.currentWeek;
  }

  void nextWeek() {
    if (week < 40) setState(() => week++);
  }

  void prevWeek() {
    if (week > 1) setState(() => week--);
  }

  @override
  Widget build(BuildContext context) {
    final story = BabyStoryRepository.forWeek(week);
    final color = ThreadTheme.threadColorForWeek(week);

    return Scaffold(
      backgroundColor: ThreadTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ───────── HEADER ─────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Baby Story",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 20),

                // ───────── WEEK NAV ─────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: prevWeek,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Week $week",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: nextWeek,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ───────── TITLE ─────────
                Text(
                  story.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // ───────── PROGRESS BAR ─────────
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: week / 40,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: color,
                  ),
                ),

                const SizedBox(height: 20),

                // ───────── STORY CARD ─────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Text(
                    story.story,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ───────── WHAT HAPPENS THIS WEEK ─────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          story.fact,
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ───────── MINI TIMELINE ─────────
                Text(
                  "This week development",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 10),

                Column(
                  children: [
                    _bullet("Growth continues rapidly"),
                    _bullet("Organs are developing"),
                    _bullet("Baby is becoming more active"),
                  ],
                ),

                const SizedBox(height: 40),
              ],
              
            ),
          ),
        ),
      ),
    );
    
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}