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
  String _errorMessage = '';
  late Todo _lastRemovedTodo;

  Future<File> _getFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    File file = File('${appDir.path}/todos_data.json');
    return file;
  }

  Future<void> _saveFile() async {
    File file = await _getFile();

    String data = json.encode(_todos);
    await file.writeAsString(data);
  }

  Future<void> _addTodo() async {
    Todo todo = Todo.build(_todoController.text);

    setState(() {
      _errorMessage = '';
      _todos.add(todo);
    });

    await _saveFile();

    _todoController.clear();

    if(mounted) {
      Navigator.pop(context);
    }
  }

  Future<List<Todo>?> _readTodos() async {
    File file = await _getFile();

    try {
      String fileData = await file.readAsString();

      List<dynamic> jsonData = json.decode(fileData);

      List<Todo> todos = jsonData
          .map((d) => Todo.fromJSON(d))
          .toList();

      return todos;
    } on PathNotFoundException {
      setState(() {
        _errorMessage = 'Nenhuma tarefa encontrada.';
      });
      return null;
    } catch(err) {
      setState(() {
        _errorMessage = 'Erro ao buscar dados.';
      });
      return null;
    }
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

  Future<void> _checkTodoDone(int id) async {
    int todoIdx = _todos.indexWhere((t) => t.id == id);
    if (todoIdx == -1) return;

    setState(() {
      _todos[todoIdx].done = true;
    });
    await _saveFile();
  }

  Future<void> _removeTodo(int id) async {
    int todoIdx = _todos.indexWhere((t) => t.id == id);
    if (todoIdx == -1) return;

    _lastRemovedTodo = _todos[todoIdx];

    setState(() {
      _todos.removeAt(todoIdx);
    });
    await _saveFile();

    SnackBar snackBar = SnackBar(
      content: Text('Tarefa ${_lastRemovedTodo.title} removida.'),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.black45,
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () async {
          setState(() {
            _todos.insert(todoIdx, _lastRemovedTodo);
          });
          await _saveFile();
        }
      ),
    );

    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  initState() {
    super.initState();

    _readTodos().then((data) {
      if(data != null) {
        setState(() {
          _todos = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Todos List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _errorMessage.isNotEmpty ?
        Center(child: Text(_errorMessage)) :
        ListView.builder(
          itemCount: _todos.length,
          itemBuilder: (_, idx) {
            var todo = _todos[idx];
            
            return Dismissible(
              key: Key(todo.id.toString()),
              onDismissed: (direction) => _removeTodo(todo.id),
              background: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.delete, color: Colors.white),
                  ],
                ),
              ),
              direction: DismissDirection.endToStart,
              child: CheckboxListTile(
                  title: Text(todo.title),
                  value: todo.done,
                  onChanged: (_) {
                    if (!todo.done) {
                      _checkTodoDone(todo.id);
                    }
                  }
              ),
            );
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
