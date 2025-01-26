import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../services/dashboard_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardManagementPage extends StatefulWidget {
  const AdminDashboardManagementPage({super.key});

  @override
  State<AdminDashboardManagementPage> createState() => _AdminDashboardManagementPageState();
}

class _AdminDashboardManagementPageState extends State<AdminDashboardManagementPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DashboardService _dashboardService = DashboardService();
  Map<String, dynamic>? _dashboardStats;
  Map<int, int>? _weeklyStats;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final stats = await _dashboardService.getDashboardStats(
      startDate: _startDate,
      endDate: _endDate,
    );
    final weeklyStats = await _dashboardService.getWeeklyReservationsCount(
      startDate: _startDate,
      endDate: _endDate,
    );
    setState(() {
      _dashboardStats = stats;
      _weeklyStats = weeklyStats;
    });
  }

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: _dashboardStats == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTile(
                    'Total réservations',
                    '${_dashboardStats!['totalReservations']}',
                    '${_dashboardStats!['reservationsDiff'] >= 0 ? '+' : ''}${_dashboardStats!['reservationsDiff']} par rapport à hier',
                    Iconsax.chart,
                    Colors.red,
                  ),
                  const SizedBox(height: 16),
                  _buildTile(
                    'Total encaissé',
                    '${_dashboardStats!['totalRevenue'].toStringAsFixed(0)} XOF',
                    '${_dashboardStats!['revenueDiff'] >= 0 ? '+' : ''}${_dashboardStats!['revenueDiff'].toStringAsFixed(0)} XOF par rapport à hier',
                    Iconsax.wallet,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
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
              Text('Sélectionner une période', 
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
              ),
              SizedBox(height: 10),
              SfDateRangePicker(
                selectionMode: DateRangePickerSelectionMode.range,
                onSelectionChanged: _onDateRangeChanged,
                initialSelectedRange: PickerDateRange(_startDate, _endDate),
                maxDate: DateTime.now(),
                backgroundColor: Colors.white,
                startRangeSelectionColor: Colors.blue,
                endRangeSelectionColor: Colors.blue,
                rangeSelectionColor: Colors.blue.withOpacity(0.15),
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
                  firstDayOfWeek: 1,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                      _loadDashboardData();
                      Navigator.pop(context);
                    },
                    child: Text('Réinitialiser', 
                      style: TextStyle(color: Colors.red)
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _loadDashboardData();
                      Navigator.pop(context);
                    },
                    child: Text('Appliquer', 
                      style: TextStyle(color: Colors.white)
                    ),
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
            ],
          ),
        );
      },
    );
  }

  void _onDateRangeChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      setState(() {
        _startDate = args.value.startDate;
        _endDate = args.value.endDate;
      });
    }
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
    if (_weeklyStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final spots = _weeklyStats!.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Réservations par jours', style: GoogleFonts.sora(fontSize: 16)),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 4,
                      getTitlesWidget: (value, _) => Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0: return const Text('Lun');
                          case 1: return const Text('Mar');
                          case 2: return const Text('Mer');
                          case 3: return const Text('Jeu');
                          case 4: return const Text('Ven');
                          case 5: return const Text('Sam');
                          case 6: return const Text('Dim');
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((LineBarSpot touchedSpot) {
                        return LineTooltipItem(
                          '${touchedSpot.y.toInt()} réservations',
                          const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
