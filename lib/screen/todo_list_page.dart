import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rest_api/screen/add_page_.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  int _currentIndex = 0;
  bool isLoading = true;
  List items = [];
  List filteredItems = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Todo List',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: navigateToAddPage,
              label: const Text('Add Todo'),
            )
          : null,
      body: Column(
        children: [
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  filterTodoList(value);
                },
                decoration: const InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          Visibility(
            visible: isLoading,
            child: const Center(child: CircularProgressIndicator()),
            replacement: RefreshIndicator(
              onRefresh: fetchTodo,
              child: _currentIndex == 0
                  ? TodoListWidget(
                      items: filteredItems,
                      onDelete: deleteById,
                      onEdit: navigateToEditPage)
                  : Container(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 1:
              ProfileInfoDialog.show(context);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  void filterTodoList(String query) {
    setState(() {
      filteredItems = items
          .where((item) =>
              item['title']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              item['description']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
    });
  }

  void navigateToEditPage(Map item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoPage(todo: item),
      ),
    );

    if (result != null && result is bool && result) {
      fetchTodo();
      showSuccessMessage(context, 'Todo edited successfully');
    }
  }

  Future<void> navigateToAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTodoPage(todo: {}),
      ),
    );

    if (result != null && result is bool && result) {
      fetchTodo();
      showSuccessMessage(context, 'Todo added successfully');
    }
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
        filteredItems = filtered;
      });
      showSuccessMessage(context, 'Todo deleted successfully');
    } else {
      showErrorMessage(context, 'Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
        filteredItems = result;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showSuccessMessage(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class TodoListWidget extends StatelessWidget {
  final List items;
  final Function(Map) onEdit;
  final Function(String) onDelete;

  const TodoListWidget(
      {Key? key,
      required this.items,
      required this.onEdit,
      required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index] as Map;
        final id = item['_id'] as String;
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(item['title']),
          subtitle: Text(item['description']),
          trailing: PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit(item);
              } else if (value == 'delete') {
                onDelete(id);
              }
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text('Edit'),
                  value: 'edit',
                ),
                PopupMenuItem(
                  child: Text('Delete'),
                  value: 'delete',
                ),
              ];
            },
          ),
        );
      },
    );
  }
}

class ProfileInfoDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Information'),
          content: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://media.istockphoto.com/id/1356420393/id/foto/wanita-futuristik-3d-dengan-kacamata-vr-metavers.jpg?s=1024x1024&w=is&k=20&c=sSyne_m1wKhk6jPqbAu9y8DqlyScW2R9E3Z7CCVVoWQ=',
                ),
              ),
              SizedBox(height: 16),
              Text('Name: Irenius Bonan'),
              Text('Email: irenisbonan@gmail.com'),
              Text('Kelas: TIF RP 221 PB'),
              Text('Prodi: Teknik Informatika'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
