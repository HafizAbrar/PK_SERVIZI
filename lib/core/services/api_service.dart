import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  late final Dio _dio;
  static const String baseUrl = 'https://api.pkservizi.com/api/v1';
  static const _storage = FlutterSecureStorage();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('REQUEST: ${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          }
          handler.next(error);
        },
      ),
    );
  }
}

class PublicApiService extends ApiService {
  Future<Response> getServiceTypes() async => await _dio.get('/service-types');
  Future<Response> getServiceTypeById(String id) async => await _dio.get('/service-types/$id');
  Future<Response> getServiceTypeSchema(String id) async => await _dio.get('/service-types/$id/schema');
  Future<Response> getServiceTypeDocuments(String id) async => await _dio.get('/service-types/$id/required-documents');
  Future<Response> getFaqs() async => await _dio.get('/cms/faqs');
  Future<Response> getNews() async => await _dio.get('/cms/news');
  Future<Response> getNewsById(String id) async => await _dio.get('/cms/news/$id');
  Future<Response> getPageBySlug(String slug) async => await _dio.get('/cms/pages/$slug');
  Future<Response> getSubscriptionPlans() async => await _dio.get('/subscriptions/plans');
  Future<Response> getPlansComparison() async => await _dio.get('/subscriptions/plans/comparison');
  Future<Response> getPlanById(String id) async => await _dio.get('/subscriptions/plans/$id');
  Future<Response> trackNotification(String id) async => await _dio.get('/notifications/track/$id');
  Future<Response> healthCheck() async => await _dio.get('/health');
  
  // Public Appointments
  Future<Response> getPublicAvailableSlots({String? date, int? duration}) async {
    Map<String, dynamic> queryParams = {};
    if (date != null) queryParams['date'] = date;
    if (duration != null) queryParams['duration'] = duration;
    return await _dio.get('/appointments/available-slots', queryParameters: queryParams);
  }
}

class AuthApiService extends ApiService {
  Future<Response> register(Map<String, dynamic> userData) async => await _dio.post('/auth/register', data: userData);
  Future<Response> login(String email, String password) async => await _dio.post('/auth/login', data: {'email': email, 'password': password});
  Future<Response> logout() async => await _dio.post('/auth/logout');
  Future<Response> getCurrentUser() async => await _dio.get('/auth/me');
  Future<Response> changePassword(String currentPassword, String newPassword) async => await _dio.post('/auth/change-password', data: {'currentPassword': currentPassword, 'newPassword': newPassword});
  Future<Response> refreshToken(String refreshToken) async => await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
  Future<Response> forgotPassword(String email) async => await _dio.post('/auth/forgot-password', data: {'email': email});
  Future<Response> resetPassword(String token, String newPassword) async => await _dio.post('/auth/reset-password', data: {'token': token, 'newPassword': newPassword});
}

class CustomerApiService extends ApiService {
  // Profile
  Future<Response> getProfile() async => await _dio.get('/users/profile');
  Future<Response> updateProfile(Map<String, dynamic> profileData) async => await _dio.put('/users/profile', data: profileData);
  Future<Response> getExtendedProfile() async => await _dio.get('/users/profile/extended');
  Future<Response> updateExtendedProfile(Map<String, dynamic> profileData) async => await _dio.put('/users/profile/extended', data: profileData);
  Future<Response> uploadAvatar(FormData formData) async => await _dio.post('/users/avatar', data: formData);
  Future<Response> deleteAvatar() async => await _dio.delete('/users/avatar');
  Future<Response> updateGdprConsent(bool gdprConsent, bool privacyConsent) async => await _dio.post('/users/gdpr/consent', data: {'gdprConsent': gdprConsent, 'privacyConsent': privacyConsent});
  Future<Response> getConsentHistory() async => await _dio.get('/users/gdpr/consent-history');
  Future<Response> requestDataExport() async => await _dio.get('/users/gdpr/data-export');
  Future<Response> requestAccountDeletion() async => await _dio.post('/users/gdpr/deletion-request');
  
