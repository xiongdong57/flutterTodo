import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/model/task.dart';
import 'package:todo/pages/project_page.dart';
import 'package:todo/pages/task_page.dart';
import 'package:todo/provider/task_provider.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return Text('${taskProvider.homeFilter}');
          },
        ),
        actions: <Widget>[buildPopupMenu(context)],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.orange,
        onPressed: () {
          //  todo add task
          Provider.of<TaskProvider>(context, listen: false).initTaskProject();
          Task task =
              Provider.of<TaskProvider>(context, listen: false).currentTask;
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTaskPage(task)));
        },
      ),
      drawer: SideDrawer(),
      body: TaskPage(),
    );
  }
}

enum MenuItem { taskCompleted }
Widget buildPopupMenu(BuildContext context) {
  return PopupMenuButton(
      onSelected: (MenuItem result) async {
        switch (result) {
          case MenuItem.taskCompleted:
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => CompletedTasks()));
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItem>>[
            const PopupMenuItem(
                value: MenuItem.taskCompleted, child: Text('Completed Tasks'))
          ]);
}

class SideDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.all(0.0),
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Dong'),
            accountEmail: Text('xiongdong57@gmail.com'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).accentColor,
              backgroundImage: AssetImage('assets/profile_pic.jpg'),
            ),
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .setHomeFilterByName("Inbox");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Today'),
            onTap: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .setHomeFilterByName("Today");
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Next 7 Days'),
            onTap: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .setHomeFilterByName("Next 7 Days");
              Navigator.pop(context);
            },
          ),
          ProjectPage()
        ],
      ),
    );
  }
}
