import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';

Color _tone(double? v) => v == null ? Colors.grey : (v < .4 ? const Color(0xFFB3392F) : (v < .7 ? const Color(0xFFE0A100) : const Color(0xFF1D7A46)));

class MasteryBar extends StatelessWidget {
  final double? value;
  const MasteryBar(this.value, {super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(value: value ?? 0, minHeight: 9, color: _tone(value), backgroundColor: Colors.black12),
      );
}

Widget _masteryRows(Student st) => Column(children: [
      for (final t in topics.keys)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            SizedBox(width: 104, child: Text(t, style: const TextStyle(fontSize: 13))),
            Expanded(child: MasteryBar(st.mastery[t])),
          ]),
        ),
    ]);

class HomeScreen extends StatefulWidget {
  final AppState state;
  final VoidCallback onPractice;
  const HomeScreen(this.state, {required this.onPractice, super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _name = TextEditingController();
  String _grade = 'Básica';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cur = widget.state.current;
    return ListView(padding: EdgeInsets.zero, children: [
      Container(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0E7C86), Color(0xFF0A4F66)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('EduRural IA', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
          SizedBox(height: 6),
          Text('Aprendizaje personalizado para instituciones rurales del Valle del Cauca', style: TextStyle(color: Colors.white70, fontSize: 15)),
          SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 4, children: [
            Chip(avatar: Icon(Icons.wifi_off, size: 18), label: Text('Funciona sin internet')),
            Chip(avatar: Icon(Icons.auto_graph, size: 18), label: Text('Se adapta a cada estudiante')),
          ]),
        ]),
      ),
      Padding(padding: const EdgeInsets.all(16), child: cur == null ? _login() : _dashboard(cur)),
    ]);
  }

  Widget _login() => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Empieza tu práctica', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre y apellido', border: OutlineInputBorder())),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [ButtonSegment(value: 'Básica', label: Text('Básica')), ButtonSegment(value: 'Media', label: Text('Media'))],
              selected: {_grade},
              onSelectionChanged: (v) => setState(() => _grade = v.first),
            ),
            const SizedBox(height: 14),
            const Text('Tu progreso se guarda en este dispositivo, sin necesidad de internet.'),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                final n = _name.text.trim();
                if (n.isNotEmpty) widget.state.login(n, _grade);
              },
              child: const Text('Comenzar'),
            ),
          ]),
        ),
      );

  Widget _dashboard(Student cur) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hola, ${cur.name}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            Text('${cur.total} respuestas, ${(cur.accuracy * 100).round()}% de aciertos'),
            const SizedBox(height: 14),
            const Text('Tu dominio por tema', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            _masteryRows(cur),
            const SizedBox(height: 14),
            FilledButton.icon(onPressed: widget.onPractice, icon: const Icon(Icons.play_arrow), label: const Text('Practicar ahora')),
            TextButton(onPressed: widget.state.logout, child: const Text('Cambiar de estudiante')),
          ]),
        ),
      );
}

