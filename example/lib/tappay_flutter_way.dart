import 'package:flutter/material.dart';
import 'package:flutter_tappay/flutter_tappay.dart';

class TappayFlutterScreen extends StatefulWidget {
  @override
  _TappayFlutterScreenState createState() => _TappayFlutterScreenState();
}

class _TappayFlutterScreenState extends State<TappayFlutterScreen> {
  String _token;
  FlutterTappay payer;
  bool prepared = false;

  TextEditingController _cardNumber;
  TextEditingController _cardMonth;
  TextEditingController _cardYear;
  TextEditingController _cardCCV;

  bool _isCardNumberValid = true;
  bool _isCardCCVValid = true;
  bool _isCardYearValid = true;
  bool _isCardMonthValid = true;
  bool _totalValid = false;

  @override
  void initState() {
    super.initState();
    payer = FlutterTappay();
    payer.init(
        appKey: "app_whdEWBH8e8Lzy4N6BysVRRMILYORF6UxXbiOFsICkz0J9j1C0JUlCHv1tVJC",
        appId: 11334,
        serverType: FlutterTappayServerType.Sandbox
    ).then((_){
      setState(() {
        prepared = true;
      });
    });

    Function validator = () {
      payer.validate(
        cardNumber: _cardNumber.text,
        dueMonth: _cardMonth.text,
        dueYear: _cardYear.text,
        ccv: _cardCCV.text,
      ).then((validationResult) {
        bool cardValid = validationResult.isCardNumberValid;
        bool dateValid = validationResult.isExpiryDateValid;
        bool ccvValid = validationResult.isCCVValid;
        _totalValid = cardValid && ccvValid && dateValid;
        if(cardValid == true)
          _isCardNumberValid = true;
        else
          _isCardNumberValid = _cardNumber.text != "" ? false : true;
        if(ccvValid == true)
          _isCardCCVValid = true;
        else
          _isCardCCVValid = _cardCCV.text != "" ? false : true;
        if(dateValid == true) {
          _isCardYearValid = true;
          _isCardMonthValid = true;
        } else {
          _isCardYearValid = _cardYear.text != "" ? false : true;
          _isCardMonthValid = _cardMonth.text != "" ? false : true;
        }

        setState(() {
        });
      });

    };

    _cardNumber = new TextEditingController(text: "")..addListener(validator);
    _cardMonth = new TextEditingController(text: "")..addListener(validator);
    _cardYear = new TextEditingController(text: "")..addListener(validator);
    _cardCCV = new TextEditingController(text: "")..addListener(validator);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: Column(
            children: <Widget>[
              Text("All validL: $_totalValid"),
              Text("Prepared: $prepared"),
              Text("Token on: $_token"),
              TextFormField(
                maxLength: 16,
                controller: _cardNumber,
                validator: (v) => _isCardNumberValid ? null : "卡號不正確",
                autovalidate: true,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 48,
                    child: TextFormField(
                      controller: _cardMonth,
                      validator: (v) => _isCardMonthValid ? null : "月份不正確",
                      maxLength: 2,
                      autovalidate: true,
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    child: TextFormField(
                      controller: _cardYear,
                      maxLength: 2,
                      validator: (v) => _isCardYearValid ? null : "年分不正確",
                      autovalidate: true,
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 48,
                    child: TextFormField(
                      controller: _cardCCV,
                      maxLength: 3,
                      validator: (v) => _isCardCCVValid ? null : "CCV不正確",
                      autovalidate: true,
                    ),
                  ),
                ],
              )
            ],
          )
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            child: Icon(Icons.send),
            onPressed: !_totalValid ? null : () async {
              try {
                TappayTokenResponse response = await payer.sendToken(
                  cardNumber: _cardNumber.text,
                  dueYear: _cardYear.text,
                  dueMonth: _cardMonth.text,
                  ccv: _cardCCV.text,
                );
                setState(() {
                  _token = response.prime;
                });
              } catch(err) {
                print(err.toString());
                Scaffold.of(context).showSnackBar(
                    SnackBar(
                        content: Text("金流付款發生錯誤: ${err.toString()}")
                    )
                );
              }
            },
          );
        }
      )

    );
  }
}