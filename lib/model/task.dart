import 'package:todo/model/priority.dart';
import 'package:flutter/material.dart';

enum TaskStatus { PENDING, COMPLETE }

class Task {
  static final tblTask = 'Tasks';
  static final dbID = 'id';
  static final dbTitle = 'title';
  static final dbComment = 'comment';
  static final dbDueDate = 'dueDate';
  static final dbPriority = 'priority';
  static final dbStatus = 'status';
  static final dbProjectID = 'projectID';

  String title, comment, projectName;
  int id, dueDate, projectID, projectColor;
  Status priority;
  TaskStatus taskStatus;
  List<String> labelList;

  Task(
      {this.title,
      this.projectID,
      this.comment,
      this.dueDate,
      this.priority,
      this.taskStatus});

  Task.create(
      {@required this.title,
      @required this.projectID,
      this.comment = '',
      this.dueDate = -1,
      this.priority = Status.PRIORITY_1}) {
    if (this.dueDate == -1) {
      this.dueDate = DateTime.now().millisecondsSinceEpoch;
    }
    this.taskStatus = TaskStatus.PENDING;
  }

  Task.update(
      {@required this.id,
      @required this.title,
      @required this.projectID,
      this.comment = '',
      this.dueDate = -1,
      this.priority = Status.PRIORITY_1,
      this.taskStatus = TaskStatus.PENDING}) {
    if (this.dueDate == -1) {
      this.dueDate = DateTime.now().millisecondsSinceEpoch;
    }
  }

  Task.fromMap(Map<String, dynamic> map)
      : this.update(
            id: map[dbID],
            title: map[dbTitle],
            projectID: map[dbProjectID],
            comment: map[dbComment],
            dueDate: map[dbDueDate],
            priority: Status.values[map[dbPriority]],
            taskStatus: TaskStatus.values[map[dbStatus]]);
}
