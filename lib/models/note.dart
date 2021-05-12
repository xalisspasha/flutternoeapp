class Note {
  String id;
  String description;
  Note({this.id, this.description});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      description: json['note'],
    );
  }
}
