import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp()

//export const deletePhotos = functions.firestore

const db = admin.firestore();
const fcm = admin.messaging();
export const deleteOldStories = functions.runWith({ memory: '2GB' }).pubsub.schedule('* * * * *').onRun(async context => {
        //console.log('promises below 0');
        const now = admin.firestore.Timestamp.now();
        const querySnapshot = await db.collection('stories').where('deleted', '<=', now).get();
        //console.log('promises below 1');
        const promises: Promise<any>[] = [];
        querySnapshot.forEach((doc) => {
            promises.push(doc.ref.delete());
        });
        console.log(`promises below 2 ${promises}`);
        return await Promise.all(promises);
    });

export const deleteOldGroupChats = functions.runWith({ memory: '2GB' }).pubsub.schedule('* * * * *').onRun(async context => {
    //console.log('promises below 0');
    const now = admin.firestore.Timestamp.now();
    const promises: Promise<any>[] = []
    /*const chatDoc: any = */await db.collection('chatRoom').where('type', '==', 'group').get().then(snapshot => {
        snapshot.forEach((doc) => {
            db.collection('chatRoom').doc(doc.id).collection('chat').where('deleted', '<=', now).get()
                .then(snapshot2 => {
                    snapshot2.forEach((doc1) => {
                        promises.push(doc1.ref.delete());
                    });
                }).catch((err) => console.log(`there is an error in snapshot 2 :( ${err}`));
                //promises.push(doc.ref.delete());
        });
    }).catch((err) => console.log(`there is an error in snapshot 1 :( ${err}`));
    //promises.push(chatDoc);
    console.log(`promises below 2 ${promises}`);
    return await Promise.all(promises);
});

export const friends = functions.firestore.document('usernames/{userId}/addedUsers/{addedUserId}')
    .onCreate(async snapshot => {
        //console.log('promises below 0');
        //const now = admin.firestore.Timestamp.now();
        const addedUser = snapshot.data();
        const promises: Promise<any>[] = [];
        const friendDoc: any = await db.collection('usernames').doc(addedUser.addedBy)
            .collection('addedUsers').doc(addedUser.addedUserUid).get().then((doc) => {
                //doc.data()
                const addedUser1: any = doc?.data();
                const queryFriendDoc = db.collection('usernames').doc(addedUser.addedBy)
                    .collection('addedMe').doc(addedUser.addedUserUid).get().then((doc2) => {
                        const addedUser2: any = doc2.data();
                        if (addedUser1.addedUserUid == addedUser2.hasAddedMe) {
                            const createFriendsForMe = db.collection('usernames').doc(addedUser.addedBy)
                                .collection('friends').doc(addedUser.addedUserUid).set({'friend': addedUser.addedUserUid});
                            const createFriends = db.collection('usernames').doc(addedUser.addedUserUid)
                                .collection('friends').doc(addedUser.addedBy).set({'friend': addedUser.addedBy});
                            promises.push(createFriendsForMe, createFriends);
                        }
                    });
                promises.push(queryFriendDoc);
            });
        promises.push(friendDoc);
        //console.log('promises below 1');
        //const promises: Promise<any>[] = [];
        console.log(`promises below!! ${promises}`);
        return await Promise.all(promises);
    });

    

export const addedMeNotifications = functions.firestore
    .document('usernames/{userId}/addedUsers/{addedUserId}')
    .onCreate(async snapshot => {
        const added = snapshot.data();
        const querySnapshot = await db.collection('usernames').doc(added.addedUserUid).collection('tokens').get();
        const docRef = await db.collection('usernames').doc(added.addedUserUid).collection('aMNotifications').doc(added.notificationId);
        const saveData = await docRef.set({
            'title': `${added.addedUserName}`,
            'body': `${added.addedUserName} has liked your post`,
            'notificationFor': `${added.addedUserUid}`,
            'sendBy': `${added.addedBy}`,
            'time': `${added.time}`,
            'id': `${added.notificationId}`
        });
        const tokens = querySnapshot.docs.map(snap => snap.id);
        console.log(`tokens ${tokens}`);
        const payLoad: admin.messaging.MessagingPayload = {
            notification: {
                title: `${added.addedUserName}`,
                body: `${added.addedUserName} has liked your post`,
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            }
        };
        console.log(`payload ${payLoad}`);
        return fcm.sendToDevice(tokens, payLoad, saveData);
    });

    export const deleteNotifications = functions.firestore
        .document('usernames/{userId}/addedUsers/{addedUserId}')
        .onDelete(async snapshot => {
            //console.log('promises below 0');
            const added = snapshot.data();
            //const now = admin.firestore.Timestamp.now();
            const promises: Promise<any>[] = []
            await db.collection('usernames').doc(added.addedUserUid).collection('aMNotifications').doc(added.notificationId).get().then(doc => {
                promises.push(doc.ref.delete());
            });
            /*await db.collection('usernames').where('type', '==', 'group').get().then(snapshot => {
                snapshot.forEach((doc) => {
                    db.collection('chatRoom').doc(doc.id).collection('chat').where('deleted', '<=', now).get()
                        .then(snapshot2 => {
                            snapshot2.forEach((doc1) => {
                                promises.push(doc1.ref.delete());
                            });
                        }).catch((err) => console.log(`there is an error in snapshot 2 :( ${err}`));
                        //promises.push(doc.ref.delete());
                });
            }).catch((err) => console.log(`there is an error in snapshot 1 :( ${err}`));*/
            /*deletedDoc.then((doc) => {
                promises.push(doc.ref.delete());
            });*/
            //promises.push(chatDoc);

            console.log(`promises below 2 ${promises}`);
            return await Promise.all(promises);
    });

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
