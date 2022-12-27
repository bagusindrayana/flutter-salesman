import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class BayarTagihanPage extends StatefulWidget {
  const BayarTagihanPage({super.key});

  @override
  State<BayarTagihanPage> createState() => _BayarTagihanPageState();
}

class _BayarTagihanPageState extends State<BayarTagihanPage> {
  Tagihan? tagihan;

  DateTime selectedDate = DateTime.now();

  TextEditingController _tanggalBayarController = TextEditingController();
  TextEditingController _totalBayarController = TextEditingController();
  TextEditingController _keteranganController = TextEditingController();

  //datepicker
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        //format date before fill _tanggalBayarController
        _tanggalBayarController.text =
            DateFormat('dd-MM-yyyy').format(selectedDate);
      });
  }

  void bayarTaghan() async {
    UtilityProvider.showLoadingDialog(context);

    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pop(context);
      return;
    } else if (tagihan != null) {
      await TagihanRepository()
          .bayarTagihan(token, tagihan!.sId!, _totalBayarController.text,
              _tanggalBayarController.text, _keteranganController.text)
          .then((value) {
        if (value.status == 200) {
          UtilityProvider.showSnackBar("${value.message}", context);
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
          UtilityProvider.showAlertDialog("Gagal", "${value.message}", context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Duration.zero, () {
      _tanggalBayarController.text =
          DateFormat('dd-MM-yyyy').format(selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    //get argument Tagihan
    tagihan = ModalRoute.of(context)!.settings.arguments as Tagihan;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bayar Tagihan'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Total Tagihan",
                        style: TextStyle(color: Colors.black26),
                      ),
                      subtitle: Text(
                        "${UtilityProvider.formatCurrency("${tagihan!.totalTagihan}")}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Sisa Tagihan",
                        style: TextStyle(color: Colors.black26),
                      ),
                      subtitle: Text(
                        "${UtilityProvider.formatCurrency("${(tagihan!.totalTagihan! - tagihan!.totalBayar!)}")}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    )
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Form(
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await _selectDate(context);
                          },
                          child: TextFormField(
                            onTap: () async {
                              await _selectDate(context);
                            },
                            controller: _tanggalBayarController,
                            readOnly: true,
                            //enabled: false,
                            decoration: InputDecoration(
                              labelText: "Tanggal Tagihan",
                            ),
                          ),
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _totalBayarController,
                          decoration: InputDecoration(
                            labelText: "Jumlah Bayar",
                          ),
                        ),
                        TextFormField(
                          controller: _keteranganController,
                          decoration: InputDecoration(
                            labelText: "Keterangan",
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        ElevatedButton(
                            onPressed: () {
                              bayarTaghan();
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.attach_money),
                                Text("Bayar")
                              ],
                            ))
                      ],
                    )),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
