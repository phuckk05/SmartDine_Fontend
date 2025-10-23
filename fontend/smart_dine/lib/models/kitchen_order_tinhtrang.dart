enum KitchenOrderStatus {
  pending('PENDING', 'Chưa làm'),
  completed('COMPLETED', 'Đã làm'),
  outOfStock('OUT_OF_STOCK', 'Hết món'),
  cancelled('CANCELLED', 'Đã hủy');

  final String value;
  final String displayName;

  const KitchenOrderStatus(this.value, this.displayName);

  // Thêm phương thức này
  static KitchenOrderStatus fromTabIndex(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return KitchenOrderStatus.pending;
      case 1:
        return KitchenOrderStatus.completed;
      case 2:
        return KitchenOrderStatus.outOfStock;
      case 3:
        return KitchenOrderStatus.cancelled;
      default:
        return KitchenOrderStatus.pending;
    }
  }

  static KitchenOrderStatus fromString(String value) {
    return KitchenOrderStatus.values.firstWhere(
      (status) => status.value == value.toUpperCase(),
      orElse: () => KitchenOrderStatus.pending,
    );
  }
}
