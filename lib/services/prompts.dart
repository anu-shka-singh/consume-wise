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
      'https://world.openfoodfacts.org/api/v2/product/$productId.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['product'];
  } else {
    print('Failed to fetch product information');
    return null;
  }
}

Future<String> healthAnalysis(Map<String, dynamic> product) async {
  // Fetch the product information from OpenFoodFacts API
  // final productInfo = await fetchProductInfo(productId);

  // if (productInfo == null) {
  //   return 'Product information could not be retrieved.';
  // }

  // // Extract relevant information from productInfo for the prompt
  // final productName = productInfo['product_name'] ?? 'Unknown Product';
  // final ingredients = productInfo['ingredients_text'] ?? 'No ingredients info';
  // final nutritionInfo = productInfo['nutriments'] != null
  //     ? productInfo['nutriments']
  //         .map((key, value) => MapEntry(key, '$key: $value'))
  //         .values
  //         .join(', ')
  //     : 'No nutritional info available';

  final prompt = '''
    You are tasked with analyzing the health impact of a packaged food product based on the provided product details in JSON format. Your goal is to provide a thorough analysis covering both the positive and negative aspects of the product from a health perspective. The analysis must also check for allergens, compliance with certain diets, harmful ingredients, and provide recommendations for healthier alternatives. The final output should be in the following JSON format.

    Required Analysis:
    1. Positive Impacts Tags: Identify and list the short prominent positive health benefits of the product, such as high protein, low sugar, presence of vitamins or minerals, etc.

    2. Negative Impacts Tags: Identify and list the short prominent negative health impacts of the product, such as high sugar, high sodium, low fiber, artificial additives, etc.

    3. Allergens: Check for the presence of common allergens from these only [Peanuts, Eggs, Wheat, Soybeans, Milk, Fish, Tree Nuts, Sesame Seeds] and list any allergens found. Do not add any other allergen than these.

    4. Dietary Compliance: Determine which common diets the product complies with, and for each diet provide a brief description of why it is compliant. If it does not comply with any specific diet, state that.

    5. Harmful Ingredients: Identify and list any harmful or controversial ingredients present, such as trans fats, artificial sweeteners, artificial preservatives, etc.

    6. Rating: Provide a rating for how healthy the product is based on all the analyzed factors (positive and negative impacts, harmful ingredients). The rating should be on a scale of 1 to 5 (1 being unhealthy, 5 being very healthy).

    7. Recommendations for Healthier Alternatives: Suggest 3 healthier alternative products from the same category (e.g., healthier versions of the same type of snack, beverage, etc.) For alternatives, make sure you are recommending packaged food and not home made food alternatives. Also keep in mind to recommend only those alternatives which are available in Indian Markets.

    8. Portion Size: Based on the product's QUANTITY and type, give a **common portion size** in grams along with a **reference in terms of portion** (e.g., for a 400g bread, the common portion size would be 50g, which means 2 slices of bread). The reference should be in easily understandable terms like "2 biscuits," "1 handful of namkeen," "1 slice of bread," etc.
    
    The response should only contain the following JSON format:

    {
      
      "positive": [<list of positive impacts>],  // Example: ['high protein', 'low fat']
      "negative": [<list of negative impacts>],  // Example: ['high sugar', 'low fiber']
      "allergens": [<list of allergens found>],  // Example: ['peanuts', 'wheat']
      "diet": [
        {
          "name": <diet name>,  // Example: 'vegan', 'keto'
          "description": <brief explanation of compliance or non-compliance>
        }
      ],
      "harmful_ingredients": [<list of harmful ingredients>],  // Example: ['trans fats', 'aspartame'],
      "rating": <rating>,  // A decimal number from 1 to 5
      "recommendations": [<alternative product 1>, <alternative product 2>, <alternative product 3>]  // Suggest 3 healthier alternative products
      "portion_size_grams": <portion size in grams> // A decimal number, Example: 50.5, 20.0
      "portion_size": <portion size> // Example: 2 slices of bread, 2 biscuits, 1 handful of namkeen, 
    }

    Instructions:
    1. Evaluate the product’s ingredients and nutritional values carefully to determine its positive and negative health impacts.
    2. Identify any common allergens based on the ingredient list.
    3. Analyze which diets the product complies with and provide a brief description.
    4. Detect harmful ingredients, if any, and list them.
    5. Rate the product based on its overall health impact, from 1 to 5.
    6. Provide three healthier alternatives from the same category of food products.
    
    Based on the above, please provide the health analysis of the following product whose information is given below:
    $product

  ''';

  final response = await getResponse(prompt);
  return response ?? "";
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

Future<String> chatResponse(String userMessage) async {
  final String prompt = '''
    You are the chatbot for EatWise, an app designed to help consumers make informed decisions when purchasing packaged food. Your main role is to assist users by answering the user queries as accurately as possible. Use the information given below if the user wants to know about the app and its features. For queries realted to food or packaged products, use the general information that you have.

    Here is the information about the key Features of the app that You Should Be Aware of:

    1. Health Analysis: Eatwise allow users to analyze ingredients and nutrition based on the user's preferences and dietary restrictions.
    2. Claim Verification: Eatwise helps users verify if the health claims made by the products are accurate.
    3. Calorie Counter: Eatwise allows users to know the calories gained by the entering the meal they just had and the time to burn off those calories by walking or running.
    4. Search or Scan: Users can either search for a product or scan its barcode to get an instant analysis.
    5. Personalized Insights: Eatwise provides personalized recommendations based on the user's diet, food preferences, age, height and weight.
    6. Overlay Functionality (Upcoming): This feature guide users while they shop on other platforms (e.g., Zepto, Blinkit) through an overlay that scans product information.
    
    Tone & Style:

    1. Keep responses crisp and concise, as the app is used on mobile devices.
    2. If a user asks a question outside the app’s core features, use your general intelligence to respond appropriately.
    3. Politely decline to answer questions that are not related to health, food or packaged products.

    Based on above instructions, Answer the user query.
    User Query: $userMessage
    ''';
  final response = await getResponse(prompt);
  return response ?? "";
}
