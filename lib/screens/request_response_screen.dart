import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestResponseScreen extends StatefulWidget {
  final Size size; // Menambahkan parameter Size
  final bool trigger;

  RequestResponseScreen({required this.size, required this.trigger});
  @override
  _RequestResponseScreenState createState() => _RequestResponseScreenState();
}

class _RequestResponseScreenState extends State<RequestResponseScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> person = {};
  bool isRequestSent = false;
  bool isResponseReceived = false;
  bool isServerResponding = false;
  bool isRunning = false;
  bool hasExecuted = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
  }

  // Method untuk mereset status
  void resetState() {
    setState(() {
      isRequestSent = false;
      isResponseReceived = false;
      isServerResponding = false;
      isRunning = false;
      _controller.reset();
      person = {};
    });
  }

  // Method untuk mengirim permintaan ke server
  Future<void> sendRequest() async {
    // Menandakan bahwa permintaan sedang dikirim
    setState(() {
      isRequestSent = true; // Tandai bahwa permintaan telah dikirim
      isRunning = true;
      _controller.forward(); // Mulai animasi
    });

    try {
      // Mengirim permintaan GET ke API pengguna
      final result = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users/1'),
      );

      // Jika respons berhasil, ubah data pengguna dari JSON
      if (result.statusCode == 200) {
        // Delay untuk mensimulasikan waktu respons server
        await Future.delayed(Duration(seconds: 2));

        setState(() {
          isServerResponding = true; // Server sedang mempersiapkan respons
        });

        // Delay lebih lanjut untuk mensimulasikan pemrosesan server
        await Future.delayed(Duration(seconds: 2));

        setState(() {
          person = json.decode(result.body); // Parsing JSON
          isResponseReceived = true; // Tandai respons diterima
          isServerResponding = false; // Reset status server yang merespons
        });
      } else {
        await Future.delayed(Duration(seconds: 4));
        setState(() {
          person = {
            "error": "Gagal mengambil data pengguna."
          }; // Menangani error
          isRunning = false;
          isResponseReceived = false; // Set respons diterima meskipun ada error
          isServerResponding = false; // Reset status server yang merespons
        });
      }
    } catch (e) {
      await Future.delayed(Duration(seconds: 4));
      setState(() {
        person = {"error": "Terjadi kesalahan: $e"}; // Menangani kesalahan
        isRunning = false;
        isResponseReceived =
            false; // Set respons diterima dalam kasus kesalahan
        isServerResponding = false; // Reset status server yang merespons
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trigger && !hasExecuted) {
      setState(() {
        hasExecuted = true;
      });
      sendRequest();
    }
    return Scaffold(
      appBar: AppBar(title: Text('Simulasi Request Response')),
      body: Stack(
        children: [
          // Garis putus-putus untuk permintaan dan respons
          Positioned.fill(
            child: CustomPaint(
              painter: DashedLinePainter(),
            ),
          ),

          // Ikon dan label Client (Pengirim)
          Positioned(
            left: 50,
            top: 50,
            child: Column(
              children: [
                Icon(Icons.person, size: 50),
                Text('Client', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Ikon dan label Server
          Positioned(
            right: 50,
            top: 50,
            child: Column(
              children: [
                Icon(Icons.cloud, size: 50),
                Text('Server', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          // Animasi panah permintaan (bergerak maju)
          AnimatedPositioned(
            left: isRequestSent
                ? widget.size.width - 100
                : 50, // Pindahkan panah ke server
            top: 25,
            duration: Duration(seconds: 2), // Ubah durasi menjadi 2 detik
            child: Icon(Icons.message, size: 30, color: Colors.blue),
          ),

          // Animasi panah respons (bergerak mundur)
          AnimatedPositioned(
            left: isServerResponding || isResponseReceived
                ? 50
                : widget.size.width - 100, // Pindahkan panah kembali
            top: 130,
            duration: Duration(seconds: 2), // Ubah durasi menjadi 2 detik
            child: Icon(Icons.message, size: 30, color: Colors.green),
          ),

          // Bagian bawah dengan tombol dan teks respons
          Positioned(
            bottom: 100,
            left: 100,
            right: 100,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: sendRequest, // Tombol untuk mengirim permintaan
                  child: Text("Get Data Pengguna"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: resetState, // Tombol untuk mereset simulasi
                  child: Text("Reset Simulasi"),
                ),
                SizedBox(height: 20),
                Text(
                  isRequestSent
                      ? (isServerResponding
                          ? "Server mengirim respons..." // Status ketika server merespons
                          : (isResponseReceived
                              ? "Respons diterima dari server:"
                              : (isRunning
                                  ? "Mengirim permintaan ke server..."
                                  : "Gagal mengirim permintaan ke server:"))) // Status ketika tidak ada respons
                      : "Tekan tombol untuk mendapatkan data pengguna.", // Petunjuk untuk pengguna
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),

                // Menampilkan data pengguna secara dinamis
                if (isRequestSent)
                  isResponseReceived
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (person.containsKey("error")) ...[
                              Text(
                                "Status: ${person['error']}", // Menampilkan pesan kesalahan
                                style: TextStyle(color: Colors.red),
                              ),
                            ] else ...[
                              Text(
                                "Status: Respons berhasil diterima", // Status ketika respons berhasil
                                style: TextStyle(color: Colors.green),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Detail Pengguna:", // Label untuk detail pengguna
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text("Nama: ${person['name'] ?? 'N/A'}"),
                              Text("Email: ${person['email'] ?? 'N/A'}"),
                              Text("Telepon: ${person['phone'] ?? 'N/A'}"),
                            ]
                          ],
                        )
                      : isServerResponding
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Status: Server mengirim respons...", // Status ketika server sedang mengirim respons
                                  style: TextStyle(color: Colors.orange),
                                ),
                                SizedBox(height: 10),
                                Text(
                                    "Menunggu respons dari server."), // Menunggu respons
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isRequestSent && isRunning)
                                  Text(
                                    "Status: Mengirim permintaan...", // Status ketika mengirim permintaan
                                    style: TextStyle(color: Colors.orange),
                                  )
                                else
                                  Text(
                                    "Status: Server tidak merespons.", // Status ketika server tidak merespons
                                    style: TextStyle(color: Colors.red),
                                  ),
                                SizedBox(height: 10),
                                Text(isRunning
                                    ? "Menunggu respons dari server." // Menunggu respons
                                    : (isRequestSent
                                        ? ""
                                        : "Belum ada permintaan yang dikirim.")), // Tidak ada permintaan
                              ],
                            )
                else
                  Text(
                      "Belum ada permintaan yang dikirim."), // Ketika belum ada permintaan
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

    // Menggambar garis putus-putus dari Client ke Server (Jalur Permintaan)
    drawDashedLine(
      canvas,
      Offset(50, 50), // Titik awal (Client)
      Offset(size.width - 100, 50), // Titik akhir (Server)
      paint,
    );

    // Menggambar garis putus-putus dari Server ke Client (Jalur Respons)
    drawDashedLine(
      canvas,
      Offset(size.width - 100, 135), // Titik awal (Server)
      Offset(50, 135), // Titik akhir (Client)
      paint,
    );
  }

  // Method untuk menggambar garis putus-putus
  void drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0; // Lebar garis putus-putus
    const dashSpace = 3.0; // Jarak antara garis putus-putus
    final totalDistance = (end - start).distance;
    final dashCount = (totalDistance / (dashWidth + dashSpace)).floor();
    final double dx =
        (end.dx - start.dx) / dashCount; // Perhitungan pergerakan sumbu x
    final double dy =
        (end.dy - start.dy) / dashCount; // Perhitungan pergerakan sumbu y

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
