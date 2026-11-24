class Question {
  final String topic;
  final int level;
  final String text;
  final List<String> options;
  final int answer;
  final String explanation;
  const Question(this.topic, this.level, this.text, this.options, this.answer, this.explanation);
}

const topics = {
  'Operaciones': 'Matemáticas',
  'Fracciones': 'Matemáticas',
  'Álgebra': 'Matemáticas',
  'Ortografía': 'Lenguaje',
  'Ecosistemas': 'Ciencias',
  'Materia': 'Ciencias',
};

const bank = <Question>[
  Question('Operaciones', 1, '¿Cuánto es 48 + 27?', ['65', '75', '73', '76'], 1, '48 + 27 = 75.'),
  Question('Operaciones', 2, '¿Cuánto es 12 × 15?', ['160', '190', '180', '170'], 2, '12 × 15 = 180.'),
  Question('Operaciones', 3, 'Un bus lleva 45 pasajeros. Bajan 18 y suben 26. ¿Cuántos van ahora?', ['53', '63', '71', '89'], 0, '45 − 18 = 27, y 27 + 26 = 53.'),
  Question('Fracciones', 1, '¿Cuál fracción es la mayor?', ['1/4', '1/2', '1/8', '1/3'], 1, 'Con el mismo numerador, gana la de menor denominador: 1/2.'),
  Question('Fracciones', 2, '¿Cuánto es 1/2 + 1/4?', ['2/6', '2/4', '3/4', '1/6'], 2, '1/2 = 2/4, y 2/4 + 1/4 = 3/4.'),
  Question('Fracciones', 3, '¿Cuánto es 3/4 de 20?', ['12', '15', '16', '5'], 1, '20 ÷ 4 = 5, y 5 × 3 = 15.'),
  Question('Álgebra', 1, 'Si x + 5 = 12, ¿cuánto vale x?', ['5', '17', '7', '8'], 2, 'x = 12 − 5 = 7.'),
  Question('Álgebra', 2, 'Si 3x = 21, ¿cuánto vale x?', ['18', '7', '63', '24'], 1, 'x = 21 ÷ 3 = 7.'),
  Question('Álgebra', 3, 'Si 2x + 4 = 18, ¿cuánto vale x?', ['11', '9', '7', '22'], 2, '2x = 14, entonces x = 7.'),
  Question('Ortografía', 1, '¿Cuál palabra está bien escrita?', ['vistido', 'vestido', 'bestido', 'bestído'], 1, 'Se escribe vestido, con v y e.'),
  Question('Ortografía', 2, '¿Cuál palabra está bien escrita?', ['cancíon', 'canción', 'cáncion', 'cancion'], 1, 'Es aguda terminada en n, por eso lleva tilde en la o.'),
  Question('Ortografía', 3, '¿Cuál oración está bien escrita?', ['¿Porque no viniste?', '¿Por qué no viniste?', '¿Porqué no viniste?', '¿Por que no viniste?'], 1, 'En preguntas directas se usa “por qué”, separado y con tilde.'),
  Question('Ecosistemas', 1, 'En una cadena alimentaria, ¿quién es el productor?', ['El león', 'La planta', 'El zorro', 'El hongo'], 1, 'Las plantas producen su propio alimento.'),
  Question('Ecosistemas', 2, '¿Qué necesitan las plantas para la fotosíntesis?', ['Solo tierra', 'Luz solar, agua y dióxido de carbono', 'Solo oxígeno', 'Calor y sal'], 1, 'Con luz, agua y CO₂ producen glucosa y oxígeno.'),
  Question('Ecosistemas', 3, 'Si desaparecen los depredadores de un ecosistema, ¿qué puede pasar?', ['Las presas se multiplican en exceso', 'Nada cambia', 'Aumenta el agua', 'Todas las plantas crecen más'], 0, 'Sin depredadores, las presas crecen sin control y agotan sus recursos.'),
  Question('Materia', 1, '¿Cuál es un estado de la materia?', ['Sólido', 'Calor', 'Luz', 'Sonido'], 0, 'Los estados son sólido, líquido y gaseoso.'),
  Question('Materia', 2, 'El agua pasa de líquido a gas por:', ['Condensación', 'Evaporación', 'Solidificación', 'Fusión'], 1, 'La evaporación es el paso de líquido a gas.'),
  Question('Materia', 3, 'El agua con sal disuelta es:', ['Un elemento', 'Una mezcla heterogénea', 'Una mezcla homogénea', 'Un compuesto puro'], 2, 'Se ve uniforme en toda la muestra, así que es homogénea.'),
];

class Attempt {
  final int q;
  final bool ok;
  Attempt(this.q, this.ok);
}

class Student {
  final String name;
  String grade;
  final Map<String, double> mastery;
  final List<Attempt> log;
  Student(this.name, this.grade, this.mastery, this.log);

  int get total => log.length;
  double get accuracy => total == 0 ? 0 : log.where((a) => a.ok).length / total;
  int attemptsIn(String t) => log.where((a) => bank[a.q].topic == t).length;

  Map<String, dynamic> toJson() => {
        'n': name,
        'g': grade,
        'm': mastery,
        'l': log.map((a) => [a.q, a.ok ? 1 : 0]).toList(),
      };

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        j['n'] as String,
        j['g'] as String,
        (j['m'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())),
        (j['l'] as List).map((e) => Attempt(e[0] as int, e[1] == 1)).toList(),
      );
}
