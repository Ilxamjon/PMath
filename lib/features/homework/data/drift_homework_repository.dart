import '../../../core/storage/local_snapshot.dart';
import '../../../models/homework_model.dart';
import '../domain/homework_repository.dart';

class DriftHomeworkRepository implements HomeworkRepository {
  DriftHomeworkRepository(this._store);

  final LocalSnapshot _store;

  @override
  List<HomeworkModel> getHomeworkList() {
    return [..._store.homework]
      ..sort((a, b) => b.assignedAt.compareTo(a.assignedAt));
  }

  @override
  Future<void> saveHomeworkList(List<HomeworkModel> items) =>
      _store.saveHomework(items);

  @override
  Future<void> upsertHomework(HomeworkModel homework) async {
    final list = [...getHomeworkList()];
    final idx = list.indexWhere((item) => item.id == homework.id);
    if (idx >= 0) {
      list[idx] = homework;
    } else {
      list.insert(0, homework);
    }
    await saveHomeworkList(list);
  }

  @override
  HomeworkModel? getHomeworkById(String id) {
    for (final item in getHomeworkList()) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  HomeworkModel? getHomeworkForLesson(String lessonId) {
    for (final item in getHomeworkList()) {
      final open = item.status == HomeworkStatus.assigned ||
          item.status == HomeworkStatus.needsRevision;
      if (item.lessonId == lessonId && open) return item;
    }
    return null;
  }

  @override
  List<HomeworkModel> getHomeworkListForLesson(String lessonId) {
    return getHomeworkList().where((item) => item.lessonId == lessonId).toList();
  }

  @override
  Future<void> deleteHomework(String id) async {
    final list = getHomeworkList().where((item) => item.id != id).toList();
    await saveHomeworkList(list);
  }

  @override
  List<HomeworkModel> get pendingHomework =>
      getHomeworkList().where((item) => item.isPendingScan).toList();

  @override
  List<HomeworkModel> get overdueHomework =>
      getHomeworkList().where((item) => item.isOverdue).toList();
}
