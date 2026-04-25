import 'package:flutter/material.dart';

class HeightPicker extends StatefulWidget {
  final double initialHeight;
  final Function(double) onChanged;

  const HeightPicker({
    super.key,
    required this.initialHeight,
    required this.onChanged,
  });

  @override
  State<HeightPicker> createState() => _HeightPickerState();
}

class _HeightPickerState extends State<HeightPicker> {
  late FixedExtentScrollController _controller;

  final double min = 130;
  final double max = 200;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: (widget.initialHeight - min).toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 50,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              final value = min + index;
              widget.onChanged(value);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: (max - min).toInt(),
              builder: (context, index) {
                final value = min + index;
                return Center(
                  child: Text(
                    '${value.toInt()} cm',
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              },
            ),
          ),

          // 🔥 center highlight
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.pink, width: 2),
                bottom: BorderSide(color: Colors.pink, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}