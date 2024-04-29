
class Group {
  final String id;
  final String name;
  final String description; // Optional
  final String creatorId;
  final List<String> members; // List of user IDs

  const Group({
    required this.id,
    required this.name,
    this.description = "",
    required this.creatorId,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name' : name,
      'description': description,
      'creatorId': creatorId,
      'members': members,
    };
  }
}
