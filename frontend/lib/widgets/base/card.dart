import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/theme/theme.dart';
import 'package:animations/animations.dart';
import 'package:frontend/widgets/pages/client/show_class.dart';

class CustomCard extends StatelessWidget {
  final String imageUrl;
  final String cost;
  final String location;
  final String className;
  final String classGender;
  final Map<String, dynamic> classData;

  CustomCard({
    required this.imageUrl,
    required this.cost,
    required this.location,
    required this.className,
    required this.classGender,
    required this.classData,
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
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(15)),
                        child: Image.network(
                          imageUrl,
                          // width: MediaQuery.of(context).size.width * 0.4,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
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
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
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
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(className,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800)),
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
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(location,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                Icons.wc_rounded,
                                color: Colors.grey.shade800,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Text(classGender,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800)),
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
                              ),
                              const SizedBox(width: 14),
                              Flexible(
                                child: Text(cost,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade800)),
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
          );
        },
        openBuilder: (context, action) {
          HapticFeedback.lightImpact();
          return ShowClassPage(
            classData: classData,
          );
        });
  }
}
