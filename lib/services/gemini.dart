import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<String?> getResponse(String prompt) async {
  try {
    final model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: '');

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text;
  } on SocketException catch (e) {
    print("No Internet connection: $e");
    return "No internet connection. Please check your network.";
  } on http.ClientException catch (e) {
    print("ClientException: $e");
    return "Unable to reach server. Please try again later.";
  } catch (e) {
    print("Unexpected error: $e");
    return "An unexpected error occurred. Please try again.";
  }
}
