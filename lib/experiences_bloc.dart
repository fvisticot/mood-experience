import 'bloc_provider.dart';
import 'dart:async';
import 'model/experience.dart';
import 'firestore_ds.dart';
import 'package:meta/meta.dart';

enum ExperiencesActionType { addExperienceAction, removeExperienceAction }

class ExperiencesAction {
  final Experience experience;
  final ExperiencesActionType type;
  final String userId;

  ExperiencesAction({this.userId, this.type, this.experience});

  @override
  String toString() {
    return 'ExperiencesAction{experience: $experience, type: $type, userId: $userId}';
  }
}

class ExperiencesInfo {
  int currentIndex;
  List<Experience> experiences;

  ExperiencesInfo({@required this.experiences, this.currentIndex});

  @override
  String toString() {
    return 'ExperiencesInfo{currentIndex: $currentIndex, experiences: $experiences}';
  }
}

class ExperiencesBloc implements BlocBase {
  FirestoreDatasource _api = new FirestoreDatasource();
  StreamController<ExperiencesAction> _actionController =
      StreamController<ExperiencesAction>();
  StreamController<int> _experienceIndexController = StreamController<int>.broadcast();
  StreamController<Experience> _experienceController = StreamController<Experience>.broadcast();

  StreamSink<ExperiencesAction> get action => _actionController.sink;
  StreamSink<int> get experienceIndex => _experienceIndexController.sink;

  List<Experience> _experiences = List<Experience>();
  int _currentIndex=0;

  ExperiencesBloc() {
    _actionController.stream.listen((ExperiencesAction action) {
      switch (action.type) {
        case ExperiencesActionType.addExperienceAction:
          this.addExperience(action);
          break;
        case ExperiencesActionType.removeExperienceAction:
          this.removeExperience(action);
          break;
        default:
          break;
      }
    });


    _experienceIndexController.stream.listen((index) {
      if (index > 0 && index < _experiences.length) {
        print("Updating index from listen to ${index}");
        _currentIndex=index;
        _experienceController.add(_experiences[index]);
      }
    });


  }

  @override
  void dispose() {
    _actionController.close();
  }

  addExperience(ExperiencesAction action) async {
    print('Adding experience action: ${action}');
    var docID=await _api.createGroupExperience(action.userId, action.experience.name);
    print("DocID: ${docID}");
  }

  removeExperience(ExperiencesAction action) async {
    print('Removing experience action: ${action}');
    await _api.unsubscribeToGroupExperience(action.userId, action.experience.uid);
  }

  Stream<Experience> get experienceStream {
    return _experienceController.stream;
  }

  Future<Experience> _groupExperienceFromId(String experienceId) async {
    return await _api.groupExperienceFromId(experienceId);
  }

  Stream<ExperiencesInfo> experiencesStream(String userId) {
    _experiences.clear();
    return _api
        .userExperiencesIdsStream(userId)
        .asyncMap((List<ExperienceChange> experienceChanges) {
      print('experienceChanges, Changes: ${experienceChanges.length}.');
      List<Future<Experience>> experiencesFutures = List();

      experienceChanges.forEach((ExperienceChange experienceChange) {
        switch (experienceChange.type) {
          case ExperienceChangeType.added:
            print('Experience Added: ${experienceChange}');
            experiencesFutures
                .add(this._groupExperienceFromId(experienceChange.experienceId));
            break;
          case ExperienceChangeType.removed:
            print('Experience removed: ${experienceChange}');
            _experiences = _experiences
                .where((Experience experience) =>
                    experience.uid != experienceChange.experienceId)
                .toList();
            break;
          case ExperienceChangeType.modified:
            print('====MODIFIED');
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
          if (experiences.length > 1) {
            _experienceIndexController.sink.add(0);
          } else {
            _experienceIndexController.sink.add(_experiences.length - 1);
          }
          var experiencesInfo = ExperiencesInfo(
              experiences: _experiences, currentIndex: _currentIndex);
          print("Returned ExperiencesInfo: $experiencesInfo");
          return experiencesInfo;
        });
      } else {
        print('Updating IndexSink');

        if (_currentIndex == _experiences.length) {
          _currentIndex = _currentIndex-1;
        }
        _experienceIndexController.sink.add(_currentIndex);
        var experiencesInfo = ExperiencesInfo(
            experiences: _experiences, currentIndex: _currentIndex);
        print("Returned ExperiencesInfo: $experiencesInfo");
        return experiencesInfo;
      }
    });
  }





}
