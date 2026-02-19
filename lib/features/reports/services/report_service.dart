import '../../../core/utils/mock_data.dart';

class ReportService {
  static Map<String, double> getFundBalances() {
    // This already exists in MockData, but we'll wrap it for the service layer
    return MockData.getFundBalances();
  }

  static List<Map<String, dynamic>> getMemberPaymentSummary() {
    final members = MockData.getMembers();
    return members.map((member) {
      final totalPaid = MockData.getTransactionsForMember(
        member.id,
      ).fold(0.0, (sum, t) => sum + t.amount);
      final outstanding = MockData.getOutstandingAmount(member.id);

      return {
        'name': member.name,
        'flat': 'A-101', // Mock flat mapping
        'paid': totalPaid,
        'pending': outstanding,
      };
    }).toList();
  }
}
