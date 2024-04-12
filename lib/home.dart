import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_list/todo.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _todoController = TextEditingController();
  List<Todo> _todos = [];

  Future<File> _getFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    File file = File('${appDir.path}/todos_data.json');
    return file;
  }

  Future<void> _addTodo() async {
    Todo todo = Todo.build(_todoController.text);
    _todos.add(todo);

    File file = await _getFile();

    String data = json.encode(_todos);
    await file.writeAsString(data);

    _todoController.clear();

    if(mounted) {
      Navigator.pop(context);
    }
  }

  _read() async {
    File file = await _getFile();

    String fileData = await file.readAsString();

    List<dynamic> jsonData = json.decode(fileData);

    List<Todo> todos = jsonData
      .map((d) => Todo.fromJSON(d))
      .toList();

    setState(() {
      _todos = todos;
    });
  }

  void _onPressAddButton() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add todo'),
          content: TextField(
            controller: _todoController,
            decoration: const InputDecoration(
              label: Text('Type your todo')
            ),
          ),
          backgroundColor: Colors.white,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _addTodo,
              child: const Text('Save'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    _read();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Todos List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (_, idx) {
          var todo = _todos[idx];
          return ListTile(title: Text(todo.title));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 10,
        mini: false,
        onPressed: _onPressAddButton,
        tooltip: 'Add todo',
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
