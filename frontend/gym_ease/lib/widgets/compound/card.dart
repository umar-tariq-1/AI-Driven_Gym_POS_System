import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:gym_ease/data/secure_storage.dart';
import 'package:gym_ease/states/server_address.dart';
import 'package:gym_ease/theme/theme.dart';
import 'package:animations/animations.dart';
import 'package:gym_ease/widgets/base/confirmation_dialog.dart';
import 'package:gym_ease/widgets/base/custom_outlined_button.dart';
import 'package:gym_ease/widgets/compound/audience.dart';
import 'package:gym_ease/widgets/compound/broadcaster.dart';
import 'package:gym_ease/widgets/pages/client/book%20classes/show_class.dart';
import 'package:gym_ease/widgets/pages/client/shop_products/show_product.dart';
import 'package:gym_ease/widgets/pages/owner/point_of_sales/show_my_product.dart';
import 'package:gym_ease/widgets/pages/trainer/manage%20classes/show_my_class.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:redacted/redacted.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClassesCard extends StatelessWidget {
  final String imageUrl;
  final String cost;
  final String location;
  final String className;
  final String classGender;
  final Map<String, dynamic> classData;
  bool isTrainer;

  ClassesCard({
    required this.imageUrl,
    required this.cost,
    required this.location,
    required this.className,
    required this.classGender,
    required this.classData,
    this.isTrainer = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 600),
        openColor: Colors.white,
        closedColor: Colors.white,
        middleColor: Colors.white,
        closedBuilder: (context, action) {
          return GestureDetector(
            onTap: classData.isNotEmpty
                ? () {
                    HapticFeedback.mediumImpact();
                    action();
                  }
                : () {},
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: SizedBox(
                // width: MediaQuery.of(context).size.width * 1,
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(15)),
                          child: Image(
                            image: CachedNetworkImageProvider(imageUrl),
                            // width: MediaQuery.of(context).size.width * 0.4,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.4,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              // width: MediaQuery.of(context).size.width * 0.4,
                              height: double.infinity,
                              color: Colors.grey[300],
                              child: Center(
                                  child: Icon(
                                Icons.error,
                                color: colorScheme.error,
                                size: 30,
                              )),
                            ),
                          ).redacted(
                              context: context, redact: classData.isEmpty),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.fitness_center_sharp,
                                  color: Colors.grey.shade800,
                                  size: 24,
                                ).redacted(
                                    context: context,
                                    redact: classData.isEmpty),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(className,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: classData.isEmpty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_sharp,
                                  color: Colors.grey.shade800,
                                  size: 24,
                                ).redacted(
                                    context: context,
                                    redact: classData.isEmpty),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(location,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: classData.isEmpty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  isTrainer
                                      ? Icons.people_rounded
                                      : Icons.wc_rounded,
                                  color: Colors.grey.shade800,
                                  size: 24,
                                ).redacted(
                                    context: context,
                                    redact: classData.isEmpty),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                          isTrainer
                                              ? '${classData['maxParticipants'] - classData['remainingSeats']}/${classData['maxParticipants']}'
                                              : classGender,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: classData.isEmpty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  Icons.attach_money_rounded,
                                  color: Colors.grey.shade800,
                                  size: 25,
                                ).redacted(
                                    context: context,
                                    redact: classData.isEmpty),
                                const SizedBox(width: 14),
                                Flexible(
                                  child: Text(cost,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: classData.isEmpty),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        openBuilder: (context, action) {
          return isTrainer
              ? ShowMyClassPage(
                  classData: classData,
                )
              : ShowClassPage(
                  classData: classData,
                );
        });
  }
}

class LiveStreamingCard extends StatelessWidget {
  final String imageUrl;
  final String className;
  final String userName;
  final String userId;
  final Map<String, dynamic> classData;
  bool isTrainer;
  final void Function(bool)? setLoading;

