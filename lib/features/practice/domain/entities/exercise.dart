class Exercise {
  final String id;
  final String type;
  final String promptText;
  final List<ExerciseOption> options;

  Exercise({
    required this.id,
    required this.type,
    required this.promptText,
    required this.options,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      promptText: json['prompt']?['text'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => ExerciseOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ExerciseOption {
  final String id;
  final String label;

  ExerciseOption({required this.id, required this.label});

  factory ExerciseOption.fromJson(Map<String, dynamic> json) {
    return ExerciseOption(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
    );
  }
}
