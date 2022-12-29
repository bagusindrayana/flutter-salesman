import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman/model/tagihan.dart';
import 'package:salesman/provider/storage_provider.dart';
import 'package:salesman/provider/utility_provider.dart';
import 'package:salesman/repository/tagihan_repository.dart';

class DetailTagihanPage extends StatefulWidget {
  const DetailTagihanPage({super.key});

  @override
  State<DetailTagihanPage> createState() => _DetailTagihanPageState();
}

class _DetailTagihanPageState extends State<DetailTagihanPage> {
  Tagihan? tagihan;
  TextEditingController _tanggalTagihanController = TextEditingController();
  TextEditingController _totalTagihanController = TextEditingController();
  TextEditingController _keteranganController = TextEditingController();
  bool uangCash = false;
  DateTime selectedDate = DateTime.now();

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        //format date before fill _tanggalTagihanController
        _tanggalTagihanController.text =
            DateFormat('dd-MM-yyyy').format(selectedDate);
      });
  }

  void updateTagihan() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      await TagihanRepository()
          .updateTagihan(
              token,
              tagihan!.sId!,
              Tagihan(
                tanggalTagihan: _tanggalTagihanController.text,
                totalTagihan: int.parse(_totalTagihanController.text),
                keterangan: _keteranganController.text,
                cash: uangCash,
              ))
          .then((value) {
        if (value.status == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value.message!),
          ));
          Navigator.pop(context);
        } else if (value.status == 401) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(value.message!),
          ));
        }
      });
    }
    Navigator.pop(context);
  }

  void hapusTagihan() async {
    UtilityProvider.showLoadingDialog(context);
    var token = await StorageProvider.getToken();
    if (token == null) {
      Navigator.of(context).pop();
      return;
    } else {
      await TagihanRepository()
          .hapusTagihan(token, tagihan!.sId!)
          .then((value) {
        if (value.status == 200) {
          Navigator.of(context).pop();

          UtilityProvider.showSnackBar("${value.message}", context);
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
          UtilityProvider.showAlertDialog("Gagal", "${value.message}", context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    tagihan = ModalRoute.of(context)!.settings.arguments as Tagihan;
    // tstring to date
    selectedDate = DateTime.parse(tagihan!.tanggalTagihan.toString());

    _tanggalTagihanController.text = tagihan!.tanggalTagihan.toString();
    _totalTagihanController.text = (tagihan!.totalTagihan ?? 0).toString();
    _keteranganController.text = tagihan!.keterangan.toString();
    uangCash = tagihan!.cash ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tagihan'),
        actions: [
          IconButton(
            onPressed: () {
              //alert
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Hapus Tagihan"),
                      content: Text(
                          "Apakah anda yakin ingin menghapus tagihan ini?"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () {
                            hapusTagihan();
                          },
                          child: Text("Hapus"),
                        ),
                      ],
                    );
                  });
            },
            icon: Icon(Icons.delete),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: (tagihan != null)
                ? Column(children: [
                    SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _selectDate(context);
                      },
                      child: TextFormField(
                        onTap: () async {
                          await _selectDate(context);
                        },
                        controller: _tanggalTagihanController,
                        readOnly: true,
                        //enabled: false,
                        decoration: InputDecoration(
                          labelText: "Tanggal Tagihan",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: _totalTagihanController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Total Tagihan",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          value: uangCash,
                          onChanged: (bool? value) {
                            setState(() {
                              uangCash = uangCash!;
                            });
                          },
                        ),
                        GestureDetector(
                          onTap: (() {
                            setState(() {
                              uangCash = !uangCash;
                            });
                          }),
                          child: Text("Uang Cash"),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    //multiline TextFormField
                    TextFormField(
                      controller: _keteranganController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "Keterangan Tambahan",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () {
                                  updateTagihan();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text("Simpan")
                                  ],
                                )))
                      ],
                    )
                  ])
                : Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
