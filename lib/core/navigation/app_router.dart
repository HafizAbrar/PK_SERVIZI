import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/sign_in_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/reset_password_screen.dart';
import '../../features/auth/presentation/pages/change_password_screen.dart';
import '../../features/home/presentation/pages/main_navigation_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/profile/presentation/pages/edit_profile_screen.dart';
import '../../features/appointments/presentation/pages/appointments_screen.dart';
import '../../features/appointments/presentation/pages/book_appointment_screen.dart';
import '../../features/documents/presentation/pages/documents_screen.dart';
import '../../features/documents/presentation/pages/document_upload_screen.dart';
import '../../features/requests/presentation/pages/service_request_detail_screen.dart';
import '../../features/requests/presentation/pages/service_requests_screen.dart';
import '../../features/requests/presentation/pages/create_service_request_screen.dart';
import '../../features/requests/presentation/pages/request_submission_screen.dart';
import '../../features/notifications/presentation/pages/notifications_screen.dart';
import '../../features/payments/presentation/pages/payments_screen.dart';
import '../../features/payments/presentation/pages/payment_detail_screen.dart';
import '../../features/payments/presentation/pages/payment_checkout_screen.dart';
import '../../features/payments/presentation/pages/payment_success_screen.dart';
import '../../features/subscriptions/presentation/pages/subscription_screen.dart';
import '../../features/subscriptions/presentation/pages/subscription_plans_screen.dart';
import '../../features/subscriptions/presentation/pages/subscription_plan_details_screen.dart';
import '../../features/courses/presentation/pages/courses_screen.dart';
import '../../features/services/presentation/pages/services_screen.dart';
import '../../features/services/presentation/pages/service_detail_screen.dart';
import '../../features/services/presentation/pages/services_by_type_screen.dart';
import '../../features/services/presentation/pages/service_request_form_screen.dart';


class RoutePaths {
  // Public routes
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // Public content
  static const String serviceTypes = '/service-types';
  static const String serviceTypeDetail = '/service-types/:id';
  static const String subscriptionPlans = '/subscription-plans';
  static const String subscriptionPlanDetails = '/subscription-plan-details/:planId';
  static const String faqs = '/faqs';
  static const String news = '/news';
  static const String newsDetail = '/news/:id';
  static const String page = '/page/:slug';
  
  // Customer dashboard (main navigation)
  static const String dashboard = '/home';
  static const String home = '/home';
  
  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String securitySuccess = '/security-success';
  static const String gdprSettings = '/profile/gdpr';
  
  // Family members
  static const String familyMembers = '/family-members';
  static const String addFamilyMember = '/family-members/add';
  static const String editFamilyMember = '/family-members/:id/edit';
  static const String familyMemberDetail = '/family-members/:id';
  
  // Service requests
  static const String serviceRequests = '/service-requests';
  static const String createServiceRequest = '/service-requests/create';
  static const String serviceRequestDetail = '/service-requests/:id';
  static const String editServiceRequest = '/service-requests/:id/edit';
  
  // Documents
  static const String documents = '/documents';
  static const String documentUpload = '/document-upload';
  static const String documentsByRequest = '/documents/request/:requestId';
  
  // Request submission
  static const String requestSubmission = '/request-submission';
  
  // Appointments
  static const String appointments = '/appointments';
  static const String bookAppointment = '/appointments/book';
  static const String appointmentDetail = '/appointments/:id';
  static const String rescheduleAppointment = '/appointments/:id/reschedule';
  
  // Subscription & payments
  static const String subscription = '/subscription';
  static const String subscriptionUpgrade = '/subscription/upgrade';
  static const String payments = '/payments';
  static const String paymentDetail = '/payments/:id';
  static const String paymentCheckout = '/payment-checkout';
  static const String paymentSuccess = '/payment-success';
  static const String checkout = '/checkout';
  
  // Notifications
  static const String notifications = '/notifications';
  
  // Services
  static const String services = '/services';
  static const String serviceDetail = '/services/:id';
  static const String serviceRequestForm = '/service-request-form/:serviceId';
  static const String servicesByType = '/services/by-type/:serviceTypeId';
  
  // Courses
  static const String courses = '/courses';
  static const String courseDetail = '/courses/:id';
  static const String myEnrollments = '/courses/my-enrollments';
  
  // Settings
  static const String settings = '/settings';
}

