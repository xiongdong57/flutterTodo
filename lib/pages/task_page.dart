import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/model/priority.dart';
import 'package:todo/model/task.dart';
import 'package:todo/provider/task_provider.dart';
import 'package:todo/util/app_constant.dart';
import 'package:todo/util/util.dart';

class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Task> pendingTasks =
        Provider.of<TaskProvider>(context).filterTasks;
    if (pendingTasks.length > 0) {
      return _buildTaskList(pendingTasks);
    } else {
      return Center(child: Text("No task"));
    }
  }
}

class CompletedTasks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Task> archivedTasks = Provider.of<TaskProvider>(context)
        .tasks
        .where((elem) => elem.taskStatus == TaskStatus.COMPLETE)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Completed Tasks'),
      ),
      body: archivedTasks.length > 0
          ? _buildTaskList(archivedTasks)
          : Center(child: Text('no task archived')),
    );
  }
}

class AddTaskPage extends StatelessWidget {
  final Task currentTask;
  AddTaskPage([this.currentTask]);
  TextEditingController taskTitleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: currentTask.title != '' ? Text("Edit Task") : Text("Add Task"),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: ValueKey('addTitle'),
                controller: taskTitleController
                  ..text =
                      "${Provider.of<TaskProvider>(context, listen: false).currentTask.title}",
                validator: (value) {
                  var msg = value.isEmpty ? "Task title cannot be empty" : null;
                  return msg;
                },
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(hintText: 'title'),
              ),
            ),
          ),
          ListTile(
              leading: Icon(Icons.book),
              title: Text('Project'),
              subtitle: Consumer<TaskProvider>(
                builder: (context, taskProvider, child) {
                  if (taskProvider.currentTask.projectName != null) {
                    return Text("${taskProvider.currentTask.projectName}");
                  } else {
                    return Text("Select Project");
                  }
                },
              ),
              onTap: () {
                //  todo show dialog
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        title: Text('Select Project'),
                        children: _buildProjects(context),
                      );
                    }).then((project) {
                  //      todo set project
                  if (project != null) {
                    Provider.of<TaskProvider>(context, listen: false)
                        .setCurrentProject(project);
                  }
                });
              }),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Due Date'),
            subtitle: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return Text(
                    "${getFormattedDate(taskProvider.currentTask.dueDate)}");
              },
            ),
            onTap: () {
              //  todo show dialog
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020, 1),
                      lastDate: DateTime(2120, 1))
                  .then((pickedDate) {
                if (pickedDate != null) {
                  //  set task dueDate
                  Provider.of<TaskProvider>(context, listen: false)
                      .setDueDate(pickedDate.millisecondsSinceEpoch);
                }
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.flag),
            title: Text('Priority'),
            subtitle: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return Text(
                    "${priorityText[taskProvider.currentTask.priority.index]}");
              },
            ),
            onTap: () {
              //  todo
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      title: Text('Select Dialog'),
                      children: [
                        _buildPriority(context, Status.PRIORITY_1),
                        _buildPriority(context, Status.PRIORITY_2),
                        _buildPriority(context, Status.PRIORITY_3),
                        _buildPriority(context, Status.PRIORITY_4)
                      ],
                    );
                  }).then((newPriority) {
                if (newPriority != null) {
                  Provider.of<TaskProvider>(context, listen: false)
                      .setPriority(newPriority);
                }
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.mode_comment),
            title: Text('Comments'),
            subtitle: Text('no comments'),
            onTap: () {
              final snackBar = SnackBar(content: Text('comming soon'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send, color: Colors.white),
        onPressed: () {
          var taskTitle = taskTitleController.text;
          if (_formKey.currentState.validate()) {
            Provider.of<TaskProvider>(context, listen: false)
                .setTaskTitle(taskTitle);
            Provider.of<TaskProvider>(context, listen: false).saveTask();
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}

List<Widget> _buildProjects(BuildContext context) {
  List<Widget> projects = [];
  Provider.of<TaskProvider>(context, listen: false).projects.forEach((elem) {
    projects.add(ListTile(
      leading: Container(
        width: 12.0,
        height: double.infinity,
        child: CircleAvatar(
          backgroundColor: Color(elem.colorCode),
        ),
      ),
      title: Text(elem.name),
      onTap: () {
        Navigator.pop(context, elem);
      },
    ));
  });
  return projects;
}

GestureDetector _buildPriority(BuildContext context, Status status) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context, status);
    },
    child: Container(
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 2.0),
        decoration: BoxDecoration(
            border: Border(
                left: BorderSide(
                    width: 6.0, color: priorityColor[status.index]))),
        child: Container(
          margin: const EdgeInsets.all(12.0),
          child: Text(
            priorityText[status.index],
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      ),
    ),
  );
}

Widget _buildTaskList(List<Task> tasks) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Container(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            key: UniqueKey(),
            background: Container(
              color: Colors.red,
              child: ListTile(
                trailing: Text('Delete',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                leading: Icon(Icons.delete, color: Colors.white),
              ),
            ),
            secondaryBackground: tasks[index].taskStatus == TaskStatus.COMPLETE
                ? Container(
                    color: Colors.grey,
                    child: ListTile(
                      trailing: Text(
                        "UNDO",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.green,
                    child: ListTile(
                      trailing: Text(
                        'Archive',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      leading: Icon(Icons.check_box, color: Colors.white),
                    ),
                  ),
            onDismissed: (DismissDirection direction) {
              var task = tasks[index];
              var message = '';
              if (direction == DismissDirection.endToStart) {
                //  update Status
                if (task.taskStatus == TaskStatus.PENDING) {
                  message = 'task completed';
                  Provider.of<TaskProvider>(context, listen: false)
                      .updateTaskStatus(task, TaskStatus.COMPLETE);
                } else {
                  message = 'task undo';
                  Provider.of<TaskProvider>(context, listen: false)
                      .updateTaskStatus(task, TaskStatus.PENDING);
                }
              } else {
                //  delete task
                Provider.of<TaskProvider>(context, listen: false)
                    .deleteTask(task);
                message = 'task delete';
              }
              SnackBar snackbar = SnackBar(
                content: Text(message),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            },
            child: TaskRow(tasks[index]),
          );
        },
      ),
    ),
  );
}

class TaskRow extends StatelessWidget {
  final Task task;
  TaskRow(this.task);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //  todo setTask, tap to edit task
        Provider.of<TaskProvider>(context, listen: false).setTask(task);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AddTaskPage(task)));
      },
      child: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 1.0),
            decoration: BoxDecoration(
                border: Border(
                    left: BorderSide(
                        width: 4.0,
                        color: priorityColor[task.priority.index]))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Text(
                      task.title,
                      style: TextStyle(
                          decoration: task.taskStatus == TaskStatus.PENDING
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                          fontSize: FONT_SIZE_TITLE,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  //  todo getlabels

                  Padding(
                    padding: const EdgeInsets.only(
                        left: PADDING_SMALL, bottom: PADDING_VERY_SMALL),
                    child: Row(
                      children: <Widget>[
                        Text(
                          getFormattedDate(task.dueDate),
                          style: TextStyle(
                              color: Colors.grey, fontSize: FONT_SIZE_DATE),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  task.projectName,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: FONT_SIZE_LABEL),
                                ),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  width: 8.0,
                                  height: 8.0,
                                  child: CircleAvatar(
                                    backgroundColor: Color(task.projectColor),
                                  ),
                                )
                              ],
                            )
                          ],
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.grey))),
          )
        ],
      ),
    );
  }
}
