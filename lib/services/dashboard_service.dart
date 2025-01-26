import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class DashboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getReservationsStream() {
    return _firestore
        .collection('Reservations')
        .orderBy('start_time', descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>> getDashboardStats({DateTime? startDate, DateTime? endDate}) async {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final effectiveStartDate = startDate ?? DateTime(now.year, now.month, now.day);
    final effectiveEndDate = endDate ?? now;
    
    // Calculer la période précédente avec la même durée
    final duration = endDate != null && startDate != null 
        ? endDate.difference(startDate) 
        : const Duration(days: 1);
    final previousPeriodStart = effectiveStartDate.subtract(duration);

    final currentPeriodReservations = await _firestore
        .collection('Reservations')
        .where('start_time', isGreaterThanOrEqualTo: effectiveStartDate)
        .where('start_time', isLessThanOrEqualTo: effectiveEndDate)
        .get();

    final previousPeriodReservations = await _firestore
        .collection('Reservations')
        .where('start_time', isGreaterThanOrEqualTo: previousPeriodStart)
        .where('start_time', isLessThan: effectiveStartDate)
        .get();

    double currentTotal = 0;
    double previousTotal = 0;

    for (var doc in currentPeriodReservations.docs) {
      currentTotal += (doc.data()['ticket_price'] ?? 0).toDouble();
    }

    for (var doc in previousPeriodReservations.docs) {
      previousTotal += (doc.data()['ticket_price'] ?? 0).toDouble();
    }

    return {
      'totalReservations': currentPeriodReservations.size,
      'reservationsDiff': currentPeriodReservations.size - previousPeriodReservations.size,
      'totalRevenue': currentTotal,
      'revenueDiff': currentTotal - previousTotal,
    };
  }

  Future<Map<int, int>> getWeeklyReservationsCount({DateTime? startDate, DateTime? endDate}) async {
    final now = DateTime.now();
    final weekStart = startDate ?? now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = endDate ?? now;
    
    final weeklyReservations = await _firestore
        .collection('Reservations')
        .where('start_time', isGreaterThanOrEqualTo: weekStart)
        .where('start_time', isLessThanOrEqualTo: weekEnd)
        .get();

    Map<int, int> dailyCounts = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (var doc in weeklyReservations.docs) {
      final reservationDate = (doc.data()['start_time'] as Timestamp).toDate();
      final dayOfWeek = reservationDate.weekday - 1;
      dailyCounts[dayOfWeek] = (dailyCounts[dayOfWeek] ?? 0) + 1;
    }

    return dailyCounts;
  }
}
