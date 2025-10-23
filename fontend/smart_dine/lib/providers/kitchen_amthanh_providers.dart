import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/kitchen_order.dart';
import '../models/kitchen_order_tinhtrang.dart';
import '../models/kitchen_data.dart';
import '../models/lichsu_order.dart';
import 'thongbao_provider.dart';
import 'lichsu_provider.dart';
import 'caidat_provider.dart';

// Exports removed — providing canCancelOrderProvider locally
final canCancelOrderProvider = Provider<bool>((ref) => true);

// ==================== SOUND SERVICE ====================

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Phát âm thanh khi hoàn thành món (Ting ting ting)
  Future<void> playCompletedSound() async {
    try {
      // Option 1: Dùng asset (nếu có file)
      await _audioPlayer.play(AssetSource('sounds/completed.mp3'));

      // Option 2: Dùng URL (file online)
      // await _audioPlayer.play(
      //   UrlSource(
      //     'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
      //   ),
      // );
      print('🔊 [SoundService] Playing completed sound');
    } catch (e) {
      print('❌ [SoundService] Error playing completed sound: $e');
    }
  }

  /// Phát âm thanh khi hết món (Âm thanh cảnh báo)
  Future<void> playOutOfStockSound() async {
    try {
      // Option 1: Dùng asset (nếu có file)
      // await _audioPlayer.play(AssetSource('sounds/out_of_stock.mp3'));

      // Option 2: Dùng URL (file online)
      await _audioPlayer.play(
        UrlSource(
          // 'https://actions.google.com/sounds/v1/alarms/beep_short.ogg',
          'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg',
        ),
      );
      print('🔊 [SoundService] Playing out of stock sound');
    } catch (e) {
      print('❌ [SoundService] Error playing out of stock sound: $e');
    }
  }

  /// Stop âm thanh
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}

// ==================== SOUND PROVIDER ====================

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(() => service.dispose());
  return service;
});

// ==================== STATE PROVIDERS ====================

final ordersProvider = StateProvider<List<KitchenOrder>>((ref) {
  return KitchenMockData.getAllKitchenOrders();
});

