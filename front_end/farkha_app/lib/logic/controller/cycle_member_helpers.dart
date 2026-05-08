import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

Future<String?> requireAuthToken(FirebaseAuth auth) async {
  final user = auth.currentUser;
  if (user == null) return null;
  final token = await user.getIdToken();
  return (token == null || token.isEmpty) ? null : token;
}

int? resolveCycleId(Map<String, dynamic> map) {
  final raw = map['cycle_id'];
  return raw is int ? raw : int.tryParse(raw?.toString() ?? '');
}

int? resolveMemberId(dynamic m) {
  final raw = (m as Map)['id'] ?? m['user_id'];
  return raw is int ? raw : int.tryParse(raw?.toString() ?? '');
}

bool memberMatches(dynamic m, int targetUserId) {
  return resolveMemberId(m) == targetUserId;
}

void removeMemberFromLocalState({
  required RxMap<String, dynamic> currentCycle,
  required RxList<Map<String, dynamic>> cycles,
  required int targetUserId,
  required int cycleId,
}) {
  final currentMembers = List<dynamic>.from(
    currentCycle['members'] as List? ?? [],
  );
  currentMembers.removeWhere((m) => memberMatches(m, targetUserId));
  currentCycle['members'] = currentMembers;
  currentCycle.refresh();

  final cycleIdx = cycles.indexWhere((c) => resolveCycleId(c) == cycleId);
  if (cycleIdx != -1) {
    final cycleMap = Map<String, dynamic>.from(cycles[cycleIdx]);
    final cycleMembers = List<dynamic>.from(
      cycleMap['members'] as List? ?? [],
    );
    cycleMembers.removeWhere((m) => memberMatches(m, targetUserId));
    cycleMap['members'] = cycleMembers;
    cycles[cycleIdx] = cycleMap;
  }
}

void updateMemberRoleInLocalState({
  required RxMap<String, dynamic> currentCycle,
  required RxList<Map<String, dynamic>> cycles,
  required int targetUserId,
  required String newRole,
  required int cycleId,
}) {
  void updateInList(List<dynamic> membersList) {
    for (int i = 0; i < membersList.length; i++) {
      final m = membersList[i] as Map;
      if (resolveMemberId(m) == targetUserId) {
        membersList[i] = {
          ...Map<String, dynamic>.from(m),
          'role': newRole,
        };
        break;
      }
    }
  }

  final currentMembers = List<dynamic>.from(
    currentCycle['members'] as List? ?? [],
  );
  updateInList(currentMembers);
  currentCycle['members'] = currentMembers;
  currentCycle.refresh();

  final cycleIdx = cycles.indexWhere((c) => resolveCycleId(c) == cycleId);
  if (cycleIdx != -1) {
    final cycleMap = Map<String, dynamic>.from(cycles[cycleIdx]);
    final cycleMembers = List<dynamic>.from(
      cycleMap['members'] as List? ?? [],
    );
    updateInList(cycleMembers);
    cycleMap['members'] = cycleMembers;
    cycles[cycleIdx] = cycleMap;
  }
}
