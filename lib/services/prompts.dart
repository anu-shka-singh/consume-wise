import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:overlay/services/gemini.dart';

Future<String?> calorieCalculator(String userMeal) async {
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

  final response = await getResponse(prompt);
  return response;
}

// Function to fetch product information from OpenFoodFacts API
Future<Map<String, dynamic>?> fetchProductInfo(int productId) async {
  final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v0/product/$productId.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['product'];
  } else {
    print('Failed to fetch product information');
    return null;
  }
}

Future<String?> healthAnalysis(int productId) async {
  // Fetch the product information from OpenFoodFacts API
  final productInfo = await fetchProductInfo(productId);

  if (productInfo == null) {
    return 'Product information could not be retrieved.';
  }

  // Extract relevant information from productInfo for the prompt
  final productName = productInfo['product_name'] ?? 'Unknown Product';
  final ingredients = productInfo['ingredients_text'] ?? 'No ingredients info';
  final nutritionInfo = productInfo['nutriments'] != null
      ? productInfo['nutriments']
          .map((key, value) => MapEntry(key, '$key: $value'))
          .values
          .join(', ')
      : 'No nutritional info available';

  final prompt = '''
    Please analyze the health impact of the following product:

    Product Name: $productName
    Ingredients: $ingredients
    Nutritional Information: $nutritionInfo

    Please provide the health analysis in JSON format with the following keys:
    - "positive": A list of major positive health impacts of the product.
    - "negative": A list of major negative health impacts of the product.
    - "allergy": A list of major possible allergies that the product may cause.
    - "diet": A list of diets with which the product is compatible with.
    - "rating" : A score out of 5, you think is suitable for the product based on its impact on health. This rating could be in decimal upto one place.

    Include only the headings (e.g., "High Sugar Content") without detailed explanations. The response should be a JSON object where each key maps to a list of relevant headings. Keep the lists extremely relevant and do not include any headings that are not applicable. Make sure to analyze the health impact of the product strictly with respect to the Indian Context.

  ''';

  final response = await getResponse(prompt);
  return response;
}

Future<String> analyzeClaim(String claim, Map<String, dynamic> product) async {
  final String prompt = '''
    You are tasked with analyzing claims made by packaged food products. Your goal is to evaluate whether the claim is:

    1. Accurate: The claim is factually correct and based on the provided product details.
    2. Misleading: The claim is somewhat correct but exaggerated or incomplete, potentially confusing or misinforming consumers.
    3. Invalid Input: The claim cannot be analyzed due to lack of sufficient information or the claim being nonsensical or out of scope.

    The response should include the following in JSON format:

    Verdict: Whether the claim is accurate, misleading, or invalid input.
    Percentage Accuracy: A percentage (0% to 100%) representing how confident you are in the verdict.
    Reasons: An explanation of why the claim is accurate, misleading, or invalid. If misleading, explain which parts of the claim are exaggerated or contradictory to the product information.
    Detailed Analysis: A deeper analysis of the product's ingredients, nutrients, or other information to back up your verdict. Mention specific ingredients or nutrient values that support the decision.

    Instructions for Analysis:

    1. Evaluate Ingredients & Nutrients: Check the product's ingredient list and nutrient values to see if they support or contradict the claim.
    2. Verdict Accuracy: Determine if the claim is accurate, misleading, or if the input is invalid (e.g., if the claim is nonsensical or cannot be analyzed).
    3. Justify the Verdict: Provide a clear explanation, including specific reasons and references to the product's ingredients or nutrients.
    4. Deliver Detailed Analysis: Offer a comprehensive analysis of how the product's components align with or deviate from the claim.

    Based on the above instructions, please provide the claim analysis for the following input:
    Product Information : $product
    Claim to be analyzed : $claim
    ''';
  final response = await getResponse(prompt);
  return response ?? "";
}
