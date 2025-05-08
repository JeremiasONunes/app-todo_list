import 'package:flutter/material.dart';
import '../model/task.dart';
import '../services/task_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _quantityController = TextEditingController();

  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _valueController.text = widget.task!.value.toString();
      _quantityController.text = widget.task!.quantity.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final value = double.tryParse(_valueController.text.trim()) ?? 0.0;
      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

      if (widget.task == null) {
        final newTask = Task(
          title: title,
          description: description,
          value: value,
          quantity: quantity,
        );
        await _taskService.addTask(newTask);
      } else {
        final updatedTask = Task(
          id: widget.task!.id,
          title: title,
          description: description,
          value: value,
          quantity: quantity,
        );
        await _taskService.updateTask(updatedTask);
      }

      Navigator.pop(context, true);
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 13, 13),
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditing ? Icons.edit_note_outlined : Icons.add_box_outlined,
              color: Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              isEditing ? 'Editar Produto' : 'Novo Produto',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Marca do Produto'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Marca'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe a marca do produto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _valueController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Preço (opcional)'),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Quantidade'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe uma quantidade';
                        }
                        if (int.tryParse(value.trim()) == null) {
                          return 'Quantidade inválida';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  isEditing
                      ? Icons.check_circle_outline
                      : Icons.add_circle_outline,
                ),
                label: Text(
                  isEditing ? 'Atualizar' : 'Adicionar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
