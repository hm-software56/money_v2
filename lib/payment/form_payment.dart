import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/models/model_payment.dart';
import 'package:money/models/model_type_pay.dart';
import 'package:money/models/model_url.dart';
import 'package:money/payment/list_payment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPayment extends StatefulWidget {
  @override
  _FormPaymentState createState() => _FormPaymentState();
}

class _FormPaymentState extends State<FormPayment> {
  ModelPayment modelpayment = ModelPayment();
  ModelUrl modelurl = ModelUrl();
  ModelTypePay modeltypepay = ModelTypePay();
  Dio dio = Dio();

  List listtypepay = [''];
  var maptypepay;
  bool isloading = true;
  void alert(var title, var detail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Center(
              child: new Text("${title}",
                  style: TextStyle(fontSize: 20.0, color: Colors.red))),
          content: new Text("${detail}"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("ປິດ"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

/*==================== Load list type payment  ==================*/
  Future loadlisttypepayment() async {
    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    try {
      Response response = await dio.get('${modelurl.url}api/listtypepay');
      if (response.statusCode == 200) {
        for (var item in response.data) {
          listtypepay.add('${item['name']}');
        }
        setState(() {
          maptypepay = response.data;
          listtypepay = listtypepay;
        });
        isloading = false;
      }
    } on DioError catch (e) {
      isloading = false;
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

  /*===================== Select date picker =================*/
  Future _chooseDate(BuildContext context, String initialDateString) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initialDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime(2018),
        lastDate: new DateTime(9999));

    if (result == null) return;

    setState(() {
      modelpayment.controller_date.text = new DateFormat.yMd().format(result);
      modelpayment.date = modelpayment.controller_date.text;
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return null;
    }
  }
/* ================= Save date ==============*/
  Future save() async {
    var type_id;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = await prefs.get('token');
    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    print(modelpayment.controller_date.text);
    for (var item in maptypepay) {
      if (item['name'] == modelpayment.controller_type_pay_id.text) {
        type_id = item['id'];
      }
    }

    FormData formData = new FormData.from({
      'type_id': type_id,
      'amount': modelpayment.controller_amount.text,
      'description': modelpayment.controller_description.text,
      'date': modelpayment.controller_date.text,
      'user_id': userID
    });
    try {
      Response response =
          await dio.post('${modelurl.url}api/createpayment', data: formData);
      if (response.statusCode == 200) {
        if (response.data == true) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ListPayment()));
        } else {
          alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', response.data);
        }
      }
    } on DioError catch (e) {
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadlisttypepayment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ປ້ອນ​​ລາ​ຍ​ຈ່າຍ'),
      ),
      body: new Container(
        child: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: <Widget>[
                  InputDecorator(
                    decoration:
                        InputDecoration(labelText: 'ເລືອກ​ປະ​ເພດ​ລາຍ​ຈ່າຍ'),
                    isEmpty: modelpayment.controller_type_pay_id.text == null,
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        value: modelpayment.controller_type_pay_id.text,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            modelpayment.controller_type_pay_id.text = newValue;
                          });
                        },
                        items: listtypepay.map((value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  TextField(
                    controller: modelpayment.controller_amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ຈ​ຳ​ນວນ​ເງີນ',
                    ),
                    onChanged: (value) {
                      modelpayment.amount = value;
                    },
                  ),
                  TextField(
                    controller: modelpayment.controller_description,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ອະ​ທີ​ບາຍ​ຈ່າຍ​ຍັງ',
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        _chooseDate(context, modelpayment.controller_date.text),
                    child: IgnorePointer(
                      child: TextFormField(
                        // validator: widget.validator,
                        controller: modelpayment.controller_date,
                        decoration: InputDecoration(
                          labelText: 'ວັນ​ທີ່​ຈ່າຍ',
                          suffixIcon: Icon(Icons.date_range),
                        ),
                      ),
                    ),
                  ),
                  RaisedButton.icon(
                    color: Colors.blue,
                    label: Text('ບັນ​ທຶກ'),
                    icon: Icon(Icons.save),
                    onPressed: () {
                      save();
                    },
                  )
                ],
              ),
        padding: const EdgeInsets.all(5.0),
        alignment: Alignment.center,
      ),
    );
  }
}
