import 'package:flutter/material.dart';

class PointOfSalesPage extends StatefulWidget {
  const PointOfSalesPage({super.key});

  static const String routePath = '/owner/point_of_sales';

  @override
  State<PointOfSalesPage> createState() => _PointOfSalesPageState();
}

class _PointOfSalesPageState extends State<PointOfSalesPage> {
  @override
  Widget build(BuildContext context) {
    return Text('Point of Sales');
  }
}
