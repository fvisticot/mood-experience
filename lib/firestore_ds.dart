import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/experience.dart';
import 'model/mood.dart';
import 'user_utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:meta/meta.dart';


enum ExperienceChangeType{added, modified, removed }

class ExperienceChange {
  String experienceId;
  ExperienceChangeType type;

  ExperienceChange(this.experienceId, this.type);

  @override
  String toString() {
    return 'ExperienceChange{experienceId: $experienceId, type: $type}';
  }

}

class FirestoreDatasource {

  bool isRegistered = false;
  StreamSubscription _subscription;
  static final FirestoreDatasource _singleton = new FirestoreDatasource._internal();

  factory FirestoreDatasource() {
    return _singleton;
  }

  FirestoreDatasource._internal() {
    ;
  }

  /// Returns a Future with a list of all [Experience] (private and grouped).
  ///
  /// First element is the user private list.
  /*
  Future<List<Experience>> userExperiences(String userId) async {
    print('=======> User experiences');
    QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users/' + userId + '/experiences')
        .getDocuments();

    var experiencesFutures = List<Future>();
    querySnapshot.documentChanges.forEach((doc) {
      experiencesFutures
          .add(this.groupExperienceFromId(doc.document.documentID));
    });

    var experiences = List<Experience>();
    experiences
        .add(Experience(uid: userId, type: ExperienceType.private, name: 'Me'));

    await Future.wait(experiencesFutures).then((List responses) {
      responses.forEach((response) {
        if (response != null) {
          experiences.add(response);
        }
      });
    });

    return experiences;
  }
  */

  Stream<List<ExperienceChange>> userExperiencesIdsStream(String userId) {

    Stream<QuerySnapshot> stream = Firestore.instance
        .collection('users/' + userId + '/experiences')
        .snapshots();

    Stream<List<ExperienceChange>> experiencesStream =
        stream.map((QuerySnapshot snapshot) {
      List<ExperienceChange> experienceChanges = List();
      snapshot.documentChanges.forEach((DocumentChange documentChange) {
        switch (documentChange.type) {
          case DocumentChangeType.added:
            experienceChanges.add(ExperienceChange(
                documentChange.document.documentID,
                ExperienceChangeType.added));
            break;
          case DocumentChangeType.modified:
            experienceChanges.add(ExperienceChange(
                documentChange.document.documentID,
                ExperienceChangeType.modified));
            break;
          case DocumentChangeType.removed:
            experienceChanges.add(ExperienceChange(
                documentChange.document.documentID,
                ExperienceChangeType.removed));
            break;
        }
      });
      return experienceChanges;
    });
    return experiencesStream;
  }

