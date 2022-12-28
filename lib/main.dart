import 'package:flutter/material.dart';
import 'package:salesman/page/tagihan/bayar_tagihan_page.dart';
import 'package:salesman/page/home_page.dart';
import 'package:salesman/page/login_page.dart';
import 'package:salesman/page/pelanggan/detail_pelanggan.dart';
import 'package:salesman/page/pelanggan/pelanggan_page.dart';
import 'package:salesman/page/pelanggan/tambah_pelanggan_page.dart';
import 'package:salesman/page/pelanggan/ubah_pelanggan_page.dart';
import 'package:salesman/page/peta_rute_page.dart';
import 'package:salesman/page/pilih_lokasi_page.dart';
import 'package:salesman/page/splase_screen_page.dart';
import 'package:salesman/page/tagihan/detail_tagihan_page.dart';
import 'package:salesman/page/tagihan/tagihan_page.dart';
import 'package:salesman/page/tambah_pembayaran_page.dart';

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
          '/tagihan': (context) => const TagihanPage(),
          '/detail-tagihan': (context) => const DetailTagihanPage(),
          '/pilih-lokasi': (context) => const PilihaLokasiPage(),
          '/tambah-pelanggan': (context) => const TambahPelangganPage(),
          '/ubah-pelanggan': (context) => const UbahPelangganPage(),
          '/bayar-tagihan': (context) => const BayarTagihanPage(),
          '/tambah-pembayaran': (context) => const TamabahPembayaranPage(),
          '/peta-rute': (context) => const PetaRutePage(),
        });
  }
}
