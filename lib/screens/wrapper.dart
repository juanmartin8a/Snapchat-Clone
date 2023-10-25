import 'package:flutter/material.dart';
import 'home/home.dart';
import 'auth/authenticate.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/helper/helperfunctions.dart';

class Wrapper extends StatefulWidget {
  @override
  WrapperState createState() => WrapperState();
}

class WrapperState extends State<Wrapper> {
  bool userIsLoggedIn;

  @override
  void initState() {
    getLoggedInState();
    super.initState();
  }

  getLoggedInState() async {
    await HelperFunctions.getUserLoggedinSharedPreference().then((value) {
      print(value);
      setState(() {
        userIsLoggedIn = value;
      });
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    //print(user);
    // return either home or auth
    //return userIsLoggedIn != null ? Home() : Authenticate();
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
