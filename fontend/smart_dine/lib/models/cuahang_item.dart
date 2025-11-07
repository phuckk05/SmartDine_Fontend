import 'package:flutter/material.dart';
import 'package:mart_dine/models/company.dart';

class CuaHangItem extends StatelessWidget {
  final Company store;
  final ValueChanged<bool> onToggle;

  const CuaHangItem({super.key, required this.store, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final bool isActive = store.statusId == 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green[100] : Colors.grey[200],
          child: Icon(
            Icons.store_mall_directory,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          store.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          'Mã: ${store.companyCode}\nĐịa chỉ: ${store.address}',
          style: const TextStyle(height: 1.4, color: Colors.black54),
        ),
        trailing: Switch(
          value: isActive,
          activeColor: Colors.green,
          onChanged: onToggle,
        ),
      ),
    );
  }
}
