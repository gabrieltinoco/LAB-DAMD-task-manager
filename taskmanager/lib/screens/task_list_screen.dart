import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  final _titleController = TextEditingController();
  String _selectedPriority = 'medium';
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseService.instance.readAll(status: _currentFilter);
    setState(() => _tasks = tasks);
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      title: _titleController.text.trim(),
      priority: _selectedPriority,
    );
    await DatabaseService.instance.create(task);
    _titleController.clear();
    _loadTasks();
  }

  Future<void> _toggleTask(Task task) async {
    final updated = task.copyWith(completed: !task.completed);
    await DatabaseService.instance.update(updated);
    _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await DatabaseService.instance.delete(id);
    _loadTasks();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    
    appBar: AppBar(
      title: const Text('Minhas Tarefas'),
    ),
    body: Column(
      children: [
        // INÍCIO - Bloco do formulário de adição
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Nova tarefa...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPriority,
                      decoration: const InputDecoration(
                        labelText: 'Prioridade',
                        border: OutlineInputBorder(),
                      ),
                      items: ['low', 'medium', 'high']
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority.replaceFirst(
                                    priority[0], priority[0].toUpperCase())),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _addTask,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // FIM - Bloco do formulário de adição

        // INÍCIO - Bloco dos botões de filtro 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment(value: 'all', label: Text('Todas')),
              ButtonSegment(value: 'pending', label: Text('Pendentes')),
              ButtonSegment(value: 'completed', label: Text('Completas')),
            ],
            selected: <String>{_currentFilter},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _currentFilter = newSelection.first;
                _loadTasks(); // Recarrega as tarefas com o novo filtro
              });
            },
          ),
        ),
        // FIM - Bloco dos botões de filtro

        // INÍCIO - Bloco da lista de tarefas 
        Expanded(
          child: ListView.builder(
            itemCount: _tasks.length,
            itemBuilder: (context, index) {
              final task = _tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (_) => _toggleTask(task),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTask(task.id),
                ),
              );
            },
          ),
        ),
        // FIM - Bloco da lista de tarefas
      ],
    ),
  );
}
}
