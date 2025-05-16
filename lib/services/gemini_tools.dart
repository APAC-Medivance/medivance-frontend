import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

part 'gemini_tools.g.dart';

class LogStateNotifier extends StateNotifier<List<String>> {
  LogStateNotifier() : super([]);

  void logFunctionCall(String functionName, Map<String, Object?> arguments) {
    state = [
      ...state,
      'Function called: $functionName with arguments: $arguments',
    ];
  }

  void logFunctionResults(Map<String, Object?> results) {
    state = [...state, 'Function results: $results'];
  }

  void logError(String error) {
    state = [...state, 'Error: $error'];
  }

  void logWarning(String warning) {
    state = [...state, 'Warning: $warning'];
  }
}

final logStateNotifierProvider =
    StateNotifierProvider<LogStateNotifier, List<String>>(
      (ref) => LogStateNotifier(),
    );

class GeminiTools {
  GeminiTools(this.ref);

  final Ref ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  FunctionDeclaration get fetchUserDataFuncDecl => FunctionDeclaration(
    'fetch_user_data',
    'Fetch the logged-in user\'s profile data for prompt tuning.',
    parameters: {
      'name': Schema.string(description: 'The name of the user.'),
      'age': Schema.string(description: 'The age of the user.'),
      'weight': Schema.string(description: 'The weight of the user.'),
      'height': Schema.string(description: 'The height of the user.'),
      'gender': Schema.string(description: 'The gender of the user.'),
    },
  );

  FunctionDeclaration get fetchFamilyHistoryFuncDecl => FunctionDeclaration(
    'fetch_family_history',
    'Fetch the logged-in user\'s family health history for prompt tuning.',
    parameters: {
      'relation': Schema.string(
        description: 'The relation to the user (e.g., father, mother).',
      ),
      'condition': Schema.string(
        description: 'The medical condition of the family member.',
      ),
      'diagnosisYear': Schema.string(
        description: 'The year the condition was diagnosed.',
      ),
      'medication': Schema.string(
        description: 'The medication prescribed for the condition.',
      ),
    },
  );

  FunctionDeclaration get fetchPastHistoryFuncDecl => FunctionDeclaration(
    'fetch_past_history',
    'Fetch the logged-in user\'s past health history for prompt tuning.',
    parameters: {
      'historyItems': Schema.array(
        items: Schema.string(
          description: 'A past health condition of the user.',
        ),
        description: 'A list of past health conditions of the user.',
      ),
      'timestamp': Schema.string(
        description: 'The timestamp when the past health history was recorded.',
      ),
    },
  );

  FunctionDeclaration get fetchSocialHistoryFuncDecl => FunctionDeclaration(
    'fetch_social_history',
    'Fetch the logged-in user\'s social health history for prompt tuning.',
    parameters: {
      'alcoholType': Schema.string(
        description: 'The type of alcohol consumed by the user.',
      ),
      'cigarettesPerDay': Schema.integer(
        description: 'The number of cigarettes smoked per day.',
      ),
      'consumesAlcohol': Schema.boolean(
        description: 'Whether the user consumes alcohol.',
      ),
      'drinksPerWeek': Schema.integer(
        description: 'The number of alcoholic drinks consumed per week.',
      ),
      'isSmoker': Schema.boolean(description: 'Whether the user is a smoker.'),
      'mealsPerDay': Schema.integer(
        description: 'The number of meals consumed per day.',
      ),
      'sanitation': Schema.string(
        description: 'The sanitation condition of the user.',
      ),
      'timestamp': Schema.string(
        description: 'The timestamp when the social history was recorded.',
      ),
      'ventilation': Schema.string(
        description: 'The ventilation condition of the user\'s environment.',
      ),
      'workplace': Schema.string(
        description: 'The type of workplace of the user.',
      ),
      'yearsOfSmoking': Schema.integer(
        description: 'The number of years the user has been smoking.',
      ),
    },
  );

  List<Tool> get tools => [
    Tool.functionDeclarations([
      fetchUserDataFuncDecl,
      fetchFamilyHistoryFuncDecl,
      fetchPastHistoryFuncDecl,
      fetchSocialHistoryFuncDecl,
    ]),
  ];

  Future<Map<String, Object?>> handleFunctionCall(
    String functionName,
    Map<String, Object?> arguments,
  ) async {
    final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
    logStateNotifier.logFunctionCall(functionName, arguments);

    return switch (functionName) {
      'fetch_user_data' => await handleFetchUserData(arguments),
      'fetch_family_history' => await handleFetchFamilyHistory(arguments),
      'fetch_past_history' => await handleFetchPastHistory(arguments),
      'fetch_social_history' => await handleFetchSocialHistory(arguments),
      _ => handleUnknownFunction(functionName),
    };
  }

