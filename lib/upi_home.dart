import 'dart:math';
import 'package:flutter/material.dart';
import 'package:upi_pay/upi_pay.dart';

class UpiPayment extends StatefulWidget {
  @override
  _UpiPaymentState createState() => _UpiPaymentState();
}

class _UpiPaymentState extends State<UpiPayment> {

  // used for storing errors.
  String _upiAddrError;

  // used for defining amount and UPI address of merchant where
  // payment is to be received.
  TextEditingController _upiAddressController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  // used for showing list of UPI apps installed in current device
  Future<List<ApplicationMeta>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _amountController.text = (1).toString();

    // we have used sample UPI address (will be used to receive amount)
    _upiAddressController.text = 'sourabhchavan73@okicici';

    // used for getting list of UPI apps installed in current device
    _appsFuture = UpiPay.getInstalledUpiApplications();

    _getAppList();
  }

  _getAppList()async{
    List<ApplicationMeta> upiApps = await UpiPay.getInstalledUpiApplications();
    print(upiApps);
  }

  @override
  void dispose() {

    // dispose text field controllers after use.
    _upiAddressController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // this will open correspondence UPI Payment gateway app on which user has tapped.
  Future<void> _openUPIGateway(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");

    // this function will initiate UPI transaction.
    final a = await UpiPay.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: 'Kapil',
      receiverUpiAddress: _upiAddressController.text,
      transactionNote: "Lunch",
      url: "www.johnshop.com/order/ORD1215236",
      transactionRef: transactionRef,
      merchantCode: '7372',
    );
    print(a);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
        home: Scaffold(
          appBar: AppBar(title: Text('UPI Payment')),
          body: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: _upiAddressController,
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'address@upi',
                                labelText: 'Receiving UPI Address',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_upiAddrError != null)
                      Container(
                        margin: EdgeInsets.only(top: 4, left: 12),
                        child: Text(
                          _upiAddrError,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(top: 32),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              readOnly: true,
                              enabled: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Amount',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 128, bottom: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Pay Using',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                          FutureBuilder<List<ApplicationMeta>>(
                            future: _appsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState != ConnectionState.done) {
                                return Container();
                              }

                              return GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.6,
                                physics: NeverScrollableScrollPhysics(),
                                children: snapshot.data.map((i) => Material(
                                  key: ObjectKey(i.upiApplication),
                                  color: Colors.grey[200],
                                  child: InkWell(
                                    onTap: () => _openUPIGateway(i),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Image.memory(
                                          i.icon,
                                          width: 64,
                                          height: 64,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 4),
                                          child: Text(
                                            i.upiApplication.getAppName(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          ),
        )
    );
  }
}

String _validateUpiAddress(String value) {
  if (value.isEmpty) {
    return 'UPI Address is required.';
  }

  if (!UpiPay.checkIfUpiAddressIsValid(value)) {
    return 'UPI Address is invalid.';
  }

  return null;
}