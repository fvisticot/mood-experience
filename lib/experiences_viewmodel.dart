import 'package:flutter_app/rest_ds.dart';
import 'package:flutter_app/firestore_ds.dart';
import 'package:flutter_app/model/user.dart';
import 'package:flutter_app/model/experience.dart';
import 'package:flutter_app/model/mood.dart';
import 'package:location/location.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'user_utils.dart';
import 'firebase_auth.dart';
import 'dart:io' as Io;
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:geocoder/geocoder.dart';
import 'experiences_bloc.dart';

enum Action{addExperience, removeExperience}

/*
class ExperiencesInfo {
  num nbExperiences;
  num currentExperienceIndex;
  Experience currentExperience;
  List<Experience> experiences;

  @override
  String toString() {
    return 'ExperiencesInfo{nbExperiences: $nbExperiences, currentExperienceIndex: $currentExperienceIndex, currentExperience: $currentExperience}';
  }

  ExperiencesInfo(this.experiences, this.nbExperiences, this.currentExperienceIndex, this.currentExperience);
}
*/

class ExperiencesViewModel {
  FirestoreDatasource _api = new FirestoreDatasource();
  var _location = Location();
  List<Experience> _experiences = List<Experience>();
  StreamController<num> _experienceIndexStreamController = StreamController<num>.broadcast();
  num _currentExperienceIndex=0;
  StreamController<ExperiencesInfo> _experiencesInfoStreamController = StreamController<ExperiencesInfo>.broadcast();
  Action _currentAction;


  ExperiencesViewModel() {
    print('Constructor ExperiencesViewModel');
  }

  setMood({Experience experience, num mood}) async {
    final currentLocation = await _location.getLocation();
    final coordinates =
        Coordinates(currentLocation['latitude'], currentLocation['longitude']);
    final addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final address = addresses.first;

    switch (experience.type) {
      case ExperienceType.private:
        return this.setPrivateMood(
            userId: experience.uid, mood: mood, address: address);
      case ExperienceType.group:
        return this.setGroupMood(
            experienceId: experience.uid, mood: mood, address: address);
    }
  }

  List<Experience> get experiences {
    return _experiences;
  }

  Sink get experienceIndexSink {
    return _experienceIndexStreamController.sink;
  }

  /*
  Stream<ExperiencesInfo> experiencesInfoStream() {
    return _experienceIndexStreamController.stream.map((experienceIndex) {
      print("===>experienceIndex in viewModel updated to: $experienceIndex");
      _currentExperienceIndex=experienceIndex;
      var experiencesInfo;
      if (experienceIndex < _experiences.length) {
        experiencesInfo= ExperiencesInfo(_experiences, _experiences.length, experienceIndex,
            _experiences[experienceIndex]);
      } else {
        experiencesInfo = ExperiencesInfo(_experiences, _experiences.length, experienceIndex-1,
            _experiences[experienceIndex-1]);
      }
      return experiencesInfo;
    });
  }
  */

  setGroupMood({String experienceId, num mood, Address address}) {
    //_api.setGroupMood(experienceId, mood, address);
  }

  setPrivateMood({String userId, num mood, Address address}) async {
    _api.setPrivateMood(userId: userId, mood: mood, address: address);
  }

  createGroupExperience(String userId, String name) async {
    print('Create experience ${name}');
    _currentAction=Action.addExperience;
    var experienceId = await _api.createGroupExperience(userId, name);
  }

  subscribeToGroupExperience(String userId, String experienceId) async {
    return _api.subscribeToGroupExperience(userId, experienceId);
  }

  unsubscribeToGroupExperience(String userId, String experienceId) async {
    _currentAction=Action.removeExperience;
    return _api.unsubscribeToGroupExperience(userId, experienceId);
  }

  Stream<ExperiencesInfo> userExperiencesStream(String userId) {
    return null;
    /*
    return  _api
        .userExperiencesIdsStream(userId)
        .asyncMap((List<ExperienceChange> experienceChanges) {
      print('experienceChanges, nbExperiences: ${_experiences.length}, Changes: ${experienceChanges.length}.');
      List<Future<Experience>> experiencesFutures = List();

      experienceChanges.forEach((ExperienceChange experienceChange) {
        switch (experienceChange.type) {
          case ExperienceChangeType.added:
            print('Experience Added: ${experienceChange}');
            experiencesFutures
                .add(this.groupExperienceFromId(experienceChange.experienceId));
            break;
          case ExperienceChangeType.removed:
            print('Experience removed: ${experienceChange}');
            _experiences = _experiences
                .where((Experience experience) =>
                    experience.uid != experienceChange.experienceId)
                .toList();
            break;
          case ExperienceChangeType.modified:
            //experiencesFutures.add(this.groupExperienceFromId(experienceChange.experienceId));
            break;
        }
      });


        if (experiencesFutures.length > 0) {
          return Future.wait(experiencesFutures)
              .then((List<Experience> experiences) {
            experiences.forEach((Experience experience) {
              if (experience != null) _experiences.add(experience);
            });
            print('Returned Experiences from Stream: (${_experiences.length})');
            //this.experienceIndexSink.add(_experiences.length);
            var experiencesInfo = ExperiencesInfo(
                _experiences, _experiences.length, _currentExperienceIndex,
                _experiences[_currentExperienceIndex]);
            print("Returned ExperiencesInfo: $experiencesInfo");
            return experiencesInfo;
          });
        } else {
          print('Updating IndexSink');
          //this.experienceIndexSink.add(_experiences.length-1);
          var experiencesInfo = ExperiencesInfo(
              _experiences, _experiences.length, _currentExperienceIndex,
              _experiences[_currentExperienceIndex-1]);
          print("Returned ExperiencesInfo: $experiencesInfo");
          return experiencesInfo;
        }

    });
    */
  }

  Future<Experience> groupExperienceFromId(String experienceId) async {
    return await _api.groupExperienceFromId(experienceId);
  }

  membersIdsFromExperience(String experienceId) async {
    return await _api.membersIdsFromExperience(experienceId);
  }

  Stream<Mood> registerTodaysExperienceMoodStream(Experience experience) {
    switch (experience.type) {
      case ExperienceType.private:
        return this.registerTodaysPrivateExperienceMoodStream(experience.uid);
      case ExperienceType.group:
        return this.registerTodaysGroupExperienceMoodStream(experience.uid);
    }
  }

  Stream<Mood> registerTodaysPrivateExperienceMoodStream(String userId) {
    var day = new DateFormat("D").format(new DateTime.now());
    var year = new DateFormat("y").format(new DateTime.now());
    return _api.registerPrivateExperienceMoodStream(userId, year, day);
  }

  Stream<Mood> registerTodaysGroupExperienceMoodStream(String groupId) {
    var day = new DateFormat("D").format(new DateTime.now());
    var year = new DateFormat("y").format(new DateTime.now());
    return _api.registerGroupExperienceMoodStream(groupId, year, day);
  }
}
