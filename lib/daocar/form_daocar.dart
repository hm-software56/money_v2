import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money/daocar/list_daocar.dart';
import 'package:money/login.dart';
import 'package:money/models/model_daocar.dart';
import 'package:money/models/model_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormDaocar extends StatefulWidget {
  var id;
  FormDaocar(this.id);
  @override
  _FormDaocarState createState() => _FormDaocarState(this.id);
}

class _FormDaocarState extends State<FormDaocar> {
  var id;
  _FormDaocarState(this.id);
  ModelDaocar modeldaocar = ModelDaocar();
  ModelUrl modelurl = ModelUrl();
  Dio dio = Dio();
  List liststatus = ['', 'ເກັບ​ໄວ້', '​ຈ່າຍ', '​ເອົາ​ໄປ​ໃຊ້​ແນວ​ອື່ນ'];
  Map mapstatus = {
    'Saving': 'ເກັບ​ໄວ້',
    'Paid': '​ຈ່າຍ',
    'remark': '​ເອົາ​ໄປ​ໃຊ້​ແນວ​ອື່ນ'
  };
  Map mapsavestatus = {
    'ເກັບ​ໄວ້': 'Saving',
    '​ຈ່າຍ': 'Paid',
    '​ເອົາ​ໄປ​ໃຊ້​ແນວ​ອື່ນ': 'remark'
  };
  bool isloading = true;
  bool isloadingsave = false;

  /*========== Login expired ================*/
  Future<Null> checkloginexiped() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var now = new DateTime.now();
    var formatter = new DateFormat('h');
    String formatted = formatter.format(now);
    if (int.parse(formatted) > prefs.getInt('time')) {
      prefs.remove('token');
      prefs.remove('time');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      prefs.setInt('time', int.parse(formatted) + 2);
    }
  }
  /*================ alert ================*/
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

/*==================== Load data daocar show to field  ==================*/
  Future loaddatadaocar() async {
    if (id != null) {
      dio.options.connectTimeout = 3000; //5s
      dio.options.receiveTimeout = 3000;
      try {
        Response response =
            await dio.get('${modelurl.url}api/listdaocarpk', data: {'id': id});
        if (response.statusCode == 200) {
          setState(() {
            modeldaocar.controller_amount.text = response.data['amount'];
            modeldaocar.controller_status.text =
                mapstatus[response.data['status']];
            modeldaocar.controller_date.text = response.data['date'];
            modeldaocar.controller_remark.text = response.data['remark'];

            isloading = false;
          });
        }
      } on DioError catch (e) {
        setState(() {
          isloading = false;
        });
        alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
      }
    } else {
      setState(() {
        isloading = false;
      });
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
      modeldaocar.controller_date.text = new DateFormat.yMd().format(result);
      modeldaocar.date = modeldaocar.controller_date.text;
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

/* ================= Save datata ==============*/
  Future save() async {
    setState(() {
      isloadingsave = true;
    });
    dio.options.connectTimeout = 3000; //5s
    dio.options.receiveTimeout = 3000;
    FormData formData = new FormData.from({
      'amount': modeldaocar.controller_amount.text,
      'status': mapsavestatus[modeldaocar.controller_status.text],
      'date': modeldaocar.controller_date.text,
      'remark': modeldaocar.controller_remark.text,
      'id': id, // use for create or update if id=null is create
    });
    try {
      Response response = await dio
          .post('${modelurl.url}api/createorupdatedaocar', data: formData);
      if (response.statusCode == 200) {
        setState(() {
          isloadingsave = false;
        });
        if (response.data == true) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ListDaocar()));
        } else {
          alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', response.data);
        }
      }
    } on DioError catch (e) {
      setState(() {
        isloadingsave = false;
      });
      alert('ມີ​ຂ​ໍ້​ຜິດ​ພາດ', 'ກວດ​ເບີ່ງ​ການ​ເຊື່ອມ​ຕໍ່​ເນັ​ດ.!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkloginexiped();
    loaddatadaocar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: id == null
            ? Text('ປ້ອນ​​ສຳ​ລະ​ຄ່າ​ລົດ')
            : Text('​ແກ້​ໄຂສຳ​ລະ​ຄ່າ​ລົດ'),
      ),
      body: new Container(
        child: isloading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: EdgeInsets.only(top: 50.0),
                children: <Widget>[
                  TextField(
                    controller: modeldaocar.controller_amount,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ຈ​ຳ​ນວນ​ເງີນສຳ​ລະ',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                    onChanged: (value) {
                      modeldaocar.amount = value;
                    },
                  ),
                  SizedBox(height: 20.0),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'ເລືອກ​ສະ​ຖາ​ນະ',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                    isEmpty: modeldaocar.controller_status.text == null,
                    child: new DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        value: modeldaocar.controller_status.text,
                        isDense: true,
                        onChanged: (String newValue) {
                          setState(() {
                            modeldaocar.controller_status.text = newValue;
                          });
                        },
                        items: liststatus.map((value) {
                          return new DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: modeldaocar.controller_remark,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'ຄຳ​ຄິດ​ເຫັນ',
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  InkWell(
                    onTap: () =>
                        _chooseDate(context, modeldaocar.controller_date.text),
                    child: IgnorePointer(
                      child: TextFormField(
                        // validator: widget.validator,
                        controller: modeldaocar.controller_date,
                        decoration: InputDecoration(
                          labelText: 'ວັນ​ທີ່​ສຳ​ລະ',
                          contentPadding:
                              EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                          suffixIcon: Icon(Icons.date_range),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  isloadingsave
                      ? Center(child: CircularProgressIndicator())
                      : RaisedButton.icon(
                          color: Colors.blue,
                          label: Text(
                            'ບັນ​ທຶກ',
                            style: TextStyle(color: Colors.white),
                          ),
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
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
