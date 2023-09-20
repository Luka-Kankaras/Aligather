class User {
  final String id;
  final String name;
  final String location;
  List<dynamic> attends;

  User({
    required this.id,
    required this.name,
    required this.location,
    required this.attends
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      attends: json['attends'] as List<dynamic>,
    );
  }

  @override
  String toString() {
    return 'User{\nid: $id, \nname: $name, \nlocation: $location, \nattends: $attends\n}';
  }
}


class Event {
  final String id;
  final String name;
  final String hostName;
  final String description;
  final String location;
  final String hostId;
  final String picturePath;
  final List<dynamic> attends;

  Event({
    required this.id,
    required this.name,
    required this.hostName,
    required this.description,
    required this.location,
    required this.hostId,
    required this.picturePath,
    required this.attends,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] as String,
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      picturePath: json['picturePath'] as String,
      attends: json['attends'] as List<dynamic>,
    );
  }

  @override
  String toString() {
    return 'Event{id: $id, \nname: $name, \nhostName: $hostName, \ndescription: $description, \nlocation: $location, \nhostId: $hostId, \npicturePath: $picturePath, \nattends: $attends\n}';
  }
}
