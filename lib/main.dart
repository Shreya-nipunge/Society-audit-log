import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/member/screens/member_dashboard.dart';
import 'features/member/screens/payment_history_screen.dart';
import 'features/member/screens/profile_screen.dart';
import 'features/member/screens/my_dues_screen.dart';
import 'features/billing/screens/generate_bills_screen.dart';
import 'features/admin/screens/bulk_import_screen.dart';
import 'features/payments/screens/allocation_editor.dart';
import 'features/admin/screens/system_health_screen.dart';
import 'features/audit/screens/document_upload_screen.dart';
import 'features/audit/screens/record_expense_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/admin/screens/chairman_dashboard.dart';
import 'features/admin/screens/add_member_screen.dart';
import 'features/admin/screens/member_list_screen.dart';
import 'features/admin/screens/treasurer_dashboard.dart';
import 'features/audit/screens/audit_log_screen.dart';
import 'features/audit/screens/document_list_screen.dart';
import 'features/payments/screens/record_payment_screen.dart';
import 'features/notices/screens/notice_detail_screen.dart';
import 'features/notices/screens/notice_list_screen.dart';
import 'features/notices/screens/create_notice_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/complaints/screens/submit_complaint_screen.dart';
import 'features/complaints/screens/my_complaints_screen.dart';
import 'features/complaints/screens/admin_complaints_screen.dart';
import 'features/auth/models/user_model.dart';
import 'features/notices/models/notice_model.dart';
import 'core/guards/role_guard.dart';
import 'core/widgets/error_boundary.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SocietyAuditLogApp());
}

class SocietyAuditLogApp extends StatelessWidget {
  const SocietyAuditLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/member-dashboard': (context) => const RoleGuard(
            allowedRoles: [UserRole.member],
            child: MemberDashboard(),
          ),
          '/payment-history': (context) => const RoleGuard(
            allowedRoles: [UserRole.member],
            child: PaymentHistoryScreen(),
          ),
          '/my-dues': (context) => const RoleGuard(
            allowedRoles: [UserRole.member],
            child: MyDuesScreen(),
          ),
          '/profile': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.member,
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: MemberProfileScreen(),
          ),
          '/generate-bills': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.treasurer],
            child: GenerateBillsScreen(),
          ),
          '/upload-document': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.secretary],
            child: DocumentUploadScreen(),
          ),
          '/reports': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.treasurer,
              UserRole.secretary,
            ],
            child: ReportsScreen(),
          ),
          '/admin-dashboard': (context) => const RoleGuard(
            allowedRoles: [UserRole.secretary],
            child: AdminDashboard(),
          ),
          '/chairman-dashboard': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman],
            child: ChairmanDashboard(),
          ),
          '/add-member': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: AddMemberScreen(),
          ),
          '/member-list': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: MemberListScreen(),
          ),
          '/treasurer-dashboard': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.treasurer,
              UserRole.secretary,
            ],
            child: TreasurerDashboard(),
          ),
          '/audit-logs': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: AuditLogScreen(),
          ),
          '/record-payment': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: RecordPaymentScreen(),
          ),
          '/document-list': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.member,
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: DocumentListScreen(),
          ),
          '/bulk-import': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.secretary],
            child: BulkImportScreen(),
          ),
          '/allocation-editor': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.treasurer],
            child: AllocationEditorScreen(),
          ),
          '/system-health': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.secretary],
            child: SystemHealthScreen(),
          ),
          '/record-expense': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: RecordExpenseScreen(),
          ),
          '/notice-detail': (context) {
            final notice =
                ModalRoute.of(context)!.settings.arguments
                    as NoticeModel;
            return NoticeDetailScreen(notice: notice);
          },
          '/notice-list': (context) => const RoleGuard(
            allowedRoles: [
              UserRole.chairman,
              UserRole.secretary,
              UserRole.treasurer,
            ],
            child: NoticeListScreen(),
          ),
          '/create-notice': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.secretary],
            child: CreateNoticeScreen(),
          ),
          '/my-complaints': (context) => const RoleGuard(
            allowedRoles: [UserRole.member],
            child: MyComplaintsScreen(),
          ),
          '/submit-complaint': (context) => const RoleGuard(
            allowedRoles: [UserRole.member],
            child: SubmitComplaintScreen(),
          ),
          '/admin-complaints': (context) => const RoleGuard(
            allowedRoles: [UserRole.chairman, UserRole.secretary, UserRole.treasurer],
            child: AdminComplaintsScreen(),
          ),
        },
      ),
    );
  }
}
