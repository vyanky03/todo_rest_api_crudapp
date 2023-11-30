import 'package:flutter/material.dart';
import 'package:todo_rest_api/screens/add_page.dart';
import 'package:todo_rest_api/services/todo_services.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodooListPageState();
}

class _TodooListPageState extends State<TodoListPage> {
  bool isLoading = false;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo App'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigatetoAddPage,
        label: const Text('Add Todo'),
      ),
      body: Visibility(
        visible: isLoading,
        child: const Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: const Center(child: Text('No ToDo Item')),
            child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index] as Map;
                  final id = item['_id'] as String;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            //open the edit page
                            navigatetoEditPage(item);
                          } else if (value == 'delete') {
                            //delete the todo
                            deteletById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              child: Text('Edit'),
                              value: 'edit',
                            ),
                            const PopupMenuItem(
                              child: Text('Delete'),
                              value: 'delete',
                            )
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }

  Future<void> deteletById(String id) async {
    //delete the item
    final success = await TodoService.deteletById(id);
    if (success) {
      //remove from api
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showMessage('Deletion Faild');
    }
  }

  Future<void> fetchTodo() async {
    final resp = await TodoService.fetchTodo();
    if (resp != null) {
      setState(() {
        items = resp;
      });
    } else {
      showMessage('Something went wrong');
    }
    setState(() {
      isLoading = false;
    });
  }

  void showMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> navigatetoAddPage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddTodoPage(),
    );
    Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> navigatetoEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodoPage(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }
}