class QuizScreen extends StatefulWidget {
  final AppState state;
  const QuizScreen(this.state, {super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int i = 0, ok = 0, q = -1;
  int? chosen;
  String? last;
  bool done = false;
  AppState get s => widget.state;

  void _choose(int k) {
    if (chosen != null) return;
    final correct = k == bank[q].answer;
    setState(() {
      chosen = k;
      if (correct) ok++;
    });
    s.record(q, correct);
  }

  void _next() => setState(() {
        i++;
        if (i >= 6) {
          done = true;
        } else {
          last = bank[q].topic;
          q = s.pick(last);
          chosen = null;
        }
      });

  void _restart() => setState(() {
        i = 0;
        ok = 0;
        done = false;
        chosen = null;
        last = null;
        q = s.pick(null);
      });

  @override
  Widget build(BuildContext context) {
    final cur = s.current;
    if (cur == null) {
      return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Primero ingresa tu nombre en Inicio.', textAlign: TextAlign.center)));
    }
    if (q < 0) q = s.pick(last);
    if (done) return _summary(cur);
    final item = bank[q];
    final level = ['Básico', 'Intermedio', 'Avanzado'][item.level - 1];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 48, 16, 16), children: [
      Text('Pregunta ${i + 1} de 6', style: const TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      LinearProgressIndicator(value: (i + (chosen == null ? 0 : 1)) / 6, minHeight: 8, borderRadius: BorderRadius.circular(8)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, children: [Chip(label: Text(item.topic)), Chip(label: Text('Nivel $level'))]),
      const SizedBox(height: 8),
      Text(item.text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 14),
      for (var k = 0; k < item.options.length; k++) _option(item, k),
      if (chosen != null) ...[
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: chosen == item.answer ? const Color(0xFFE1F3E8) : const Color(0xFFFBE7E4), borderRadius: BorderRadius.circular(12)),
          child: Text('${chosen == item.answer ? '¡Correcto!' : 'Casi.'} ${item.explanation}'),
        ),
        const SizedBox(height: 12),
        FilledButton(onPressed: _next, child: Text(i >= 5 ? 'Ver resultados' : 'Siguiente pregunta')),
      ],
    ]);
  }

  Widget _option(Question item, int k) {
    Color bg = Colors.white, border = const Color(0xFFCFDDE0);
    if (chosen != null && k == item.answer) {
      bg = const Color(0xFFE1F3E8);
      border = const Color(0xFF1D7A46);
    } else if (chosen == k) {
      bg = const Color(0xFFFBE7E4);
      border = const Color(0xFFB3392F);
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 2), borderRadius: BorderRadius.circular(14)),
      child: Material(type: MaterialType.transparency, child: ListTile(onTap: () => _choose(k), title: Text(item.options[k]))),
    );
  }

  Widget _summary(Student cur) {
    final weakest = topics.keys.reduce((a, b) => (cur.mastery[a] ?? .5) <= (cur.mastery[b] ?? .5) ? a : b);
    return ListView(padding: const EdgeInsets.fromLTRB(16, 48, 16, 16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Acertaste $ok de 6', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _masteryRows(cur),
            const SizedBox(height: 12),
            Text('Recomendación: refuerza $weakest. En la próxima sesión recibirás más preguntas de ese tema.'),
            const SizedBox(height: 14),
            FilledButton(onPressed: _restart, child: const Text('Nueva sesión')),
          ]),
        ),
      ),
    ]);
  }
}

class TeacherScreen extends StatelessWidget {
  final AppState state;
  const TeacherScreen(this.state, {super.key});

  @override
  Widget build(BuildContext context) {
    final list = state.students.values.toList();
    final alerts = <String>[];
    for (final st in list) {
      for (final t in topics.keys) {
        if (st.attemptsIn(t) >= 2 && (st.mastery[t] ?? .5) < .45) alerts.add('${st.name} tiene bajo dominio en $t. Conviene un refuerzo guiado.');
      }
    }
    final answers = list.fold<int>(0, (a, st) => a + st.total);
    final avg = list.isEmpty ? 0 : list.map((st) => st.accuracy).reduce((a, b) => a + b) / list.length;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 48, 16, 16), children: [
      const Text('Panel del docente', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Row(children: [
        _stat('Estudiantes', '${list.length}'),
        _stat('Respuestas', '$answers'),
        _stat('Aciertos', '${(avg * 100).round()}%'),
      ]),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Dificultades detectadas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (alerts.isEmpty) const Text('No hay alertas por ahora.'),
            for (final a in alerts) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(a)),
          ]),
        ),
      ),
      for (final st in list)
        Card(
          child: ExpansionTile(
            title: Text(st.name),
            subtitle: Text('${st.grade}, ${st.total} respuestas, ${(st.accuracy * 100).round()}% de aciertos'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            children: [_masteryRows(st)],
          ),
        ),
      Wrap(spacing: 8, children: [
        OutlinedButton(onPressed: state.loadDemo, child: const Text('Cargar datos de demostración')),
        OutlinedButton(onPressed: state.wipe, child: const Text('Borrar todos los datos')),
      ]),
    ]);
  }

  Widget _stat(String label, String value) => Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ]),
          ),
        ),
      );
}
