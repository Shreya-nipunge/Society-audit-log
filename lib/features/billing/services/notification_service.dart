import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Notification types for maintenance payment reminders
enum MaintenanceNotificationType {
  assignment,  // 1st of month — maintenance assigned
  reminder,    // 5th of month — gentle reminder
  warning,     // 9th-10th of month — urgent warning
  penaltyApplied, // 11th+ — penalty has been applied
}

/// Data class for a notification banner
class MaintenanceNotification {
  final MaintenanceNotificationType type;
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const MaintenanceNotification({
    required this.type,
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

/// Service to generate appropriate notifications based on the current date.
class NotificationService {
  /// Get the current notification for the member dashboard.
  ///
  /// [currentDate] - Override for testing (defaults to DateTime.now())
  /// [outstandingAmount] - The member's current outstanding dues
  /// [monthName] - Name of the current month (e.g., "April")
  static MaintenanceNotification? getMaintenanceNotification({
    DateTime? currentDate,
    double outstandingAmount = 0,
    String monthName = '',
  }) {
    final now = currentDate ?? DateTime.now();
    final day = now.day;

    // Only show notifications if there are outstanding dues or it's early in the month
    if (day == 1) {
      return MaintenanceNotification(
        type: MaintenanceNotificationType.assignment,
        title: '🔔 Maintenance Bill Generated',
        message:
            'Your maintenance bill for $monthName has been generated. '
            'Please pay before 10th $monthName to avoid penalty of ₹25.',
        icon: Icons.notifications_active_rounded,
        color: AppColors.info,
        backgroundColor: AppColors.info.withValues(alpha: 0.08),
      );
    }

    if (day >= 2 && day <= 4) {
      if (outstandingAmount > 0) {
        return MaintenanceNotification(
          type: MaintenanceNotificationType.reminder,
          title: '📋 Payment Due',
          message:
              'Your maintenance of ₹${outstandingAmount.toStringAsFixed(0)} is due. '
              'Pay before 10th $monthName to avoid ₹25 late penalty.',
          icon: Icons.info_outline_rounded,
          color: AppColors.info,
          backgroundColor: AppColors.info.withValues(alpha: 0.08),
        );
      }
      return null;
    }

    if (day == 5) {
      if (outstandingAmount > 0) {
        return MaintenanceNotification(
          type: MaintenanceNotificationType.reminder,
          title: '⏰ Reminder: 5 Days Left',
          message:
              'Your maintenance payment of ₹${outstandingAmount.toStringAsFixed(0)} '
              'is due by 10th $monthName. Only 5 days remaining!',
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.08),
        );
      }
      return null;
    }

    if (day >= 6 && day <= 8) {
      if (outstandingAmount > 0) {
        final daysLeft = 10 - day;
        return MaintenanceNotification(
          type: MaintenanceNotificationType.reminder,
          title: '⏰ Payment Reminder',
          message:
              '₹${outstandingAmount.toStringAsFixed(0)} due in $daysLeft days. '
              'Pay before 10th to avoid ₹25 penalty.',
          icon: Icons.schedule_rounded,
          color: AppColors.warning,
          backgroundColor: AppColors.warning.withValues(alpha: 0.08),
        );
      }
      return null;
    }

    if (day == 9) {
      if (outstandingAmount > 0) {
        return MaintenanceNotification(
          type: MaintenanceNotificationType.warning,
          title: '⚠️ URGENT: Tomorrow is the Last Day!',
          message:
              'Pay your ₹${outstandingAmount.toStringAsFixed(0)} maintenance by '
              '10th $monthName. ₹25 penalty will be applied from 11th!',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.08),
        );
      }
      return null;
    }

    if (day == 10) {
      if (outstandingAmount > 0) {
        return MaintenanceNotification(
          type: MaintenanceNotificationType.warning,
          title: '🚨 TODAY is the Last Day!',
          message:
              'Pay ₹${outstandingAmount.toStringAsFixed(0)} TODAY to avoid '
              '₹25 late penalty starting tomorrow!',
          icon: Icons.error_rounded,
          color: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
        );
      }
      return null;
    }

    // Day 11+: Penalty applied
    if (day >= 11 && outstandingAmount > 0) {
      final lateMonths = 1; // At minimum 1 month late for current month
      final penalty = lateMonths * 25;
      return MaintenanceNotification(
        type: MaintenanceNotificationType.penaltyApplied,
        title: '💸 Late Payment Penalty Applied',
        message:
            'A penalty of ₹$penalty has been added to your outstanding dues. '
            'Total payable: ₹${(outstandingAmount + penalty).toStringAsFixed(0)}. '
            'Pay immediately to avoid further penalties.',
        icon: Icons.money_off_rounded,
        color: AppColors.error,
        backgroundColor: AppColors.error.withValues(alpha: 0.12),
      );
    }

    return null;
  }

  /// Get a list of all active notifications for a member.
  /// This includes both date-based reminders and penalty warnings.
  static List<MaintenanceNotification> getAllNotifications({
    DateTime? currentDate,
    double outstandingAmount = 0,
    String monthName = '',
    int totalLateMonths = 0,
  }) {
    final notifications = <MaintenanceNotification>[];

    // Add date-based notification
    final dateNotification = getMaintenanceNotification(
      currentDate: currentDate,
      outstandingAmount: outstandingAmount,
      monthName: monthName,
    );
    if (dateNotification != null) {
      notifications.add(dateNotification);
    }

    // Add accumulated penalty warning if multiple months are late
    if (totalLateMonths > 1) {
      final totalPenalty = totalLateMonths * 25;
      notifications.add(
        MaintenanceNotification(
          type: MaintenanceNotificationType.penaltyApplied,
          title: '⚠️ Accumulated Penalties',
          message:
              'You have $totalLateMonths months of unpaid maintenance. '
              'Total penalty: ₹$totalPenalty (₹25 × $totalLateMonths months).',
          icon: Icons.warning_rounded,
          color: AppColors.error,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
        ),
      );
    }

    return notifications;
  }
}
