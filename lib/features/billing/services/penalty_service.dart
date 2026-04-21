/// Service to calculate late-payment penalties and provide utility functions
/// for the maintenance receipt system.
///
/// Penalty Logic:
/// - Due date is the 10th of every month
/// - Payment window: 1st to 10th of each month (for that month's maintenance)
/// - If paid after 10th: ₹25 penalty per late month
/// - Penalties accumulate: e.g., 2 months late = ₹50 penalty
class PenaltyService {
  /// Penalty amount per late month (in Rupees)
  static const double penaltyPerMonth = 25.0;

  /// Calculate the total penalty for unpaid months.
  ///
  /// [unpaidMonths] - list of DateTime representing the 1st of each unpaid month
  /// [currentDate] - the date to calculate against (defaults to now)
  ///
  /// Returns total penalty amount (₹25 × number of late months)
  static double calculatePenalty({
    required List<DateTime> unpaidMonths,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    int lateCount = 0;

    for (final monthStart in unpaidMonths) {
      // Due date is the 10th of that month
      final dueDate = DateTime(monthStart.year, monthStart.month, 10);

      // If current date is past the due date, this month is late
      if (now.isAfter(dueDate)) {
        lateCount++;
      }
    }

    return lateCount * penaltyPerMonth;
  }

  /// Count number of late months from unpaid months list.
  static int countLateMonths({
    required List<DateTime> unpaidMonths,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    int lateCount = 0;

    for (final monthStart in unpaidMonths) {
      final dueDate = DateTime(monthStart.year, monthStart.month, 10);
      if (now.isAfter(dueDate)) {
        lateCount++;
      }
    }

    return lateCount;
  }

  /// Check if a specific month's payment is late.
  static bool isPaymentLate(int month, int year, {DateTime? currentDate}) {
    final now = currentDate ?? DateTime.now();
    final dueDate = DateTime(year, month, 10);
    return now.isAfter(dueDate);
  }

  /// Get the due date for a given month.
  static DateTime getDueDate(int month, int year) {
    return DateTime(year, month, 10);
  }

  /// Convert a number to Indian Rupee words.
  /// e.g., 3525 → "Three Thousand Five Hundred Twenty Five Only"
  static String numberToWords(double amount) {
    final int rupees = amount.round();

    if (rupees == 0) return 'Zero Only';

    final ones = [
      '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
      'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
      'Seventeen', 'Eighteen', 'Nineteen',
    ];

    final tens = [
      '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety',
    ];

    String convertBelowThousand(int n) {
      String result = '';

      if (n >= 100) {
        result += '${ones[n ~/ 100]} Hundred ';
        n %= 100;
      }

      if (n >= 20) {
        result += '${tens[n ~/ 10]} ';
        n %= 10;
      }

      if (n > 0) {
        result += '${ones[n]} ';
      }

      return result;
    }

    if (rupees < 0) return 'Minus ${numberToWords(-amount)}';

    String result = '';
    int remaining = rupees;

    // Crore (1,00,00,000)
    if (remaining >= 10000000) {
      result += '${convertBelowThousand(remaining ~/ 10000000)}Crore ';
      remaining %= 10000000;
    }

    // Lakh (1,00,000)
    if (remaining >= 100000) {
      result += '${convertBelowThousand(remaining ~/ 100000)}Lakh ';
      remaining %= 100000;
    }

    // Thousand (1,000)
    if (remaining >= 1000) {
      result += '${convertBelowThousand(remaining ~/ 1000)}Thousand ';
      remaining %= 1000;
    }

    // Remaining below 1000
    if (remaining > 0) {
      result += convertBelowThousand(remaining);
    }

    return 'Rupees ${result.trim()} Only';
  }

  /// Get the floor name from a flat number.
  /// 0xx → Ground Floor, 1xx → 1st Floor, 2xx → 2nd Floor, etc.
  static String getFloorFromFlatNumber(String flatNumber) {
    // Remove non-numeric prefix if any
    final cleanFlat = flatNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanFlat.isEmpty) return '1st Floor';

    final flatNum = int.tryParse(cleanFlat) ?? 0;

    if (flatNum < 100) return 'Ground Floor';
    if (flatNum < 200) return '1st Floor';
    if (flatNum < 300) return '2nd Floor';
    if (flatNum < 400) return '3rd Floor';
    return '4th Floor';
  }
}
