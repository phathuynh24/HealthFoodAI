import 'package:app/models/weight_model.dart';
import 'package:app/views/setting/add_weight_screen.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class WeightTrackingChart extends StatelessWidget {
  final List<WeightModel> data;
  final VoidCallback onAddWeight;
  final bool isAddButtonVisible;

  const WeightTrackingChart({
    Key? key,
    required this.data,
    required this.onAddWeight,
    this.isAddButtonVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Sắp xếp dữ liệu từ ngày cũ đến mới
    List<WeightModel> sortedData = List.from(data)
      ..sort((a, b) => a.date.compareTo(b.date));

    // ✅ Chỉ lấy 30 ngày gần nhất nếu có nhiều hơn 30 ngày
    if (sortedData.length > 30) {
      sortedData = sortedData.sublist(sortedData.length - 30);
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SfCartesianChart(
            primaryXAxis: DateTimeAxis(
              title: const AxisTitle(text: 'Ngày'),
              dateFormat: DateFormat('d/M'),
              maximum: DateTime.now(),
              minimum: DateTime.now().subtract(const Duration(days: 10)),
              interval: 1,
              intervalType: DateTimeIntervalType.days,
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: const NumericAxis(
              title: AxisTitle(text: 'Cân nặng (kg)'),
              minimum: 40,
              maximum: 100,
              interval: 10,
              majorGridLines: MajorGridLines(width: 0.5),
            ),
            title: const ChartTitle(
              text: 'Sơ đồ cân nặng',
              textStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
            legend: const Legend(isVisible: false),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<WeightModel, DateTime>>[
              LineSeries<WeightModel, DateTime>(
                dataSource: sortedData,
                xValueMapper: (WeightModel weight, _) => weight.date,
                yValueMapper: (WeightModel weight, _) => weight.weight,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
                markerSettings: const MarkerSettings(isVisible: true),
                color: Colors.green,
                name: 'Cân nặng',
              ),
            ],
          ),
        ),
        if (isAddButtonVisible)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onAddWeight,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Icon(Icons.add, color: Colors.black, size: 32),
              ),
            ),
          ),
      ],
    );
  }
}

// Trang chính để hiển thị biểu đồ
void main() {
  runApp(const MaterialApp(home: WeightTrackingScreen()));
}

class WeightTrackingScreen extends StatefulWidget {
  const WeightTrackingScreen({Key? key}) : super(key: key);

  @override
  State<WeightTrackingScreen> createState() => _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends State<WeightTrackingScreen> {
  List<WeightModel> sampleData = [
    WeightModel(DateTime.now().subtract(const Duration(days: 90)), 68),
    WeightModel(DateTime.now().subtract(const Duration(days: 60)), 67),
    WeightModel(DateTime.now().subtract(const Duration(days: 30)), 66),
    WeightModel(DateTime.now(), 65.5),
  ];

  void _navigateToAddWeightScreen(BuildContext context) async {
    final newWeight = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWeightScreen()),
    );

    if (newWeight != null) {
      setState(() {
        sampleData.add(
          WeightModel(
            DateFormat('dd-MM-yyyy').parse(newWeight['date']),
            newWeight['value'],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biểu đồ cân nặng'),
        backgroundColor: Colors.green,
      ),
      body: WeightTrackingChart(
        data: sampleData,
        onAddWeight: () => _navigateToAddWeightScreen(context),
      ),
    );
  }
}