class AppRouter {
  static const _storage = FlutterSecureStorage();
  
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      // Public routes
      GoRoute(path: RoutePaths.splash, name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: RoutePaths.onboarding, name: 'onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: RoutePaths.login, name: 'login', builder: (context, state) => const SignInScreen()),
      GoRoute(path: '/signin', name: 'signin', builder: (context, state) => const SignInScreen()), // Alias for login
      GoRoute(path: RoutePaths.register, name: 'register', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: RoutePaths.forgotPassword, name: 'forgot-password', builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: RoutePaths.resetPassword, name: 'reset-password', builder: (context, state) => ResetPasswordScreen(token: state.uri.queryParameters['token'] ?? '')),
      
      // Public content
      GoRoute(path: RoutePaths.serviceTypes, name: 'service-types', builder: (context, state) => const PlaceholderScreen(title: 'Service Types')),
      GoRoute(path: RoutePaths.serviceTypeDetail, name: 'service-type-detail', builder: (context, state) => PlaceholderScreen(title: 'Service Type Detail: ${state.pathParameters['id']}')),
      GoRoute(path: RoutePaths.subscriptionPlans, name: 'subscription-plans', builder: (context, state) => const SubscriptionPlansScreen()),
      GoRoute(path: RoutePaths.subscriptionPlanDetails, name: 'subscription-plan-details', builder: (context, state) => SubscriptionPlanDetailsScreen(planId: state.pathParameters['planId']!)),
      GoRoute(path: RoutePaths.faqs, name: 'faqs', builder: (context, state) => const PlaceholderScreen(title: 'FAQs')),
      GoRoute(path: RoutePaths.news, name: 'news', builder: (context, state) => const PlaceholderScreen(title: 'News')),
      GoRoute(path: RoutePaths.newsDetail, name: 'news-detail', builder: (context, state) => PlaceholderScreen(title: 'News Detail: ${state.pathParameters['id']}')),
      GoRoute(path: RoutePaths.page, name: 'page', builder: (context, state) => PlaceholderScreen(title: 'Page: ${state.pathParameters['slug']}')),
      
      // Authenticated routes - Main Navigation
      GoRoute(path: RoutePaths.home, name: 'home', builder: (context, state) => const MainNavigationScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.dashboard, name: 'dashboard', builder: (context, state) => const MainNavigationScreen(), redirect: _authGuard),
      
      // Profile
      GoRoute(path: RoutePaths.profile, name: 'profile', builder: (context, state) => const ProfileScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.editProfile, name: 'edit-profile', builder: (context, state) => const EditProfileScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.changePassword, name: 'change-password', builder: (context, state) => const ChangePasswordScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.securitySuccess, name: 'security-success', builder: (context, state) => const SecuritySuccessScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.gdprSettings, name: 'gdpr-settings', builder: (context, state) => const GdprSettingsScreen(), redirect: _authGuard),
      
      // Family members
      GoRoute(path: RoutePaths.familyMembers, name: 'family-members', builder: (context, state) => const FamilyMembersScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.addFamilyMember, name: 'add-family-member', builder: (context, state) => const AddFamilyMemberScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.editFamilyMember, name: 'edit-family-member', builder: (context, state) => EditFamilyMemberScreen(memberId: state.pathParameters['id']!), redirect: _authGuard),
      GoRoute(path: RoutePaths.familyMemberDetail, name: 'family-member-detail', builder: (context, state) => FamilyMemberDetailScreen(memberId: state.pathParameters['id']!), redirect: _authGuard),
      
      // Service requests
      GoRoute(path: RoutePaths.serviceRequests, name: 'service-requests', builder: (context, state) => const ServiceRequestsScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.createServiceRequest, name: 'create-service-request', builder: (context, state) => CreateServiceRequestScreen(serviceId: state.uri.queryParameters['serviceId']), redirect: _authGuard),
      GoRoute(path: RoutePaths.serviceRequestDetail, name: 'service-request-detail', builder: (context, state) => ServiceRequestDetailScreenNew(requestId: state.pathParameters['id']!), redirect: _authGuard),
      GoRoute(path: RoutePaths.editServiceRequest, name: 'edit-service-request', builder: (context, state) => EditServiceRequestScreen(requestId: state.pathParameters['id']!), redirect: _authGuard),
      
      // Documents
      GoRoute(path: RoutePaths.documents, name: 'documents', builder: (context, state) => const DocumentsScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.documentUpload, name: 'document-upload', builder: (context, state) => DocumentUploadScreen(
        serviceId: state.uri.queryParameters['serviceId']!,
        requestId: state.uri.queryParameters['requestId']!,
      ), redirect: _authGuard),
      GoRoute(path: RoutePaths.documentsByRequest, name: 'documents-by-request', builder: (context, state) => DocumentsByRequestScreen(requestId: state.pathParameters['requestId']!), redirect: _authGuard),
      
      // Request submission
      GoRoute(path: RoutePaths.requestSubmission, name: 'request-submission', builder: (context, state) => RequestSubmissionScreen(
        requestId: state.uri.queryParameters['requestId']!,
      ), redirect: _authGuard),
      
      // Appointments
      GoRoute(path: RoutePaths.appointments, name: 'appointments', builder: (context, state) => const AppointmentsScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.bookAppointment, name: 'book-appointment', builder: (context, state) => BookAppointmentScreen(serviceTypeId: state.uri.queryParameters['serviceTypeId']), redirect: _authGuard),
      GoRoute(path: RoutePaths.appointmentDetail, name: 'appointment-detail', builder: (context, state) => AppointmentDetailScreen(appointmentId: state.pathParameters['id']!), redirect: _authGuard),
      GoRoute(path: RoutePaths.rescheduleAppointment, name: 'reschedule-appointment', builder: (context, state) => RescheduleAppointmentScreen(appointmentId: state.pathParameters['id']!), redirect: _authGuard),
      
      // Subscription & payments
      GoRoute(path: RoutePaths.subscription, name: 'subscription', builder: (context, state) => const SubscriptionScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.subscriptionUpgrade, name: 'subscription-upgrade', builder: (context, state) => const SubscriptionUpgradeScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.payments, name: 'payments', builder: (context, state) => const PaymentsScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.paymentDetail, name: 'payment-detail', builder: (context, state) => PaymentDetailScreen(paymentId: state.pathParameters['id']!), redirect: _authGuard),
      GoRoute(path: RoutePaths.paymentCheckout, name: 'payment-checkout', builder: (context, state) => PaymentCheckoutScreen(
        paymentUrl: state.uri.queryParameters['url']!,
        serviceRequestId: state.uri.queryParameters['serviceRequestId'],
      )),
      GoRoute(path: RoutePaths.paymentSuccess, name: 'payment-success', builder: (context, state) => PaymentSuccessScreen(
        requestId: state.uri.queryParameters['requestId'],
        serviceId: state.uri.queryParameters['serviceId'],
      )),

      // Notifications
      GoRoute(path: RoutePaths.notifications, name: 'notifications', builder: (context, state) => const NotificationsScreen(), redirect: _authGuard),
      
      // Services
      GoRoute(path: RoutePaths.services, name: 'services', builder: (context, state) => const ServicesScreen()),
      GoRoute(path: RoutePaths.serviceDetail, name: 'service-detail', builder: (context, state) => ServiceDetailScreen(serviceId: state.pathParameters['id']!)),
      GoRoute(path: RoutePaths.serviceRequestForm, name: 'service-request-form', builder: (context, state) => ServiceRequestFormScreen(
        serviceId: state.pathParameters['serviceId']!,
        serviceRequestId: state.uri.queryParameters['serviceRequestId'],
      )),
      GoRoute(path: RoutePaths.servicesByType, name: 'services-by-type', builder: (context, state) => ServicesByTypeScreen(serviceTypeId: state.pathParameters['serviceTypeId']!)),
      
      // Courses
      GoRoute(path: RoutePaths.courses, name: 'courses', builder: (context, state) => const CoursesScreen(), redirect: _authGuard),
      GoRoute(path: RoutePaths.courseDetail, name: 'course-detail', builder: (context, state) => CourseDetailScreen(courseId: state.pathParameters['id']!), redirect: _authGuard),
      GoRoute(path: RoutePaths.myEnrollments, name: 'my-enrollments', builder: (context, state) => const MyEnrollmentsScreen(), redirect: _authGuard),
      
      // Settings
      GoRoute(path: RoutePaths.settings, name: 'settings', builder: (context, state) => const SettingsScreen(), redirect: _authGuard),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
  
  static Future<String?> _authGuard(BuildContext context, GoRouterState state) async {
    final token = await _storage.read(key: 'access_token');
    return token == null ? RoutePaths.login : null;
  }
}

class AppNavigation {
  static final GoRouter _router = AppRouter.router;
  
