import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Estado global: estudiantes, motor adaptativo y persistencia local.
class AppState extends ChangeNotifier {
  Map<String, Student> students = {};
  Student? current;
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString('data');
    if (raw != null) {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      students = m.map((k, v) => MapEntry(k, Student.fromJson(v as Map<String, dynamic>)));
    }
  }

  void _save() => _prefs?.setString('data', jsonEncode(students.map((k, v) => MapEntry(k, v.toJson()))));

  void login(String name, String grade) {
    current = students.putIfAbsent(name, () => Student(name, grade, {}, []));
    current!.grade = grade;
    _save();
    notifyListeners();
  }

  void logout() {
    current = null;
    notifyListeners();
  }

  /// Nivel de dificultad según el dominio: <0.4 básico, <0.7 intermedio, resto avanzado.
  int levelFor(double m) => m < .4 ? 1 : (m < .7 ? 2 : 3);

  /// Elige el tema más débil (evitando repetirlo) y la pregunta menos vista de la dificultad adecuada.
  int pick(String? last) {
    final st = current!;
    final rnd = Random();
    final score = {for (final t in topics.keys) t: (st.mastery[t] ?? .5) + rnd.nextDouble() * .15};
    final order = topics.keys.toList()..sort((a, b) => score[a]!.compareTo(score[b]!));
    var t = order.first;
    if (t == last) t = order[1];
    final lv = levelFor(st.mastery[t] ?? .5);
    var best = 0;
    double bs = 1e9;
    for (var i = 0; i < bank.length; i++) {
      if (bank[i].topic != t) continue;
      final double sc = st.log.where((a) => a.q == i).length * 2 + (bank[i].level - lv).abs() + rnd.nextDouble() * .1;
      if (sc < bs) {
        bs = sc;
        best = i;
      }
    }
    return best;
  }

  /// Actualiza el dominio con promedio ponderado (pesa más lo reciente).
  void record(int q, bool ok) {
    final st = current!;
    final t = bank[q].topic;
    st.mastery[t] = (st.mastery[t] ?? .5) * .65 + (ok ? .35 : 0);
    st.log.add(Attempt(q, ok));
    _save();
    notifyListeners();
  }

  void loadDemo() {
    final demo = [
      ('Valentina R. (demo)', 'Básica', {'Operaciones': .85, 'Fracciones': .7, 'Álgebra': .3, 'Ortografía': .8, 'Ecosistemas': .75, 'Materia': .6}),
      ('Samuel G. (demo)', 'Media', {'Operaciones': .9, 'Fracciones': .8, 'Álgebra': .75, 'Ortografía': .35, 'Ecosistemas': .6, 'Materia': .7}),
      ('Laura M. (demo)', 'Básica', {'Operaciones': .5, 'Fracciones': .3, 'Álgebra': .4, 'Ortografía': .7, 'Ecosistemas': .9, 'Materia': .8}),
    ];
    for (final (n, g, p) in demo) {
      final log = <Attempt>[];
      p.forEach((t, v) {
        final qi = bank.indexWhere((q) => q.topic == t);
        for (var k = 0; k < 6; k++) {
          log.add(Attempt(qi, k / 6 < v));
        }
      });
      students[n] = Student(n, g, Map.of(p), log);
    }
    _save();
    notifyListeners();
  }

  void wipe() {
    students = {};
    current = null;
    _save();
    notifyListeners();
  }
}
