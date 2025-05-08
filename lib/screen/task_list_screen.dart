import 'package:flutter/material.dart';
import '../model/task.dart';
import '../services/task_service.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  final List<Task> initialTasks;

  const TaskListScreen({super.key, required this.initialTasks});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  late List<Task> _tasks;
  double _totalValue = 0.0;

  @override
  void initState() {
    super.initState();
    _tasks = widget.initialTasks;
    _updateTotalValue();
  }

  void _updateTotalValue() {
    _totalValue = _tasks.fold(
      0.0,
      (sum, task) => sum + (task.value * task.quantity),
    );
  }

  Future<void> _navigateToForm({Task? task}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
    );

    if (result == true) {
      final tasks = await _taskService.getTasks();
      setState(() {
        _tasks = tasks;
        _updateTotalValue();
      });
    }
  }

  Future<void> _deleteTask(int id) async {
    await _taskService.deleteTask(id);
    final tasks = await _taskService.getTasks();
    setState(() {
      _tasks = tasks;
      _updateTotalValue();
    });
  }

  Future<void> _toggleCompleted(Task task) async {
    await _taskService.updateTaskCompletion(task.id!, !task.completed);
    final tasks = await _taskService.getTasks();
    setState(() {
      _tasks = tasks;
      _updateTotalValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minhas Lista de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.blue[900],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: Text(
                'Total: R\$ ${_totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _tasks.isEmpty
                    ? const Center(
                      child: Text(
                        'Não existem tarefas no momento',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          color: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () => _toggleCompleted(task),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        task.completed
                                            ? Colors.blue
                                            : Colors.white,
                                    width: 2,
                                  ),
                                  color:
                                      task.completed
                                          ? Colors.blue
                                          : Colors.transparent,
                                ),
                                child:
                                    task.completed
                                        ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.black,
                                        )
                                        : null,
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                color:
                                    task.completed ? Colors.blue : Colors.white,
                                fontWeight:
                                    task.completed
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: task.completed ? 16 : 20,
                              ),
                            ),
                            subtitle: Text(
                              '${task.description}\nPreço: R\$ ${task.value.toStringAsFixed(2)}  •  Quantidade: ${task.quantity}',
                              style: TextStyle(
                                color: Colors.white,
                                decoration:
                                    task.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () => _deleteTask(task.id!),
                            ),
                            onTap: () => _navigateToForm(task: task),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}
