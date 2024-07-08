import 'package:flutter/material.dart';
import '../models/stripe_payment_method.dart';
import '../services/stripe/stripe_payment_method_service.dart';

class StripePaymentMethodProvider extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _saveCard = true;
  List<StripePaymentMethod> savedCards = [];
  bool _isNewCardSelected = true;

  StripePaymentMethodProvider() {
    _selectedIndex = 0;
    _saveCard = true;
    _isNewCardSelected = true;
  }

  int get selectedIndex => _selectedIndex;
  bool get saveCard => _saveCard;
  bool get isNewCardSelected => _isNewCardSelected;

  Future<void> loadPaymentMethods(String stripeCustomerId) async {
    try {
      final stripePaymentMethodService = StripePaymentMethodService();
      if (stripeCustomerId.isNotEmpty) {
        final paymentMethods =
            await stripePaymentMethodService.listCustomerPaymentMethods(
          stripeCustomerId,
        );

        savedCards = paymentMethods;
        if (savedCards.isNotEmpty) {
          _isNewCardSelected = false;
        }
        notifyListeners();
      }
    } catch (error) {
      throw Exception('Failed to load payment methods.');
    }
  }

  StripePaymentMethod? getSelectedPaymentMethod() {
    if (_isNewCardSelected) {
      return null;
    } else {
      return savedCards[_selectedIndex];
    }
  }

  void selectPaymentMethod(int index) {
    _selectedIndex = index;
    _isNewCardSelected = index == savedCards.length;
    notifyListeners();
  }

  void toggleSaveCard(bool value) {
    _saveCard = value;
    notifyListeners();
  }
}
