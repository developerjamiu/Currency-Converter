import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../business_logic/utils/iso_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = TextEditingController();
  bool isLoading = false;

  String baseCurrencyCode = 'NGN';
  String baseCurrencyName = 'Naira';

  String targetCurrencyCode = 'USD';
  String targetCurrencyName = 'US Dollar';
  String targetAmount = '?';

  TextStyle baseCurrencyStyle = TextStyle(
    color: Colors.white,
    fontSize: 24.0,
  );

  TextStyle targetCurrencyStyle = TextStyle(
    color: Colors.indigo,
    fontSize: 24.0,
  );

  TextStyle baseAmountInputHint = TextStyle(
    fontSize: 36.0,
    color: Colors.grey,
  );

  TextStyle baseAmountInput = TextStyle(
    fontSize: 56.0,
    color: Colors.white,
  );

  TextStyle targetAmountInput = TextStyle(
    fontSize: 56.0,
    color: Colors.indigo,
  );

  void convertCurrency(String base, String target, String amount) async {
    final _host = 'api.exchangerate.host';
    final _path = 'convert';

    final uri = Uri.https(
      _host,
      _path,
      {'from': base, 'to': target, 'amount': amount},
    );

    setState(() {
      isLoading = true;
    });

    final results = await http.get(uri).timeout(
      Duration(seconds: 15),
      onTimeout: () {
        return null;
      },
    );

    final jsonObject = json.decode(results.body);

    setState(() {
      isLoading = false;
      targetAmount = jsonObject['result'].toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                baseCurrency(context),
                targetCurrency(context),
              ],
            ),
            convertButton(context),
          ],
        ),
      ),
    );
  }

  Widget baseCurrency(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 32.0),
              child: Text(
                baseCurrencyName.toUpperCase(),
                style: baseCurrencyStyle,
              ),
            ),
            Expanded(
              child: Center(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: baseAmountInput,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Enter Amount',
                    hintStyle: baseAmountInputHint,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: 48.0,
              ),
              child: DropdownButton<String>(
                value: baseCurrencyCode,
                icon: Icon(Icons.arrow_downward, color: Colors.grey),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 24.0,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.grey,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    baseCurrencyCode = newValue;
                    baseCurrencyName = IsoData.longNameOf(baseCurrencyCode);
                  });
                },
                items: IsoData.data.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget targetCurrency(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 48.0,
              ),
              child: DropdownButton<String>(
                value: targetCurrencyCode,
                icon: Icon(Icons.arrow_downward, color: Colors.grey),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 24.0,
                ),
                underline: Container(
                  height: 2,
                  color: Colors.grey,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    targetCurrencyCode = newValue;
                    targetCurrencyName = IsoData.longNameOf(targetCurrencyCode);
                  });
                },
                items: IsoData.data.keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  targetAmount,
                  style: targetAmountInput,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: Text(
                targetCurrencyName.toUpperCase(),
                style: targetCurrencyStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget convertButton(BuildContext context) {
    return Center(
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        radius: 40.0,
        child: CircleAvatar(
          radius: 35.0,
          backgroundColor: Colors.white,
          child: isLoading
              ? CircularProgressIndicator()
              : IconButton(
                  iconSize: 48.0,
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () {
                    convertCurrency(baseCurrencyCode, targetCurrencyCode,
                        controller.text ?? 0);
                  },
                ),
        ),
      ),
    );
  }
}
