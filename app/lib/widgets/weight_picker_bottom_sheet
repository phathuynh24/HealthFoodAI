import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WeightPickerBottomSheet extends StatefulWidget {
  final double initialWeight;
  final ValueChanged<double> onSelected;

  const WeightPickerBottomSheet({
    Key? key,
    required this.initialWeight,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<WeightPickerBottomSheet> createState() =>
      _WeightPickerBottomSheetState();
}

class _WeightPickerBottomSheetState extends State<WeightPickerBottomSheet> {
  late int selectedIntegerPart;
  late int selectedDecimalPart;

  @override
  void initState() {
    super.initState();
    selectedIntegerPart = widget.initialWeight.floor();
    selectedDecimalPart = ((widget.initialWeight - selectedIntegerPart) * 10).round();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Cancel and Save buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
                ),
                const Text("Chọn Cân Nặng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () {
                    final selectedWeight =
                        selectedIntegerPart + selectedDecimalPart / 10;
                    widget.onSelected(selectedWeight);
                    Navigator.pop(context);
                  },
                  child: const Text("Lưu", style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ),

          // Pickers
          SizedBox(
            height: 200,
            width: 400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Integer Part (30 - 180 kg)
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedIntegerPart - 30,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedIntegerPart = 30 + index;
                      });
                    },
                    children: List.generate(151, (index) {
                      return Center(
                        child: Text(
                          '${30 + index}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }),
                  ),
                ),

                // Decimal Point
                const Text(
                  ".",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                // Decimal Part (0 - 9)
                Expanded(
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedDecimalPart,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedDecimalPart = index;
                      });
                    },
                    children: List.generate(10, (index) {
                      return Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }),
                  ),
                ),

                // kg Label
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    "kg",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