  // User Management
  Future<Response> createUser(Map<String, dynamic> userData) async => await _dio.post('/users', data: userData);
  Future<Response> getAllUsers() async => await _dio.get('/users');
  Future<Response> getUserById(String id) async => await _dio.get('/users/$id');
  Future<Response> updateUser(String id, Map<String, dynamic> userData) async => await _dio.put('/users/$id', data: userData);
  Future<Response> deleteUser(String id) async => await _dio.delete('/users/$id');
  Future<Response> activateUser(String id) async => await _dio.patch('/users/$id/activate');
  Future<Response> deactivateUser(String id) async => await _dio.patch('/users/$id/deactivate');
  Future<Response> getUserActivity(String id) async => await _dio.get('/users/$id/activity');
  Future<Response> getUserSubscriptions(String id) async => await _dio.get('/users/$id/subscriptions');
  
  // Family Members
  Future<Response> getFamilyMembers() async => await _dio.get('/family-members');
  Future<Response> createFamilyMember(Map<String, dynamic> memberData) async => await _dio.post('/family-members', data: memberData);
  Future<Response> getFamilyMemberById(String id) async => await _dio.get('/family-members/$id');
  Future<Response> updateFamilyMember(String id, Map<String, dynamic> memberData) async => await _dio.put('/family-members/$id', data: memberData);
  Future<Response> deleteFamilyMember(String id) async => await _dio.delete('/family-members/$id');
  
  // Service Requests
  Future<Response> createServiceRequest(Map<String, dynamic> requestData, {String? serviceType}) async {
    String endpoint = '/service-requests';
    if (serviceType != null) endpoint += '?serviceType=$serviceType';
    return await _dio.post(endpoint, data: requestData);
  }
  Future<Response> getMyServiceRequests() async => await _dio.get('/service-requests/my');
  Future<Response> getServiceRequestById(String id) async => await _dio.get('/service-requests/$id');
  Future<Response> updateServiceRequest(String id, Map<String, dynamic> requestData) async => await _dio.put('/service-requests/$id', data: requestData);
  Future<Response> submitServiceRequest(String id, {String? notes}) async => await _dio.post('/service-requests/$id/submit', data: {if (notes != null) 'notes': notes});
  Future<Response> getServiceRequestStatusHistory(String id) async => await _dio.get('/service-requests/$id/status-history');
  Future<Response> deleteServiceRequest(String id) async => await _dio.delete('/service-requests/$id');
  
  // Documents
  Future<Response> uploadDocuments(FormData formData) async => await _dio.post('/documents/upload-multiple', data: formData);
  Future<Response> downloadDocument(String id) async => await _dio.get('/documents/$id/download');
  Future<Response> getDocumentsByRequest(String requestId) async => await _dio.get('/documents/request/$requestId');
  Future<Response> getRequiredDocumentsByServiceType(String serviceTypeId) async => await _dio.get('/documents/service-type/$serviceTypeId/required');
  Future<Response> getDocumentById(String id) async => await _dio.get('/documents/$id');
  Future<Response> updateDocument(String id, Map<String, dynamic> data) async => await _dio.patch('/documents/$id', data: data);
  Future<Response> deleteDocument(String id) async => await _dio.delete('/documents/$id');
  Future<Response> getAllRequestDocuments(String requestId) async => await _dio.get('/documents/request/$requestId/all');
  Future<Response> approveDocument(String id) async => await _dio.patch('/documents/$id/approve');
  Future<Response> rejectDocument(String id) async => await _dio.patch('/documents/$id/reject');
  Future<Response> addDocumentNotes(String id, String notes) async => await _dio.post('/documents/$id/notes', data: {'notes': notes});
  Future<Response> previewDocument(String id) async => await _dio.get('/documents/$id/preview');
  
