import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/practice_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class PracticeScreen extends StatefulWidget {
  final String lessonId;

  const PracticeScreen({super.key, required this.lessonId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _answers = [];
  
  // Selection and response inputs
  String? _selectedOptionId;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  // Cached list of exercises from runtime
  List<dynamic>? _exercises;

  @override
  void initState() {
    super.initState();
    context.read<PracticeBloc>().add(GetRuntimeEvent(widget.lessonId));
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _submitCurrentAnswer(String attemptId, List<dynamic> exercises, String exerciseId, String type) {
    dynamic answerData;
    if (type == 'multiple_choice' || type == 'listening') {
      answerData = _selectedOptionId;
    } else {
      answerData = _textController.text.trim();
    }

    _handleAnswer(attemptId, exercises, exerciseId, type, answerData);
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
        _selectedOptionId = null;
        _textController.clear();
      });
      // Delay auto-focus slightly to ensure the view transition completed smoothly
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && type != 'multiple_choice' && type != 'listening') {
          _textFocusNode.requestFocus();
        }
      });
    } else {
      context.read<PracticeBloc>().add(SubmitAttemptEvent(attemptId, _answers));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<PracticeBloc, PracticeState>(
          buildWhen: (previous, current) {
            // Do not rebuild the UI on error if we are already in a practice session or results screen.
            // In those cases, showing a SnackBar is sufficient.
            if (current is PracticeError) {
              return previous is PracticeInitial || previous is PracticeLoading;
            }
            // Do not rebuild on AttemptAbandoned state because the screen is popping anyway.
            if (current is AttemptAbandoned) {
              return false;
            }
            return true;
          },
          listener: (context, state) {
            if (state is PracticeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: theme.colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is AttemptAbandoned) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attempt abandoned.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              Navigator.of(context).pop(); // Go back to lesson screen
            } else if (state is AttemptStarted) {
              setState(() {
                _currentIndex = 0;
                _answers.clear();
                _selectedOptionId = null;
                _textController.clear();
              });
            }
          },
          builder: (context, state) {
            if (state is PracticeLoading || state is PracticeInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is RuntimeLoaded) {
              return _buildStartScreen(context, state.lesson, state.runtime);
            } else if (state is AttemptStarted) {
              _exercises = state.exercises;
              return _buildPracticeSession(context, state.attemptId, state.exercises);
            } else if (state is AttemptSubmitted) {
              return _buildAttemptResults(context, state.result);
            } else if (state is PracticeError) {
              return _buildErrorScreen(context, state.message);
            } else {
              return const Center(child: Text('Unknown State'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildStartScreen(BuildContext context, Map<String, dynamic> lesson, Map<String, dynamic> runtime) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercises = runtime['exercises'] ?? [];
    
    final title = lesson['title'] ?? 'Lesson Overview';
    final summary = lesson['summary'] ?? '';
    final contentBlocks = lesson['contentBlocks'] as List<dynamic>? ?? [];

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.3),
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 48,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Study Material',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  if (contentBlocks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Read the lesson summary and tap below to start your practice session.',
                        style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.4),
                      ),
                    )
                  else
                    ...contentBlocks.map<Widget>((block) {
                      final blockType = block['type'] ?? 'text';
                      final blockHeading = block['heading'] ?? '';
                      final blockBody = block['body'] ?? '';

                      final isExample = blockType == 'example';
                      final cardBg = isExample 
                          ? AppColors.secondaryLight.withOpacity(0.08) 
                          : AppColors.primaryLight.withOpacity(0.04);
                      final iconData = isExample 
                          ? Icons.lightbulb_rounded 
                          : Icons.bookmark_added_rounded;
                      final iconColor = isExample 
                          ? AppColors.secondaryLight 
                          : AppColors.primaryLight;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0,
                        color: cardBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: iconColor.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(iconData, color: iconColor, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    blockHeading.isNotEmpty 
                                        ? blockHeading 
                                        : (isExample ? 'Example' : 'Note'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: iconColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (blockBody.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  blockBody,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.textPrimaryLight,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 24),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.secondaryLight.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.assignment_turned_in_rounded, size: 20, color: AppColors.secondaryLight),
                        const SizedBox(width: 10),
                        Text(
                          '${exercises.length} Interactive Exercises Available',
                          style: const TextStyle(
                            color: AppColors.secondaryLight,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (exercises.isNotEmpty) ...[
                    Text(
                      'PRACTICE INDIVIDUAL EXERCISES',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...exercises.map<Widget>((exercise) {
                      final promptText = exercise['prompt']?['text'] ?? 'Question';
                      final type = exercise['type'] ?? 'multiple_choice';
                      final order = (exercise['order'] ?? 0) + 1;
                      
                      String typeLabel = type.toString().replaceAll('_', ' ').toUpperCase();
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                            width: 1.5,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                            child: Text(
                              '$order',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            promptText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              typeLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.secondaryLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.play_arrow_rounded,
                              color: theme.colorScheme.primary,
                              size: 28,
                            ),
                            onPressed: () {
                              context.read<PracticeBloc>().add(
                                StartExerciseAttemptEvent(exercise['id'], exercise),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                  width: 1.5,
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                if (exercises.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No exercises found in this lesson.')),
                  );
                  return;
                }
                context.read<PracticeBloc>().add(StartAttemptEvent(widget.lessonId, exercises));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Start Practice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeSession(BuildContext context, String attemptId, List<dynamic> exercises) {
    if (_currentIndex >= exercises.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final exercise = exercises[_currentIndex];
    final options = exercise['options'] as List<dynamic>? ?? [];
    final type = exercise['type'] as String;
    final prompt = exercise['prompt']?['text'] ?? 'Translate this phrase';

    // Calculate progression
    final double progressVal = (_currentIndex + 1) / exercises.length;

    // Check if bottom action is enabled
    bool canProceed = false;
    if (type == 'multiple_choice' || type == 'listening') {
      canProceed = _selectedOptionId != null;
    } else {
      canProceed = _textController.text.trim().isNotEmpty;
    }

    return Column(
      children: [
        // Custom interactive top progress bar and exit button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 28),
                onPressed: () {
                  // Show confirm exit dialog
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Quit Practice?'),
                      content: const Text('Your progress in this practice session will not be saved.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Keep Practicing'),
                        ),
                        TextButton(
                          onPressed: () {
                            final bloc = context.read<PracticeBloc>();
                            Navigator.of(dialogContext).pop(); // Dismiss dialog
                            bloc.add(AbandonAttemptEvent(attemptId));
                            Navigator.of(context).pop(); // Go back immediately
                          },
                          child: Text(
                            'Quit',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progressVal,
                    minHeight: 12,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${_currentIndex + 1}/${exercises.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Main Exercise Area
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Session label
                Text(
                  'LESSON PRACTICE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Question Card containing prompt
                Card(
                  elevation: 0,
                  color: isDark ? theme.colorScheme.surface : theme.colorScheme.primary.withOpacity(0.04),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : theme.colorScheme.primary.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      prompt,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Render respective widgets based on type
                if (type == 'multiple_choice' || type == 'listening')
                  _buildMultipleChoiceContent(options)
                else
                  _buildTextInputContent(),
              ],
            ),
          ),
        ),

        // Fixed Action bar containing check / submit button
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                width: 1.5,
              ),
            ),
          ),
          child: ElevatedButton(
            onPressed: canProceed
                ? () => _submitCurrentAnswer(attemptId, exercises, exercise['id'], type)
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: canProceed ? theme.colorScheme.primary : Colors.grey[400],
              elevation: canProceed ? 4 : 0,
            ),
            child: Text(
              _currentIndex < exercises.length - 1 ? 'Next Question' : 'Submit Practice',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceContent(List<dynamic> options) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(options.length, (idx) {
        final option = options[idx];
        final optionId = option['id'] as String;
        final isSelected = _selectedOptionId == optionId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedOptionId = optionId;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.08)
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? AppColors.borderDark : Colors.grey[300]!),
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Alphabet indicator (A, B, C, D)
                  Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isDark ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      String.fromCharCode(65 + idx),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option['label'] ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (isDark ? Colors.white : theme.colorScheme.primary)
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInputContent() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'YOUR TRANSLATION',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          autofocus: true,
          maxLines: 4,
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
          onChanged: (text) {
            setState(() {}); // Re-evaluate Next button disabled/enabled state
          },
          decoration: InputDecoration(
            hintText: 'Type your translation here...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            fillColor: isDark ? theme.colorScheme.surface : Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptResults(BuildContext context, Map<String, dynamic> result) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final attempt = result['attempt'] ?? {};
    final scoreSummary = attempt['scoreSummary'] ?? {};
    final score = scoreSummary['score'] ?? 0;
    final maxScore = scoreSummary['maxScore'] ?? 0;
    final passed = scoreSummary['passed'] ?? false;
    final feedbackList = result['feedback'] as List<dynamic>? ?? [];

    final double successPercentage = maxScore > 0 ? (score / maxScore) * 100 : 0;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result Top Summary
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: passed
                        ? theme.colorScheme.primary.withOpacity(0.08)
                        : theme.colorScheme.error.withOpacity(0.08),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                        size: 72,
                        color: passed ? Colors.orangeAccent : theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        passed ? 'Practice Completed!' : 'Attempt Finished!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your score: $score / $maxScore (${successPercentage.toStringAsFixed(0)}%)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: passed ? theme.colorScheme.primary : theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Detailed Review Title
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 8),
                  child: Text(
                    'DETAILED REVIEW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: theme.colorScheme.primary.withOpacity(0.8),
                    ),
                  ),
                ),

                // Scrollable Feedback review list
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, idx) {
                    final feedback = feedbackList[idx];
                    final isCorrect = feedback['isCorrect'] as bool? ?? false;
                    final explanation = feedback['explanation'] as String?;

                    // Look up exercise details from cached list
                    final exercise = _exercises?.firstWhere(
                      (e) => e['id'] == feedback['exerciseId'],
                      orElse: () => null,
                    );
                    final prompt = exercise?['prompt']?['text'] ?? 'Question';
                    final options = exercise?['options'] as List<dynamic>? ?? [];
                    final type = feedback['type'] as String;

                    final submittedAnswer = feedback['submittedAnswer'] ?? {};
                    final submittedOptionIds = submittedAnswer['selectedOptionIds'] as List<dynamic>? ?? [];
                    final submittedResponse = submittedAnswer['response'] as String? ?? '';

                    final correctOptionIds = feedback['correctOptionIds'] as List<dynamic>? ?? [];
                    final acceptedAnswers = feedback['acceptedAnswers'] as List<dynamic>? ?? [];

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isCorrect
                              ? theme.colorScheme.primary.withOpacity(0.3)
                              : theme.colorScheme.error.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Question prompt
                            Text(
                              prompt,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Status Badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? theme.colorScheme.primary.withOpacity(0.12)
                                        : theme.colorScheme.error.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        size: 16,
                                        color: isCorrect ? theme.colorScheme.primary : theme.colorScheme.error,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isCorrect ? 'Correct' : 'Incorrect',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect ? theme.colorScheme.primary : theme.colorScheme.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  isCorrect ? '+1 XP' : '+0 XP',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isCorrect ? theme.colorScheme.primary : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Selection Review block
                            if (type == 'multiple_choice' || type == 'listening')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: List.generate(options.length, (optIdx) {
                                  final option = options[optIdx];
                                  final optionId = option['id'] as String;
                                  
                                  final isUserSelected = submittedOptionIds.contains(optionId);
                                  final isRightOption = correctOptionIds.contains(optionId);

                                  Color cardBg = Colors.transparent;
                                  Color borderCol = isDark ? AppColors.borderDark : Colors.grey[300]!;
                                  double borderWidth = 1.0;
                                  FontWeight fWeight = FontWeight.normal;

                                  if (isUserSelected) {
                                    fWeight = FontWeight.bold;
                                    if (isCorrect) {
                                      cardBg = theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.08);
                                      borderCol = theme.colorScheme.primary;
                                      borderWidth = 1.5;
                                    } else {
                                      cardBg = theme.colorScheme.error.withOpacity(isDark ? 0.2 : 0.08);
                                      borderCol = theme.colorScheme.error;
                                      borderWidth = 1.5;
                                    }
                                  } else if (isRightOption) {
                                    // Highlight correct option if the user chose the wrong one
                                    cardBg = theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.04);
                                    borderCol = theme.colorScheme.primary.withOpacity(0.6);
                                    borderWidth = 1.5;
                                  }

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: borderCol, width: borderWidth),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${String.fromCharCode(65 + optIdx)}. ',
                                          style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87),
                                        ),
                                        Expanded(
                                          child: Text(
                                            option['label'] ?? '',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: fWeight,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        if (isRightOption)
                                          Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 20)
                                        else if (isUserSelected && !isCorrect)
                                          Icon(Icons.close_rounded, color: theme.colorScheme.error, size: 20),
                                      ],
                                    ),
                                  );
                                }),
                              )
                            else ...[
                              // Text input response review
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isCorrect
                                      ? theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.06)
                                      : theme.colorScheme.error.withOpacity(isDark ? 0.15 : 0.06),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCorrect
                                        ? theme.colorScheme.primary.withOpacity(0.4)
                                        : theme.colorScheme.error.withOpacity(0.4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Your Answer:',
                                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      submittedResponse.isNotEmpty ? submittedResponse : '(No answer submitted)',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isCorrect
                                            ? (isDark ? Colors.green[300] : theme.colorScheme.primary)
                                            : (isDark ? Colors.red[300] : theme.colorScheme.error),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!isCorrect && acceptedAnswers.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(isDark ? 0.12 : 0.04),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Correct / Accepted Answer:',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        acceptedAnswers.first.toString(),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.green[200] : theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],

                            // Explanation block
                            if (explanation != null && explanation.trim().isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.lightbulb_outline_rounded, size: 20, color: theme.colorScheme.secondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        explanation,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Button to navigate back
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.borderDark : Colors.grey[200]!,
                width: 1.5,
              ),
            ),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              backgroundColor: theme.colorScheme.primary,
            ),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorScreen(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Something went wrong',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PracticeBloc>().add(GetRuntimeEvent(widget.lessonId));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
