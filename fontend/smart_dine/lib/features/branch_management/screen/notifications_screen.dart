import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mart_dine/core/style.dart';
import '../../../models/notification.dart' as model;
import '../../../providers/notification_management_provider.dart';
import '../../../providers/user_session_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  final bool showBackButton;
  
  const NotificationsScreen({super.key, this.showBackButton = true});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String? _selectedCategoryFilter;
  bool _showOnlyNew = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load notifications and categories using user session data
    final currentBranchId = ref.read(currentBranchIdProvider);
    final currentCompanyId = ref.read(currentCompanyIdProvider);
    
    if (currentBranchId != null && currentCompanyId != null) {
      ref.read(notificationManagementProvider.notifier).loadNotifications(
        'branch-$currentBranchId', 
        'company-$currentCompanyId'
      );
      ref.read(notificationCategoryProvider.notifier).loadCategories();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Style.colorLight : Style.colorDark;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    final notificationsAsyncValue = ref.watch(notificationManagementProvider);
    final categoriesAsyncValue = ref.watch(notificationCategoryProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Style.backgroundColor,
      appBar: widget.showBackButton
        ? AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text('Thông báo', style: Style.fontTitle),
            actions: [
              IconButton(
                icon: Icon(Icons.mark_email_read, color: textColor),
                onPressed: _markAllAsRead,
                tooltip: 'Đánh dấu tất cả đã đọc',
              ),
            ],
          )
        : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text('Thông báo', style: Style.fontTitle),
            actions: [
              IconButton(
                icon: Icon(Icons.mark_email_read, color: textColor),
                onPressed: _markAllAsRead,
                tooltip: 'Đánh dấu tất cả đã đọc',
              ),
            ],
          ),
      body: notificationsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Lỗi khi tải dữ liệu: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (notifications) => categoriesAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Lỗi khi tải danh mục: $error'),
          ),
          data: (categories) => _buildNotificationListView(
            isDark, 
            textColor, 
            cardColor, 
            notifications, 
            categories
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationListView(
    bool isDark, 
    Color textColor, 
    Color cardColor, 
    List<model.Notification> notifications,
    List<model.NotificationCategory> categories,
  ) {
    return Column(
      children: [
        // Filter and search controls
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {}); // Rebuild để apply search filter
                },
                style: Style.fontNormal.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm thông báo...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
                  prefixIcon: Icon(Icons.search, color: textColor),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Filter controls
              Row(
                children: [
                  // Category filter
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategoryFilter,
                          hint: Text(
                            'Lọc danh mục',
                            style: Style.fontCaption.copyWith(color: Colors.grey[600]),
                          ),
                          dropdownColor: cardColor,
                          style: Style.fontNormal.copyWith(color: textColor),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả danh mục'),
                            ),
                            ...categories.map((category) => DropdownMenuItem(
                              value: category.name,
                              child: Text(category.name),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategoryFilter = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // New notifications toggle
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showOnlyNew = !_showOnlyNew;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _showOnlyNew ? Colors.blue : cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _showOnlyNew ? Colors.blue : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_new,
                            size: 16,
                            color: _showOnlyNew ? Colors.white : textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mới',
                            style: Style.fontCaption.copyWith(
                              color: _showOnlyNew ? Colors.white : textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Statistics row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildStatisticsRow(isDark, textColor, cardColor, notifications),
        ),
        const SizedBox(height: 16),
        
        // Notifications list
        Expanded(
          child: Builder(
            builder: (context) {
              // Apply filters
              List<model.Notification> filteredNotifications = notifications.where((notification) {
                // Category filter
                if (_selectedCategoryFilter != null && notification.category != _selectedCategoryFilter) {
                  return false;
                }
                
                // New notifications filter
                if (_showOnlyNew && !notification.isNew) {
                  return false;
                }
                
                // Search filter
                final searchQuery = _searchController.text.toLowerCase();
                if (searchQuery.isNotEmpty) {
                  return notification.category.toLowerCase().contains(searchQuery) ||
                         notification.type.toLowerCase().contains(searchQuery) ||
                         notification.message.toLowerCase().contains(searchQuery);
                }
                
                return true;
              }).toList();
              
              // Sort by created date (newest first) and priority
              filteredNotifications.sort((a, b) {
                if (a.priority != b.priority) {
                  return b.priority.compareTo(a.priority); // Higher priority first
                }
                return b.createdAt.compareTo(a.createdAt); // Newer first
              });
              
              if (filteredNotifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Không có thông báo nào',
                        style: Style.fontTitleMini.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredNotifications.length,
                itemBuilder: (context, index) {
                  final notification = filteredNotifications[index];
                  return _buildNotificationCard(
                    notification,
                    index,
                    isDark,
                    textColor,
                    cardColor,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsRow(bool isDark, Color textColor, Color cardColor, List<model.Notification> notifications) {
    final totalCount = notifications.length;
    final newCount = notifications.where((n) => n.isNew).length;
    final highPriorityCount = notifications.where((n) => n.isHighPriority()).length;
    
    return Row(
      children: [
        _buildStatCard('Tổng số', totalCount.toString(), Icons.notifications, Colors.blue, isDark, textColor, cardColor),
        const SizedBox(width: 12),
        _buildStatCard('Mới', newCount.toString(), Icons.fiber_new, Colors.green, isDark, textColor, cardColor),
        const SizedBox(width: 12),
        _buildStatCard('Quan trọng', highPriorityCount.toString(), Icons.priority_high, Colors.red, isDark, textColor, cardColor),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, bool isDark, Color textColor, Color cardColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Style.fontTitleMini.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Style.fontCaption.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    model.Notification notification,
    int index,
    bool isDark,
    Color textColor,
    Color cardColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: notification.isNew 
            ? Border.all(color: Colors.blue.withOpacity(0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notification.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Text(
                          notification.category,
                          style: Style.fontCaption.copyWith(
                            color: notification.iconColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (notification.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'MỚI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (notification.isHighPriority() && !notification.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'QUAN TRỌNG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Message
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: notification.type,
                            style: Style.fontNormal.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: ' ${notification.message}',
                            style: Style.fontNormal.copyWith(
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Time and priority
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.getTimeDisplay(),
                          style: Style.fontCaption.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        if (notification.isHighPriority()) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.priority_high,
                            size: 14,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.getPriorityName(),
                            style: Style.fontCaption.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Actions
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'mark_read':
                      _markAsRead(notification);
                      break;
                    case 'delete':
                      _deleteNotification(notification);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Row(
                      children: [
                        Icon(
                          notification.isNew ? Icons.mark_email_read : Icons.mark_email_unread,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(notification.isNew ? 'Đánh dấu đã đọc' : 'Đánh dấu chưa đọc'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Xóa', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAsRead(model.Notification notification) {
    ref.read(notificationManagementProvider.notifier).markAsRead(notification.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(notification.isNew ? 'Đã đánh dấu là đã đọc' : 'Đã đánh dấu là chưa đọc'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _markAllAsRead() {
    ref.read(notificationManagementProvider.notifier).markAllAsRead('branch-001');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã đánh dấu tất cả thông báo là đã đọc'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteNotification(model.Notification notification) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardColor = isDark ? Colors.grey[900]! : Colors.white;
        
        return AlertDialog(
          backgroundColor: cardColor,
          title: const Text('Xóa thông báo'),
          content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                ref.read(notificationManagementProvider.notifier).deleteNotification(notification.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa thông báo')),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}