  // Appointments
  Future<Response> getAvailableSlots({String? date, int? duration}) async {
    Map<String, dynamic> queryParams = {};
    if (date != null) queryParams['date'] = date;
    if (duration != null) queryParams['duration'] = duration;
    return await _dio.get('/appointments/available-slots', queryParameters: queryParams);
  }
  Future<Response> bookAppointment(Map<String, dynamic> appointmentData) async => await _dio.post('/appointments', data: appointmentData);
  Future<Response> getAllAppointments() async => await _dio.get('/appointments');
  Future<Response> getMyAppointments() async => await _dio.get('/appointments/my');
  Future<Response> getAppointmentById(String id) async => await _dio.get('/appointments/$id');
  Future<Response> cancelAppointment(String id) async => await _dio.delete('/appointments/$id');
  Future<Response> rescheduleAppointment(String id, String newDate) async => await _dio.patch('/appointments/$id/reschedule', data: {'appointmentDate': newDate});
  Future<Response> confirmAppointment(String id) async => await _dio.patch('/appointments/$id/confirm');
  Future<Response> getCalendarView() async => await _dio.get('/appointments/calendar/view');
  Future<Response> assignOperatorToAppointment(String id, String operatorId) async => await _dio.patch('/appointments/$id/assign', data: {'operatorId': operatorId});
  Future<Response> updateAppointmentStatus(String id, String status) async => await _dio.patch('/appointments/$id/status', data: {'status': status});
  Future<Response> getOperatorAppointments(String operatorId) async => await _dio.get('/appointments/operator/$operatorId');
  Future<Response> addAppointmentNote(String id, String note) async => await _dio.post('/appointments/$id/notes', data: {'note': note});
  Future<Response> getAppointmentReminders(String id) async => await _dio.get('/appointments/$id/reminders');
  Future<Response> sendAppointmentReminder(String id) async => await _dio.post('/appointments/$id/send-reminder');
  Future<Response> exportCalendar() async => await _dio.get('/appointments/export/calendar');
  
  // Subscriptions
  Future<Response> getMySubscription() async => await _dio.get('/subscriptions/my');
  Future<Response> getMyUsage() async => await _dio.get('/subscriptions/my/usage');
  Future<Response> getMyLimits() async => await _dio.get('/subscriptions/my/limits');
  Future<Response> createCheckoutSession(Map<String, dynamic> checkoutData) async => await _dio.post('/subscriptions/checkout', data: checkoutData);
  Future<Response> upgradeSubscription(Map<String, dynamic> upgradeData) async => await _dio.post('/subscriptions/my/upgrade', data: upgradeData);
  Future<Response> cancelSubscription() async => await _dio.post('/subscriptions/my/cancel');
  
  // Payments
  Future<Response> getMyPayments() async => await _dio.get('/payments/my');
  Future<Response> getPaymentReceipt(String id) async => await _dio.get('/payments/$id/receipt');
  Future<Response> getPaymentInvoice(String id) async => await _dio.get('/payments/$id/invoice');
  Future<Response> resendPaymentReceipt(String id) async => await _dio.post('/payments/$id/resend-receipt');
  
  // Notifications
  Future<Response> getMyNotifications() async => await _dio.get('/notifications/my');
  Future<Response> getUnreadCount() async => await _dio.get('/notifications/unread-count');
  Future<Response> markNotificationAsRead(String id) async => await _dio.patch('/notifications/$id/read');
  Future<Response> markAllNotificationsAsRead() async => await _dio.patch('/notifications/mark-all-read');
  Future<Response> deleteNotification(String id) async => await _dio.delete('/notifications/$id');
  
  // Courses
  Future<Response> getCourses() async => await _dio.get('/courses');
  Future<Response> getCourseById(String id) async => await _dio.get('/courses/$id');
  Future<Response> enrollInCourse(String id) async => await _dio.post('/courses/$id/enroll');
  Future<Response> getMyEnrollments() async => await _dio.get('/courses/my-enrollments');
}

class ApiServiceFactory {
  static final PublicApiService _publicService = PublicApiService();
  static final AuthApiService _authService = AuthApiService();
  static final CustomerApiService _customerService = CustomerApiService();
  
  static PublicApiService get public => _publicService;
  static AuthApiService get auth => _authService;
  static CustomerApiService get customer => _customerService;
}