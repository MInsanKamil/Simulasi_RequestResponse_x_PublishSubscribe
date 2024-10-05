import 'package:flutter/material.dart';
import 'package:sim_com/screens/publish_subscribe_screen.dart';
import 'package:sim_com/screens/request_response_screen.dart';
import 'package:sim_com/screens/comparison_screen.dart'; // Tambahkan import

void main() => runApp(SimulasiModelApp());

class SimulasiModelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SimulationScreen(),
    );
  }
}

class SimulationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3, // Update jumlah tab
      child: Scaffold(
        appBar: AppBar(
          title: Text("Simulasi Interaktif Model"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Request-Response"),
              Tab(text: "Publish-Subscribe"),
              Tab(text: "Perbandingan"), // Tambahkan tab perbandingan
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RequestResponseScreen(size: size, trigger: false),
            PubSubScreen(size: size, trigger: false),
            ComparisonScreen(), // Tambahkan screen perbandingan
          ],
        ),
      ),
    );
  }
}
