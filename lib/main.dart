import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:task_list/data.dart';

const taskBoxName = 'task';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<Task>(taskBoxName);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
    return Scaffold(
      appBar: AppBar(title: const Text('To Do List')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => EditTaskScreen()));
        },
        label: const Text('Add New Task'),
      ),
      body: ValueListenableBuilder<Box<Task>>(
          valueListenable: box.listenable(),
          builder: (context, box, child) {
            return ListView.builder(
                itemCount: box.values.length,
                itemBuilder: (context, index) {
                  final Task task = box.values.toList()[index];
                  return Container(
                    child: Text(
                      task.name,
                      style: const TextStyle(fontSize: 24),
                    ),
                  );
                });
          }),
    );
  }
}

class EditTaskScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  EditTaskScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final task = Task();
          task.name = _controller.text;
          if (task.isInBox) {
            task.save();
          } else {
            final Box<Task> box = Hive.box(taskBoxName);
            box.add(task);
          }
          Navigator.of(context).pop();
        },
        label: const Text('Save Changes'),
      ),
      body: Column(children: [
        TextField(
          controller: _controller,
          decoration:
              const InputDecoration(label: Text('Add a task for todsy...')),
        ),
      ]),
    );
  }
}
