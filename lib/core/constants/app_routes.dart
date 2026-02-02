class ApiEndpoints {
  static const String baseUrl = 'https://api.pkservizi.com/api/v1';
  
  // Public routes
  static const String serviceTypes = '/service-types';
  static String serviceTypeById(String id) => '/service-types/$id';
  static String serviceTypeSchema(String id) => '/service-types/$id/schema';
  static String serviceTypeDocuments(String id) => '/service-types/$id/required-documents';
  static const String faqs = '/cms/faqs';
  static const String news = '/cms/news';
  static String newsById(String id) => '/cms/news/$id';
  static String pageBySlug(String slug) => '/cms/pages/$slug';
  static const String subscriptionPlans = '/subscriptions/plans';
  static const String plansComparison = '/subscriptions/plans/comparison';
  static String planById(String id) => '/subscriptions/plans/$id';
  static String trackNotification(String id) => '/notifications/track/$id';
  static const String health = '/health';
  
  // Authentication routes
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // Profile
  static const String profile = '/users/profile';
  static const String extendedProfile = '/users/profile/extended';
  static const String avatar = '/users/avatar';
  static const String gdprConsent = '/users/gdpr/consent';
  static const String consentHistory = '/users/gdpr/consent-history';
  static const String dataExport = '/users/gdpr/data-export';
  static const String deletionRequest = '/users/gdpr/deletion-request';
  
  // User Management
  static const String users = '/users';
  static String userById(String id) => '/users/$id';
  static String activateUser(String id) => '/users/$id/activate';
  static String deactivateUser(String id) => '/users/$id/deactivate';
  static String userActivity(String id) => '/users/$id/activity';
  static String userSubscriptions(String id) => '/users/$id/subscriptions';
  
  // Family Members
  static const String familyMembers = '/family-members';
  static String familyMemberById(String id) => '/family-members/$id';
  
  // Service Requests
  static const String serviceRequests = '/service-requests';
  static const String myServiceRequests = '/service-requests/my';
  static String serviceRequestById(String id) => '/service-requests/$id';
  static String submitServiceRequest(String id) => '/service-requests/$id/submit';
  static String serviceRequestStatusHistory(String id) => '/service-requests/$id/status-history';
  
  // Documents
  static const String uploadDocuments = '/documents/upload-multiple';
  static String downloadDocument(String id) => '/documents/$id/download';
  static String documentsByRequest(String requestId) => '/documents/request/$requestId';
  static String requiredDocumentsByServiceType(String serviceTypeId) => '/documents/service-type/$serviceTypeId/required';
  static String documentById(String id) => '/documents/$id';
  static String approveDocument(String id) => '/documents/$id/approve';
  static String rejectDocument(String id) => '/documents/$id/reject';
  static String documentNotes(String id) => '/documents/$id/notes';
  static String previewDocument(String id) => '/documents/$id/preview';
  static String allRequestDocuments(String requestId) => '/documents/request/$requestId/all';
  
  // Appointments
  static const String availableSlots = '/appointments/available-slots';
  static const String appointments = '/appointments';
  static const String myAppointments = '/appointments/my';
  static String appointmentById(String id) => '/appointments/$id';
  static String rescheduleAppointment(String id) => '/appointments/$id/reschedule';
  static String confirmAppointment(String id) => '/appointments/$id/confirm';
  static const String calendarView = '/appointments/calendar/view';
  static String assignAppointmentOperator(String id) => '/appointments/$id/assign';
  static String updateAppointmentStatus(String id) => '/appointments/$id/status';
  static String operatorAppointments(String operatorId) => '/appointments/operator/$operatorId';
  static String appointmentNotes(String id) => '/appointments/$id/notes';
  static String appointmentReminders(String id) => '/appointments/$id/reminders';
  static String sendAppointmentReminder(String id) => '/appointments/$id/send-reminder';
  static const String exportCalendar = '/appointments/export/calendar';
  
  // Subscriptions
  static const String mySubscription = '/subscriptions/my';
  static const String myUsage = '/subscriptions/my/usage';
  static const String myLimits = '/subscriptions/my/limits';
  static const String checkout = '/subscriptions/checkout';
  static const String upgradeSubscription = '/subscriptions/my/upgrade';
  static const String cancelSubscription = '/subscriptions/my/cancel';
  
  // Payments
  static const String myPayments = '/payments/my';
  static String paymentReceipt(String id) => '/payments/$id/receipt';
  static String paymentInvoice(String id) => '/payments/$id/invoice';
  static String resendPaymentReceipt(String id) => '/payments/$id/resend-receipt';
  
  // Notifications
  static const String myNotifications = '/notifications/my';
  static const String unreadCount = '/notifications/unread-count';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsAsRead = '/notifications/mark-all-read';
  static String deleteNotification(String id) => '/notifications/$id';
  
  // Courses
  static const String courses = '/courses';
  static String courseById(String id) => '/courses/$id';
  static String enrollInCourse(String id) => '/courses/$id/enroll';
  static const String myEnrollments = '/courses/my-enrollments';
}

class NavigationRoutes {
  // Public screens
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String serviceTypes = '/service-types';
  static const String serviceTypeDetail = '/service-type-detail';
  static const String faqs = '/faqs';
  static const String news = '/news';
  static const String newsDetail = '/news-detail';
  static const String subscriptionPlans = '/subscription-plans';
  
  // Customer screens
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String familyMembers = '/family-members';
  static const String addFamilyMember = '/add-family-member';
  static const String editFamilyMember = '/edit-family-member';
  static const String serviceRequests = '/service-requests';
  static const String createServiceRequest = '/create-service-request';
  static const String serviceRequestDetail = '/service-request-detail';
  static const String documents = '/documents';
  static const String uploadDocuments = '/upload-documents';
  static const String appointments = '/appointments';
  static const String bookAppointment = '/book-appointment';
  static const String appointmentDetail = '/appointment-detail';
  static const String subscription = '/subscription';
  static const String payments = '/payments';
  static const String paymentDetail = '/payment-detail';
  static const String notifications = '/notifications';
  static const String courses = '/courses';
  static const String courseDetail = '/course-detail';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String gdprSettings = '/gdpr-settings';
}

enum HttpMethod { get, post, put, patch, delete }

class RouteConfig {
  final String endpoint;
  final HttpMethod method;
  final bool requiresAuth;
  final Map<String, String>? headers;
  
  const RouteConfig({
    required this.endpoint,
    required this.method,
    this.requiresAuth = false,
    this.headers,
  });
}