  Stream<Mood> registerGroupExperienceMoodStream(
      String experienceId, String year, String day) {

    print('RegisterGroupExperienceMoodStream for experience ${experienceId}');
    if (_subscription != null) {
      print('Canceling subscription');
      _subscription.cancel();
    }

    StreamController<Mood> streamController = StreamController<Mood>.broadcast();

    DocumentReference documentRef = Firestore.instance
        .document('groups-experiences/' +
        experienceId +
        '/years/' +
        year +
        '/days/' +
        day);

     _subscription = documentRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        num avgMood = snapshot.data['avgMood'];
        print("Returned mood: ${avgMood.toDouble()}");
        streamController.add(Mood(value: avgMood.toDouble(), status: MoodStatus.completed));
      } else {
        streamController.add(Mood(value: 0.0, status: MoodStatus.completed));
      }
    });

    return streamController.stream;
  }

  Stream<Mood> registerPrivateExperienceMoodStream(
      String userId, String year, String day) {
    print(
        'Registering mood stream for user ${userId} year: ${year} day: ${day}');
    Stream<DocumentSnapshot> stream = Firestore.instance
        .document(
            'private-experiences/' + userId + '/years/' + year + '/days/' + day)
        .snapshots();
    Stream<Mood> moodStream = stream.map((snapshot) {
      if (snapshot.exists) {
        return Mood(value: snapshot.data['mood'], status: MoodStatus.completed);
      }
    });
    return moodStream;
  }

  /*
  enterGroupExperience(String userId, String experienceId) async {
    print('Entering group experience: ${experienceId}');
    var documentRef = Firestore.instance
        .document('groups-experiences/' + experienceId + '/members/' + userId);
    documentRef.setData({'inExperience': true});
  }

  leaveGroupExperience(String userId, String experienceId) async {
    print('Leaving group experience: ${experienceId}');
    var documentRef = Firestore.instance
        .document('groups-experiences/' + experienceId + '/members/' + userId);
    documentRef.setData({'inExperience': false});
  }
  */

  setUserPhotoUrl(String userId, String photoUrl) async {
    var documentRef = Firestore.instance.document('users/' + userId);
    documentRef.setData({'photoUrl': photoUrl});
  }

  Future<String> getUserPhotoUrl(String userId) {
    return Firestore.instance
        .document('users/' + userId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        return snapshot.data['photoUrl'];
      } else {
        print('User photo not set.');
      }
    });
  }

  Future<Experience> groupExperienceFromId(String experienceId) async {
    print("GroupExpeFromId: ${experienceId}");
    DocumentSnapshot document = await Firestore.instance
        .document('groups-experiences/' + experienceId)
        .get();
    if (document.exists) {
      int typeAsInt = document.data['type'];
      ExperienceType type = ExperienceType.values[typeAsInt];
      Experience experience = Experience(
          uid: document.documentID,
          name: document.data['name'],
          type: type);
      print("Experience: ${experience}");
      return experience;
    } else {
      print('Document not found with experienceId: ${experienceId}');
      return null;
    }

  }

  Stream<List<String>>membersIdsFromExperience(String experienceId) {
    Stream<QuerySnapshot> stream = Firestore.instance
        .collection('groups-experiences/' + experienceId + '/members')
        .snapshots();
    Stream<List<String>> membersStream = stream.map((QuerySnapshot snapshot) {
      var membersIds = new List<String>();
      snapshot.documentChanges.forEach((doc) {
        membersIds.add(doc.document.documentID);
      });
      return membersIds;
    });
    return membersStream;
  }

  /*
  Future<String> joinGroupExperience(String userId, String experienceId) async {
    var timestamp = new DateTime.now().toIso8601String();

    var documentRef = Firestore.instance
        .collection('groups-experiences')
        .document(experienceId)
        .collection('members')
        .document(userId);
    await documentRef.setData({'timestamp': timestamp});
    await subscribeToGroupExperience(userId, experienceId);
  }
  */

  Future<String> createGroupExperience(String userId, String name) async {

    return this._createExperience(userId, ExperienceType.group, name);

    /*
    var timestamp = new DateTime.now().toIso8601String();
    var documentRef =
    Firestore.instance.collection('groups-experiences').document();
    documentRef.setData({
      'timestamp': timestamp,
      'owner': userId,
      'name': name,
      'type': 'group'
    });
    subscribeToGroupExperience(userId, documentRef.documentID);
    return documentRef.documentID;*/
  }

  Future<String> _createExperience(String userId, ExperienceType type,  String name) async {
    var timestamp = new DateTime.now().toIso8601String();
    var documentRef =
    Firestore.instance.collection('groups-experiences').document();
    documentRef.setData({
      'timestamp': timestamp,
      'owner': userId,
      'name': name,
      'type': type.index
    });
    subscribeToGroupExperience(userId, documentRef.documentID);
    return documentRef.documentID;
  }

  Future<String> createPrivateExperience({@required String userId, String name}) async {
    /*var timestamp = new DateTime.now().toIso8601String();
    var documentRef =
    Firestore.instance.collection('private-experiences').document(userId);
    documentRef.setData({
      'timestamp': timestamp,
      'owner': userId,
      'name': name,
      'type': 'private'
    });
    return documentRef.documentID;*/
    return this._createExperience(userId, ExperienceType.private, 'Me');
  }

  Future<String> subscribeToGroupExperience(
      String userId, String experienceId) async {
    print('subscribeToGroupExperience ${experienceId}.');

    final subscriptionDate = {'subscriptionDate': FieldValue.serverTimestamp()};

    var documentRef = Firestore.instance
        .collection('groups-experiences/${experienceId}/members')
        .document(userId);
    await documentRef.setData(subscriptionDate);

    var experienceRef = Firestore.instance
        .collection('users/${userId}/experiences')
        .document(experienceId);
    await experienceRef.setData(subscriptionDate);
    return experienceRef.documentID;
  }

  Future<void> unsubscribeToGroupExperience(
      String userId, String experienceId) async {
    print('unsubscribeToGroupExperience ${experienceId}.');
    var documentRef = Firestore.instance
        .collection('groups-experiences/${experienceId}/members')
        .document(userId);
    await documentRef.delete();

    var experienceRef = Firestore.instance
        .collection('users/${userId}/experiences')
        .document(experienceId);


    await experienceRef.delete();

  }


  setGroupMood({String experienceId, double mood, Address address}) async {
    var dayNum = new DateFormat("D").format(new DateTime.now());
    var year = new DateFormat("y").format(new DateTime.now());
    final userId = await new UserUtils().get('userId');
    print(
        '[Group: ${dayNum}]Setting moodValue: ${mood} for userId: ${userId} and experienceId: ${experienceId} address: ${address.locality}');
    var documentRef = Firestore.instance.document('groups-experiences/' +
        experienceId +
        '/years/' +
        year +
        '/days/' +
        dayNum +
        '/users/' +
        userId);

    var filteredAddressMap = address.toMap();
    filteredAddressMap.keys
        .where((k) => filteredAddressMap[k] == null)
        .toList()
        .forEach(filteredAddressMap.remove);

    var timestamp = new DateTime.now().toIso8601String();
    documentRef.setData(
        {'timestamp': timestamp, 'mood': mood, 'location': filteredAddressMap});

  }

  setPrivateMood({String userId, double mood, Address address}) async {
    var dayNum = new DateFormat("D").format(new DateTime.now()); //'101';
    var year = new DateFormat("y").format(new DateTime.now());
    print(
        '[Private: ${dayNum}] Setting moodValue: ${mood} for userId: ${userId} Location(${address.coordinates.latitude}, ${address.coordinates.longitude})');
    var documentRef = Firestore.instance.document(
        'private-experiences/' + userId + '/years/' + year + '/days/' + dayNum);

    var timestamp = new DateTime.now().toIso8601String();

    var filteredAddressMap = address.toMap();
    filteredAddressMap.keys
        .where((k) => filteredAddressMap[k] == null)
        .toList()
        .forEach(filteredAddressMap.remove);

    documentRef.setData(
        {'timestamp': timestamp, 'mood': mood, 'location': filteredAddressMap});
  }
}
