import 'package:flutter_riverpod/flutter_riverpod.dart';

final uri1 = 'https://spring-boot-smartdine.onrender.com/api/order-items';
final uri2 = 'https://smartdine-backend-oq2x.onrender.com/api/order-items';

class KitchenApi {}

final kitchenApiProvider = Provider<KitchenApi>((ref) => KitchenApi());
