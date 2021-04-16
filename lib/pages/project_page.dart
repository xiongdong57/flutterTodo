import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/task_provider.dart';
import 'package:todo/util/appExpansion.dart';
import 'package:todo/util/util.dart';

class ProjectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.book),
      title: Text(
        'Projects',
        style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      children: _buildProjects(context),
    );
  }
}

List<Widget> _buildProjects(BuildContext context) {
  List<Widget> projectWidgetsList = [];
  Provider.of<TaskProvider>(context).projects.forEach((element) {
    projectWidgetsList.add(ListTile(
        leading: Container(
          width: 14.0,
          height: double.infinity,
        ),
        title: Text('${element.name}'),
        trailing: Container(
          height: double.infinity,
          width: 10.0,
          child: CircleAvatar(
            backgroundColor: Color(element.colorCode),
          ),
        ),
        onTap: () {
          Provider.of<TaskProvider>(context, listen: false)
              .setHomeFilterByName('@' + element.name);
          Navigator.pop(context);
        }));
  });
  projectWidgetsList.add(ListTile(
    leading: Icon(Icons.add),
    title: Text("new project"),
    onTap: () {
      Provider.of<TaskProvider>(context, listen: false).initNewProject();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => AddProject()));
    },
  ));
  return projectWidgetsList;
}

class AddProject extends StatefulWidget {
  @override
  _AddProjectState createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController projectTitleController = TextEditingController();
  final GlobalKey<AppExpansionTileState> expansionTile = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: projectTitleController,
                key: ValueKey('add project'),
                decoration: InputDecoration(hintText: "Project name"),
                maxLength: 20,
                validator: (value) {
                  return value.isEmpty ? "Project name cannot be empty" : null;
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.0),
            child: AppExpansionTile(
              key: expansionTile,
              title: Consumer<TaskProvider>(
                  builder: (context, taskProvider, child) {
                if (taskProvider.newProject != null) {
                  var newProject = taskProvider.newProject;
                  return ListTile(
                    title: Text('${newProject.colorName}'),
                    leading: Container(
                      width: 12.0,
                      height: double.infinity,
                      child: CircleAvatar(
                        backgroundColor: Color(newProject.colorCode),
                      ),
                    ),
                  );
                } else {
                  // return Text('select color');
                  return ListTile(
                    title: Text('HI'),
                    leading: Container(
                      width: 12.0,
                      height: double.infinity,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  );
                }
              }),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
              children: colorsPalettes.map((elem) {
                return ListTile(
                  leading: Container(
                    width: 12.0,
                    height: double.infinity,
                    child: CircleAvatar(
                      backgroundColor: Color(elem.colorValue),
                    ),
                  ),
                  title: Text(elem.colorName),
                  onTap: () {
                    print(elem.colorValue);
                    Provider.of<TaskProvider>(context, listen: false)
                        .setNewProjectColor(elem.colorName, elem.colorValue);
                    setState(() {
                      expansionTile.currentState.collapse();
                    });
                  },
                );
              }).toList(),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.send, color: Colors.white),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            Provider.of<TaskProvider>(context, listen: false)
                .setNewProjectName(projectTitleController.text);
            Provider.of<TaskProvider>(context, listen: false).updateProject();
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
