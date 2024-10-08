import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class HealthOverlay extends StatefulWidget {
  final double rating;
  final List<dynamic> positive;
  final List<dynamic> negative;

  const HealthOverlay({
    super.key,
    required this.rating,
    required this.positive,
    required this.negative,
  });

  @override
  State<HealthOverlay> createState() => _HealthOverlayState();
}

class _HealthOverlayState extends State<HealthOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          width: 390,
          height: 330,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6E7),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(),
              const Divider(
                color: Colors.black26,
                thickness: 1.5,
                indent: 20,
                endIndent: 20,
                height: 20,
              ),
              const SizedBox(height: 8.0),
              _buildHealthScore(),
              const SizedBox(height: 10.0),
              _buildScrollablePositivesNegatives(), // Updated method
            ],
          ),
        ),
      ),
    );
  }

  // Header with Logo, Title and Close Button
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          "assets/images/overlay_logo2.png",
          height: 60,
          width: 60,
        ),
        const Text(
          "Health Summary",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        InkWell(
          onTap: () {
            //await FlutterOverlayWindow.closeOverlay();
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: Colors.black12.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: Colors.black54,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // Health Score with star rating display
  Widget _buildHealthScore() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RatingBar.builder(
          ignoreGestures: true,
          initialRating: widget.rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemSize: 40.0,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            // Optional: Add logic if you want to handle rating updates
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildScrollablePositivesNegatives() {
    return Expanded(
      // Use Expanded to take available space
      child: Row(
        children: [
          // Positive Impacts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Positives",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8.0),
                buildImpactList(
                    widget.positive, Icons.add_circle, Colors.green),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Negative Impacts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Negatives",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8.0),
                buildImpactList(
                    widget.negative, Icons.remove_circle, Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the impact list (either positives or negatives)
  Widget buildImpactList(List<dynamic> items, IconData icon, Color color) {
    // Limit the items to a maximum of 3
    final limitedItems = items.take(3).toList();

    return Column(
      children: limitedItems
          .map(
            (item) => Tooltip(
              message: item, // Full text as tooltip
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis, // Show ellipsis if overflow
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
