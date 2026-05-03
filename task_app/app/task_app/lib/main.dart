import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';
import 'screens/task_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Tarefas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/tasks',
      routes: {
        '/tasks': (_) => const TaskListScreen(),
        '/task-form': (_) => const TaskFormScreen(),
      },
    );
  }
}
