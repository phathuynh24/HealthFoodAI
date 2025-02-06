import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomPickerBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final String Function(T)? displayValue;

  const CustomPickerBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    int selectedIndex = options.indexOf(selectedValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Cancel - Title - Save
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
              ),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onSelected(options[selectedIndex]);
                },
                child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),

          // Picker (Cupertino Style)
          SizedBox(
            height: 180,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: selectedIndex),
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                selectedIndex = index;
              },
              children: options.map((option) {
                return Center(
                  child: Text(
                    displayValue != null ? displayValue!(option) : option.toString(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
