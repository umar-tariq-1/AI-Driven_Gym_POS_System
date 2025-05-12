import 'package:flutter/material.dart';
import 'package:gym_ease/widgets/pages/client/ai_buddy/ai_buddy_page.dart';
import 'package:gym_ease/widgets/pages/client/book%20classes/book_classes.dart';
import 'package:gym_ease/widgets/pages/client/home_page.dart';
import 'package:gym_ease/widgets/pages/client/live_classes/live_classes.dart';
import 'package:gym_ease/widgets/pages/client/notifications/notifications.dart';
import 'package:gym_ease/widgets/pages/client/shop_products/shop_products_page.dart';
import 'package:gym_ease/widgets/pages/landing_page.dart';
import 'package:gym_ease/widgets/pages/manager/home_page.dart';
import 'package:gym_ease/widgets/pages/manager/point_of_sales/point_of_sales_page.dart';
import 'package:gym_ease/widgets/pages/owner/home_page.dart';
import 'package:gym_ease/widgets/pages/owner/register_gym/register_gym.dart';
import 'package:gym_ease/widgets/pages/owner/point_of_sales/create_product.dart';
import 'package:gym_ease/widgets/pages/owner/point_of_sales/point_of_sales_page.dart';
import 'package:gym_ease/widgets/pages/sign/forget_passsword_page.dart';
import 'package:gym_ease/widgets/pages/sign/register_page.dart';
import 'package:gym_ease/widgets/pages/sign/signin_page.dart';
import 'package:gym_ease/widgets/pages/trainer/dashboard_page.dart';
import 'package:gym_ease/widgets/pages/trainer/live_classes/live_classes.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/create_class.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/manage_classes_page.dart';
import 'package:gym_ease/widgets/pages/welcome_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  // Main Routes
  WelcomePage.routePath: (context) => const WelcomePage(),
  RegisterPage.routePath: (context) => const RegisterPage(),
  SigninPage.routePath: (context) => const SigninPage(),
  ForgetPasswordPage.routePath: (context) =>
      ForgetPasswordPage(email: "No Email Entered"),
  LandingPage.routePath: (context) => const LandingPage(),

  // Client Routes
  ClientHomePage.routePath: (context) => const ClientHomePage(),
  BookClassesPage.routePath: (context) => const BookClassesPage(),
  ClientLiveClassesPage.routePath: (context) => const ClientLiveClassesPage(),
  AIBuddyPage.routePath: (context) => const AIBuddyPage(),
  ShopProductsPage.routePath: (context) => const ShopProductsPage(),
  NotificationsPage.routePath: (context) => const NotificationsPage(),

  // Trainer Routes
  TrainerDashboardPage.routePath: (context) => const TrainerDashboardPage(),
  ManageClassesPage.routePath: (context) => const ManageClassesPage(),
  CreateClassPage.routePath: (context) => const CreateClassPage(),
  TrainerLiveClassesPage.routePath: (context) => const TrainerLiveClassesPage(),

  // Owner Routes
  OwnerHomePage.routePath: (context) => const OwnerHomePage(),
  OwnerPointOfSalesPage.routePath: (context) => const OwnerPointOfSalesPage(),
  CreatePOSProductPage.routePath: (context) => const CreatePOSProductPage(),
  OwnerRegisterGymPage.routePath: (context) => const OwnerRegisterGymPage(),

  // Manager Routes
  ManagerHomePage.routePath: (context) => const ManagerHomePage(),
  ManagerPointOfSalesPage.routePath: (context) =>
      const ManagerPointOfSalesPage(),
};
