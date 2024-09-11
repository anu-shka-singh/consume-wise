import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

// Access your API key as an environment variable (see "Set up your API key" above)
const apiKey = "";

Future<String?> calorieCalculator(String userMeal) async {
  try {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final String prompt = '''
    You are a nutritionist tasked with analyzing a meal based on its content of calories, fat, and protein. Your goal is to calculate the total calories, fat, and protein the user's meal contains, based on the input provided. Additionally, you should offer comments on the meal's overall nutritional value and suggest ways to make the meal more wholesome if necessary. Lastly, provide an estimate of the time required to burn the total calories from the meal through walking and jogging.

    Please follow these instructions:
    1. If any inedible item is mentioned, return null. 
    2. If the quantity of food is not mentioned, make reasonable assumptions based on common serving sizes.
    3. If insufficient details are provided, base the analysis on popular recipes of the mentioned meal.

    Provide the response in the following valid JSON object (using integers for calories, fat, and protein, and strings for comments and time estimates):
    {
      "user_meal": "",
      "total_calories": 0,
      "total_fat": 0,
      "total_protein": 0,
      "comment": "",
      "time_jog": "",
      "time_walk": ""
    }

    Input: $userMeal
    ''';

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

