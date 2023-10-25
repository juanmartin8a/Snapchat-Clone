import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/database.dart';
import '../../services/auth.dart';
//import '../../shared/loading.dart';
import '../../services/helper/helperfunctions.dart';

class SignIn extends StatefulWidget {
  Function toSignUp;
  SignIn({this.toSignUp}); // Use ({}) when there is a statefull widget

  @override
  createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  final DatabaseService databaseService = DatabaseService();
  QuerySnapshot snapshotUserInfo;

  // text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.brown[100],
              title: Text('SignIn'),
              elevation: 0.0,
              actions: [
                FlatButton(
                    child: Text('SIGN UP'),
                    onPressed: () {
                      widget.toSignUp();
                    })
              ],
            ),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                    ))),
                            validator: (val) =>
                                val.isEmpty ? 'Enter an Email' : null,
                            onChanged: (val) {
                              setState(() => email = val);
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 12),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(
                                      color: Colors.red,
                                    ))),
                            validator: (val) => val.length < 6
                                ? 'Enter a password longer than 6 numbers'
                                : null,
                            obscureText: true,
                            onChanged: (val) {
                              setState(() => password = val);
                            },
                          ),
                          SizedBox(height: 20.0),
                          RaisedButton(
                              color: Colors.pink,
                              child: Text(
                                'Sign In',
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  //validate validates the form (true or false)
                                  setState(() => loading = true);
                                  HelperFunctions.saveUserEmailSharedPreference(
                                      email);

                                  databaseService
                                      .getUserByUserEmail(email)
                                      .then((val) {
                                    snapshotUserInfo = val;
                                    HelperFunctions
                                        .saveUserNameSharedPreference(
                                            snapshotUserInfo.docs[0]
                                                .data()['name']);
                                    print(snapshotUserInfo.docs[0]
                                        .data()['name']);
                                  });

                                  dynamic result =
                                      await _auth.signInWithEmailAndPassword(
                                          email, password);

                                  if (result == null) {
                                    setState(() {
                                      error = 'invalid credentials';
                                      setState(() => loading = false);
                                    });
                                  }
                                }
                              }),
                          SizedBox(height: 12.0),
                          Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: 15),
                          )
                        ]))),
          );
  }
}