  static void go(String path) => _router.go(path);
  static void push(String path) => _router.push(path);
  static void pop() => _router.pop();
  static void replace(String path) => _router.pushReplacement(path);
  
  static void goNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    _router.goNamed(name, pathParameters: pathParameters ?? {}, queryParameters: queryParameters ?? {});
  }
  
  static void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    _router.pushNamed(name, pathParameters: pathParameters ?? {}, queryParameters: queryParameters ?? {});
  }
  
  // Specific navigation methods
  static void goToLogin() => goNamed('login');
  static void goToSignIn() => goNamed('login'); // Alias for login
  static void goToDashboard() => goNamed('home');
  static void goToHome() => goNamed('home');
  static void goToProfile() => goNamed('profile');
  static void goToServiceTypeDetail(String serviceTypeId) => goNamed('service-type-detail', pathParameters: {'id': serviceTypeId});
  static void goToServiceRequestDetail(String requestId) => goNamed('service-request-detail', pathParameters: {'id': requestId});
  static void goToCreateServiceRequest({String? serviceTypeId}) => goNamed('create-service-request', queryParameters: {if (serviceTypeId != null) 'serviceTypeId': serviceTypeId});
  static void goToAppointmentDetail(String appointmentId) => goNamed('appointment-detail', pathParameters: {'id': appointmentId});
  static void goToBookAppointment({String? serviceTypeId}) => goNamed('book-appointment', queryParameters: {if (serviceTypeId != null) 'serviceTypeId': serviceTypeId});
  static void goToUploadDocuments({String? requestId}) => goNamed('upload-documents', queryParameters: {if (requestId != null) 'requestId': requestId});
  static void goToCheckout({String? planId}) => goNamed('checkout', queryParameters: {if (planId != null) 'planId': planId});
}

