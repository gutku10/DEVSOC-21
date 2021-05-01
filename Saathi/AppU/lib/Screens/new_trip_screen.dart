import 'package:AppU/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class NewTripScreen extends StatefulWidget {
  static const routeName = '/new-trip-screen';

  final Function changePageCallback;

  NewTripScreen({
    this.changePageCallback,
  });

  @override
  _NewTripScreenState createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  bool _isLoading = false;

  Future<void> _scanAndSubmitTripNumber(BuildContext context) async {
    String cameraScanResult = await scanner.scan();
    //String cameraScanResult = '5963358';

    try {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;

      var _firebaseRef =
          FirebaseDatabase().reference().child('Parents/${user.uid}');

      await _firebaseRef.update({
        'QR Code': cameraScanResult,
        'Trip': 'true',
      });

      setState(() {
        _isLoading = false;
      });
      widget.changePageCallback(1);
    } on FirebaseAuthException catch (error) {
      setState(() {
        _isLoading = false;
      });
      String errorMessage = 'An error occurred, please check your credentials!';

      if (error.message != null) {
        errorMessage = error.message;
      }

      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(firstLine: 'Scan and', secondLine: 'start trip'),
          Expanded(
            child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : FlatButton.icon(
                      onPressed: () => _scanAndSubmitTripNumber(context),
                      icon: Icon(
                        Icons.qr_code_scanner,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
                      label: Text(
                        'Scan',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
