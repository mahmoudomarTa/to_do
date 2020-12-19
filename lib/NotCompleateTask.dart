import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'todoItem.dart';
import 'dataAccess.dart';



class NotCompleteTask extends StatefulWidget {
  const NotCompleteTask({ Key key }) : super(key: key);

  @override
  _NotCompleteTaskState createState() => _NotCompleteTaskState();

}


class _NotCompleteTaskState extends State<NotCompleteTask>{
  List<TodoItem> _todoItems = List();
  DataAccess _dataAccess;

  _NotCompleteTaskState() {
    _dataAccess = DataAccess();
  }

  @override
  initState() {
    super.initState();
    _dataAccess.open().then((result) {
      _dataAccess.getTodoItems()
          .then((r) {
        setState(() {
          r.forEach((element) {
            if (!element.isComplete){
              _todoItems.add(element);
            }
          });

        });
      });
    });
  }



  void _updateTodoCompleteStatus(TodoItem item, bool newStatus) {
    item.isComplete = newStatus;
    _dataAccess.updateTodo(item);
    _dataAccess.getTodoItems()
        .then((items) {
      setState(() { _todoItems = items; });
    });
  }

  void _deleteTodoItem(TodoItem item) {
    _dataAccess.deleteTodo(item);
    _dataAccess.getTodoItems()
        .then((items) {
      setState(() { _todoItems = items; });
    });
  }

  Future<Null> _displayDeleteConfirmationDialog(TodoItem item) {
    return showDialog<Null>(
        context: context,
        barrierDismissible: true, // Allow dismiss when tapping away from dialog
        builder: (BuildContext context) {
          return  AlertDialog(
            title: Text("Delete TODO"),
            content: Text("Do you want to delete \"${item.name}\"?"),
            actions: <Widget>[
              FlatButton(
                child: Text("Cancel"),
                onPressed: Navigator.of(context).pop, // Close dialog
              ),
              FlatButton(
                child: Text("Delete"),
                onPressed: () {
                  _deleteTodoItem(item);
                  Navigator.of(context).pop(); // Close dialog
                },
              ),
            ],
          );
        }
    );
  }

  Widget _createTodoItemWidget(TodoItem item) {
    return ListTile(
      title: Text(item.name),
      trailing: Checkbox(
        value: item.isComplete,
        onChanged: (value) => _updateTodoCompleteStatus(item, value),
      ),
      onLongPress: () => _displayDeleteConfirmationDialog(item),
    );
  }
  @override
  Widget build(BuildContext context) {
    _todoItems.sort();
    final todoItemWidgets = _todoItems.map(_createTodoItemWidget).toList();

    return MaterialApp(
      home: Scaffold(
        body:  ListView(
          children: todoItemWidgets,
        ),
      ),
    );
  }


}