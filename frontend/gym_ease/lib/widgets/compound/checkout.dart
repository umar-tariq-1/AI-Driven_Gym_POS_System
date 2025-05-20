import 'package:flutter/material.dart';
import 'package:checkout_screen_ui/checkout_ui.dart';
import 'package:checkout_screen_ui/models/checkout_result.dart';

class SingleProductCheckout extends StatelessWidget {
  final String name;
  final int quantity;
  final int priceCents;

  const SingleProductCheckout({
    Key? key,
    required this.name,
    required this.quantity,
    required this.priceCents,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<CardPayButtonState> _payBtnKey =
        GlobalKey<CardPayButtonState>();

    Future<void> _creditPayClicked(
        CardFormResults results, CheckOutResult checkOutResult) async {
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.processing);

      print('Product Name: $name');
      print('Quantity: $quantity');
      print('Price (cents): $priceCents');
      print(
          'Subtotal: \$${(checkOutResult.subtotalCents / 100).toStringAsFixed(2)}');
      print('Tax: \$${(checkOutResult.taxCents / 100).toStringAsFixed(2)}');
      print(
          'Total: \$${(checkOutResult.totalCostCents / 100).toStringAsFixed(2)}');

      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.success);

      await Future.delayed(const Duration(seconds: 2));
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.ready);
    }

    final List<PriceItem> _priceItems = [
      PriceItem(name: name, quantity: quantity, itemCostCents: priceCents),
    ];

    return CheckoutPage(
      data: CheckoutData(
        priceItems: _priceItems,
        payToName: 'POS',
        onCardPay: _creditPayClicked,
        payBtnKey: _payBtnKey,
        taxRate: 0.0,
        displayNativePay: false,
        displayTestData: false,
      ),
      footer: const CheckoutPageFooter(
        privacyLink: 'https://yourstore.com/privacy',
        termsLink: 'https://yourstore.com/terms',
        note: 'Powered by Your Store',
        noteLink: 'https://yourstore.com',
      ),
    );
  }
}
