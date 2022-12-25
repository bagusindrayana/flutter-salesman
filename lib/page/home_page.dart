import 'package:flutter/material.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/stat_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? total_tagihan;
  int? total_pelanggan;

  void getStat() async {
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    UtilityProvider.showLoadingDialog(context);
    await StatRepository().getStat(token).then((value) {
      print(value.data);
      if (value.status == 200) {
        setState(() {
          total_tagihan = value.data['total_tagihan'];
          total_pelanggan = value.data['total_pelanggan'];
        });
      } else {
        UtilityProvider.showSnackBar(value.message!, context);
      }
    });
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getStat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Salesman"),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            getStat();
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: GridView.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: [
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.bar_chart, size: 50),
                      ListTile(
                        title: Text(
                          "${(total_tagihan == null) ? 'loading...' : total_tagihan}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tagihan yang belum dibayar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.people, size: 50),
                      ListTile(
                        title: Text(
                          "${(total_pelanggan == null) ? 'loding...' : total_pelanggan}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Total Pelanggan',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Welcome'),
            ),
            ListTile(
              title: const Text('Pelanggan'),
              onTap: () {
                Navigator.pushNamed(context, '/pelanggan');
              },
            ),
            ListTile(
              title: const Text('Tagihan'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
    );
  }
}
