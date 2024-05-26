import 'package:flutter/material.dart';
import 'package:prime/widgets/bank_account_tab_body.dart';
import 'package:prime/widgets/payment_tab_body.dart';

class PaymentCardsAndBankAccountScreen extends StatelessWidget {
  const PaymentCardsAndBankAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Cards & Bank Account'),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: 'Payment Cards',
                icon: Icon(Icons.payment_rounded),
              ),
              Tab(
                text: 'Bank Account',
                icon: Icon(Icons.account_balance_rounded),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PaymentCardsTabBody(),
            BankAccountTabBody(),
          ],
        ),
      ),
    );
  }
}
