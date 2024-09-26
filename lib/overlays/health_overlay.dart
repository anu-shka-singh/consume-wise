import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HealthOverlay extends StatefulWidget {
  final double rating;
  final List<dynamic> positive;
  final List<dynamic> negative;

  const HealthOverlay(
      {super.key,
      required this.rating,
      required this.positive,
      required this.negative});

  @override
  State<HealthOverlay> createState() => _HealthOverlayState();
}

class _HealthOverlayState extends State<HealthOverlay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          width: 370,
          height: 295, // Height of the dialog.
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E7),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Health Analysis",
                      style: TextStyle(
                          color: Colors.black87,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  buildAutoScrollingImpacts(
                    positive: widget.positive,
                    negative: widget.negative,
                    scrollSpeed: 50.0,
                    height: 40.0, 
                    spacing: 16.0,
                  ),
                  const Divider(
                    color: Colors.black87,
                    thickness: 2,
                    indent: 80,
                    endIndent: 80,
                    height: 25,
                  ),
                  // Rating Section (Stars and Number)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        color: const Color(0xFF86b649),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: const Padding(
                          padding:  EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                "QUALITY",
                                style:  TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                              Text(
                                "SCORE",
                                style:TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      RatingBar.builder(
                        initialRating: widget.rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 40.0,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 252, 190, 3),
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                ],
              ),
              // Close Button
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  onPressed: () async {
                    await FlutterOverlayWindow.closeOverlay();
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildAutoScrollingImpacts({
  required List<dynamic> positive,
  required List<dynamic> negative,
  double scrollSpeed = 2.0,
  double height = 70,
  double spacing = 16.0,
}) {
  // Scroll controllers
  final ScrollController positiveScrollController = ScrollController();
  final ScrollController negativeScrollController = ScrollController();

  // Method to handle auto-scrolling logic
  void _startAutoScroll(ScrollController controller, {bool reverse = false}) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      while (true) {
        await Future.delayed(
            const Duration(milliseconds: 18)); // Adjust scroll delay
        if (controller.hasClients) {
          final maxScrollExtent = controller.position.maxScrollExtent;
          final minScrollExtent = controller.position.minScrollExtent;

          if (reverse) {
            if (controller.offset <= minScrollExtent) {
              controller.jumpTo(maxScrollExtent);
            } else {
              controller.animateTo(
                controller.offset - scrollSpeed,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
              );
            }
          } else {
            if (controller.offset >= maxScrollExtent) {
              controller.jumpTo(minScrollExtent);
            } else {
              controller.animateTo(
                controller.offset + scrollSpeed,
                duration: const Duration(milliseconds: 200),
                curve: Curves.linear,
              );
            }
          }
        }
      }
    });
  }

  // Start auto-scrolling for both lists
  _startAutoScroll(positiveScrollController);
  _startAutoScroll(negativeScrollController, reverse: true);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Column(
      children: [
        // Positive Impacts (Scroll in one direction)
        SizedBox(
          height: 60,
          child: SingleChildScrollView(
            controller: positiveScrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: positive.map(
                (positiveImpact) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF055b49),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            positiveImpact,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ),
        // Negative Impacts (Scroll in the opposite direction)
        SizedBox(
          height: 60,
          child: SingleChildScrollView(
            controller: negativeScrollController,
            scrollDirection: Axis.horizontal,
            reverse: true, // Scroll in opposite direction
            child: Row(
              children: negative.map(
                (negativeImpact) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 117, 27, 33),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.remove_circle,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            negativeImpact,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 18.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    ),
  );
}
