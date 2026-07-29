enum BorrowingStatus {
  Active,
  Returned,
  Overdue,
}

extension BorrowingStatusExtension on BorrowingStatus {
  String get stringValue => toString().split('.').last;

  static BorrowingStatus fromString(String status) {
    return BorrowingStatus.values.firstWhere(
          (e) => e.stringValue == status,
      orElse: () => BorrowingStatus.Active,
    );
  }
}