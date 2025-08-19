import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking.dart';
import '../models/driver_stats.dart';
import '../models/trip.dart';

class DriverService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _tripsCollection = 'trips';
  static const String _bookingsCollection = 'bookings';
  static const String _driversCollection = 'drivers';

  Stream<List<Trip>> getDriverTrips(String driverId) {
    return _firestore
        .collection(_tripsCollection)
        .where('driver_id', isEqualTo: driverId)
        .orderBy('date_depart', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Trip.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  Stream<List<Trip>> getUpcomingTrips(String driverId) {
    final now = DateTime.now();
    return _firestore
        .collection(_tripsCollection)
        .where('driver_id', isEqualTo: driverId)
        .where('date_depart', isGreaterThan: now.toIso8601String())
        .orderBy('date_depart', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Trip.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  Stream<List<Trip>> getTodayTrips(String driverId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(_tripsCollection)
        .where('driver_id', isEqualTo: driverId)
        .where('date_depart', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date_depart', isLessThan: endOfDay.toIso8601String())
        .orderBy('date_depart', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Trip.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }


  Future<String> createTrip(Trip trip) async {
    try {
      final docRef = await _firestore.collection(_tripsCollection).add(trip.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création du trajet: $e');
    }
  }


  Future<void> updateTrip(Trip trip) async {
    try {
      await _firestore
          .collection(_tripsCollection)
          .doc(trip.id)
          .update(trip.toMap());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du trajet: $e');
    }
  }


  Future<void> deleteTrip(String tripId) async {
    try {
      await _firestore.collection(_tripsCollection).doc(tripId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du trajet: $e');
    }
  }


  Stream<List<Booking>> getDriverBookings(String driverId) {

    return _firestore
        .collection(_tripsCollection)
        .where('driver_id', isEqualTo: driverId)
        .snapshots()
        .asyncMap((tripsSnapshot) async {
      try {
        final tripIds = tripsSnapshot.docs.map((doc) => doc.id).toList();

        if (tripIds.isEmpty) {

          return <Booking>[];
        }

        final bookingsSnapshot = await _firestore
            .collection(_bookingsCollection)
            .where('trip_id', whereIn: tripIds)
            .orderBy('created_at', descending: true)
            .get();

        return bookingsSnapshot.docs
            .map((doc) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            return Booking.fromMap(data);
          } catch (e) {
            return null;
          }
        })
            .where((booking) => booking != null)
            .cast<Booking>()
            .toList();
      } catch (e) {
        return <Booking>[];
      }
    })
        .handleError((error) {
      return <Booking>[];
    });
  }

  Stream<List<Booking>> getTripBookings(String tripId) {
    return _firestore
        .collection(_bookingsCollection)
        .where('trip_id', isEqualTo: tripId)
        .where('status', isEqualTo: BookingStatus.confirmee.name)
        .orderBy('created_at', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Booking.fromMap({...doc.data(), 'id': doc.id}))
        .toList());
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore
          .collection(_bookingsCollection)
          .doc(bookingId)
          .update({'status': status.name});
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la réservation: $e');
    }
  }


  Future<DriverStats> getDriverStats(String driverId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final allTripsSnapshot = await _firestore
          .collection(_tripsCollection)
          .where('driver_id', isEqualTo: driverId)
          .get();


      final monthTripsSnapshot = await _firestore
          .collection(_tripsCollection)
          .where('driver_id', isEqualTo: driverId)
          .where('date_depart', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
          .get();


      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      final todayTripsSnapshot = await _firestore
          .collection(_tripsCollection)
          .where('driver_id', isEqualTo: driverId)
          .where('date_depart', isGreaterThanOrEqualTo: todayStart.toIso8601String())
          .where('date_depart', isLessThan: todayEnd.toIso8601String())
          .get();

      final totalTrips = allTripsSnapshot.docs.length;
      final monthTrips = monthTripsSnapshot.docs.length;
      final todayTrips = todayTripsSnapshot.docs.length;

      double monthRevenue = 0;
      for (var doc in monthTripsSnapshot.docs) {
        final trip = Trip.fromMap({...doc.data(), 'id': doc.id});
        monthRevenue += (trip.prix * trip.placesReservees);
      }

      int monthSeats = 0;
      for (var doc in monthTripsSnapshot.docs) {
        final trip = Trip.fromMap({...doc.data(), 'id': doc.id});
        monthSeats += trip.placesReservees;
      }

      return DriverStats(
        totalTrips: totalTrips,
        monthTrips: monthTrips,
        todayTrips: todayTrips,
        monthRevenue: monthRevenue,
        monthSeats: monthSeats,
      );
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }
}