final selectedTabProvider = StateProvider<int>((ref) => 0);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredOrdersProvider = Provider<List<KitchenOrder>>((ref) {
  final orders = ref.watch(ordersProvider);
  final selectedTab = ref.watch(selectedTabProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  final status = KitchenOrderStatus.fromTabIndex(selectedTab);

  var filtered = orders.where((order) => order.status == status).toList();

  if (searchQuery.isNotEmpty) {
    final query = searchQuery.toLowerCase();
    filtered =
        filtered.where((order) {
          return order.dishName.toLowerCase().contains(query) ||
              order.tableNumber.toLowerCase().contains(query);
        }).toList();
  }

  filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return filtered;
});

final orderCountByStatusProvider = Provider<Map<KitchenOrderStatus, int>>((
  ref,
) {
  final orders = ref.watch(ordersProvider);

  return {
    KitchenOrderStatus.pending:
        orders.where((o) => o.status == KitchenOrderStatus.pending).length,
    KitchenOrderStatus.completed:
        orders.where((o) => o.status == KitchenOrderStatus.completed).length,
    KitchenOrderStatus.outOfStock:
        orders.where((o) => o.status == KitchenOrderStatus.outOfStock).length,
    KitchenOrderStatus.cancelled:
        orders.where((o) => o.status == KitchenOrderStatus.cancelled).length,
  };
});

final totalOrdersProvider = Provider<int>((ref) {
  return ref.watch(ordersProvider).length;
});

final pendingOrdersCountProvider = Provider<int>((ref) {
  final counts = ref.watch(orderCountByStatusProvider);
  return counts[KitchenOrderStatus.pending] ?? 0;
});

final completedOrdersCountProvider = Provider<int>((ref) {
  final counts = ref.watch(orderCountByStatusProvider);
  return counts[KitchenOrderStatus.completed] ?? 0;
});

// ==================== ACTIONS WITH SOUND ====================

/// Complete order + TẠO notification + PHÁT ÂM THANH
final completeOrderProvider = Provider.family<void Function(), String>((
  ref,
  orderId,
) {
  return () {
    print('🔔 [CompleteOrder] Starting for orderId: $orderId');

    final orders = ref.read(ordersProvider);
    final order = orders.firstWhere((o) => o.id == orderId);

    // 1. Cập nhật order sang completed
    final updatedOrders =
        orders.map((o) {
          return o.id == orderId ? o.markAsCompleted() : o;
        }).toList();
    ref.read(ordersProvider.notifier).state = updatedOrders;
    print('✅ [CompleteOrder] Order updated to COMPLETED');

    // 2. TẠO notification "Món đã xong"
    final notification = OrderNotification.fromKitchenOrder(
      order: order.markAsCompleted(),
      type: NotificationType.orderReady,
    );

    final notifications = ref.read(notificationsProvider);
    ref.read(notificationsProvider.notifier).state = [
      notification,
      ...notifications,
    ];
    print('✅ [CompleteOrder] Notification created');

    // 3. PHÁT ÂM THANH nếu bật
    final settings = ref.read(settingsProvider);
    if (settings.soundEnabled) {
      final soundService = ref.read(soundServiceProvider);
      soundService.playCompletedSound();
      print('🔊 [CompleteOrder] Sound enabled - playing completed sound');
    } else {
      print('🔇 [CompleteOrder] Sound disabled');
    }
  };
});

/// Out of stock + TẠO notification + PHÁT ÂM THANH
final outOfStockOrderProvider = Provider.family<void Function(), String>((
  ref,
  orderId,
) {
  return () {
    print('🔔 [OutOfStock] Starting for orderId: $orderId');

    final orders = ref.read(ordersProvider);
    final order = orders.firstWhere((o) => o.id == orderId);

    // 1. Cập nhật order sang out of stock
    final updatedOrders =
        orders.map((o) {
          return o.id == orderId ? o.markAsOutOfStock() : o;
        }).toList();
    ref.read(ordersProvider.notifier).state = updatedOrders;
    print('✅ [OutOfStock] Order updated to OUT_OF_STOCK');

    // 2. TẠO notification "Món hết"
    final notification = OrderNotification.fromKitchenOrder(
      order: order.markAsOutOfStock(),
      type: NotificationType.orderOutOfStock,
    );

    final notifications = ref.read(notificationsProvider);
    ref.read(notificationsProvider.notifier).state = [
      notification,
      ...notifications,
    ];
    print('✅ [OutOfStock] Notification created');

    // 3. PHÁT ÂM THANH nếu bật
    final settings = ref.read(settingsProvider);
    if (settings.soundEnabled) {
      final soundService = ref.read(soundServiceProvider);
      soundService.playOutOfStockSound();
      print('🔊 [OutOfStock] Sound enabled - playing out of stock sound');
    } else {
      print('🔇 [OutOfStock] Sound disabled');
    }
  };
});

/// Cancel order
final cancelOrderProvider = Provider.family<void Function(), String>((
  ref,
  orderId,
) {
  return () {
    final canCancel = ref.read(canCancelOrderProvider);
    if (!canCancel) {
      throw Exception('Bạn không có quyền hủy món!');
    }

    final orders = ref.read(ordersProvider);
    final order = orders.firstWhere((o) => o.id == orderId);

    // Cập nhật order sang cancelled
    final updatedOrders =
        orders.map((o) {
          return o.id == orderId ? o.markAsCancelled() : o;
        }).toList();
    ref.read(ordersProvider.notifier).state = updatedOrders;

    // TẠO notification "Món đã hủy"
    final notification = OrderNotification.fromKitchenOrder(
      order: order.markAsCancelled(),
      type: NotificationType.orderCancelled,
    );

    final notifications = ref.read(notificationsProvider);
    ref.read(notificationsProvider.notifier).state = [
      notification,
      ...notifications,
    ];
  };
});

/// Pickup order - CHUYỂN SANG LỊCH SỬ
final pickupOrderProvider = Provider.family<void Function(), String>((
  ref,
  orderId,
) {
  return () {
    final orders = ref.read(ordersProvider);
    final order = orders.firstWhere((o) => o.id == orderId);

    // 1. Tạo history record
    final historyItem = HistoryOrder.fromKitchenOrder(
      order: order,
      servedByUser: KitchenMockData.user2,
      servedAt: DateTime.now(),
    );

    // 2. Thêm vào history
    ref.read(addHistoryOrderProvider)(historyItem);

    // 3. Xóa order khỏi kitchen
    final updatedOrders = orders.where((o) => o.id != orderId).toList();
    ref.read(ordersProvider.notifier).state = updatedOrders;
  };
});
