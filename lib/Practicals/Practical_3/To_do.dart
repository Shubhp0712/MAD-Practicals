import 'package:flutter/material.dart';

enum Priority { low, medium, high }
class Todo {
  String title;
  bool isDone;
  Priority priority;

  Todo({
    required this.title,
    this.isDone = false,
    this.priority = Priority.low,
  });
}
class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}
class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = [];
  String _searchQuery = '';
  int _filterIndex = 0;

  List<Todo> get _filteredTodos {
    List<Todo> filtered = _todos;
    if (_filterIndex == 1) {
      filtered = filtered.where((t) => !t.isDone).toList();
    } else if (_filterIndex == 2) {
      filtered = filtered.where((t) => t.isDone).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return filtered;
  }

  void _addTodo(String title, Priority priority) {
    setState(() {
      _todos.add(Todo(title: title, priority: priority));
    });
  }

  void _editTodo(int index, String newTitle, Priority newPriority) {
    setState(() {
      _todos[index].title = newTitle;
      _todos[index].priority = newPriority;
    });
  }

  void _toggleTodoStatus(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  void _showAddOrEditTodoDialog({int? editIndex}) {
    String title = editIndex != null ? _todos[editIndex].title : '';
    Priority priority = editIndex != null
        ? _todos[editIndex].priority
        : Priority.low;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: Row(
                children: [
                  Icon(
                    editIndex == null ? Icons.add_circle_outline : Icons.edit,
                    color: Colors.cyanAccent[700],
                  ),
                  SizedBox(width: 8),
                  Text(
                    editIndex == null ? 'Add New Task' : 'Edit Task',
                    style: TextStyle(
                      color: Colors.cyanAccent[100],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    controller: TextEditingController(text: title),
                    onChanged: (value) => title = value,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter task title',
                      hintStyle: TextStyle(color: Colors.cyanAccent[100]),
                      prefixIcon: Icon(
                        Icons.title,
                        color: Colors.cyanAccent[700],
                      ),
                      filled: true,
                      fillColor: Colors.blueGrey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.flag, color: Colors.cyanAccent[700]),
                      SizedBox(width: 8),
                      Text(
                        'Priority:',
                        style: TextStyle(color: Colors.cyanAccent[100]),
                      ),
                      SizedBox(width: 8),
                      DropdownButton<Priority>(
                        value: priority,
                        dropdownColor: Colors.blueGrey[800],
                        style: TextStyle(color: Colors.cyanAccent[100]),
                        items: [
                          DropdownMenuItem(
                            value: Priority.low,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.low_priority,
                                  color: Colors.greenAccent,
                                ),
                                SizedBox(width: 6),
                                Text('Low'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: Priority.medium,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.priority_high,
                                  color: Colors.amberAccent,
                                ),
                                SizedBox(width: 6),
                                Text('Medium'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: Priority.high,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 6),
                                Text('High'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setStateDialog(() {
                            priority = val!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.cyanAccent[100]),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    editIndex == null ? Icons.save : Icons.edit,
                    color: Colors.white,
                  ),
                  label: Text(editIndex == null ? 'Add' : 'Update'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (title.trim().isNotEmpty) {
                      if (editIndex == null) {
                        _addTodo(title.trim(), priority);
                      } else {
                        _editTodo(editIndex, title.trim(), priority);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _priorityChip(Priority p) {
    switch (p) {
      case Priority.low:
        return Chip(
          avatar: Icon(Icons.low_priority, color: Colors.greenAccent, size: 18),
          label: Text('Low', style: TextStyle(color: Colors.greenAccent[700])),
          backgroundColor: Colors.greenAccent.withOpacity(0.1),
        );
      case Priority.medium:
        return Chip(
          avatar: Icon(Icons.priority_high, color: Colors.amber, size: 18),
          label: Text('Medium', style: TextStyle(color: Colors.amber[800])),
          backgroundColor: Colors.amber.withOpacity(0.1),
        );
      case Priority.high:
        return Chip(
          avatar: Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
            size: 18,
          ),
          label: Text('High', style: TextStyle(color: Colors.redAccent)),
          backgroundColor: Colors.redAccent.withOpacity(0.1),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey[900],
        title: Row(
          children: [
            Icon(Icons.terminal_rounded, color: Colors.cyanAccent, size: 32),
            SizedBox(width: 10),
            Text(
              'Tech To-Do',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_suggest_rounded,
              color: Colors.cyanAccent,
            ),
            onPressed: () {},
            tooltip: 'Settings',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(color: Colors.cyanAccent[100]),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: TextStyle(color: Colors.cyanAccent[100]),
                prefixIcon: Icon(Icons.search, color: Colors.cyanAccent[700]),
                filled: true,
                fillColor: Colors.blueGrey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(12),
              isSelected: [
                _filterIndex == 0,
                _filterIndex == 1,
                _filterIndex == 2,
              ],
              onPressed: (i) => setState(() => _filterIndex = i),
              color: Colors.blueGrey[700],
              selectedColor: Colors.cyanAccent[700],
              fillColor: Colors.cyanAccent.withOpacity(0.15),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.list_alt_rounded),
                      SizedBox(width: 4),
                      Text('All'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.pending_actions),
                      SizedBox(width: 4),
                      Text('Pending'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: 4),
                      Text('Done'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredTodos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 80,
                          color: Colors.blueGrey[300],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'No tasks found!',
                          style: TextStyle(
                            color: Colors.blueGrey[400],
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Try adding a new task or changing your filter.',
                          style: TextStyle(
                            color: Colors.blueGrey[300],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: _filteredTodos.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final todo = _filteredTodos[index];
                      final realIndex = _todos.indexOf(todo);
                      return Dismissible(
                        key: ValueKey(todo.title + realIndex.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.redAccent, Colors.red],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.delete_forever,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        onDismissed: (_) => _removeTodo(realIndex),
                        child: GestureDetector(
                          onLongPress: () =>
                              _showAddOrEditTodoDialog(editIndex: realIndex),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    todo.isDone
                                        ? Colors.blueGrey[100]!
                                        : Colors.cyanAccent.withOpacity(0.15)!,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: todo.isDone
                                      ? Colors.greenAccent[400]
                                      : Colors.blueGrey[700],
                                  child: Icon(
                                    todo.isDone
                                        ? Icons.verified_rounded
                                        : Icons.memory_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  todo.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: todo.isDone
                                        ? Colors.blueGrey[400]
                                        : Colors.blueGrey[900],
                                    decoration: todo.isDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    _priorityChip(todo.priority),
                                    SizedBox(width: 8),
                                    if (todo.isDone)
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.greenAccent,
                                        size: 18,
                                      )
                                    else
                                      Icon(
                                        Icons.pending,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        todo.isDone
                                            ? Icons.undo
                                            : Icons.check_circle_outline,
                                        color: todo.isDone
                                            ? Colors.amber
                                            : Colors.greenAccent[400],
                                        size: 28,
                                      ),
                                      onPressed: () =>
                                          _toggleTodoStatus(realIndex),
                                      tooltip: todo.isDone
                                          ? 'Mark as pending'
                                          : 'Mark as done',
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.cyanAccent[700],
                                      ),
                                      onPressed: () => _showAddOrEditTodoDialog(
                                        editIndex: realIndex,
                                      ),
                                      tooltip: 'Edit Task',
                                    ),
                                  ],
                                ),
                                onTap: () => _toggleTodoStatus(realIndex),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.cyanAccent[700],
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Task',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddOrEditTodoDialog(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.cyanAccent[700],
        unselectedItemColor: Colors.blueGrey[300],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_suggest_rounded),
            label: 'Settings',
          ),
        ],
        currentIndex: 0,
        onTap: (i) {},
      ),
    );
  }
}
