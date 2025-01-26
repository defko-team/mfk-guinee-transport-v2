import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:mfk_guinee_transport/components/base_app_bar.dart';
import 'package:mfk_guinee_transport/components/custom_app_bar.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';
import 'package:mfk_guinee_transport/models/user_model.dart';
import 'package:mfk_guinee_transport/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../services/dashboard_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardManagementPage extends StatefulWidget {
  const AdminDashboardManagementPage({super.key});

  @override
  State<AdminDashboardManagementPage> createState() =>
      _AdminDashboardManagementPageState();
}

class _AdminDashboardManagementPageState
    extends State<AdminDashboardManagementPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  final DashboardService _dashboardService = DashboardService();
  StreamSubscription? _statsSubscription;
  StreamSubscription? _weeklyStatsSubscription;
  Map<String, dynamic>? _dashboardStats;
  Map<int, int>? _weeklyStats;

  @override
  void initState() {
    super.initState();
    fetchCurrentUser();
    _subscribeToStats();
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    _weeklyStatsSubscription?.cancel();
    super.dispose();
  }

  void _subscribeToStats() {
    _statsSubscription?.cancel();
    _weeklyStatsSubscription?.cancel();

    _statsSubscription = _dashboardService
        .getDashboardStatsStream()
        .listen((stats) {
      setState(() {
        _dashboardStats = stats;
      });
    });

    _weeklyStatsSubscription = _dashboardService
        .getWeeklyReservationsStream()
        .listen((stats) {
      setState(() {
        _weeklyStats = stats;
      });
    });
  }

  UserModel? user;
  UserService userService = UserService();

  Future<void> fetchCurrentUser() async {
    user = await userService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    if (_dashboardStats == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final totalReservations = _dashboardStats!['totalReservations'].toString();
    final reservationsDiff = _dashboardStats!['reservationsDiff'];
    final totalAmount = _dashboardStats!['totalAmount'].toStringAsFixed(0);
    final amountDiff = _dashboardStats!['amountDiff'];

    final reservationDiffText = '${reservationsDiff >= 0 ? '+' : ''}$reservationsDiff par rapport à hier';
    final amountDiffText = '${amountDiff >= 0 ? '+' : ''}${amountDiff.toStringAsFixed(0)}k par rapport à hier';

    return Scaffold(
      appBar: CurrentUserAppBar(
        actions: IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterModal,
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTile(
              'Total réservations', 
              totalReservations,
              reservationDiffText,
              Iconsax.chart, 
              Colors.red
            ),
            const SizedBox(height: 16),
            _buildTile(
              'Total encaissé', 
              '$totalAmount XOF',
              amountDiffText,
              Iconsax.wallet, 
              Colors.blue
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
                  todayTextStyle: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                  textStyle: TextStyle(color: Colors.black),
                ),
                headerStyle: DateRangePickerHeaderStyle(
                  backgroundColor: Colors.white,
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
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
                      _subscribeToStats();
                      Navigator.pop(context);
                    },
                    child: Text('Réinitialiser', 
                      style: TextStyle(color: Colors.red)
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _subscribeToStats();
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

  Widget _buildTile(String title, String value, String subtitle, IconData icon,
      Color iconColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.sora(fontSize: 16)),
              SizedBox(height: 8),
              Text(value,
                  style: GoogleFonts.sora(
                      fontSize: 24, fontWeight: FontWeight.bold)),
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
