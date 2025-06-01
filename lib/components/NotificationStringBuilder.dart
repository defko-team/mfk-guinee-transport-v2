import 'package:intl/intl.dart';
import 'package:mfk_guinee_transport/models/reservation.dart';

import '../models/NotificationPayload.dart';

class NotificationStringBuilder {
  static const String _kDefaultLocale = 'fr-FR';

  final StringBuffer _buffer = StringBuffer();
  final Map<String, String> _context = {};
  final String _locale;
  late final DateFormat _timeFormat;
  late final DateFormat _dateFormat;

  NotificationStringBuilder({String locale = _kDefaultLocale})
      : _locale = locale {
    _timeFormat = DateFormat('HH:mm', _locale);
    _dateFormat = DateFormat('EEE dd MMM', _locale);
  }

  factory NotificationStringBuilder.forReservation(
      ReservationModel reservation, {
      String locale = _kDefaultLocale,
      }) {
    return NotificationStringBuilder(locale: locale)
    .._initializeReservationContext(reservation);
  }

  void _initializeReservationContext(ReservationModel reservation) {
    _context.addAll({
      'route': _buildRouteString(reservation),
      'time': _timeFormat.format(reservation.startTime),
      'date': _dateFormat.format(reservation.startTime),
      'driver': reservation.driverName ?? _getLocalizedString('driver_assigned'),
      'car': reservation.carName ?? '',
      'price': '${reservation.ticketPrice ?? 0}',
      'seats': '${reservation.remainingSeats}',
      'location': reservation.departureLocation ?? reservation.departureStation ?? '',
      'status': ReservationModel.getLabelFromStatus(reservation.status),
    });
  }

  String _buildRouteString(ReservationModel reservation) {
    final departure = _getDeparturePoint(reservation);
    final arrival = _getArrivalPoint(reservation);

    if (departure.isEmpty || arrival.isEmpty) {
      return _getLocalizedString('route_unavailable');
    }

    return '$departure → $arrival';
  }

  String _getDeparturePoint(ReservationModel reservation) {
    // Priority: departureLocation > departureStation > empty
    final location = reservation.departureLocation?.trim();
    final station = reservation.departureStation?.trim();

    if (!_isNullOrEmpty(location)) return location!;
    if (!_isNullOrEmpty(station)) return station!;

    return '';
  }

  String _getArrivalPoint(ReservationModel reservation) {
    // Priority: arrivalLocation > destinationStation > empty
    final location = reservation.arrivalLocation?.trim();
    final station = reservation.destinationStation?.trim();

    if (!_isNullOrEmpty(location)) return location!;
    if (!_isNullOrEmpty(station)) return station!;

    return '';
  }

