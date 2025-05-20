import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:checkout_screen_ui/checkout_ui.dart';
import 'package:checkout_screen_ui/models/checkout_result.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/main.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:gym_ease/widgets/base/app_bar.dart';
import 'package:gym_ease/widgets/base/snackbar.dart';
import 'package:http/http.dart' as http;

class Checkout extends StatelessWidget {
  final String name;
  final int quantity;
  final int priceCents;
  final int classId;
  final int posProductId;
  final VoidCallback? onSuccess;

  const Checkout({
    Key? key,
    required this.name,
    required this.quantity,
    required this.priceCents,
    this.classId = 0,
    this.posProductId = 0,
    this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<CardPayButtonState> _payBtnKey =
        GlobalKey<CardPayButtonState>();

    _creditPayClicked(
        CardFormResults results, CheckOutResult checkOutResult) async {
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.processing);

      if (name.isEmpty || quantity <= 0 || priceCents <= 0) {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.fail);
        return;
      }

      final payload = {
        'classId': classId,
        'posProductId': posProductId,
        'quantity': quantity,
        'priceCents': priceCents,
        'subtotal': checkOutResult.subtotalCents,
        'tax': checkOutResult.taxCents,
        'total': checkOutResult.totalCostCents,
        'cardInfo': {
          'cardHolder': results.name,
          'cardNumber': results.cardNumber,
          'cardExpiry': results.cardExpiry,
          'country': results.country,
          'email': results.email,
          'cvv': results.cardSec,
        }
      };

      try {
        String authToken = await SecureStorage().getItem('authToken');
        final serverAddressController = Get.find<ServerAddressController>();
        final res = await http.post(
          Uri.parse('http://${serverAddressController.IP}:3001/payment'),
          headers: {
            'auth-token': authToken,
            'Content-Type': 'application/json'
          },
          body: jsonEncode(payload),
        );

        if (res.statusCode == 200) {
          _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.success);
          await Future.delayed(const Duration(seconds: 2));
          _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.ready);
          if (onSuccess != null) {
            onSuccess!();
          }
          Navigator.of(context).pop();
          CustomSnackbar.showSuccessSnackbar(
              context, "Success", "Payment successful");
        } else {
          _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.fail);
          CustomSnackbar.showFailureSnackbar(
              context, "Oops", json.decode(res.body)['message']);
        }
      } catch (e) {
        CustomSnackbar.showFailureSnackbar(
            context, "Oops", "Couldn't request to server");
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.fail);
      }
    }

    final List<PriceItem> _priceItems = [
      PriceItem(name: name, quantity: quantity, itemCostCents: priceCents),
    ];

    return Scaffold(
        appBar: CustomAppBar(
          title: "Payment Process",
          backgroundColor: appBarColor,
          foregroundColor: appBarTextColor,
          showBackButton: true,
        ),
        backgroundColor: colorScheme.surface,
        body: CheckoutPage(
          data: CheckoutData(
            priceItems: _priceItems,
            payToName: 'Checkout',
            onCardPay: _creditPayClicked,
            payBtnKey: _payBtnKey,
            taxRate: 0.05,
            displayNativePay: false,
            displayTestData: false,
          ),
          footer: const CheckoutPageFooter(
            privacyLink: 'https://yourstore.com/privacy',
            termsLink: 'https://yourstore.com/terms',
            // note: 'Powered by Your Store',
            // noteLink: 'https://yourstore.com',
          ),
        ));
  }
}
