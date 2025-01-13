import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AdminDashboardManagementPage extends StatefulWidget {
  const AdminDashboardManagementPage({super.key});

  @override
  State<AdminDashboardManagementPage> createState() => _AdminDashboardManagementPageState();
}

class _AdminDashboardManagementPageState extends State<AdminDashboardManagementPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tableau de bord',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.green,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTile('Total réservations', '432', '+13 par rapport à hier', Iconsax.chart, Colors.red),
            SizedBox(height: 16),
            _buildTile('Total encaissé', '439.500 XOF', '+43k par rapport à hier', Iconsax.wallet, Colors.blue),
            SizedBox(height: 16),
            Expanded(child: _buildChartTile()),
          ],
        ),
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sélectionner une période', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onDateRangeChanged,
                initialSelectedRange: PickerDateRange(_startDate, _endDate),
                backgroundColor: Colors.white,
                startRangeSelectionColor: Colors.blue, // Start date color
                endRangeSelectionColor: Colors.blue,   // End date color
                rangeSelectionColor: Colors.blue.withOpacity(0.15), // Range color
                todayHighlightColor: Colors.blue,
                selectionTextStyle: TextStyle(color: Colors.white),
                monthCellStyle: DateRangePickerMonthCellStyle(
                  todayTextStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  textStyle: TextStyle(color: Colors.black),
                ),
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Colors.white,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  firstDayOfWeek: 1, // Start the week on Monday
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Print selected dates in the console
                  print("Selected Start Date: $_startDate");
                  print("Selected End Date: $_endDate");
                },
                child: Text('Appliquer', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  void _onDateRangeChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _startDate = args.value.startDate;
        _endDate = args.value.endDate;
      }
    });
  }

  Widget _buildTile(String title, String value, String subtitle, IconData icon, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.sora(fontSize: 16)),
              SizedBox(height: 8),
              Text(value, style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.green)),
            ],
          ),
          Icon(icon, color: iconColor, size: 40),
        ],
      ),
    );
  }

Widget _buildChartTile() {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Réservations par jours', style: GoogleFonts.sora(fontSize: 16)),
        SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              borderData: FlBorderData(show: false), // Pas de bordures
              gridData: FlGridData(show: false), // Pas de grilles
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 4,
                    getTitlesWidget: (value, _) => Text(
                      '${value.toInt()}',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      switch (value.toInt()) {
                        case 0: return Text('Lun');
                        case 1: return Text('Mar');
                        case 2: return Text('Mer');
                        case 3: return Text('Jeu');
                        case 4: return Text('Ven');
                        case 5: return Text('Sam');
                        case 6: return Text('Dim');
                        default: return Text('');
                      }
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Désactive les titres à droite
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Désactive les titres en haut
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: Colors.teal,
                  barWidth: 4,
                  belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.3)),
                  spots: [
                    FlSpot(0, 4),
                    FlSpot(1, 8),
                    FlSpot(2, 12),
                    FlSpot(3, 15),
                    FlSpot(4, 10),
                    FlSpot(5, 5),
                    FlSpot(6, 7),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

}