  bool _isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }


  /// Main builder method using template pattern
  NotificationPayload buildForStatus(ReservationStatus status) {
    final template = _getTemplateForStatus(status);
    final title = _processTemplate(template.title);
    final body = _processTemplate(template.body);

    return NotificationPayload(
      title: title,
      body: body,
      data: template.data,
      priority: template.priority,
      category: template.category,
    );
  }
  _NotificationTemplate _getTemplateForStatus(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return _NotificationTemplate(
          title: '{emoji_success} {title_confirmed}',
          body: '{route}\n{emoji_calendar} {date} {preposition_at} {time}\n{emoji_driver} {driver}\n{emoji_car} {car}\n{emoji_money} {price} {currency}',
          data: {'type': 'reservation_confirmed', 'action': 'view_details'},
          priority: NotificationPriority.high,
          category: NotificationCategory.travel,
        );

      case ReservationStatus.pending:
        return _NotificationTemplate(
          title: '{emoji_pending} {title_pending}',
          body: '{route}\n{emoji_calendar} {date} {preposition_at} {time}\n{emoji_clock} {message_confirmation_progress}\n{emoji_phone} {message_notification_follow}',
          data: {'type': 'reservation_pending', 'action': 'track_status'},
          priority: NotificationPriority.normal,
          category: NotificationCategory.update,
        );

      case ReservationStatus.canceled:
        return _NotificationTemplate(
          title: '{emoji_canceled} {title_canceled}',
          body: '{route}\n{emoji_calendar} {date} {preposition_at} {time}\n{emoji_broken_heart} {message_trip_canceled}\n{emoji_money} {message_refund_progress}',
          data: {'type': 'reservation_canceled', 'action': 'view_refund'},
          priority: NotificationPriority.high,
          category: NotificationCategory.alert,
        );

      case ReservationStatus.completed:
        return _NotificationTemplate(
          title: '{emoji_completed} {title_completed}',
          body: '{route}\n{emoji_calendar} {date} {preposition_at} {time}\n{emoji_celebration} {message_thanks}\n{emoji_star} {message_rate_experience}',
          data: {'type': 'reservation_completed', 'action': 'rate_trip'},
          priority: NotificationPriority.normal,
          category: NotificationCategory.completion,
        );

      default:
        return _NotificationTemplate(
          title: '{emoji_update} {title_update}',
          body: '{message_reservation_updated}\n{route}\n{emoji_calendar} {date} {preposition_at} {time}',
          data: {'type': 'reservation_update', 'action': 'view_details'},
          priority: NotificationPriority.normal,
          category: NotificationCategory.update,
        );
    }
  }

  String _processTemplate(String template) {
    _buffer.clear(); // Reuse StringBuffer for memory efficiency

    // Performance: Use RegExp.allMatches for single pass processing
    final regex = RegExp(r'\{([^}]+)\}');
    int lastEnd = 0;

    for (final match in regex.allMatches(template)) {
      // Add text before placeholder
      _buffer.write(template.substring(lastEnd, match.start));

      // Process placeholder
      final key = match.group(1)!;
      final value = _getValueForKey(key);
      _buffer.write(value);

      lastEnd = match.end;
    }

    // Add remaining text
    _buffer.write(template.substring(lastEnd));

    return _buffer.toString();
  }

  String _getValueForKey(String key) {
    // Check context first (performance optimization)
    if (_context.containsKey(key)) {
      return _context[key]!;
    }

    // Check localized strings
    return _getLocalizedString(key);
  }

  /// Internationalization support - easily replaceable with real i18n
  String _getLocalizedString(String key) {
    const localizedStrings = {
      // Emojis
      'emoji_success': '🎯',
      'emoji_pending': '⏳',
      'emoji_canceled': '❌',
      'emoji_completed': '✅',
      'emoji_update': '📱',
      'emoji_calendar': '📅',
      'emoji_driver': '👨‍✈️',
      'emoji_car': '🚗',
      'emoji_money': '💰',
      'emoji_clock': '⏱️',
      'emoji_phone': '📱',
      'emoji_broken_heart': '💔',
      'emoji_celebration': '🎉',
      'emoji_star': '⭐',

      // Titles
      'title_confirmed': 'Réservation Confirmée',
      'title_pending': 'En Attente de Confirmation',
      'title_canceled': 'Réservation Annulée',
      'title_completed': 'Voyage Terminé',
      'title_update': 'Mise à Jour',

      // Messages
      'message_confirmation_progress': 'Confirmation en cours...',
      'message_notification_follow': 'Vous serez notifié dès validation',
      'message_trip_canceled': 'Voyage annulé',
      'message_refund_progress': 'Remboursement en cours',
      'message_thanks': 'Merci d\'avoir voyagé avec nous!',
      'message_rate_experience': 'Évaluez votre expérience',
      'message_reservation_updated': 'Votre réservation a été mise à jour',

      // Common
      'preposition_at': 'à',
      'currency': 'GNF',
      'driver_assigned': 'Chauffeur assigné',
    };

    return localizedStrings[key] ?? '{$key}'; // Graceful fallback
  }

  static NotificationPayload buildDepartureReminder(ReservationModel reservation) {
    final builder = NotificationStringBuilder.forReservation(reservation);

    return NotificationPayload(
      title: '🚌 Départ dans 30 minutes',
      body: builder._processTemplate(
          '{route}\n🕐 Départ à {time}\n📍 {location}\n🏃‍♂️ Préparez-vous!'
      ),
      data: {
        'type': 'departure_reminder',
        'reservation_id': reservation.id ?? '',
        'action': 'show_directions'
      },
      priority: NotificationPriority.urgent,
      category: NotificationCategory.reminder,
    );
  }

  static NotificationPayload buildDriverArrival(ReservationModel reservation) {
    final builder = NotificationStringBuilder.forReservation(reservation);
    final arrivalTime = DateFormat('HH:mm').format(
        DateTime.now().add(const Duration(minutes: 5))
    );

    builder._context['arrival_time'] = arrivalTime;

    return NotificationPayload(
      title: '🚗 Votre chauffeur arrive',
      body: builder._processTemplate(
          '{emoji_driver} {driver}\n{emoji_car} {car}\n📍 Arrivée prévue: {arrival_time}\n📞 Contactez si besoin'
      ),
      data: {
        'type': 'driver_arrival',
        'reservation_id': reservation.id ?? '',
        'action': 'call_driver'
      },
      priority: NotificationPriority.urgent,
      category: NotificationCategory.realtime,
    );
  }
}

class _NotificationTemplate {
  final String title;
  final String body;
  final Map<String, String> data;
  final NotificationPriority priority;
  final NotificationCategory category;

  _NotificationTemplate({
    required this.title,
    required this.body,
    this.data = const {},
    this.priority = NotificationPriority.normal,
    this.category = NotificationCategory.general,
  });
}

enum NotificationPriority { low, normal, high, urgent }
enum NotificationCategory {
  general, travel, reminder, alert, realtime, completion, update
}