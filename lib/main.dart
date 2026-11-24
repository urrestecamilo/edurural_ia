import 'package:flutter/material.dart';
import 'screens.dart';
import 'state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.init();
  runApp(EduApp(state));
}

class EduApp extends StatelessWidget {
  final AppState state;
  const EduApp(this.state, {super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'EduRural IA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7C86)).copyWith(tertiary: const Color(0xFFF2B705)),
          scaffoldBackgroundColor: const Color(0xFFEEF4F5),
        ),
        home: Shell(state),
      );
}

class Shell extends StatefulWidget {
  final AppState state;
  const Shell(this.state, {super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return Scaffold(
      body: ListenableBuilder(
        listenable: s,
        builder: (context, _) => [
          HomeScreen(s, onPractice: () => setState(() => index = 1)),
          QuizScreen(s),
          TeacherScreen(s),
        ][index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note), label: 'Practicar'),
          NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: 'Docente'),
        ],
      ),
    );
  }
}
