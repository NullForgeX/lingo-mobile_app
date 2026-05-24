import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/practice_bloc.dart';

class PracticeScreen extends StatefulWidget {
  final String lessonId;

  const PracticeScreen({super.key, required this.lessonId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    context.read<PracticeBloc>().add(GetRuntimeEvent(widget.lessonId));
  }

  void _handleAnswer(String attemptId, List<dynamic> exercises, String exerciseId, String type, dynamic answerData) {
    Map<String, dynamic> answer = {
      'type': type,
      'exerciseId': exerciseId,
    };
    if (type == 'multiple_choice' || type == 'listening') {
      answer['selectedOptionIds'] = [answerData];
    } else {
      answer['response'] = answerData;
    }
    
    _answers.add(answer);

    if (_currentIndex < exercises.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      context.read<PracticeBloc>().add(SubmitAttemptEvent(attemptId, _answers));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: BlocConsumer<PracticeBloc, PracticeState>(
        listener: (context, state) {
          if (state is PracticeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PracticeLoading || state is PracticeInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RuntimeLoaded) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.school, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Ready to start your practice?',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      final exercises = state.runtime['exercises'] ?? [];
                      if (exercises.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No exercises found in this lesson.')),
                        );
                        return;
                      }
                      context.read<PracticeBloc>().add(StartAttemptEvent(widget.lessonId, exercises));
                    },
                    child: const Text('Start Practice'),
                  ),
                ],
              ),
            );
          } else if (state is AttemptStarted) {
            final exercises = state.exercises;
            if (_currentIndex >= exercises.length) {
              return const Center(child: CircularProgressIndicator());
            }
            
            final exercise = exercises[_currentIndex];
            final options = exercise['options'] as List<dynamic>? ?? [];
            final type = exercise['type'] as String;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${exercises.length}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    exercise['prompt']?['text'] ?? 'Listen and answer',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  ...options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: OutlinedButton(
                        onPressed: () => _handleAnswer(state.attemptId, exercises, exercise['id'], type, option['id']),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(option['label'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                      ),
                    );
                  }),
                ],
              ),
            );
          } else if (state is AttemptSubmitted) {
            final score = state.result['scoreSummary']?['score'] ?? 0;
            final maxScore = state.result['scoreSummary']?['maxScore'] ?? 0;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Practice Completed!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your score: $score / $maxScore',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Back to Home'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Unknown State'));
          }
        },
      ),
    );
  }
}
