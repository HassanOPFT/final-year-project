import 'package:flutter/material.dart';
import 'package:prime/models/car.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/issue_report.dart';
import 'package:prime/models/stripe_transaction.dart';
import 'package:prime/models/user.dart';
import 'package:prime/providers/car_rental_provider.dart';
import 'package:prime/providers/issue_report_provider.dart';
import 'package:prime/providers/notification_provider.dart';
import 'package:prime/services/firebase/firebase_auth_service.dart';
import 'package:prime/services/stripe/stripe_charge_service.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/admin/admin_users_screen.dart';
import 'package:prime/views/cars/admin_cars_screen.dart';
import 'package:prime/views/home/notification_screen.dart';
import 'package:prime/views/rentals/admin_rentals_screen.dart';
import 'package:prime/widgets/card/issue_report_progress_indicator.dart';
import 'package:provider/provider.dart';

import '../../models/stripe_charge.dart';
import '../../providers/car_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/stripe/stripe_transaction_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/card/progress_indicator_with_legend.dart';
import '../../widgets/card/revenue_dashboard_card.dart';
import '../../widgets/card/total_dashboard_card.dart';
import '../../widgets/navigation_bar/admin_navigation_bar.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future<Map<String, dynamic>> getAllFinance(
        List<String?> chargesList) async {
      final stripeChargeService = StripeChargeService();
      List<StripeCharge> stripeChargesList = [];
      for (final chargeId in chargesList) {
        final charge = await stripeChargeService.getChargeDetails(
            chargeId: chargeId ?? '');
        stripeChargesList.add(charge);
      }
      final stripeTransactionService = StripeTransactionService();
      List<StripeTransaction> stripeTransactionList = [];
      for (final charge in stripeChargesList) {
        final transaction =
            await stripeTransactionService.getBalanceTransactionDetails(
                transactionId: charge.balanceTransactionId ?? '');
        stripeTransactionList.add(transaction);
      }
      double platformRevenue = 0;
      double hostsEarnings = 0;
      double stripeFees = 0;
      double totalMoneyTransferred = 0;
      for (final transaction in stripeTransactionList) {
        stripeFees += transaction.fee;
        totalMoneyTransferred += transaction.amount;
      }
      hostsEarnings = totalMoneyTransferred * 0.85;
      platformRevenue = totalMoneyTransferred - hostsEarnings - stripeFees;

      return {
        'platformRevenue': platformRevenue,
        'hostsEarnings': hostsEarnings,
        'stripeFees': stripeFees,
      };
    }

    Future<List<CarStatus>> getCarsWithStatus() async {
      final carProvider = Provider.of<CarProvider>(context, listen: false);
      final carStatuses = await carProvider.getCarStatuses();
      return carStatuses;
    }

    Future<List<CarRental>> getCarRentals() async {
      final carRentalProvider =
          Provider.of<CarRentalProvider>(context, listen: false);
      final rentalStatuses = await carRentalProvider.getCarRentalsByStatuses(
        [
          CarRentalStatus.rentedByCustomer,
          CarRentalStatus.pickedUpByCustomer,
          CarRentalStatus.customerReportedIssue,
          CarRentalStatus.customerExtendedRental,
          CarRentalStatus.customerReturnedCar,
          CarRentalStatus.hostConfirmedPickup,
          CarRentalStatus.customerCancelled,
          CarRentalStatus.hostCancelled,
          CarRentalStatus.hostReportedIssue,
          CarRentalStatus.hostConfirmedReturn,
          CarRentalStatus.adminConfirmedPayout,
          CarRentalStatus.adminConfirmedRefund,
        ],
      );
      return rentalStatuses;
    }

    Future<List<UserRole>> getUsersWithRoles() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final usersWithRoles = await userProvider.getUsersRoles();
      return usersWithRoles;
    }

    Future<List<IssueReportStatus>> getIssueReportsWithStatus() async {
      final issueReportProvider =
          Provider.of<IssueReportProvider>(context, listen: false);
      final issueReportsWithStatus =
          await issueReportProvider.getIssueReportsStatuses();
      return issueReportsWithStatus;
    }

    Future<Map<String, dynamic>> fetchAllData() async {
      final combinedFutures = await Future.wait([
        getCarsWithStatus(),
        getCarRentals(),
        getUsersWithRoles(),
        getIssueReportsWithStatus(),
      ]);

      final currentUserId = FirebaseAuthService().currentUser?.uid ?? '';

      final carsWithStatus = combinedFutures[0];
      final List<CarRental> carRentals = combinedFutures[1] as List<CarRental>;
      final usersWithRoles = combinedFutures[2];
      final issueReportsWithStatuses = combinedFutures[3];

      final stripeChargesList =
          carRentals.map((carRental) => carRental.stripeChargeId).toList();
      final allFinance = await getAllFinance(stripeChargesList);

      return {
        'totalCars': carsWithStatus.length,
        'carRentals': carRentals.length,
        'totalUsers': usersWithRoles.length,
        ...allFinance,
        'issueReportsWithStatuses': issueReportsWithStatuses,
        'currentUserId': currentUserId,
      };
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: fetchAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const AppLogo(height: 120),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const AppLogo(height: 120),
              automaticallyImplyLeading: false,
            ),
            body: const Center(
              child: Text('Error fetching data'),
            ),
          );
        } else if (snapshot.hasData) {
          final data = snapshot.data!;

          final totalCars = data['totalCars'];
          final carRentals = data['carRentals'];
          final totalUsers = data['totalUsers'];
          final platformRevenue = data['platformRevenue'];
          final hostsEarnings = data['hostsEarnings'];
          final stripeFees = data['stripeFees'];
          final issueReportsWithStatuses = data['issueReportsWithStatuses'];
          final String currentUserId = data['currentUserId'];

          // calculate how many issue reports are in each status
          int open = 0;
          int inProgress = 0;
          int resolved = 0;
          int closed = 0;
          for (final issueReport in issueReportsWithStatuses) {
            switch (issueReport) {
              case IssueReportStatus.open:
                open++;
                break;
              case IssueReportStatus.inProgress:
                inProgress++;
                break;
              case IssueReportStatus.resolved:
                resolved++;
                break;
              case IssueReportStatus.closed:
                closed++;
                break;
            }
          }

          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const AppLogo(height: 120),
              automaticallyImplyLeading: false,
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded),
                      onPressed: () => animatedPushNavigation(
                        context: context,
                        screen: NotificationScreen(userId: currentUserId),
                      ),
                    ),
                    Consumer<NotificationProvider>(
                      builder: (_, notificationProvider, __) {
                        return FutureBuilder(
                          future: notificationProvider
                              .hasUnreadNotification(currentUserId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            } else if (snapshot.hasError) {
                              return const SizedBox();
                            } else if (snapshot.hasData) {
                              final hasUnread = snapshot.data as bool;

                              if (hasUnread) {
                                return Positioned(
                                  top: 5.0,
                                  right: 8.0,
                                  child: Container(
                                    width: 12.0,
                                    height: 12.0,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            } else {
                              return const SizedBox();
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RevenueDashboardCard(
                          icon: Icons.attach_money,
                          value: 'RM${platformRevenue.toStringAsFixed(2)}',
                          title: 'Revenue',
                          backgroundColor: Colors.green.shade100,
                          iconColor: Colors.green.shade900,
                          valueColor: Colors.green.shade900,
                          titleColor: Colors.green.shade900,
                          aspectRatio: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200.0,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => animatedPushReplacementNavigation(
                            context: context,
                            screen: const AdminCarsScreen(),
                          ),
                          child: TotalDashboardCard(
                            icon: Icons.directions_car,
                            value: '$totalCars',
                            title: 'Total Cars',
                            backgroundColor: Colors.blue.shade100,
                            iconColor: Colors.blue.shade900,
                            valueColor: Colors.blue.shade900,
                            titleColor: Colors.blue.shade900,
                            aspectRatio: 1,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => animatedPushReplacementNavigation(
                              context: context,
                              screen: const AdminRentalsScreen(),
                            ),
                            child: TotalDashboardCard(
                              icon: Icons.car_rental,
                              value: '$carRentals',
                              title: 'Car Rentals',
                              backgroundColor: Colors.purple.shade100,
                              iconColor: Colors.purple.shade900,
                              valueColor: Colors.purple.shade900,
                              titleColor: Colors.purple.shade900,
                              aspectRatio: 1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => animatedPushReplacementNavigation(
                              context: context,
                              screen: const AdminUsersScreen(),
                            ),
                            child: TotalDashboardCard(
                              icon: Icons.people,
                              value: '$totalUsers',
                              title: 'Total Users',
                              backgroundColor: Colors.lime.shade100,
                              iconColor: Colors.lime.shade900,
                              valueColor: Colors.lime.shade900,
                              titleColor: Colors.lime.shade900,
                              aspectRatio: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Divider(),
                  ),
                  ProgressIndicatorWithLegend(
                    platformRevenue: platformRevenue,
                    hostsEarnings: hostsEarnings,
                    stripeFees: stripeFees,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: Divider(),
                  ),
                  GestureDetector(
                    onTap: () => animatedPushReplacementNavigation(
                      context: context,
                      screen: const AdminRentalsScreen(
                        initialTab: 2,
                      ),
                    ),
                    child: IssueReportProgressIndicator(
                      open: open,
                      inProgress: inProgress,
                      resolved: resolved,
                      closed: closed,
                      openColor: Colors.blue,
                      inProgressColor: Colors.orange,
                      resolvedColor: Colors.green,
                      closedColor: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            bottomNavigationBar: const AdminNavigationBar(currentIndex: 0),
          );
        } else {
          return const Center(child: Text('No data available'));
        }
      },
    );
  }
}
