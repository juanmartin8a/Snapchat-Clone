import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class DatabaseService {
  final String uid;
  final String docId;
  DatabaseService({this.uid, this.docId});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection('usernames');
  final CollectionReference storiesCollection = FirebaseFirestore.instance.collection('stories');
  final CollectionReference memoriesCollection = FirebaseFirestore.instance.collection('memories');
  final CollectionReference chatCollection = FirebaseFirestore.instance.collection('chatRoom');
  // final firestoreInstance = FirebaseFirestore.instance;

  Future uploadUserInfo(userMap) async {
    print(userMap);
    return await userCollection.doc(uid).set(userMap);
  }

  // userData from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    return UserData(
      uid: uid,
      name: snapshot.data()['name'],
      email: snapshot.data()['email'],
      imageUrl: snapshot.data()['imageUrl'],
    );
  }

  Stream<UserData> get userData {
    return userCollection.doc(uid).snapshots().map(_userDataFromSnapshot);
  }

  getUserByUsername(String username) async {
    print('userByUsername printed');
    return await userCollection.where('userNameIndex', arrayContains: username).get();
  }

  getUserByUserEmail(String email) async {
    return userCollection
        .where(
          'email',
          isEqualTo: email,
        )
        .get();
  }

  //get user profile by uid

  Stream<DocumentSnapshot> getUserProfile() {
    return userCollection.doc(uid).snapshots();
  }

  //get friends
  getFriends() async {
    return await userCollection.doc(uid).collection('addedUsers').get();
  }

  queryFriends(String userUid) async {
    return await userCollection.doc(uid).collection('addedUsers').where('addedUserUid', isEqualTo: userUid).get();
  }

  //for adding users
  Future addUser(addUserMap, String addedUserUid) async {
    return await userCollection.doc(uid).collection('addedUsers').doc(addedUserUid).set(addUserMap);
  }

  Future deleteUser(String addedUserUid) async {
    userCollection.doc(uid).collection('addedUsers').doc(addedUserUid).delete();
  }

  Future usersThatAddedMe(addUserMap, String addedUserUid) async {
    return await userCollection.doc(uid).collection('addedMe').doc(addedUserUid).set(addUserMap);
  }

  getAddedMeList() {
    return userCollection.doc(uid).collection('addedMe').snapshots();
  }

  getUsers() async {
    return await userCollection.get();
  }

  getQueriedFriends(String userUid) async {
    //List<dynamic> array = [];
    return await userCollection.doc(uid).collection('addedUsers').where('addedUserUid', isEqualTo: userUid).get();
  }

  Future<bool> getUserFriendsBool(String theUid) async {
    try {
      var result = await userCollection.doc(uid).collection('addedMe').doc(theUid).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  //for adding a video to your story
  Future addStory(storyMap, DocumentReference docRef) async {
    return await docRef.set(storyMap);
  }

  //get stories
  getStories(friendsUid) async {
    return await storiesCollection.where('uid', isEqualTo: friendsUid).get();
    //return await userCollection.doc(uid).collection('stories').where('uid', isEqualTo: friendsUid).get();
  }

  getStoriesTime(dateTime) async {
    return await storiesCollection.where('deleted', isGreaterThan: dateTime).get();
    //return await userCollection.doc(uid).collection('stories').where('deleted', isGreaterThan: dateTime).get();
  }

  //memories
  Future saveSnap(snapMap, DocumentReference docRef) async {
    return await docRef.set(snapMap);
  }

  getMemories() {
    return userCollection.doc(uid).collection('memories').orderBy('created', descending: true).snapshots();
  }

  getUserMemories(String snapUserUid) async {
    return await memoriesCollection.where('userUid', isEqualTo: snapUserUid).get();
  }

  deleteMemories() async {
    return await userCollection.doc(uid).collection('memories').doc(docId).delete();
  }

  //query memories by date

  queryMemories(searchDate) async {
    return await userCollection
        .doc(uid)
        .collection('memories')
        .where('createdArray', arrayContains: searchDate)
        //.orderBy('created', descending: true)
        .get();
  }

  //chat
  String chatId = FirebaseFirestore.instance.collection('chat').doc().id.toString();

  Future createChatRoom(chatRoomId, chatRoomMap) async {
    return await chatCollection.doc(chatRoomId).set(chatRoomMap);
  }

  updateChat(bool value) async {
    return await chatCollection.doc(uid).collection('chat').doc(docId).update({'seen': value});
  }

  deleteChat() async {
    return await chatCollection.doc(uid).collection('chat').doc(docId).delete();
  }

  Future addConversationMessages(messageMap, docRef) async {
    /*DocumentReference documentReference =
        chatCollection.doc(uid).collection('chat').doc();*/
    return await docRef.set(messageMap).catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return chatCollection.doc(chatRoomId).collection('chat').orderBy('time', descending: false).snapshots();
  }

  getChatRooms(String userName) {
    return chatCollection.where('users', arrayContains: userName).snapshots();
  }

  // get device token
  Future saveUserTokens(tokenMap, String docRef) async {
    return await userCollection.doc(uid).collection('tokens').doc(docRef).set(tokenMap);
  }

  //user location
  Future saveUserLocation(locationMap) async {
    return await userCollection.doc(uid).collection('location').doc(docId).set(locationMap);
  }

  //get friends location
  getFriendsLocation() async {
    return await userCollection.doc(uid).collection('location').doc(docId).get();
  }

  //get friends
  getUserFriends() async {
    return await userCollection.doc(uid).collection('friends').get();
  }

  //get addedMe notifications
  getNotifications() async {
    return await userCollection.doc(uid).collection('aMNotifications').get();
  }

  deleteNotification() async {
    return await userCollection.doc(uid).collection('aMNotifications').doc(docId).delete();
  }

  // delete addedMe and addedUsers
  deleteAddedMe() async {
    return await userCollection.doc(uid).collection('addedMe').doc(docId).delete();
  }

  deleteAddedUsers() async {
    return await userCollection.doc(uid).collection('addedUsers').doc(docId).delete();
  }

  deleteFriend() async {
    return await userCollection.doc(uid).collection('friends').doc(docId).delete();
  }

  Future<bool> isNotificationDeleted() async {
    try {
      var result = await userCollection.doc(uid).collection('aMNotifications').doc(docId).get();
      return result.exists;
    } catch (e) {
      throw e;
    }
  }

  //change name and username
  changeName(String newName) async {
    return await userCollection.doc(uid).update({'name': newName});
  }

  changeUserName(String newUserName) async {
    return await userCollection.doc(uid).update({'username': newUserName});
  }

  // get all stories
  getAllStories() async {
    return await storiesCollection.get();
  }

  //getAllUsers
  getAllUsers(theUid) async {
    return await userCollection.where('uid', isEqualTo: theUid).get();
  }

  deleteStories() async {
    return await storiesCollection.doc(docId).delete();
  }
}
