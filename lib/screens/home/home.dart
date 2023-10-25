import 'package:flutter/material.dart';
import 'package:snapchatClone/models/user.dart';
import 'package:snapchatClone/screens/home/camera/camera_state.dart';
import 'package:snapchatClone/screens/home/chat/chatrooms_screen.dart';
import 'package:snapchatClone/screens/home/discover/discover_screen.dart';
import 'package:snapchatClone/screens/home/main_botNav.dart';
import 'package:snapchatClone/screens/home/main_header.dart';
import 'package:snapchatClone/screens/home/map/map_screen.dart';
import 'package:snapchatClone/screens/home/stories/stories_page.dart';
//import 'package:flutterUntitled/models/ImagePage.dart';
import '../../services/database.dart';
import '../../services/auth.dart';
import '../../services/helper/constants.dart';
import '../../services/helper/helperfunctions.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final DatabaseService databaseService = DatabaseService();
  PageController _pageController;
  TabController tabController;
  int currentPage;
  bool active;
  int theIndex = 2;
  int tabIndex;
  bool isPageCanChanged = true;

  void initState() {
    getUserInfo();
    tabController = TabController(length: 5, vsync: this, initialIndex: 2);
    //tabIndex = tabController.index;
    tabController.addListener(() {
      if (tabController.indexIsChanging) {
        onPageChange(tabController.index, p: _pageController);
      }
    });
    _pageController = PageController(initialPage: 2, viewportFraction: 1.03);
    _pageController.addListener(() {
      int next = _pageController.page.round();

      if (currentPage != next) {
        setState(() {
          currentPage = next;
          tabIndex = next;
        });
      }
    });
    super.initState();
  }

  onPageChange(int index, {PageController p, TabController t}) async {
    if (p != null) {
      //determine which switch is
      isPageCanChanged = false;
      await _pageController.animateToPage(index,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease); //Wait for pageview to switch, then release pageivew listener
      isPageCanChanged = true;
    } else {
      tabController.animateTo(index); //Switch Tabbar
    }
  }

  getUserInfo() async {
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
  }

  indicatorColors() {
    if (theIndex == 0) {
      return Colors.greenAccent[400];
    } else if (theIndex == 1) {
      return Colors.lightBlueAccent[400];
    } else if (theIndex == 2) {
      return Colors.yellowAccent;
    } else if (theIndex == 3) {
      return Colors.purpleAccent[400];
    } else if (theIndex == 4) {
      return Colors.yellowAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<CustomUser>(context);
    print('current username is ${Constants.myName}');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(children: [
        Positioned.fill(
            child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: TabBar(
                  //controller: tabController,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //isScrollable: true,
                  indicator: TriangleTabIndicator(color: indicatorColors(), radius: 5),
                  controller: tabController,
                  labelColor: Colors.red,
                  tabs: [
                    Container(
                        child: Icon(Icons.location_on_outlined,
                            color: theIndex == 0 ? Colors.greenAccent[400] : Colors.grey[500], size: 28)),
                    Container(
                        child: Icon(Icons.messenger_outline_rounded,
                            color: theIndex == 1 ? Colors.lightBlueAccent[400] : Colors.grey[500], size: 28)),
                    Container(
                        child: Icon(Icons.camera_alt_outlined,
                            color: theIndex == 2 ? Colors.yellowAccent : Colors.grey[500], size: 28)),
                    Container(
                        child: Icon(Icons.group_outlined,
                            color: theIndex == 3 ? Colors.purpleAccent[400] : Colors.grey[500], size: 28)),
                    Container(
                        child: Icon(
                      Icons.menu_rounded,
                      color: theIndex == 4 ? Colors.yellowAccent : Colors.grey[500],
                      size: 25,
                    ))
                  ]) /*BottomNavBar(theIndex: theIndex)*/),
        )),
        Container(
            margin: EdgeInsets.only(bottom: 45),
            child: PageView(
              controller: _pageController,
              physics: AlwaysScrollableScrollPhysics(),
              onPageChanged: (index) {
                print('the current page index is $index');
                setState(() {
                  theIndex = index;
                  if (isPageCanChanged) {
                    // because the pageview switch will call back this method, it will trigger the switch tabbar operation, so define a flag, control pageview callback
                    onPageChange(index);
                  }
                });
                print('the index here is $theIndex');
                bool active = index == currentPage;
                active = active;
              },
              children: [
                FractionallySizedBox(
                  widthFactor: 1 / _pageController.viewportFraction,
                  child: MapScreen(statusBar: MediaQuery.of(context).padding.top),
                ),
                FractionallySizedBox(
                  widthFactor: 1 / _pageController.viewportFraction,
                  child: ChatRooms(statusBar: MediaQuery.of(context).padding.top),
                ),
                FractionallySizedBox(
                  widthFactor: 1 / _pageController.viewportFraction,
                  child: CameraState(statusBar: MediaQuery.of(context).padding.top),
                ),
                FractionallySizedBox(
                  widthFactor: 1 / _pageController.viewportFraction,
                  child: Stories(statusBar: MediaQuery.of(context).padding.top),
                ),
                FractionallySizedBox(
                  widthFactor: 1 / _pageController.viewportFraction,
                  child: Discover(statusBar: MediaQuery.of(context).padding.top),
                ),
              ],
            ))
        //CameraState()
        ,
        theIndex != 2
            ? Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                    child: Header(
                      theIndex: theIndex,
                    )))
            : Positioned(
                top: 0.0,
                left: 0.0,
                right: 40,
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    curve: Curves.easeIn,
                    child: Header(
                      theIndex: theIndex,
                    )))
      ]),
    );
  }
}
