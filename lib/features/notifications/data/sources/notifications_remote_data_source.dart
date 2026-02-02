import '../models/notification.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/app_routes.dart';

class NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  NotificationsRemoteDataSource(this._apiClient);

  Future<List<AppNotification>> getMyNotifications() async {
    final response = await _apiClient.get('/api/v1/notifications');
    return (response.data['data'] as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/api/v1/notifications/unread-count');
    return response.data['data']['count'];
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.patch('/api/v1/notifications/$notificationId/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.patch('/api/v1/notifications/mark-all-read');
  }

  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete('/api/v1/notifications/$notificationId');
  }

  Future<void> trackEmailOpen(String notificationId) async {
    await _apiClient.get(ApiEndpoints.trackNotification(notificationId));
  }
}