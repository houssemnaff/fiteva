import 'package:flutter/material.dart';

class WeightPicker extends StatefulWidget {
  final double initialWeight;
  final Function(double) onChanged;

  const WeightPicker({
    super.key,
    required this.initialWeight,
    required this.onChanged,
  });

  @override
  State<WeightPicker> createState() => _WeightPickerState();
}

class _WeightPickerState extends State<WeightPicker> {
  late FixedExtentScrollController _controller;

  final double min = 30;
  final double max = 200;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: ((widget.initialWeight - min) * 10).toInt(),
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
              final value = min + index * 0.1;
              widget.onChanged(value);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: ((max - min) * 10).toInt(),
              builder: (context, index) {
                final value = min + index * 0.1;

                return Center(
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 22),
                  ),
                );
              },
            ),
          ),

          // 🔥 center indicator
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