  Future<Map<String, Object?>> handleFetchUserData(
    Map<String, Object?> arguments,
  ) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in.');
      }

      final String userId = currentUser.uid;

      final DatabaseReference userRef = _database.ref('user_profiles/$userId');
      final DataSnapshot snapshot = await userRef.get();

      if (!snapshot.exists) {
        throw Exception('User data not found for user ID: $userId');
      }

      final Map<String, dynamic> userData = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final functionResults = {
        'success': true,
        'data': {
          'name': userData['name'] ?? '',
          'age': userData['age']?.toString() ?? '',
          'weight': userData['weight']?.toString() ?? '',
          'height': userData['height']?.toString() ?? '',
          'gender': userData['gender'] ?? '',
        },
      };

      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logFunctionResults(functionResults);

      return functionResults;
    } catch (e) {
      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logError('Error fetching user data: $e');

      return {'success': false, 'reason': 'Error fetching user data: $e'};
    }
  }

  Future<Map<String, Object?>> handleFetchFamilyHistory(
    Map<String, Object?> arguments,
  ) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in.');
      }

      final String userId = currentUser.uid;
      final DatabaseReference familyHistoryRef = _database.ref(
        'family_history/-OPrLdqwUMaHDiWL-vuH',
      );
      final DataSnapshot snapshot = await familyHistoryRef.get();

      if (!snapshot.exists) {
        throw Exception('Family history data not found for user ID: $userId');
      }

      final Map<String, dynamic> familyHistory = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final functionResults = {
        'success': true,
        'data': familyHistory.map((relation, details) {
          final Map<String, dynamic> detailMap = Map<String, dynamic>.from(
            details as Map,
          );
          return MapEntry(relation, {
            'relation': relation,
            'condition': detailMap['condition'] ?? '',
            'diagnosisYear': detailMap['diagnosisYear']?.toString() ?? '',
            'medication': detailMap['medication'] ?? '',
          });
        }),
      };

      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logFunctionResults(functionResults);

      return functionResults;
    } catch (e) {
      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logError('Error fetching family history: $e');
      return {'success': false, 'reason': 'Error fetching family history: $e'};
    }
  }

  Future<Map<String, Object?>> handleFetchPastHistory(
    Map<String, Object?> arguments,
  ) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in.');
      }

      final String userId = currentUser.uid;
      final DatabaseReference pastHistoryRef = _database.ref(
        'past_history/-OPyyWp2KffEG6f_pJvs',
      );
      final DataSnapshot snapshot = await pastHistoryRef.get();

      if (!snapshot.exists) {
        throw Exception('Past history data not found for user ID: $userId');
      }

      final Map<String, dynamic> pastHistory = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final List<Map<String, Object?>> historyList =
          pastHistory.entries.map((entry) {
            final Map<String, dynamic> details = Map<String, dynamic>.from(
              entry.value as Map,
            );
            return {
              'historyItems': List<String>.from(details['historyItems'] ?? []),
              'timestamp': details['timestamp']?.toString() ?? '',
            };
          }).toList();

      final functionResults = {'success': true, 'data': historyList};

      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logFunctionResults(functionResults);

      return functionResults;
    } catch (e) {
      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logError('Error fetching past history: $e');
      return {'success': false, 'reason': 'Error fetching past history: $e'};
    }
  }

  Future<Map<String, Object?>> handleFetchSocialHistory(
    Map<String, Object?> arguments,
  ) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user is currently logged in.');
      }

      final String userId = currentUser.uid;
      final DatabaseReference socialHistoryRef = _database.ref(
        'social_history/-OPrUWODAm4-9BWqqjCd',
      );
      final DataSnapshot snapshot = await socialHistoryRef.get();

      if (!snapshot.exists) {
        throw Exception('Social history data not found for user ID: $userId');
      }

      final Map<String, dynamic> socialHistory = Map<String, dynamic>.from(
        snapshot.value as Map,
      );

      final functionResults = {
        'success': true,
        'data': {
          'alcoholType': socialHistory['alcoholType'] ?? '',
          'cigarettesPerDay': socialHistory['cigarettesPerDay'] ?? 0,
          'consumesAlcohol': socialHistory['consumesAlcohol'] ?? false,
          'drinksPerWeek': socialHistory['drinksPerWeek'] ?? 0,
          'isSmoker': socialHistory['isSmoker'] ?? false,
          'mealsPerDay': socialHistory['mealsPerDay'] ?? 0,
          'sanitation': socialHistory['sanitation'] ?? '',
          'timestamp': socialHistory['timestamp']?.toString() ?? '',
          'ventilation': socialHistory['ventilation'] ?? '',
          'workplace': socialHistory['workplace'] ?? '',
          'yearsOfSmoking': socialHistory['yearsOfSmoking'] ?? 0,
        },
      };

      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logFunctionResults(functionResults);

      return functionResults;
    } catch (e) {
      final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
      logStateNotifier.logError('Error fetching social history: $e');
      return {'success': false, 'reason': 'Error fetching social history: $e'};
    }
  }

  Map<String, Object?> handleUnknownFunction(String functionName) {
    final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
    logStateNotifier.logWarning('Unsupported function call $functionName');
    return {
      'success': false,
      'reason': 'Unsupported function call $functionName',
    };
  }
}

@riverpod
GeminiTools geminiTools(Ref ref) => GeminiTools(ref);
