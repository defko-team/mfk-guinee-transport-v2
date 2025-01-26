import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';
import 'dart:async';

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

  Stream<Map<String, dynamic>> getDashboardStatsStream() {
    return _firestore
        .collection('Reservations')
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      int totalReservations = snapshot.docs.length;
      double totalAmount = 0;
      int todayReservations = 0;
      int yesterdayReservations = 0;
      double todayAmount = 0;
      double yesterdayAmount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime reservationDate = (data['start_time'] as Timestamp).toDate();
        final amount = (data['amount'] as num).toDouble();

        if (reservationDate.isAfter(today)) {
          todayReservations++;
          todayAmount += amount;
        } else if (reservationDate.isAfter(yesterday) && reservationDate.isBefore(today)) {
          yesterdayReservations++;
          yesterdayAmount += amount;
        }
        totalAmount += amount;
      }

      return {
        'totalReservations': totalReservations,
        'reservationsDiff': todayReservations - yesterdayReservations,
        'totalAmount': totalAmount,
        'amountDiff': todayAmount - yesterdayAmount,
      };
    });
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

  Stream<Map<int, int>> getWeeklyReservationsStream() {
    return _firestore
        .collection('Reservations')
        .snapshots()
        .map((snapshot) {
      final Map<int, int> weeklyStats = {};
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // Initialize all days of the week with 0
      for (int i = 1; i <= 7; i++) {
        weeklyStats[i] = 0;
      }

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final DateTime reservationDate = (data['start_time'] as Timestamp).toDate();
        
        if (reservationDate.isAfter(weekStart)) {
          final int weekday = reservationDate.weekday;
          weeklyStats[weekday] = (weeklyStats[weekday] ?? 0) + 1;
        }
      }

      return weeklyStats;
    });
  }
}