// Placeholder screens - these will be replaced by actual implementations
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text(title)),
  );
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Onboarding Screen')));
}

class SecuritySuccessScreen extends StatefulWidget {
  const SecuritySuccessScreen({super.key});
  @override
  State<SecuritySuccessScreen> createState() => _SecuritySuccessScreenState();
}

class _SecuritySuccessScreenState extends State<SecuritySuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/profile');
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Success')),
    body: const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 64),
          SizedBox(height: 16),
          Text('Password changed successfully!', style: TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );
}

class GdprSettingsScreen extends StatelessWidget {
  const GdprSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('GDPR Settings Screen')));
}

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Family Members Screen')));
}

class AddFamilyMemberScreen extends StatelessWidget {
  const AddFamilyMemberScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Add Family Member Screen')));
}

class EditFamilyMemberScreen extends StatelessWidget {
  final String memberId;
  const EditFamilyMemberScreen({super.key, required this.memberId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Edit Family Member: $memberId')));
}

class FamilyMemberDetailScreen extends StatelessWidget {
  final String memberId;
  const FamilyMemberDetailScreen({super.key, required this.memberId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Family Member Detail: $memberId')));
}

class EditServiceRequestScreen extends StatelessWidget {
  final String requestId;
  const EditServiceRequestScreen({super.key, required this.requestId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Edit Service Request: $requestId')));
}

class DocumentsByRequestScreen extends StatelessWidget {
  final String requestId;
  const DocumentsByRequestScreen({super.key, required this.requestId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Documents by Request: $requestId')));
}

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Appointment Detail: $appointmentId')));
}

class RescheduleAppointmentScreen extends StatelessWidget {
  final String appointmentId;
  const RescheduleAppointmentScreen({super.key, required this.appointmentId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Reschedule Appointment: $appointmentId')));
}

class SubscriptionUpgradeScreen extends StatelessWidget {
  const SubscriptionUpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) => const SubscriptionPlansScreen();
}

class CourseDetailScreen extends StatelessWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Course Detail: $courseId')));
}

class MyEnrollmentsScreen extends StatelessWidget {
  const MyEnrollmentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('My Enrollments Screen')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Settings Screen')));
}

class ErrorScreen extends StatelessWidget {
  final Exception? error;
  const ErrorScreen({super.key, this.error});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Error: ${error?.toString() ?? 'Unknown error'}')));
}