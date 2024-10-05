import 'package:flutter/material.dart';
import 'dart:async';

class PubSubScreen extends StatefulWidget {
  final Size size; // Menambahkan parameter Size
  final bool trigger;

  PubSubScreen(
      {required this.size, required this.trigger}); // Required parameter
  @override
  _PubSubScreenState createState() => _PubSubScreenState();
}

class _PubSubScreenState extends State<PubSubScreen> {
  String brokerMessage = '';
  String userInputMessage = '';
  bool isMessageSent = false;
  bool isMessageDeliveredToSub1 = false;
  bool isMessageDeliveredToSub2 = false;
  bool isProcessing = false;
  bool isVisible = false;
  bool isMessageReceived = false;
  bool hasExecuted = false;

  late StreamController<String> messageStreamController; // Broker

  @override
  void initState() {
    super.initState();
    messageStreamController = StreamController<String>(); // Inisialisasi broker
  }

  // Method untuk mereset semua state
  void resetState() {
    setState(() {
      brokerMessage = '';
      userInputMessage = '';
      isMessageSent = false;
      isMessageDeliveredToSub1 = false;
      isMessageDeliveredToSub2 = false;
      isProcessing = false;
      isVisible = false;
      isMessageReceived = false;
      messageStreamController.close();
    });
  }

  // Method untuk mem-publish pesan
  void publishMessage(String message) {
    setState(() {
      isMessageSent = true;
      brokerMessage = message;
      isProcessing = true;
    });

    Future.delayed(Duration(seconds: 2), () {
      messageStreamController.add(message);

      setState(() {
        isProcessing = false;
        isVisible = true;
      });

      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          isMessageDeliveredToSub1 = true;
          isMessageDeliveredToSub2 = true;

          Future.delayed(Duration(seconds: 2), () {
            setState(() {
              isMessageReceived = true;
            });
          });
        });
      });
    });
  }

  @override
  void dispose() {
    messageStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trigger && !hasExecuted) {
      setState(() {
        userInputMessage = 'Shalat Bang';
        hasExecuted = true;
      });
      publishMessage(userInputMessage);
    }
    return Scaffold(
      appBar: AppBar(title: Text('Simulasi Pub-Sub')),
      body: Stack(
        children: [
          // Garis putus-putus untuk jalur komunikasi
          Positioned.fill(
            child: CustomPaint(
              painter: DashedLinePainter(),
            ),
          ),

          // Ikon publisher dan label
          Positioned(
            left: 50,
            top: 50,
            child: Column(
              children: [
                Icon(Icons.person, size: 50),
                Text('Publisher', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Ikon broker dan label
          Positioned(
            left: widget.size.width / 2 - 50,
            top: 50,
            child: Column(
              children: [
                Icon(Icons.cloud, size: 50),
                Text('Broker', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Ikon Subscriber 1 dan label
          Positioned(
            right: 50,
            top: 20,
            child: Column(
              children: [
                Icon(Icons.person, size: 50),
                Text('Subscriber 1', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Ikon Subscriber 2 dan label
          Positioned(
            right: 50,
            top: 110,
            child: Column(
              children: [
                Icon(Icons.person, size: 50),
                Text('Subscriber 2', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Animasi message dari Publisher ke Broker
          AnimatedPositioned(
            left: isMessageSent ? widget.size.width / 2 - 50 : 50,
            top: 35,
            duration: Duration(seconds: 2),
            child: Icon(Icons.message, size: 30, color: Colors.blue),
          ),

          // Animasi message dari Broker ke Subscriber 1
          if (isVisible)
            AnimatedPositioned(
              right: isMessageDeliveredToSub1 ? 50 : widget.size.width / 2 - 50,
              top: 10,
              duration: Duration(seconds: 2),
              child: Icon(Icons.message, size: 30, color: Colors.green),
            ),

          // Animasi message dari Broker ke Subscriber 2
          if (isVisible)
            AnimatedPositioned(
              right: isMessageDeliveredToSub2 ? 50 : widget.size.width / 2 - 50,
              top: 100,
              duration: Duration(seconds: 2),
              child: Icon(Icons.message, size: 30, color: Colors.green),
            ),

          // Bagian bawah dengan input field, tombol, dan status pesan
          Positioned(
            bottom: 100,
            left: 100,
            right: 100,
            child: Column(
              children: [
                // Input field untuk pengguna mengetik pesan
                TextField(
                  onChanged: (value) {
                    userInputMessage = value;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: userInputMessage == ""
                          ? "Masukkan Pesan"
                          : userInputMessage),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (userInputMessage.isNotEmpty) {
                      publishMessage(
                          userInputMessage); // Kirim pesan jika input tidak kosong
                    }
                  },
                  child: Text("Kirim Pesan"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    resetState(); // Reset simulasi
                  },
                  child: Text("Reset Simulasi"),
                ),
                SizedBox(height: 20),
                Text(
                  isMessageSent
                      ? (isProcessing
                          ? "Memproses pesan..."
                          : (isMessageReceived
                              ? "Pesan terkirim ke semua subscriber."
                              : "Sedang mengirim pesan..."))
                      : "Tekan tombol untuk mengirim pesan.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),

                // Menampilkan penerimaan pesan oleh subscribers
                StreamBuilder<String>(
                  stream: messageStreamController.stream,
                  builder: (context, snapshot) {
                    // Jika ada data dan pesan telah diterima
                    if (snapshot.hasData && isMessageReceived) {
                      return Column(
                        children: [
                          Text('Subscriber 1 menerima pesan: ${snapshot.data}'),
                          Text('Subscriber 2 menerima pesan: ${snapshot.data}'),
                        ],
                      );
                    } else {
                      return Text('Tidak ada pesan yang diterima');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk menggambar garis putus-putus
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Menggambar garis putus-putus dari Publisher ke Broker (Jalur pesan)
    drawDashedLine(
      canvas,
      Offset(95, 75), // Titik awal (Publisher)
      Offset(size.width / 2 - 50, 75), // Titik akhir (Broker)
      paint,
    );

    // Menggambar garis putus-putus dari Broker ke Subscribers (Jalur respon)
    drawDashedLine(
      canvas,
      Offset(size.width / 2, 50), // Titik awal (Broker)
      Offset(size.width - 100, 50), // Titik akhir (Subscriber 1)
      paint,
    );

    drawDashedLine(
      canvas,
      Offset(size.width / 2, 135), // Titik awal (Broker)
      Offset(size.width - 100, 135), // Titik akhir (Subscriber 2)
      paint,
    );
  }

  // Method untuk menggambar garis putus-putus
  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    final totalDistance = (end - start).distance;
    final dashCount = (totalDistance / (dashWidth + dashSpace)).floor();
    final double dx = (end.dx - start.dx) / dashCount;
    final double dy = (end.dy - start.dy) / dashCount;

    for (int i = 0; i < dashCount; ++i) {
      if (i.isEven) {
        final x = start.dx + dx * i;
        final y = start.dy + dy * i;
        final x2 = x + dx;
        final y2 = y + dy;
        canvas.drawLine(Offset(x, y), Offset(x2, y2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
