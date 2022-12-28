import 'package:flutter/material.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/repository/auth_repository.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  void checkAuth() async {
    var token = await StorageProvider.getToken();
    if (token == null) {
      print("token null");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      await AuthRepository().checkAuth(token).then((res) {
        if (res.status == 200) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
