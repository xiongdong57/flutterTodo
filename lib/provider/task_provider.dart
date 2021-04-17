import 'package:flutter/material.dart';
import 'package:todo/db/app_db.dart';
import 'package:todo/model/priority.dart';
import 'package:todo/model/project.dart';
import 'package:todo/model/task.dart';

class TaskProvider with ChangeNotifier {
  List<Project> projects = [];
  List<Task> tasks = [];
  Task currentTask;
  Project currentProject;
  List<Task> filterTasks = [];
  String homeFilter = 'Inbox';
  Project newProject;

  TaskProvider() {
    getProjects();
    getTasks();
  }

  Future getProjects() async {
    projects = await AppDatabase.instance.getProjects();
  }

  Future getTasks() async {
    tasks = await AppDatabase.instance.getTasks();
    _setFilterTasks();
  }

  initTaskProject() {
    currentTask = Task(
        title: '',
        projectID: 1,
        comment: '',
        dueDate: DateTime.now().millisecondsSinceEpoch,
        priority: Status.PRIORITY_1,
        taskStatus: TaskStatus.PENDING);
    currentTask.projectName = 'Inbox';
    currentProject = projects.where((element) => element.id == 1).toList()[0];
  }

  setCurrentProject(Project project) {
    currentProject = project;
    currentTask.projectID = project.id;
    currentTask.projectName = project.name;
    currentTask.projectColor = project.colorCode;
    notifyListeners();
  }

  setTask(task) {
    currentTask = task;
    notifyListeners();
  }

  setDueDate(int dueDate) {
    currentTask.dueDate = dueDate;
    notifyListeners();
  }

  setPriority(newPriority) {
    currentTask.priority = newPriority;
    notifyListeners();
  }

  setTaskTitle(taskTitle) {
    currentTask.title = taskTitle;
    notifyListeners();
  }

  saveTask() async {
    if (currentTask.projectID == null) {
      currentTask.projectID = currentProject.id;
    }

    await AppDatabase.instance.updateTask(currentTask);
    await getTasks();
    notifyListeners();
  }

  updateTaskStatus(Task task, TaskStatus status) async {
    await AppDatabase.instance.updateTaskStatus(task.id, status);
    await getTasks();
    notifyListeners();
  }

  deleteTask(Task task) async {
    await AppDatabase.instance.deleteTask(task.id);
    await getTasks();
    notifyListeners();
  }

  _setFilterTasks() {
    if (homeFilter == 'Inbox') {
      filterTasks =
          tasks.where((elem) => elem.taskStatus == TaskStatus.PENDING).toList();
    }

    if (homeFilter == 'Today') {
      final dateTime = DateTime.now();
      var startDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final int taskStartTime = startDate.millisecondsSinceEpoch;
      var endDate =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59);
      final int taskEndTime = endDate.millisecondsSinceEpoch;
      filterTasks = tasks
          .where((elem) =>
              elem.taskStatus == TaskStatus.PENDING &&
              elem.dueDate >= taskStartTime &&
              elem.dueDate <= taskEndTime)
          .toList();
    }

    if (homeFilter == 'Next 7 Days') {
      final dateTime = DateTime.now();
      var startDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final int taskStartTime = startDate.millisecondsSinceEpoch;
      var endDate =
          DateTime(dateTime.year, dateTime.month, dateTime.day + 7, 23, 59);
      final int taskEndTime = endDate.millisecondsSinceEpoch;
      filterTasks = tasks
          .where((elem) =>
              elem.taskStatus == TaskStatus.PENDING &&
              elem.dueDate >= taskStartTime &&
              elem.dueDate <= taskEndTime)
          .toList();
    }

    if (homeFilter.startsWith('@')) {
      String _projectName = homeFilter.substring(1);
      filterTasks = tasks
          .where((elem) =>
              elem.taskStatus == TaskStatus.PENDING &&
              elem.projectName == _projectName)
          .toList();
    }

    notifyListeners();
  }

  setHomeFilterByName(String filter) {
    homeFilter = filter;
    _setFilterTasks();
    notifyListeners();
  }

  initNewProject(
      {String projectName = "",
      String colorName = "Grey",
      int colorCode = 4288585374}) {
    newProject =
        Project(name: projectName, colorName: colorName, colorCode: colorCode);
    notifyListeners();
  }

  setNewProjectColor(String colorName, int colorCode) {
    newProject.colorName = colorName;
    newProject.colorCode = colorCode;
    notifyListeners();
  }

  setNewProjectName(String projectName) {
    newProject.name = projectName;
    notifyListeners();
  }

  Future updateProject() async {
    if (newProject != null) {
      await AppDatabase.instance.updateProject(newProject);
      await getProjects();
      notifyListeners();
    }
  }
}
