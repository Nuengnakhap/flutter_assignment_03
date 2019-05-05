import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

final String columnId = "id";
final String columnTitle = "title";
final String columnDone = "done";
final String tableName = 'todo';
List<Todo> _list = List<Todo>();

class Todo {
  int id;
  String title;
  bool done;

  Todo({
    this.id,
    this.title,
    this.done,
  });

  factory Todo.fromMap(Map<dynamic, dynamic> json) => new Todo(
        // id: json[columnId],
        title: json[columnTitle],
        done: json[columnDone] == 1,
      );

  Map<String, dynamic> toMap() => {
        columnTitle: title,
        columnDone: done == true ? 1 : 0,
      };
}

class TodoProvider {
  TodoProvider._();

  static final TodoProvider db = TodoProvider._();

  initDB() async {
    QuerySnapshot querySnapshot = await Firestore.instance.collection(tableName).getDocuments();
    List<Todo> lst = List();
    
    for (DocumentSnapshot item in querySnapshot.documents) {
      lst.length = int.parse(item.documentID);
      lst.insert(int.parse(item.documentID), Todo(title: item.data['title'], done: item.data['done'] == 0 ? false : true));
    }
    _list = lst;
  }

  insertTodo(Todo todo) async {
    _list.add(todo);
    Firestore.instance.collection(tableName).document(_list.indexOf(todo).toString()).setData(todo.toMap());
    return todo;
  }

  doneOrUndone(Todo todo) async {
    await Firestore.instance.collection(tableName).document(todo.id.toString()).setData(todo.toMap());
  }

  Stream<QuerySnapshot> getDoneTodo() {
    return Firestore.instance.collection(tableName).where('done', isEqualTo: 1).snapshots();
  }

  Stream<QuerySnapshot> getUnDoneTodo() {
    return Firestore.instance.collection(tableName).where('done', isEqualTo: 0).snapshots();
  }

  deleteDone() async {
    await Firestore.instance.collection(tableName).where('done', isEqualTo: 1).getDocuments().then((d) {
      d.documents.forEach((r) {
        r.reference.delete();
      });
    });
  }

}
