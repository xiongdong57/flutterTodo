import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart';
import 'package:todo/model/label.dart';
import 'package:todo/model/project.dart';
import 'package:todo/model/task.dart';
import 'package:todo/model/task_labels.dart';

class AppDatabase {
  AppDatabase._privateConsTructor();
  static final AppDatabase instance = AppDatabase._privateConsTructor();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _init();
    return _database;
  }

  _init() async {
    print('init database');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'task.db');
    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      print('create db');
      await _createProjectTable(db);
      await _createTaskTable(db);
      await _createLabelTable(db);
    }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
      await db.execute('DROP TABLE ${Task.tblTask}');
      await db.execute('DROP TABLE ${Project.tblProject}');
      await db.execute('DROP TABLE ${Label.tblLabel}');

      await _createProjectTable(db);
      await _createTaskTable(db);
      await _createLabelTable(db);
    });
    return _database;
  }

  Future _createProjectTable(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute("CREATE TABLE ${Project.tblProject} ("
          "${Project.dbID} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${Project.dbName} TEXT,"
          "${Project.dbColorName} TEXT,"
          "${Project.dbColorCode} INTEGER);");
      txn.rawInsert("INSERT INTO "
          "${Project.tblProject} (${Project.dbID}, ${Project.dbName}, ${Project.dbColorName}, ${Project.dbColorCode})"
          "VALUES (1, 'Inbox', 'Grey', ${Colors.grey.value});");
    });
  }

  Future _createTaskTable(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute("CREATE TABLE ${Task.tblTask} ("
          "${Task.dbID} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${Task.dbTitle} TEXT,"
          "${Task.dbComment} TEXT,"
          "${Task.dbDueDate} LONG,"
          "${Task.dbPriority} LONG,"
          "${Task.dbProjectID} LONG,"
          "${Task.dbStatus} LONG,"
          "FOREIGN KEY(${Task.dbProjectID}) REFERENCES ${Project.tblProject}(${Project.dbID}) ON DELETE CASCADE);");
    });
  }

  Future _createLabelTable(Database db) {
    return db.transaction((Transaction txn) async {
      txn.execute("CREATE TABLE ${Label.tblLabel} ("
          "${Label.dbID} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${Label.dbName} TEXT,"
          "${Label.dbColorName} TEXT,"
          "${Label.dbColorCode} INTEGER);");
      txn.execute("CREATE TABLE ${TaskLabels.tblTaskLabel} ("
          "${TaskLabels.dbID} INTEGER PRIMARY KEY AUTOINCREMENT,"
          "${TaskLabels.dbTaskID} INTEGER,"
          "${TaskLabels.dbLabelID} INTEGER,"
          "FOREIGN KEY(${TaskLabels.dbTaskID}) REFERENCES ${Task.tblTask}(${Task.dbID}) ON DELETE CASCADE,"
          "FOREIGN KEY(${TaskLabels.dbLabelID}) REFERENCES ${Label.tblLabel}(${Label.dbID}) ON DELETE CASCADE);");
    });
  }

  Future<List<Project>> getProjects({bool isInboxVisible = true}) async {
    print('get all projects');
    var db = await AppDatabase.instance.database;
    var result = await db.rawQuery("SELECT * FROM ${Project.tblProject};");
    List<Project> projects = [];
    for (Map<String, dynamic> item in result) {
      var myProject = Project.fromMap(item);
      projects.add(myProject);
    }
    return projects;
  }

  Future updateProject(Project project) async {
    var db = await AppDatabase.instance.database;
    await db.rawInsert('INSERT OR REPLACE INTO '
        '${Project.tblProject}(${Project.dbID},${Project.dbName},${Project.dbColorCode},${Project.dbColorName})'
        ' VALUES(${project.id},"${project.name}", ${project.colorCode}, "${project.colorName}")');
  }

  Future deleteProject(int projectID) async {
    var db = await AppDatabase.instance.database;
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          "DELETE FROM ${Project.tblProject} WHERE ${Project.dbID} == $projectID;");
    });
  }

  Future<List<Label>> getLabels() async {
    var db = await AppDatabase.instance.database;
    var result = await db.rawQuery("SELECT * FROM ${Label.tblLabel};");
    List<Label> labels = [];
    for (Map<String, dynamic> item in result) {
      var myLabel = Label.fromMap(item);
      labels.add(myLabel);
    }
    return labels;
  }

  Future updateLabel(Label label) async {
    var db = await AppDatabase.instance.database;
    await db.rawInsert("INSERT OR REPLACE INTO "
        "${Label.tblLabel} (${Label.dbID}, ${Label.dbName}, ${Label.dbColorName}, ${Label.dbColorCode})"
        " VALUES(${label.id}, ${label.name}, ${label.colorName}, ${label.colorCode})");
  }

  Future deleteLabel(int labelID) async {
    var db = await AppDatabase.instance.database;
    await db.transaction((Transaction txn) async {
      await txn.rawDelete(
          "DELETE FROM ${Label.dbID} WHERE ${Project.dbID} == $labelID;");
    });
  }

  List<Task> _bindTaskData(List<Map<String, dynamic>> result) {
    List<Task> tasks = [];
    for (Map<String, dynamic> item in result) {
      var myTask = Task.fromMap(item);
      myTask.projectName = item[Project.dbName];
      myTask.projectColor = item[Project.dbColorCode];
      var labelComma = item['labelNames'];
      if (labelComma != null) {
        myTask.labelList = labelComma.toString().split(',');
      }

      tasks.add(myTask);
    }

    return tasks;
  }

  Future<List<Task>> getTasks(
      {int startDate = 0, int endDate = 0, TaskStatus taskStatus}) async {
    var db = await AppDatabase.instance.database;
    var whereClause = startDate > 0 && endDate > 0
        ? "WHERE ${Task.tblTask}.${Task.dbDueDate} BETWEEN $startDate and $endDate"
        : "";
    var result = await db.rawQuery(
        'SELECT ${Task.tblTask}.*,${Project.tblProject}.${Project.dbName},${Project.tblProject}.${Project.dbColorCode},group_concat(${Label.tblLabel}.${Label.dbName}) as labelNames '
        'FROM ${Task.tblTask} LEFT JOIN ${TaskLabels.tblTaskLabel} ON ${TaskLabels.tblTaskLabel}.${TaskLabels.dbTaskID}=${Task.tblTask}.${Task.dbID} '
        'LEFT JOIN ${Label.tblLabel} ON ${Label.tblLabel}.${Label.dbID}=${TaskLabels.tblTaskLabel}.${TaskLabels.dbLabelID} '
        'INNER JOIN ${Project.tblProject} ON ${Task.tblTask}.${Task.dbProjectID} = ${Project.tblProject}.${Project.dbID} $whereClause GROUP BY ${Task.tblTask}.${Task.dbID} ORDER BY ${Task.tblTask}.${Task.dbDueDate} ASC;');

    return _bindTaskData(result);
  }

  Future getTasksByProject(int projectID, {TaskStatus status}) async {}

  getTasksByLabel(String labelName, {TaskStatus status}) async {}

  Future updateTaskStatus(int taskID, TaskStatus status) async {
    var db = await AppDatabase.instance.database;
    await db.transaction((Transaction txn) async {
      await txn.rawInsert(
          "UPDATE ${Task.tblTask} SET ${Task.dbStatus} = '${status.index}' WHERE ${Task.dbID} = $taskID");
    });
  }

  Future updateTask(Task task, {List<int> labelIDs}) async {
    var db = await AppDatabase.instance.database;
    await db.transaction((Transaction txn) async {
      int id = await txn.rawInsert('INSERT OR REPLACE INTO '
          '${Task.tblTask}(${Task.dbID},${Task.dbTitle},${Task.dbProjectID},${Task.dbComment},${Task.dbDueDate},${Task.dbPriority},${Task.dbStatus})'
          ' VALUES(${task.id}, "${task.title}", ${task.projectID},"${task.comment}", ${task.dueDate},${task.priority.index},${task.taskStatus.index})');
      if (id > 0 && labelIDs != null && labelIDs.length > 0) {
        labelIDs.forEach((labelID) {
          txn.rawInsert("INSERT OR REPLACE INTO "
              "${TaskLabels.tblTaskLabel} (${TaskLabels.dbID}, ${TaskLabels.dbTaskID}, ${TaskLabels.dbLabelID}) "
              " VALUES(null, $id, $labelID)");
        });
      }
    });
  }

  Future deleteTask(int taskID) async {
    var db = await AppDatabase.instance.database;
    await db.transaction((Transaction txn) async {
      await txn
          .rawDelete('DELETE FROM ${Task.tblTask} WHERE ${Task.dbID}=$taskID;');
    });
  }
}
