import 'package:flutter/material.dart';
import 'package:activity_tracker/generated/l10n.dart';

class ActivitiesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                S.of(context).welcomeBack,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text(
                    S.of(context).myActivities,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2), // Add space between text and underline
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Use LayoutBuilder to get the text width dynamically
                      final textWidth = TextPainter(
                        text: TextSpan(
                          text: S.of(context).myActivities,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                      )..layout();

                      return Container(
                        width: textWidth.size.width + 20,
                        height: 1.5, // Set the thickness of the underline
                        color:
                            Color(0xFF3477A7), // Blue color for the underline
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // FutureBuilder or other widgets to display activities
          ],
        ),
      ),
    );
  }
}
