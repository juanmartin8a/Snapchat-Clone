import 'package:flutter/material.dart';
import '../../services/helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth.dart';
//import '../../shared/loading.dart';
import '../../services/database.dart';

class Register extends StatefulWidget {
  // when passing props to other stateful widget files pass it to the state full widget
  Function toSignIn;

  Register({this.toSignIn});
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final DatabaseService databaseService = DatabaseService();
  final HelperFunctions helperFunctions = HelperFunctions();

  final _formKey = GlobalKey<FormState>();
  bool loading = false;
  QuerySnapshot snapshotUserInfo;

  String username = '';
  String name = '';
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
              title: Text('Sign up'),
              elevation: 0.0,
              actions: [
                FlatButton(
                    child: Text('SIGN IN'),
                    onPressed: () {
                      widget
                          .toSignIn(); // use widget. to refer to the stateful widget
                    })
              ],
            ),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                child: Form(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) =>
                            val.isEmpty ? 'Enter a valid name' : null,
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) =>
                            val.isEmpty ? 'Enter a valid Username' : null,
                        onChanged: (val) {
                          setState(() => username = val);
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        validator: (val) {
                          return RegExp(
                                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val)
                              ? null
                              : "Enter correct email";
                        },
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
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
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              //validate validates the form (true or false)
                              setState(() => loading = true);
                              dynamic result = await _auth
                                  .registerWithEmailAndPassword(email, password)
                                  .then((user) {
                                List<String> splitList = username.split(" ");
                                List<String> indexList = [];
                                for (int i = 0; i < splitList.length; i++) {
                                  for (int y = 1;
                                      y < splitList[i].length + 1;
                                      y++) {
                                    indexList.add(splitList[i]
                                        .substring(0, y)
                                        .toLowerCase());
                                  }
                                }
                                Map<String, dynamic> userMap = {
                                  "username": username,
                                  "email": email,
                                  "uid": user.uid,
                                  "userNameIndex": indexList,
                                  "profileImg":
                                      'https://genslerzudansdentistry.com/wp-content/uploads/2015/11/anonymous-user.png',
                                  "name": name,
                                  'privacy': false,
                                };
                                print(user.uid);
                                HelperFunctions
                                    .saveUserLoggedinSharedPreference(true);
                                HelperFunctions.saveUserEmailSharedPreference(
                                    email);
                                HelperFunctions.saveUserNameSharedPreference(
                                    name);
                                DatabaseService(uid: user.uid)
                                    .uploadUserInfo(userMap);
                              });
                              if (result == null) {
                                error = 'please suply a valid email';
                                loading = false;
                                /*setState(() {
                                  error = 'please suply a valid email';
                                  loading = false;
                                });*/
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
