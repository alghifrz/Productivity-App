import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(const ProductivityApp());
}

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productivity List App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];
  Color _backgroundColor = Colors.transparent;
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _taskController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _addTask() {
    String task = _taskController.text.trim();
    if (task.isNotEmpty && !_tasks.any((element) => element['title'] == task)) {
      setState(() {
        _tasks.add({
          'title': task, 
          'completed': false,
          'priority': 'Medium',
          'created': DateTime.now(),
        });
        _taskController.clear();
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['completed'] = !_tasks[index]['completed'];
    });
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _tasks.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted successfully'),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _changePriority(int index) {
    final priorities = ['Low', 'Medium', 'High'];
    final currentPriority = _tasks[index]['priority'];
    final currentIndex = priorities.indexOf(currentPriority);
    final nextIndex = (currentIndex + 1) % priorities.length;
    
    setState(() {
      _tasks[index]['priority'] = priorities[nextIndex];
    });
  }

  double _calculateCompletion() {
    if (_tasks.isEmpty) return 0;
    int completedTasks = _tasks.where((task) => task['completed']).length;
    return completedTasks / _tasks.length;
  }

  void _changeBackgroundColor(Color color) {
    setState(() {
      _backgroundColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _tasks.where((task) => task['completed']).toList();
    final pendingTasks = _tasks.where((task) => !task['completed']).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: FadeIn(
          child: const Text(
            'PRODUCTIVITY LIST APP',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.palette_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildColorPicker(),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.pending_actions),
              text: 'Pending (${pendingTasks.length})',
            ),
            Tab(
              icon: const Icon(Icons.task_alt),
              text: 'Completed (${completedTasks.length})',
            ),
          ],
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              image: const DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _taskController,
                            decoration: InputDecoration(
                              labelText: 'Enter a new task',
                              hintText: 'What needs to be done?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.task_alt_outlined),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: _addTask,
                              ),
                            ),
                            onSubmitted: (_) => _addTask(),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _addTask,
                            icon: const Icon(Icons.add_task),
                            label: const Text('Add Task'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Progress indicator
                  if (_tasks.isNotEmpty)
                    FadeIn(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.insights, color: Colors.indigo),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Progress: ${(_calculateCompletion() * 100).toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearPercentIndicator(
                                lineHeight: 14,
                                percent: _calculateCompletion(),
                                backgroundColor: Colors.grey[200],
                                progressColor: Colors.indigo,
                                barRadius: const Radius.circular(7),
                                animation: true,
                                animationDuration: 1000,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Task lists
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Pending Tasks
                        pendingTasks.isEmpty
                            ? _emptyTasksPlaceholder('No pending tasks')
                            : _buildTasksList(pendingTasks),
                            
                        // Completed Tasks
                        completedTasks.isEmpty
                            ? _emptyTasksPlaceholder('No completed tasks')
                            : _buildTasksList(completedTasks),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => _buildAddTaskSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTasksList(List<Map<String, dynamic>> tasksList) {
    return ListView.builder(
      itemCount: tasksList.length,
      itemBuilder: (context, originalIndex) {
        final index = _tasks.indexOf(tasksList[originalIndex]);
        final task = _tasks[index];
        
        return FadeInUp(
          from: 20,
          delay: Duration(milliseconds: originalIndex * 100),
          duration: const Duration(milliseconds: 500),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Slidable(
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => _changePriority(index),
                    backgroundColor: _getPriorityColor(task['priority']),
                    foregroundColor: Colors.white,
                    icon: Icons.flag,
                    label: task['priority'],
                  ),
                  SlidableAction(
                    onPressed: (_) => _deleteTask(index),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              ),
              child: Card(
                color: task['completed'] 
                    ? Colors.grey[100] 
                    : Colors.white,
                child: ListTile(
                  leading: InkWell(
                    onTap: () => _toggleTask(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task['completed'] ? Colors.green : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        task['completed'] 
                            ? Icons.check_circle 
                            : Icons.circle_outlined,
                        color: task['completed'] ? Colors.green : Colors.grey,
                        size: 22,
                      ),
                    ),
                  ),
                  title: Text(
                    task['title'],
                    style: TextStyle(
                      decoration: task['completed'] 
                          ? TextDecoration.lineThrough 
                          : null,
                      fontWeight: FontWeight.w500,
                      color: task['completed'] ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 14,
                        color: _getPriorityColor(task['priority']),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task['priority'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _getPriorityColor(task['priority']),
                        ),
                      ),
                    ],
                  ),
                  trailing: Checkbox(
                    value: task['completed'],
                    onChanged: (_) => _toggleTask(index),
                    activeColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onTap: () => _toggleTask(index),
                  onLongPress: () => _deleteTask(index),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyTasksPlaceholder(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.task_outlined, 
            size: 80, 
            color: Colors.grey
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _tabController.animateTo(0);
              _taskController.text = '';
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => _buildAddTaskSheet(),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    final colors = [
      Colors.transparent,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.pink.shade50,
      Colors.yellow.shade50,
      Colors.purple.shade50,
      Colors.orange.shade50,
      Colors.teal.shade50,
    ];
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Background Color',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: colors.map((color) => _colorBox(color)).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorBox(Color color) {
    final isSelected = _backgroundColor == color;
    
    return GestureDetector(
      onTap: () => _changeBackgroundColor(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.black12,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: isSelected
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.indigo,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAddTaskSheet() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Task',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _taskController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Task Name',
              hintText: 'What needs to be done?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.task_alt_outlined),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _addTask();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add Task',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}