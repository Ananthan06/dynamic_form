import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class JsonSchema extends StatefulWidget {
  const JsonSchema({
    required this.form,
    required this.onChanged,
    this.padding,
    this.formMap,
    this.errorMessages = const {},
    this.validations = const {},
    this.decorations = const {},
    this.buttonSave,
    this.actionSave,
  });

  final Map errorMessages;
  final Map validations;
  final Map decorations;
  final String form;
  final Map? formMap;
  final double? padding;
  final Widget? buttonSave;
  final Function? actionSave;
  final ValueChanged<dynamic> onChanged;

  @override
  _CoreFormState createState() => _CoreFormState(formMap ?? json.decode(form));
}

class _CoreFormState extends State<JsonSchema> {
  final dynamic formGeneral;

  int? radioValue;
  String? userSelected;
  var countyName = TextEditingController();

  var fermentableName = TextEditingController();

  // validators

  String isRequired(item, value) {
    if (value.isEmpty) {
      return widget.errorMessages[item['key']] ?? 'This field is required!';
    }
    return '';
  }

  String validateEmail(item, String value) {
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = RegExp(p);

    if (regExp.hasMatch(value)) {
      return '';
    }
    return 'Email is not valid';
  }

  String validatePhone(item, String value) {
    if (value.length != 10)
      return 'Mobile Number must be of 10 digit';
    else
      return '';
  }

  bool labelHidden(item) {
    if (item.containsKey('hiddenLabel')) {
      if (item['hiddenLabel'] is bool) {
        return !item['hiddenLabel'];
      }
    } else {
      return true;
    }
    return false;
  }

  // Return widgets

