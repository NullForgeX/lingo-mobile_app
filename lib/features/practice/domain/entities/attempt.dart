class QuizAttempt {
  final String id;
  final String status;
  final int attemptNumber;
  
  QuizAttempt({required this.id, required this.status, required this.attemptNumber});

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      attemptNumber: json['attemptNumber'] ?? 1,
    );
  }
}
