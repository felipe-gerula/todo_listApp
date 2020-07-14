import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(TODOlistApp());
}

class Todo {
  String task;
  bool done;
  Todo(this.task) : done = false;

  Todo.fromJson(Map<String, dynamic> json)
  : task = json['task'],
    done = json['done'];

  Map<String,dynamic> toJson() => {
    "task" : task,
    "done" : done,
  };

}

class TODOlistApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:TodoListPage()
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({
      Key key,
  }) : super(key : key);
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];

  int get taskDoneCount => todos.where((todo) => todo.done).length;
  
@override
  void initState() {
    _readTodos();
    super.initState();
  }

  _readTodos() async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/todos.json");
      List json = jsonDecode(await file.readAsString());
      List<Todo> newtodos = [];
      for (var todo in json) {
        newtodos.add(Todo.fromJson(todo));
      }
      super.setState(() => todos = newtodos);
    }catch(e){
       setState(() => todos = []);
    }
  }

  void setState(fn){
   super.setState(fn);
   _writeTodos();
  }

  _writeTodos() async{
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/todos.json");
      String jsonText = jsonEncode(todos);
      await file.writeAsString(jsonText);
    }
    catch(e){
      Scaffold.of(context).showSnackBar(SnackBar(content: Text("no se a podido guardar el fichero"),
      ));
    }
  }

  _removeTask(){
    List<Todo> pending = [];
    for(var todo in todos){
      if(!todo.done) pending.add(todo);
    }
    setState(() => todos = pending);
  }

  _listBuilder(){
  if(todos == null){
    return Center(child: CircularProgressIndicator(),);
  }
   return ListView.builder(
     itemBuilder: (context,index){
       return ListTile(
         leading: Checkbox(
             value : todos[index].done,
             onChanged: (checked){
               setState(() => todos[index].done = checked);
             }
         ),
         title: Text(todos[index].task,
           style: TextStyle(decoration: (todos[index].done ?  TextDecoration.lineThrough : TextDecoration.none)),),
       );
     },
     itemCount: todos.length,);
  }

  @override
  Widget build(BuildContext context) {
  _confirmRemoveTask(){
    if(taskDoneCount == 0 ){
      return;
    }
    showDialog(
      context:context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar"),
        content: Text("desea borrar las tareas hechas?"),
        actions: <Widget>[
          FlatButton(
            child: Text("CANCELAR"),
            onPressed: (){
              Navigator.of(context).pop(false);
            } ,),
          FlatButton(
            child: Text("BORRAR"),
            onPressed: (){
              Navigator.of(context).pop(true);
            } ,),
       ],
      ),
    ).then((remove){
      if(remove) _removeTask();
    });
  }

    return Scaffold(
        appBar: AppBar(
          title: Text("TODO list"),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.delete_forever),
              onPressed: _confirmRemoveTask,
            )
          ],
        ),
        body:Container(
          decoration: new BoxDecoration(image: new DecorationImage( image: new AssetImage("assets/fondo.jpg"),fit: BoxFit.cover, ),),
          child:_listBuilder()),
          floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_circle),
         onPressed: (){
          Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTodoPage(),
              )
            ).then((task){
              if(task != null) {
                setState(() {
                  todos.add(Todo(task));
                });
               }
              });
          },
       ),
    );
   }
}



class AddTodoPage extends StatefulWidget {
  @override
  AddTodoPageState createState() => AddTodoPageState();
}

class AddTodoPageState extends State<AddTodoPage> {
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add task"),),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              onSubmitted: (task){
                Navigator.of(context).pop(task);
              },
            ),
            RaisedButton(
              child: Text("Guardar"),
              onPressed: (){
                Navigator.of(context).pop(_controller.text);
              },
            )
          ],
        ),
      ),
    );
  }
}

