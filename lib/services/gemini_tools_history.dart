// import 'package:firebase_vertexai/firebase_vertexai.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';

// part 'gemini_tools_history.g.dart';

// class LogStateNotifier extends StateNotifier<List<String>> {
//   LogStateNotifier() : super([]);

//   void logFunctionCall(String functionName, Map<String, Object?> arguments) {
//     state = [
//       ...state,
//       'Function called: $functionName with arguments: $arguments',
//     ];
//   }

//   void logFunctionResults(Map<String, Object?> results) {
//     state = [...state, 'Function results: $results'];
//   }

//   void logError(String error) {
//     state = [...state, 'Error: $error'];
//   }

//   void logWarning(String warning) {
//     state = [...state, 'Warning: $warning'];
//   }
// }

// final logStateNotifierProvider =
//     StateNotifierProvider<LogStateNotifier, List<String>>(
//       (ref) => LogStateNotifier(),
//     );

// class GeminiTools {
//   GeminiTools(this.ref);

//   final Ref ref;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
//     app: Firebase.app(),
//     databaseURL:
//         'https://hajjhealth-app-default-rtdb.asia-southeast1.firebasedatabase.app',
//   );

//   FunctionDeclaration get fetchUserDataFuncDecl => FunctionDeclaration(
//     'fetch_user_data',
//     'Fetch the logged-in user\'s profile data for prompt tuning.',
//     parameters: {
//       'name': Schema.string(description: 'The name of the user.'),
//       'age': Schema.string(description: 'The age of the user.'),
//       'weight': Schema.string(description: 'The weight of the user.'),
//       'height': Schema.string(description: 'The height of the user.'),
//       'gender': Schema.string(description: 'The gender of the user.'),
//     },
//   );

//   List<Tool> get tools => [
//     Tool.functionDeclarations([fetchUserDataFuncDecl]),
//   ];

//   Future<Map<String, Object?>> handleFunctionCall(
//     String functionName,
//     Map<String, Object?> arguments,
//   ) async {
//     final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
//     logStateNotifier.logFunctionCall(functionName, arguments);

//     return switch (functionName) {
//       'fetch_user_data' => await handleFetchUserData(arguments),
//       _ => handleUnknownFunction(functionName),
//     };
//   }

//   Future<Map<String, Object?>> handleFetchUserData(
//     Map<String, Object?> arguments,
//   ) async {
//     try {
//       // Mendapatkan user yang sedang login
//       final User? currentUser = _auth.currentUser;
//       if (currentUser == null) {
//         throw Exception('No user is currently logged in.');
//       }

//       // Mendapatkan UserID
//       final String userId = currentUser.uid;

//       // Mengakses data dari Firebase Realtime Database
//       final DatabaseReference userRef = _database.ref('family_history/$userId');
//       final DataSnapshot snapshot = await userRef.get();

//       if (!snapshot.exists) {
//         throw Exception('User data not found for user ID: $userId');
//       }

//       // Mengambil data dari snapshot
//       final Map<String, dynamic> userData = Map<String, dynamic>.from(
//         snapshot.value as Map,
//       );

//       // Menyusun hasil
//       final functionResults = {
//         'success': true,
//         'data': {
//           'name': userData['name'] ?? '',
//           'age': userData['age']?.toString() ?? '',
//           'weight': userData['weight']?.toString() ?? '',
//           'height': userData['height']?.toString() ?? '',
//           'gender': userData['gender'] ?? '',
//         },
//       };

//       // Logging hasil
//       final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
//       logStateNotifier.logFunctionResults(functionResults);

//       return functionResults;
//     } catch (e) {
//       // Logging error
//       final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
//       logStateNotifier.logError('Error fetching user data: $e');

//       return {'success': false, 'reason': 'Error fetching user data: $e'};
//     }
//   }

//   Map<String, Object?> handleUnknownFunction(String functionName) {
//     final logStateNotifier = ref.read(logStateNotifierProvider.notifier);
//     logStateNotifier.logWarning('Unsupported function call $functionName');
//     return {
//       'success': false,
//       'reason': 'Unsupported function call $functionName',
//     };
//   }
// }

// @riverpod
// GeminiTools geminiTools(Ref ref) => GeminiTools(ref);
