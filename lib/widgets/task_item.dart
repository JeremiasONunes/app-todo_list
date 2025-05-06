import 'package:flutter/material.dart';
import '../model/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onCompletionChanged;

  const TaskItem({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onCompletionChanged, // Adicionando a função de callback para a conclusão
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: task.completed, // Marca a tarefa como concluída ou não
          onChanged: onCompletionChanged, // Callback para atualizar o status
          activeColor: Colors.blue, // Cor azul quando marcado
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration:
                task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none, // Risca o texto se estiver concluído
            color:
                task.completed
                    ? Colors.grey
                    : Colors
                        .black, // Altera a cor do texto para cinza se concluído
          ),
        ),
        subtitle: Text(task.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                // Confirmação de exclusão
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: const Text('Deseja excluir esta tarefa?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDelete();
                            },
                            child: const Text('Excluir'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
