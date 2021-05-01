import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  String _email;
  String _password;
  String _parentName;
  String _childName;
  String _contactNumber;

  Future<void> _submitForm() async {
    UserCredential userCredential;

    if (!_formKey.currentState.validate()) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      FocusScope.of(context).unfocus();

      final _auth = FirebaseAuth.instance;
      userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email.trim(),
        password: _password.trim(),
      );

      var _firebaseRef = FirebaseDatabase()
          .reference()
          .child('Parents/${userCredential.user.uid}');

      await _firebaseRef.set({
        "Parent Name": _parentName.trim(),
        "Child Name": _childName.trim(),
        "Contact Number": _contactNumber.trim(),
        'Email Id': _email.trim(),
        'QR Code': '',
        'Trip': 'false',
      });

      setState(() {
        _isLoading = false;
      });
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
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(labelText: "Parent's Name"),
            onChanged: (value) {
              _parentName = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return "Parent's name can't be empty.";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Child Name'),
            onChanged: (value) {
              _childName = value;
            },
            validator: (value) {
              if (value.isEmpty) {
                return "Child name can't be empty.";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Contact Number'),
            onChanged: (value) {
              _contactNumber = value;
            },
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value.isEmpty) {
                return "Please provide a valid contact number.";
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Email Address'),
            onChanged: (value) {
              _email = value;
            },
            validator: (email) {
              bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(email);
              if (!emailValid) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: InputDecoration(labelText: 'Password'),
            onChanged: (value) {
              _password = value;
            },
            validator: (value) {
              if (value.length < 8) {
                return 'Password must be at least 8 characters.';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : FlatButton(
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    onPressed: _submitForm,
                    child:
                        Text('SIGN UP', style: TextStyle(color: Colors.white)),
                  ),
          ),
        ],
      ),
    );
  }
}