  LiveStreamingCard({
    required this.imageUrl,
    required this.className,
    required this.classData,
    required this.userName,
    required this.userId,
    this.isTrainer = false,
    this.setLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
      child: SizedBox(
        // width: MediaQuery.of(context).size.width * 1,
        height: 180,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(15)),
                  child: Image(
                    image: CachedNetworkImageProvider(imageUrl),
                    // width: MediaQuery.of(context).size.width * 0.4,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.4,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      // width: MediaQuery.of(context).size.width * 0.4,
                      height: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                          child: Icon(
                        Icons.error,
                        color: colorScheme.error,
                        size: 30,
                      )),
                    ),
                  ).redacted(context: context, redact: classData.isEmpty),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center_sharp,
                          color: Colors.grey.shade800,
                          size: 24,
                        ).redacted(context: context, redact: classData.isEmpty),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(className,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade800))
                              .redacted(
                                  context: context, redact: classData.isEmpty),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_view_week_rounded,
                          color: Colors.grey.shade800,
                          size: 24,
                        ).redacted(context: context, redact: classData.isEmpty),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (index) {
                              bool isActive = classData.isEmpty
                                  ? true
                                  : jsonDecode(
                                          classData['selectedDays'])[index] ==
                                      true;
                              List<String> dayLabels = [
                                "M",
                                "Tu",
                                "W",
                                "Th",
                                "F",
                                "Sa",
                                "Su"
                              ];
                              return Text(dayLabels[index],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        color: isActive
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                        fontSize: 15.4,
                                        fontWeight: FontWeight.bold,
                                      ))
                                  .redacted(
                                      context: context,
                                      redact: classData.isEmpty);
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.grey.shade800,
                          size: 24,
                        ).redacted(context: context, redact: classData.isEmpty),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                                  classData.isEmpty
                                      ? '12:00 - 13:00'
                                      : '${classData['startTime'].substring(0, 5)} - ${classData['endTime'].substring(0, 5)}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade800))
                              .redacted(
                                  context: context, redact: classData.isEmpty),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: CustomOutlinedButton(
                          buttonText: isTrainer ? 'Go Live' : 'Join Live',
                          height: 0,
                          leadingIcon: const Icon(
                            Icons.send,
                            size: 19,
                          ),
                          transitionColor: true,
                          fontSize: 16,
                          disabled: classData.isEmpty,
                          onClick: () async {
                            HapticFeedback.mediumImpact();
                            if (isTrainer) {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Broadcaster(
                                      userId: '${userName}_$userId'
                                          .replaceAll(' ', '_'),
                                      userName: userName,
                                      liveId:
                                          '${className}_${classData['id'].toString()}'
                                              .replaceAll(' ', '_'))));
                            } else {
                              setLoading?.call(true);
                              final authToken =
                                  await SecureStorage().getItem('authToken');
                              final serverAddressController =
                                  Get.find<ServerAddressController>();
                              final response = await http.get(
                                  Uri.parse(
                                      'http://${serverAddressController.IP}:3001/client/classes/is-streaming/${classData['id']}'),
                                  headers: {
                                    'auth-token': authToken,
                                  });
                              final responseBody = jsonDecode(response.body);
                              setLoading?.call(false);
                              CustomConfirmationDialog.show(
                                context,
                                yesText: "Join",
                                noText: "Cancel",
                                title: "Confirm Join",
                                message: responseBody['isStreaming']
                                    ? "Are you sure you want to join the live class?"
                                    : "Trainer has not started live class yet. Do you still want to join and wait?",
                                yesCallback: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Audience(
                                          userId: '${userName}_$userId'
                                              .replaceAll(' ', '_'),
                                          userName: userName,
                                          liveId:
                                              '${className}_${classData['id'].toString()}'
                                                  .replaceAll(' ', '_'))));
                                },
                                noCallback: () => Navigator.of(context).pop(),
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class POSProductCard extends StatelessWidget {
  final String imageUrl;
  final String cost;
  final String location;
  final String productName;
  final String quantity;
  final Map<String, dynamic> productData;
  bool isSeller;

  POSProductCard({
    required this.imageUrl,
    required this.cost,
    required this.location,
    required this.productName,
    required this.quantity,
    required this.productData,
    this.isSeller = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 600),
        openColor: Colors.white,
        closedColor: Colors.white,
        middleColor: Colors.white,
        closedBuilder: (context, action) {
          return GestureDetector(
            onTap: productData.isNotEmpty
                ? () {
                    HapticFeedback.mediumImpact();
                    action();
                  }
                : () {},
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
              child: SizedBox(
                // width: MediaQuery.of(context).size.width * 1,
                height: 180,
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(15)),
                          child: Image(
                            image: CachedNetworkImageProvider(imageUrl),
                            // width: MediaQuery.of(context).size.width * 0.4,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                // width: MediaQuery.of(context).size.width * 0.4,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              // width: MediaQuery.of(context).size.width * 0.4,
                              height: double.infinity,
                              color: Colors.grey[300],
                              child: Center(
                                  child: Icon(
                                Icons.error,
                                color: colorScheme.error,
                                size: 30,
                              )),
                            ),
                          ).redacted(
                              context: context, redact: productData.isEmpty),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.boxOpen,
                                  color: Colors.grey.shade800,
                                  size: 19.75,
                                ).redacted(
                                    context: context,
                                    redact: productData.isEmpty),
                                const SizedBox(width: 13),
                                Flexible(
                                  child: Text(productName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: productData.isEmpty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_sharp,
                                  color: Colors.grey.shade800,
                                  size: 24,
                                ).redacted(
                                    context: context,
                                    redact: productData.isEmpty),
                                const SizedBox(width: 11),
                                Flexible(
                                  child: Text(location,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: productData.isEmpty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.cartShopping,
                                  color: Colors.grey.shade800,
                                  size: 19.6,
                                ).redacted(
                                    context: context,
                                    redact: productData.isEmpty),
                                const SizedBox(width: 14.75),
                                Flexible(
                                  child: Text(quantity,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: productData.isEmpty),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                const SizedBox(width: 6.75),
                                FaIcon(
                                  FontAwesomeIcons.dollarSign,
                                  color: Colors.grey.shade800,
                                  size: 19.6,
                                ).redacted(
                                    context: context,
                                    redact: productData.isEmpty),
                                const SizedBox(width: 15.6),
                                Flexible(
                                  child: Text(cost,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade800))
                                      .redacted(
                                          context: context,
                                          redact: productData.isEmpty),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        openBuilder: (context, action) {
          return isSeller
              ? ShowMyPOSProductPage(
                  productData: productData,
                )
              : ShowShopProductPage(productData: productData);
        });
  }
}
