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

  Widget _buildSwipeBackground({required bool isStart}) {
    return Container(
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isStart ? Icons.edit_outlined : Icons.delete_outline,
        color: Colors.white70,
        size: 26,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 13, 13),
        elevation: 1,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.shopping_cart_outlined, color: Colors.white70),
            SizedBox(width: 8),
            Text(
              'Minha Lista de Compras',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total estimado:',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                Text(
                  'R\$ ${_totalValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _tasks.isEmpty
                    ? const Center(
                      child: Text(
                        'Não existem tarefas no momento',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Dismissible(
                          key: Key(task.id.toString()),
                          background: _buildSwipeBackground(isStart: true),
                          secondaryBackground: _buildSwipeBackground(
                            isStart: false,
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await _navigateToForm(task: task);
                              return false;
                            } else if (direction ==
                                DismissDirection.endToStart) {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      backgroundColor: const Color(0xFF1E1E1E),
                                      title: const Text(
                                        'Confirmar exclusão',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: const Text(
                                        'Deseja realmente excluir este item?',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () =>
                                                  Navigator.of(ctx).pop(false),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(ctx).pop(true),
                                          child: const Text('Excluir'),
                                        ),
                                      ],
                                    ),
                              );
                              return confirm ?? false;
                            }
                            return false;
                          },
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              _deleteTask(task.id!);
                            }
                          },
                          child: Card(
                            color: const Color(0xFF1A1A1A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: GestureDetector(
                                onTap: () => _toggleCompleted(task),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          task.completed
                                              ? Colors.greenAccent
                                              : Colors.white54,
                                      width: 2,
                                    ),
                                    color:
                                        task.completed
                                            ? Colors.greenAccent
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
                                      task.completed
                                          ? Colors.greenAccent
                                          : Colors.white,
                                  fontWeight:
                                      task.completed
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Text(
                                '${task.description}\nR\$ ${task.value.toStringAsFixed(2)}  •  Quantidade: ${task.quantity}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.4,
                                  decoration:
                                      task.completed
                                          ? TextDecoration.lineThrough
                                          : null,
                                ),
                              ),
                              isThreeLine: true,
                              trailing: const Icon(
                                Icons.drag_handle,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[600],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _navigateToForm(),
      ),
    );
  }
}
