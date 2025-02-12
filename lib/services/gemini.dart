import 'dart:developer';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

Future<String?> getResponse(String prompt) async {
  try {
    final model = GenerativeModel(
        model: 'gemini-1.5-flash-latest',
        apiKey: 'AIzaSyBwfX07bHDHLTuXNnM4L8XvIpoLRDctY0s');

    final response = await model.generateContent([Content.text(prompt)]);
    log(response.text!);
    return response.text;
  } on SocketException catch (e) {
    log("No Internet connection: $e");
    return "No internet connection. Please check your network.";
  } on http.ClientException catch (e) {
    log("ClientException: $e");
    return "Unable to reach server. Please try again later.";
  } catch (e) {
    log("Unexpected error: $e");
    return "An unexpected error occurred. Please try again.";
  }
}

String getCleanResponse(String response) {
  log("Original response: $response");
  final start = response.indexOf('{');
  final end = response.lastIndexOf('}');
  if (start != -1 && end != -1 && end >= start) {
    return response.substring(start, end + 1);
  } else {
    throw const FormatException('Invalid JSON format');
  }
}
