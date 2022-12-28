import 'package:flutter/material.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class TagihanPage extends StatefulWidget {
  const TagihanPage({super.key});

  @override
  State<TagihanPage> createState() => _TagihanPageState();
}

class _TagihanPageState extends State<TagihanPage> {
  List<Tagihan> listTagihan = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getTagihan() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    } else {
      await TagihanRepository().getAllTagihan(token).then((res) {
        if (res.status == 200) {
          setState(() {
            listTagihan = res.data!;
          });
        } else if (res.status == 401) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res.message!),
          ));
        }
      });
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      getTagihan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Tagihan"),
      ),
      body: RefreshIndicator(
          child: (listTagihan.length > 0)
              ? ListView.builder(
                  itemCount: listTagihan.length,
                  itemBuilder: (context, index) {
                    var tanggalTagihan = listTagihan[index].tanggalTagihan;
                    //format string to date
                    var date = DateTime.parse(tanggalTagihan!);
                    //add 7 days to date
                    var date7 = date.add(Duration(days: 7));
                    //get YYYY-MM-DD
                    var date7String = date7.toString().substring(0, 10);
                    return Card(
                      child: ListTile(
                        onTap: () {},
                        title:
                            Text("${listTagihan[index].pelanggan!.namaUsaha}"),
                        subtitle: Row(
                          children: [
                            Text(
                                '${UtilityProvider.formatCurrency("${listTagihan[index].totalTagihan}")}'),
                            Text("/"),
                            Text(
                              '${UtilityProvider.formatCurrency("${listTagihan[index].totalBayar}")}',
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                "${DateTime.parse(tanggalTagihan!).toString().substring(0, 10)}"),
                            Container(
                              height: 2,
                              width: 70,
                              color: Colors.black26,
                            ),
                            Text(
                              "${date7String}",
                              style: TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Tidak ada data"),
                  ),
                ),
          onRefresh: () async {
            getTagihan();
          }),
    );
  }
}
