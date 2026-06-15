class StaticCurriculumData {
  static const List<Map<String, dynamic>> staticLanguages = [
    {
      'id': '6a12c216c24497386f0a9bc0',
      'name': 'Amharic',
      'slug': 'amharic',
      'nativeName': 'አማርኛ',
      'summary': 'Foundational Amharic for everyday communication.',
      'description':
          'Structured beginner-to-mastery Amharic curriculum with greetings, daily life, and cultural context.',
      'script': 'Ethiopic',
      'proficiencyLevels': [
        {'code': 'beginner', 'label': 'Beginner', 'order': 1},
        {'code': 'intermediate', 'label': 'Intermediate', 'order': 2},
        {'code': 'advanced', 'label': 'Advanced', 'order': 3}
      ]
    },
    {
      'id': '6a12cc0ea612e8468f3a13f0',
      'name': 'Afan Oromoo',
      'slug': 'oromo',
      'nativeName': 'Afaan Oromoo',
      'summary': 'Foundational Afan Oromoo for everyday communication.',
      'description':
          'Structured beginner-to-mastery Afan Oromoo curriculum with practical vocabulary and dialogues.',
      'script': 'Latin',
      'proficiencyLevels': [
        {'code': 'beginner', 'label': 'Beginner', 'order': 1},
        {'code': 'intermediate', 'label': 'Intermediate', 'order': 2},
        {'code': 'advanced', 'label': 'Advanced', 'order': 3}
      ]
    },
    {
      'id': '6a12cc0fa612e8468f3a1529',
      'name': 'Tigrinya',
      'slug': 'tigrinya',
      'nativeName': 'ትግርኛ',
      'summary': 'Foundational Tigrinya for everyday communication.',
      'description':
          'Structured beginner-to-mastery Tigrinya curriculum with greetings, travel, and community topics.',
      'script': 'Ethiopic',
      'proficiencyLevels': [
        {'code': 'beginner', 'label': 'Beginner', 'order': 1},
        {'code': 'intermediate', 'label': 'Intermediate', 'order': 2},
        {'code': 'advanced', 'label': 'Advanced', 'order': 3}
      ]
    }
  ];

  static const Map<String, List<Map<String, dynamic>>> staticUnits = {
    '6a12c216c24497386f0a9bc0': [
      {
        'id': '6a12c25ac24497386f0a9bc2',
        'order': 0,
        'title': 'Basics & Greetings',
        'summary': 'Learn to say hello, ask how someone is, and introduce yourself in Amharic.',
      },
      {
        'id': '6a12cc0da612e8468f3a1320',
        'order': 1,
        'title': 'Numbers & Time',
        'summary': 'Master counting from 1 to 100 and telling time in Amharic.',
      }
    ],
    '6a12cc0ea612e8468f3a13f0': [
      {
        'id': '6a12cc0ea612e8468f3a13f1',
        'order': 0,
        'title': 'Greetings & Essentials',
        'summary': 'Learn fundamental greetings and essential vocabulary in Afan Oromoo.',
      }
    ],
    '6a12cc0fa612e8468f3a1529': [
      {
        'id': '6a12cc0fa612e8468f3a152a',
        'order': 0,
        'title': 'Greetings & Introductions',
        'summary': 'Beginner greetings, personal introductions, and basic courtesy in Tigrinya.',
      }
    ]
  };

  static const Map<String, List<Map<String, dynamic>>> staticLessons = {
    '6a12c25ac24497386f0a9bc2': [
      {
        'id': '6a12c2a6c24497386f0a9bc4',
        'unitId': '6a12c25ac24497386f0a9bc2',
        'title': 'Saying Hello',
        'summary': 'Learn basic Amharic greetings like Selam and Tadias.',
        'estimatedDurationMinutes': 5,
        'order': 0,
      },
      {
        'id': '6a12cac2e2bd7c7bcbe68747',
        'unitId': '6a12c25ac24497386f0a9bc2',
        'title': 'Introductions',
        'summary': 'Learn how to introduce yourself and say where you are from.',
        'estimatedDurationMinutes': 5,
        'order': 1,
      }
    ],
    '6a12cc0da612e8468f3a1320': [
      {
        'id': '6a12cc0da612e8468f3a132b',
        'unitId': '6a12cc0da612e8468f3a1320',
        'title': 'Numbers 1 to 10',
        'summary': 'Count from 1 to 10 in Amharic.',
        'estimatedDurationMinutes': 5,
        'order': 0,
      }
    ],
    '6a12cc0ea612e8468f3a13f1': [
      {
        'id': '6a12cc0ea612e8468f3a13f2',
        'unitId': '6a12cc0ea612e8468f3a13f1',
        'title': 'Basic Greetings',
        'summary': 'Learn basic Afan Oromoo greetings like Akkam and Fayya.',
        'estimatedDurationMinutes': 5,
        'order': 0,
      }
    ],
    '6a12cc0fa612e8468f3a152a': [
      {
        'id': '6a12cc0fa612e8468f3a152b',
        'unitId': '6a12cc0fa612e8468f3a152a',
        'title': 'Basic Greetings',
        'summary': 'Learn basic Tigrinya greetings like Selam and Kemey Alena.',
        'estimatedDurationMinutes': 5,
        'order': 0,
      }
    ]
  };

  static const Map<String, Map<String, dynamic>> staticLessonDetails = {
    '6a12c2a6c24497386f0a9bc4': {
      'id': '6a12c2a6c24497386f0a9bc4',
      'title': 'Saying Hello',
      'summary': 'Learn basic Amharic greetings like Selam and Tadias.',
      'estimatedDurationMinutes': 5,
      'languageName': 'Amharic',
    },
    '6a12cac2e2bd7c7bcbe68747': {
      'id': '6a12cac2e2bd7c7bcbe68747',
      'title': 'Introductions',
      'summary': 'Learn how to introduce yourself and say where you are from.',
      'estimatedDurationMinutes': 5,
      'languageName': 'Amharic',
    },
    '6a12cc0da612e8468f3a132b': {
      'id': '6a12cc0da612e8468f3a132b',
      'title': 'Numbers 1 to 10',
      'summary': 'Count from 1 to 10 in Amharic.',
      'estimatedDurationMinutes': 5,
      'languageName': 'Amharic',
    },
    '6a12cc0ea612e8468f3a13f2': {
      'id': '6a12cc0ea612e8468f3a13f2',
      'title': 'Basic Greetings',
      'summary': 'Learn basic Afan Oromoo greetings like Akkam and Fayya.',
      'estimatedDurationMinutes': 5,
      'languageName': 'Afan Oromoo',
    },
    '6a12cc0fa612e8468f3a152b': {
      'id': '6a12cc0fa612e8468f3a152b',
      'title': 'Basic Greetings',
      'summary': 'Learn basic Tigrinya greetings like Selam and Kemey Alena.',
      'estimatedDurationMinutes': 5,
      'languageName': 'Tigrinya',
    },
  };

  static const Map<String, Map<String, dynamic>> staticLessonRuntimes = {
    '6a12c2a6c24497386f0a9bc4': {
      'id': 'runtime_amharic_1_1',
      'lessonId': '6a12c2a6c24497386f0a9bc4',
      'exercises': [
        {
          'id': '6a12c2ebc24497386f0a9bc6',
          'type': 'multiple_choice',
          'instruction': 'How do you say "Hello" casually in Amharic?',
          'content': 'Hello',
          'options': [
            {'id': 'opt-1', 'label': 'ሰላም (Selam)'},
            {'id': 'opt-2', 'label': 'አመሰግናለሁ (Ameseginalehu)'},
            {'id': 'opt-3', 'label': 'ቻው (Chaw)'}
          ],
          'correctOptionIds': ['opt-1'],
          'explanation': 'Selam is the most casual greeting.'
        },
        {
          'id': '6a12c2ebc24497386f0a9bc7',
          'type': 'text_input',
          'instruction': 'Type the formal Amharic greeting meaning "May He give you health on my behalf" (Tena Yistelegn):',
          'content': 'ጤና ይስጥልኝ',
          'acceptedAnswers': ['ጤና ይስጥልኝ'],
          'explanation': 'ጤና ይስጥልኝ is the formal greeting.'
        }
      ]
    },
    '6a12cac2e2bd7c7bcbe68747': {
      'id': 'runtime_amharic_1_2',
      'lessonId': '6a12cac2e2bd7c7bcbe68747',
      'exercises': [
        {
          'id': '6a12c2ebc24497386f0a9bc8',
          'type': 'multiple_choice',
          'instruction': 'Choose the correct structural link meaning "is" to complete: ስሜ ዮናስ ___ (My name is Yonas).',
          'content': 'My name is...',
          'options': [
            {'id': 'opt-1', 'label': 'ነኝ (negn)'},
            {'id': 'opt-2', 'label': 'ነው (newu)'},
            {'id': 'opt-3', 'label': 'ነህ (neh)'}
          ],
          'correctOptionIds': ['opt-2'],
          'explanation': 'newu (is) is the correct copula.'
        }
      ]
    },
    '6a12cc0da612e8468f3a132b': {
      'id': 'runtime_amharic_2_1',
      'lessonId': '6a12cc0da612e8468f3a132b',
      'exercises': [
        {
          'id': '6a12c2ebc24497386f0a9bd0',
          'type': 'multiple_choice',
          'instruction': 'Identify the cultural flatbread that accompanies a stew order in Addis Ababa:',
          'content': 'One (1)',
          'options': [
            {'id': 'opt-1', 'label': 'ዳቦ (Dabo)'},
            {'id': 'opt-2', 'label': 'እንጀራ (Injera)'},
            {'id': 'opt-3', 'label': 'ቂጣ (Kita)'}
          ],
          'correctOptionIds': ['opt-2'],
          'explanation': 'Injera is the correct sourdough flatbread companion.'
        }
      ]
    },
    '6a12cc0ea612e8468f3a13f2': {
      'id': 'runtime_oromo_1_1',
      'lessonId': '6a12cc0ea612e8468f3a13f2',
      'exercises': [
        {
          'id': '6a12c2ebc24497386f0a9bd4',
          'type': 'multiple_choice',
          'instruction': 'Identify the canonical greeting phrase used to open conversation threads in Afaan Oromoo:',
          'content': 'How are you?',
          'options': [
            {'id': 'opt-1', 'label': 'Akkam'},
            {'id': 'opt-2', 'label': 'Nagaatti'},
            {'id': 'opt-3', 'label': 'Lakki'}
          ],
          'correctOptionIds': ['opt-1'],
          'explanation': 'Akkam means How are you in Afan Oromoo.'
        },
        {
          'id': '6a12c2ebc24497386f0a9bd5',
          'type': 'text_input',
          'instruction': 'Provide the explicit Afaan Oromoo expression used for saying "Goodbye" safely:',
          'content': 'Galatooma',
          'acceptedAnswers': ['nagaatti'],
          'explanation': 'Nagaatti means Goodbye.'
        }
      ]
    },
    '6a12cc0fa612e8468f3a152b': {
      'id': 'runtime_tigrinya_1_1',
      'lessonId': '6a12cc0fa612e8468f3a152b',
      'exercises': [
        {
          'id': '6a12c2ebc24497386f0a9bdc',
          'type': 'multiple_choice',
          'instruction': 'Which term delivers the formal greeting "How are you dynamic" targeted to a single male subject in Tigrinya?',
          'content': 'How are you? (to a male)',
          'options': [
            {'id': 'opt-1', 'label': 'ከመይ አሎኻ (Kemey alokha)'},
            {'id': 'opt-2', 'label': 'ከመይ አሎኺ (Kemey alokhi)'},
            {'id': 'opt-3', 'label': 'ሰላም (Selam)'}
          ],
          'correctOptionIds': ['opt-1'],
          'explanation': 'ከመይ አሎኻ (Kemey alokha) is correct for a male.'
        },
        {
          'id': '6a12c2ebc24497386f0a9bdd',
          'type': 'text_input',
          'instruction': 'Type the formal expression matching deep gratitude validation "Thank you" (Yekenyeley) inside Ge\'ez lettering columns:',
          'content': 'የቀንየለይ',
          'acceptedAnswers': ['የቀንየለይ', 'የቐንየለይ'],
          'explanation': 'የቀንየለይ means Thank you in Tigrinya.'
        }
      ]
    }
  };
}
