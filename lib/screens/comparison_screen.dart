import 'package:flutter/material.dart';
import 'package:sim_com/screens/publish_subscribe_screen.dart';
import 'package:sim_com/screens/request_response_screen.dart';

class ComparisonScreen extends StatefulWidget {
  @override
  _ComparisonScreenState createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen> {
  bool trigger = false;

  void onTrigger() {
    setState(() {
      trigger = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final requestResponseSize =
        Size(size.width * (2 / 5), size.height); // 2 parts
    final pubSubSize = Size(size.width * (3 / 5), size.height); // 3 parts

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Bagian Request-Response
              Expanded(
                flex: 2, // Set flex lebih besar untuk Request-Response
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RequestResponseScreen(
                          size: requestResponseSize,
                          trigger: trigger,
                        ), // Tampilan Request-Response
                      ),
                    ),
                  ],
                ),
              ),

              VerticalDivider(
                  thickness: 1, color: Colors.grey), // Divider antar screen

              // Bagian Publish-Subscribe
              Expanded(
                flex: 3, // Set flex lebih kecil untuk Pub-Sub
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PubSubScreen(
                          size: pubSubSize,
                          trigger: trigger,
                        ), // Tampilan Pub-Sub
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Action Button at the center
          Positioned(
            bottom: 20,
            left: size.width / 2 - 170, // Center horizontally
            child: Container(
              width: 90, // Set the desired width
              child: FloatingActionButton(
                onPressed: onTrigger,
                child: const Text("Compare"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
