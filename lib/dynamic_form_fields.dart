import 'dart:convert';

import 'package:dynamic_form_lead/jsonfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class DynamicFormPage extends StatefulWidget {
  final Map<String, dynamic> jsonData;

  DynamicFormPage({required this.jsonData});

  @override
  _DynamicFormPageState createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  String form =
  json.encode({
    "fields": [
      {
        "key": "first_name",
        "type": "Input",
        "label": "First Name",
        "validation": "required"
      },
      {
        "key": "last_name",
        "type": "Input",
        "label": "Last Name",
        "validation": ""
      },
      {
        "key": "email",
        "type": "Input",
        "label": "Email",
        "validation": "required",
      },
      {
        "label": "Phone",
        "key": "phone",
        "type": "Input",
      },
      {"label": "Age", "key": "age", "type": "Input", "validation": "required"},
      {"label": "Age", "key": "age", "type": "Date", "validation": "required"},

      {
        "type": "Select",
        "key": "country",
        "label": "Country",
        'items': [
          {
            'label': "product 1",
            'value': "product 1",
          },
          {
            'label': "product 2",
            'value': "product 2",
          },
          {
            'label': "product 3",
            'value': "product 3",
          }
        ]
      },


      {
        'key': 'radiobutton1',
        'type': 'RadioButton',
        'label': 'Radio Button tests',
        'value': 2,
        'items': [
          {
            'label': "product 1",
            'value': 1,
          },
          {
            'label': "product 2",
            'value': 2,
          },
          {
            'label': "product 3",
            'value': 3,
          }
        ]
      },
      {
        'key': 'switch1',
        'type': 'Switch',
        'label': 'Switch test',
        'value': false,
      },
      {
        'key': 'checkbox1',
        'type': 'Checkbox',
        'label': 'Checkbox test',
        'items': [
          {
            'label': "product 1",
            'value': true,
          },
          {
            'label': "product 2",
            'value': false,
          },
          {
            'label': "product 3",
            'value': false,
          }
        ]
      },

    ],
    "table_name": "data_collection",
    "response_code": 200,
    "response_string": "success"
  });
  bool _progressBarActive = true;

  @override
  void initState() {

    _progressBarActive = false;
    setState(() {

    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dynamic Form')),
      body: getBody(),
    );
  }


  Widget getBody() {
    return _progressBarActive != true
        ? form != ""
        ?  SingleChildScrollView(
      child:  Container(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
          child:  Column(children: <Widget>[
             DynamicFormFromJson(
               autovalidateMode: AutovalidateMode.onUserInteraction,
              form: form,
              onChanged: (dynamic response) {
                // this.response = response;
                print(response);
              },
              actionSave: (data) {
                print(data);
                print(data['fields']);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Sending Message"),
                ));
                // upload(data);
                // datas = data;
              },
              buttonSave:
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 5,
                    bottom: 15,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      // onTap: () {
                      //   if (submitButtonClickEnable) {
                      //     submitValidate();
                      //   }
                      // },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color:Colors.green,
                        ),
                        width: 100,
                        height: 40,
                        child: Center(
                          child: Text(
                            "SUBMIT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: "UbuntuRegular",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ])),
    )
        : Center(
      child: Text("NO DATA"),
    )
        : Center(
      child: const CircularProgressIndicator(),
    );
  }

}
