import 'package:flutter/material.dart';
import 'package:salesman/page/detail_pelanggan.dart';
import 'package:salesman/page/home_page.dart';
import 'package:salesman/page/login_page.dart';
import 'package:salesman/page/pelanggan_page.dart';
import 'package:salesman/page/pilih_lokasi_page.dart';
import 'package:salesman/page/splase_screen_page.dart';
import 'package:salesman/page/tambah_pelanggan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Salesman',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': (context) => const SplashScreenPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/pelanggan': (context) => const PelangganPage(),
          '/detail-pelanggan': (context) => const DetailPelangganPage(),
          '/pilih-lokasi': (context) => const PilihaLokasiPage(),
          '/tambah-pelanggan': (context) => const TambahPelangganPage(),
        });
  }
}
