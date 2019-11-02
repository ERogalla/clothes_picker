import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Signup()
      )
    );
  }
}

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final _formKey = GlobalKey<FormState>();
  final pass = TextEditingController();
  final confirmPass = TextEditingController();
  final email = TextEditingController();
  String errorText;

  void _createAccount(BuildContext context) {
    if (pass.text.length < 1 || pass.text != confirmPass.text || email.text.length < 1) {
      /* bad input */
      setState(() {
        errorText = 'incomplete form';
      });
      return;
    }

    setState(() {
      errorText = null;
    });

    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.text,
      password: pass.text
    ).then((AuthResult result) {
      FirebaseUser user = result.user;
      print('Created user ${user.uid}');
      return Firestore.instance.collection('users')
        .document(user.uid)
        .setData({
          'isAdmin': false
        });
    })
    .then((_) => print('created new user in users'))
    .catchError((dynamic err) {
      setState(() {
        errorText = err.message;
      });
    });
  }

  Widget _showError() {
    if (errorText == null)
      return Container();

    return Text('$errorText', style: TextStyle(color: Colors.redAccent, fontSize: 20));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _showError(),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: email,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: pass,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              TextFormField(
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: confirmPass,
                decoration: InputDecoration(labelText: 'Confirm Password'),
              ),
              MaterialButton(
                child: const Text('Create Account'),
                onPressed: () => _createAccount(context),
              )
            ],
          )
        )
      )
    );
  }
}