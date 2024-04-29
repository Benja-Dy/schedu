class GroupInvitation {
  final String id;
  final String groupId;
  final String invitedUserId;
  final String inviterId;
  final DateTime sentAt;

  const GroupInvitation({
    required this.id,
    required this.groupId,
    required this.invitedUserId,
    required this.inviterId,
    required this.sentAt,
  });
}