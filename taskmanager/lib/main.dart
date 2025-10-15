import 'package:flutter/material.dart';
import 'dart:io'; // <-- 1. NOVO IMPORT PARA VERIFICAR A PLATAFORMA
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // <-- 2. NOVO IMPORT DO ADAPTADOR FFI
import 'screens/task_list_screen.dart';

Future<void> main() async { // <-- 3. TRANSFORME O main() EM ASYNC

  // 4. GARANTE QUE OS WIDGETS DO FLUTTER ESTÃO PRONTOS
  WidgetsFlutterBinding.ensureInitialized();

  // 5. ADICIONE ESTE BLOCO DE INICIALIZAÇÃO PARA DESKTOP
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializa o 'adaptador' FFI
    sqfliteFfiInit();
    // Define o sqflite para usar esse 'adaptador'
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(),
      debugShowCheckedModeBanner: false, // Opcional: remove o banner "Debug"
    );
  }
}