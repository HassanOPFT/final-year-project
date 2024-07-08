import 'package:prime/controllers/car_controller.dart';
import 'package:prime/controllers/car_rental_controller.dart';
import 'package:prime/models/car.dart';
import 'package:prime/models/car_rental.dart';
import 'package:prime/models/stripe_charge.dart';

import '../models/stripe_transaction.dart';
import '../services/stripe/stripe_charge_service.dart';
import '../services/stripe/stripe_transaction_service.dart';

class FinanceUtil {
  final CarController _carController = CarController();
  final CarRentalController _carRentalController = CarRentalController();
  final StripeChargeService _stripeChargeService = StripeChargeService();
  final StripeTransactionService _stripeTransactionService =
      StripeTransactionService();

  Future<double> getTotalHostRevenueByHostId(String hostId) async {
    double totalRevenue = 0.0;
    try {
      final List<Car> cars = await _carController.getCarsByHostId(hostId);
      for (final car in cars) {
        final List<CarRental> carRentals =
            await _carRentalController.getCarRentalsByCarId(
          car.id ?? '',
        );

        // Filter out the car rentals with customerCancelled or adminConfirmedRefund status
        final List<CarRental> validCarRentals = carRentals.where((carRental) {
          return carRental.status != CarRentalStatus.customerCancelled &&
              carRental.status != CarRentalStatus.adminConfirmedRefund;
        }).toList();

        for (final carRental in validCarRentals) {
          final StripeCharge stripeCharge =
              await _stripeChargeService.getChargeDetails(
            chargeId: carRental.stripeChargeId ?? '',
          );
          final StripeTransaction stripeTransaction =
              await _stripeTransactionService.getBalanceTransactionDetails(
            transactionId: stripeCharge.balanceTransactionId ?? '',
          );
          totalRevenue += stripeTransaction.amount;
        }
      }
      return totalRevenue * 0.85;
    } catch (_) {
      rethrow;
    }
  }

  // Future<double> getTotalHostRevenueByHostId(String hostId) async {
  //   double totalRevenue = 0.0;
  //   try {
  //     final List<Car> cars = await _carController.getCarsByHostId(hostId);
  //     for (final car in cars) {
  //       final List<CarRental> carRentals =
  //           await _carRentalController.getCarRentalsByCarId(
  //         car.id ?? '',
  //       );
  //       for (final carRental in carRentals) {
  //         final StripeCharge stripeCharge =
  //             await _stripeChargeService.getChargeDetails(
  //           chargeId: carRental.stripeChargeId ?? '',
  //         );
  //         final StripeTransaction stripeTransaction =
  //             await _stripeTransactionService.getBalanceTransactionDetails(
  //           transactionId: stripeCharge.balanceTransactionId ?? '',
  //         );
  //         totalRevenue += stripeTransaction.amount;
  //       }
  //     }
  //     return totalRevenue * 0.85;
  //   } catch (_) {
  //     rethrow;
  //   }
  // }

  Future<double> getTotalHostRevenueByCarId(String carId) async {
    double totalRevenue = 0.0;
    try {
      final List<CarRental> carRentals =
          await _carRentalController.getCarRentalsByCarId(
        carId,
      );

      // Filter out the car rentals with customerCancelled or adminConfirmedRefund status
      final List<CarRental> validCarRentals = carRentals.where((carRental) {
        return carRental.status != CarRentalStatus.customerCancelled &&
            carRental.status != CarRentalStatus.adminConfirmedRefund;
      }).toList();

      for (final carRental in validCarRentals) {
        final StripeCharge stripeCharge =
            await _stripeChargeService.getChargeDetails(
          chargeId: carRental.stripeChargeId ?? '',
        );
        final StripeTransaction stripeTransaction =
            await _stripeTransactionService.getBalanceTransactionDetails(
          transactionId: stripeCharge.balanceTransactionId ?? '',
        );
        totalRevenue += stripeTransaction.amount;
      }
      return totalRevenue * 0.85;
    } catch (_) {
      rethrow;
    }
  }

  // Future<double> getTotalHostRevenueByCarId(String carId) async {
  //   double totalRevenue = 0.0;
  //   try {
  //     final List<CarRental> carRentals =
  //         await _carRentalController.getCarRentalsByCarId(
  //       carId,
  //     );
  //     for (final carRental in carRentals) {
  //       final StripeCharge stripeCharge =
  //           await _stripeChargeService.getChargeDetails(
  //         chargeId: carRental.stripeChargeId ?? '',
  //       );
  //       final StripeTransaction stripeTransaction =
  //           await _stripeTransactionService.getBalanceTransactionDetails(
  //         transactionId: stripeCharge.balanceTransactionId ?? '',
  //       );
  //       totalRevenue += stripeTransaction.amount;
  //     }
  //     return totalRevenue * 0.85;
  //   } catch (_) {
  //     rethrow;
  //   }
  // }
}
