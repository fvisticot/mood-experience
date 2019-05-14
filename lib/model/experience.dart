enum ExperienceType{private, group}

class Experience {
  String uid;
  String name;
  ExperienceType type;
  int nbMembers;
  List<String> membersIds;

  Experience({this.uid, this.name, this.type});


  @override
  String toString() {
    return 'Experience {uid: $uid, name: $name, type: $type, nbMembers: $nbMembers, membersIds: $membersIds}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Experience &&
              runtimeType == other.runtimeType &&
              uid == other.uid &&
              name == other.name;

  @override
  int get hashCode =>
      uid.hashCode ^
      name.hashCode;


}