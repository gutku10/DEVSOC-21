import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _email;
  String _password;

  Future<void> _submitForm() async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    try {
      setState(() {
        _isLoading = true;
      });

      final _auth = FirebaseAuth.instance;
      await _auth.signInWithEmailAndPassword(
        email: _email.trim(),
        password: _password.trim(),
      );
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
            decoration: InputDecoration(labelText: 'Email'),
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
              if (value.isEmpty) {
                return 'Please enter a valid password';
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
                    child: Text(
                      'LOGIN IN',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
