import 'package:app/models/weight_model.dart';
import 'package:app/views/setting/add_weight_screen.dart';
import 'package:app/widgets/custom_app_bar.dart';
import 'package:app/widgets/goal_achievement_dialog.dart';
import 'package:app/widgets/weight_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListWeightScreen extends StatefulWidget {
  final List<WeightModel> data;
  final Map<String, dynamic> userData;

  const ListWeightScreen({Key? key, required this.data, required this.userData})
      : super(key: key);

  @override
  State<ListWeightScreen> createState() => _ListWeightScreenState();
}

class _ListWeightScreenState extends State<ListWeightScreen> {
  late List<WeightModel> sortedData;
  bool hasReachedTarget = false;

  @override
  void initState() {
    super.initState();
    sortedData = List.from(widget.data);
    sortedData.sort((a, b) => b.date.compareTo(a.date)); // Gần nhất lên đầu
  }

  void _addWeight() async {
    final newWeight = await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => const AddWeightScreen(),
      ),
    );

    if (newWeight != null) {
      final DateTime newDate =
          DateFormat('dd-MM-yyyy').parse(newWeight['date']);
      final double newValue = newWeight['value'];

      hasReachedTarget = newWeight['hasReachedTarget'] ?? false;

      setState(() {
        // Kiểm tra xem ngày đã tồn tại trong danh sách chưa
        final existingIndex = sortedData.indexWhere((item) =>
            DateFormat('dd-MM-yyyy').format(item.date) ==
            DateFormat('dd-MM-yyyy').format(newDate));

        if (existingIndex != -1) {
          // Nếu ngày đã tồn tại, cập nhật giá trị cân nặng
          sortedData[existingIndex] = WeightModel(newDate, newValue);
        } else {
          // Nếu chưa có, thêm dữ liệu mới vào danh sách
          sortedData.add(WeightModel(newDate, newValue));
        }

        // Sắp xếp lại dữ liệu từ ngày mới đến ngày cũ
        sortedData.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pop(context, {
            'sortedData': sortedData,
            'hasReachedTarget': hasReachedTarget,
            'isList': true,
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Theo dõi cân nặng',
          actions: [
            IconButton(
              onPressed: _addWeight,
              icon: const Icon(
                Icons.add,
                size: 32,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WeightTrackingChart(
                data: sortedData,
                isAddButtonVisible: false,
                onAddWeight: _addWeight,
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Danh sách cân nặng",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: sortedData.length,
                itemBuilder: (context, index) {
                  final weightEntry = sortedData[index];
                  return ListTile(
                    leading:
                        const Icon(Icons.monitor_weight, color: Colors.green),
                    title: Text(
                      '${weightEntry.weight.toStringAsFixed(1)} kg',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      DateFormat('dd/MM/yyyy').format(weightEntry.date),
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
