class TaskLabels {
  static final tblTaskLabel = 'taskLabel';
  static final dbID = 'id';
  static final dbTaskID = 'taskID';
  static final dbLabelID = 'labelID';

  int id, taskID, labelID;

  TaskLabels.create(this.taskID, this.labelID);
  TaskLabels.update({this.id, this.taskID, this.labelID});
  TaskLabels.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbID], taskID: map[dbTaskID], labelID: map[dbLabelID]);
}