  List<Widget> jsonToForm() {
    List<Widget> listWidget = [];
    if (formGeneral['title'] != null) {
      listWidget.add(Text(
        formGeneral['title'],
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ));
    }
    if (formGeneral['description'] != null) {
      listWidget.add(Text(
        formGeneral['description'],
        style: const TextStyle(fontSize: 14.0, fontStyle: FontStyle.italic),
      ));
    }

    for (var count = 0; count < formGeneral['fields'].length; count++) {
      Map item = formGeneral['fields'][count];

      if (item['type'] == "Phone" ||
          item['type'] == "Password" ||
          item['type'] == "Email" ||
          item['type'] == "TextArea" ||
          item['type'] == "Input") {
        Widget label = const SizedBox.shrink();
        if (labelHidden(item)) {
          label = Container(
            child: Text(
              item['label'],
              style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'UbuntuRegular',
                  color: Colors.grey),
            ),
          );
        }

        listWidget.add(Container(
          margin: const EdgeInsets.only(top: 10.0),
          child: ListTile(
            // leading: Container(
            //   width: .5,
            // ),
            title: Container(
              // padding: EdgeInsets.only(
              // left: SizeConfig.safeBlockVertical * 1.5
              // top: SizeConfig.safeBlockVertical * 1.5
              // ),
              child: label,
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(
                  // left: SizeConfig.safeBlockVertical * 1.5,
                  right: 5,
                  bottom: 5),
              child: TextFormField(
                textInputAction:
                    item['type'] == "TextArea" ? null : TextInputAction.next,
                textAlign: TextAlign.start,
                textCapitalization: TextCapitalization.words,
                controller: null,
                initialValue: formGeneral['fields'][count]['value'],
                decoration: item['decoration'] ??
                    widget.decorations[item['key']] ??
                    InputDecoration(
                      // hintText: item['placeholder'] ?? "",
                      // helperText: item['helpText'] ?? "",
                      contentPadding: const EdgeInsets.only(
                        top: 2,
                        bottom: 2,
                      ),
                      isDense: true,
                      hintText: 'Enter ' + item['label'],
                      hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontFamily: 'UbuntuRegular'),
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 1.0,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                maxLines: item['type'] == "TextArea" ? 5 : 1,
                // keyboardType: item['type'] == "Phone" ? TextInputType.phone : TextInputType.text,
                keyboardType: item['type'] == "Phone"
                    ? TextInputType.phone
                    : item['type'] == "TextArea"
                        ? TextInputType.multiline
                        : TextInputType.text,
                onChanged: (String value) {
                  formGeneral['fields'][count]['value'] = value;
                  _handleChanged();
                },
                obscureText: item['type'] == "Password" ? true : false,
                validator: (value) {
                  if (widget.validations.containsKey(item['key'])) {
                    return widget.validations[item['key']](item, value);
                  }
                  if (item.containsKey('validator')) {
                    if (item['validator'] != null) {
                      if (item['validator'] is Function) {
                        return item['validator'](item, value);
                      }
                    }
                  }

                  if (item['type'] == "Email") {
                    if (item['required'] == true ||
                        item['required'] == 'True' ||
                        item['required'] == 'true') {
                      return validateEmail(item, value!);
                    }
                  }
                  if (item['type'] == "Phone") {
                    if (item['required'] == true ||
                        item['required'] == 'True' ||
                        item['required'] == 'true') {
                      return validatePhone(item, value!);
                    }
                  }

                  if (item.containsKey('required')) {
                    if (item['required'] == true ||
                        item['required'] == 'True' ||
                        item['required'] == 'true') {
                      return isRequired(item, value);
                    }
                  }

                  return null;
                },
                // inputFormatters: item['validator'] != null && item['validator'] != ''
                //     ? [
                //   if (item['validator'] == 'digitsOnly')
                //     FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                //   if (item['validator'] == 'textOnly')
                //     FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
                // ]
                //     : null,
              ),
            ),
          ),
        ));
      }

      if (item['type'] == "RadioButton") {
        List<Widget> radios = [];

        if (labelHidden(item)) {
          radios.add(Text(item['label'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16.0)));
        }
        radioValue = item['value'];
        for (var i = 0; i < item['items'].length; i++) {
          radios.add(
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                        formGeneral['fields'][count]['items'][i]['label'])),
                Radio<int>(
                    value: formGeneral['fields'][count]['items'][i]['value'],
                    groupValue: radioValue,
                    onChanged: (int? value) {
                      setState(() {
                        radioValue = value!;
                        formGeneral['fields'][count]['value'] = value;
                        _handleChanged();
                      });
                    })
              ],
            ),
          );
        }

        listWidget.add(
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: radios,
            ),
          ),
        );
      }

      if (item['type'] == "Switch") {
        if (item['value'] == null) {
          formGeneral['fields'][count]['value'] = false;
        }
        listWidget.add(
          Container(
            margin: const EdgeInsets.only(top: 5.0),
            child: Row(children: <Widget>[
              Expanded(child: Text(item['label'])),
              Switch(
                value: item['value'] ?? false,
                onChanged: (bool value) {
                  setState(() {
                    formGeneral['fields'][count]['value'] = value;
                    _handleChanged();
                  });
                },
              ),
            ]),
          ),
        );
      }

      selectStartDate() {
        showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2101))
            .then((DateTime? picked) {
          if (picked != null) {
            // formatted_Start_Date = DateFormat('yyyy-MM-dd').format(picked);
            // debugPrint("Date is $formatted_Start_Date");
            // selected_Start_Date = picked;
            setState(() {
              // startDate = formatted_Start_Date;
              formGeneral['fields'][count]['value'] =
                  DateFormat('yyyy-MM-dd').format(picked).toString();
              _handleChanged();
//          LeadListStage.lead_start_date_ =formatted_Start_Date;
            });
          } else {} /*else {
              formatted_Start_Date = DateFormat('yyyy-MM-dd').format(DateTime.now());
              debugPrint("Date is $formatted_Start_Date");
              selected_Start_Date = picked;
              setState(() {
                startDate = formatted_Start_Date;
              });
            }*/
        });
      }

      if (item['type'] == "Date") {
        if (item['value'] == null) {
          formGeneral['fields'][count]['value'] =
              DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
        }
        listWidget.add(
          Container(
            height: 40,
            width: 200,
            margin: const EdgeInsets.all(15.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    item['label'],
                    style: TextStyle(color: Colors.grey),
                  )),
                  InkWell(
                    onTap: () {
                      selectStartDate();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox.fromSize(
                          size: const Size(15, 15),
                          child: const Icon(Icons.date_range),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 15, top: 10),
                          child: Text(formGeneral['fields'][count]['value'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontFamily: 'UbuntuMedium',
                              )),
                        )
                      ],
                    ),
                  ),
                ]),
          ),
        );
      }

      if (item['type'] == "Checkbox") {
        List<Widget> checkboxes = [];
        if (labelHidden(item)) {
          checkboxes.add(Text(item['label'],
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16.0)));
        }
        for (var i = 0; i < item['items'].length; i++) {
          checkboxes.add(
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                        formGeneral['fields'][count]['items'][i]['label'])),
                Checkbox(
                  value: formGeneral['fields'][count]['items'][i]['value'],
                  onChanged: (bool? value) {
                    setState(
                      () {
                        formGeneral['fields'][count]['items'][i]['value'] =
                            value;
                        _handleChanged();
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }

        listWidget.add(
          Container(
            margin: const EdgeInsets.only(top: 5.0,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: checkboxes,
            ),
          ),
        );
      }

      if (item['type'] == "Select") {
        Widget label = const SizedBox.shrink();
        if (labelHidden(item)) {
          label = Text(item['label'],
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0));
        }

        listWidget.add(Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              label,
              Padding(
                padding: const EdgeInsets.only(top: 10,bottom: 20),
                child: SizedBox(
                    height: 40,
                    width: double.infinity,
                    child: TypeAheadField(
                      noItemsFoundBuilder: (context) => const SizedBox(
                        height: 50,
                        child: Center(
                          child: Text('No Item Found'),
                        ),
                      ),
                      suggestionsBoxDecoration: const SuggestionsBoxDecoration(
                          color: Colors.white,
                          elevation: 4.0,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          )),
                      debounceDuration: const Duration(milliseconds: 400),
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: countyName,
                          decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        hintText: "Search",
                        contentPadding: const EdgeInsets.only(top: 4, left: 10),
                        hintStyle:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        suffixIcon: IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.black)),
                        //fillColor: Colors.white,
                        //filled: true
                      )),
                      suggestionsCallback: (value) {
                        return getSuggestions(value);
                      },
                      itemBuilder: (context, String suggestion) {
                        return Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.refresh,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  suggestion,
                                  maxLines: 1,
                                  // style: TextStyle(color: Colors.red),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          ],
                        );
                      },
                      onSuggestionSelected: (String suggestion) {
                        setState(() {
                          userSelected = suggestion;
                          countyName.text = suggestion;
                        });
                      },

                    )),
              ),
            ],
          ),
        ));
      }
    }

    if (widget.buttonSave != null) {
      listWidget.add(Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState!.validate()) {
              widget.actionSave!(formGeneral);
            }
          },
          child: widget.buttonSave,
        ),
      ));
    }
    return listWidget;
  }

  _CoreFormState(this.formGeneral);

  void _handleChanged() {
    widget.onChanged(formGeneral);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
      // autovalidateMode: formGeneral['autoValidated'] ?? false,
      key: _formKey,
      child: Container(
        padding: EdgeInsets.all(widget.padding ?? 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: jsonToForm(),
        ),
      ),
    );
  }

  static final List<String> states = [
    'ANDAMAN AND NICOBAR ISLANDS',
    'ANDHRA PRADESH',
    'ARUNACHAL PRADESH',
    'ASSAM',
    'BIHAR',
    'CHATTISGARH',
    'CHANDIGARH',
    'DAMAN AND DIU',
    'DELHI',
    'DADRA AND NAGAR HAVELI',
    'GOA',
    'GUJARAT',
    'HIMACHAL PRADESH',
    'HARYANA',
    'JAMMU AND KASHMIR',
    'JHARKHAND',
    'KERALA',
    'KARNATAKA',
    'LAKSHADWEEP',
    'MEGHALAYA',
    'MAHARASHTRA',
    'MANIPUR',
    'MADHYA PRADESH',
    'MIZORAM',
    'NAGALAND',
    'ORISSA',
    'PUNJAB',
    'PONDICHERRY',
    'RAJASTHAN',
    'SIKKIM',
    'TAMIL NADU',
    'TRIPURA',
    'UTTARAKHAND',
    'UTTAR PRADESH',
    'WEST BENGAL',
    'TELANGANA',
    'LADAKH'
  ];

  static List<String> getSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(states);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
