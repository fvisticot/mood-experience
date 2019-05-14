import 'bloc_provider.dart';
import 'model/mood.dart';
import 'firestore_ds.dart';
import 'package:intl/intl.dart';
import 'model/experience.dart';
import 'dart:async';
import 'package:meta/meta.dart';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'package:firebase_performance/firebase_performance.dart';

class MoodUpdate {
  double value;
  String experienceId;

  MoodUpdate({@required this.value, @required this.experienceId});

  @override
  String toString() {
    return 'MoodUpdate{value: $value, experienceId: $experienceId}';
  }
}

class ExperienceBloc implements BlocBase {
  Experience _experience;

  Location _location = Location();
  FirestoreDatasource _api = FirestoreDatasource();

  StreamController<MoodUpdate> _moodUpdateStreamController =
      StreamController<MoodUpdate>.broadcast();
  StreamSink<MoodUpdate> get moodUpdate => _moodUpdateStreamController.sink;

  StreamController<Mood> _moodStreamController =
      StreamController<Mood>.broadcast();
  Stream<Mood> get moodStream => _moodStreamController.stream;

  StreamController<List<String>> _membersStreamController =
      StreamController<List<String>>.broadcast();
  Stream<List<String>> get membersStream => _membersStreamController.stream;

  StreamSubscription<Mood> _streamSubscription;

  DateTime _startProcessTime;
  Mood _currentMood;
  Timer _timeout;

  ExperienceBloc(Experience experience) {
    print('Instanciating Experience bloc (${experience.name})');
    _experience = experience;

    _moodUpdateStreamController.stream.listen((MoodUpdate moodUpdate) async {
      _moodStreamController
          .add(Mood(value: moodUpdate.value, status: MoodStatus.inProgress));
      var address = await this._currentAddress();

      _startTimeout(3);
      _startProcessTime = DateTime.now();
      _api.setGroupMood(
          experienceId: moodUpdate.experienceId,
          mood: moodUpdate.value,
          address: address);
    });

    Stream<Mood> stream = this._todaysGroupExperienceMoodStream(experience.uid);
    /*switch (experience.type) {
      case ExperienceType.private:
        stream = this._todaysPrivateExperienceMoodStream(experience.uid);
        break;
      case ExperienceType.group:
        stream = this._todaysGroupExperienceMoodStream(experience.uid);
        break;
    }*/

    _streamSubscription = stream.listen((Mood mood) {
      _timeout?.cancel();
      if (_startProcessTime != null) {
        var processTime = DateTime.now().difference(_startProcessTime);
        final Trace moodProcessTrace =
        FirebasePerformance.instance.newTrace("mood_compute_trace");
        moodProcessTrace.start();
        moodProcessTrace.putAttribute('process_time', processTime.toString());
        moodProcessTrace.stop();
        print('ProcessTime: ${processTime}');
      }
      _currentMood=mood;
      _moodStreamController.add(mood);
    });

    _api.membersIdsFromExperience(_experience.uid).pipe(_membersStreamController);


  }

  _startTimeout(duration) {
    _timeout=Timer(Duration(seconds: duration), () => _moodStreamController.add(_currentMood));
  }

  @override
  void dispose() {
    print("=========>DISPOSE (${_experience.name})");
    _moodUpdateStreamController.close();
    _moodStreamController.close();
    _streamSubscription.cancel();
  }

  Stream<Mood> _todaysPrivateExperienceMoodStream(String userId) {
    var day = new DateFormat("D").format(new DateTime.now());
    var year = new DateFormat("y").format(new DateTime.now());
    return _api.registerPrivateExperienceMoodStream(userId, year, day);
  }

  Stream<Mood> _todaysGroupExperienceMoodStream(String groupId) {
    var day = new DateFormat("D").format(new DateTime.now());
    var year = new DateFormat("y").format(new DateTime.now());
    return _api.registerGroupExperienceMoodStream(groupId, year, day);
  }

  Future<Address> _currentAddress() async {
    final Trace locationTrace =
        FirebasePerformance.instance.newTrace("location_trace");
    await locationTrace.start();
    var startTime = DateTime.now();
    final currentLocation = await _location.getLocation();
    var duration = DateTime.now().difference(startTime);
    locationTrace.putAttribute('duration', duration.toString());
    locationTrace.putAttribute(
        'accuracy', currentLocation['accuracy'].toString());
    await locationTrace.stop();
    final coordinates =
        Coordinates(currentLocation['latitude'], currentLocation['longitude']);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    return addresses.first;
  }
}
