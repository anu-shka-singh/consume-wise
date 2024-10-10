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

Future<String> healthAnalysis(Map<String, dynamic> product) async {
  final prompt = '''
    You are tasked with analyzing the health impact of a packaged food product based on the provided product details in JSON format. Your goal is to provide a thorough analysis covering both the positive and negative aspects of the product from a health perspective. The analysis must also check for allergens, compliance with certain diets, harmful ingredients, and provide recommendations for healthier alternatives. The final output should be in the following JSON format.

    Required Analysis:
    1. Positive Impact Tags: Identify and list concise, fact-checked positive impact tags based on the provided product information. Focus on health and sustainability benefits such as high protein, low sugar, vitamins, or minerals. If the product is overall unhealthy (e.g., processed foods like instant noodles), avoid listing positive attributes such as high protein, as this could encourage consumption. Include only genuinely beneficial tags. When mentioning fats, list the source (e.g., avocados, nuts) if it provides healthy fats, avoiding 'high fat' as a positive tag. Benchmark values to consider a nutrient "high" are based on general guidelines:
      * Protein: >10g per serving
      * Carbohydrates: >20g per serving (focus on complex carbs)
      * Fiber: >5g per serving
      * Healthy fats (e.g., unsaturated): >7g per serving

    2. Negative Impact Tags: Identify and list concise, fact-checked negative impact tags based on the provided product information. Focus on health and environmental concerns such as high sugar, sodium, artificial additives, or unsustainable practices. If the product contains unhealthy fats, use specific tags like 'High Saturated Fat' (>5g per serving) or 'High Trans Fat' (>0g, as these are considered harmful in any amount). Avoid unnecessary descriptions, and ensure that the negative tags clearly indicate why the product may negatively affect health or the environment.
    
    3. Allergens: Check for the presence of common allergens from these only [Peanuts, Eggs, Wheat, Soybeans, Milk, Fish, Tree Nuts, Sesame Seeds] and list any allergens found. Do not add any other allergen than these.

    4. Dietary Compliance: Determine which common diets the product complies with, and for each diet provide a brief description of why it is compliant. If it does not comply with any specific diet, state that.

    5. Harmful Ingredients: Identify and list any harmful or controversial ingredients present, such as trans fats, artificial sweeteners, artificial preservatives, etc.

    6. Rating: Provide a rating for how healthy the product is based on all the analyzed factors (positive and negative impacts, ingredients, nutrients and other headings in product information). The rating should be on a scale of 1 to 5 (1 being unhealthy, 5 being very healthy).

    7. Recommendations for Healthier Alternatives: Suggest 3 healthier alternative products from the same category (e.g., healthier versions of the same type of snack, beverage, etc.) For alternatives, make sure you are recommending packaged food and not home made food alternatives. Also keep in mind to recommend only those alternatives which are available in Indian Markets.

    8. Portion Size: Based on the product's QUANTITY and type, give a **common portion size** in grams along with a **reference in terms of portion** (e.g., for a 400g bread, the common portion size would be 50g, which means 2 slices of bread or for a 250g cereal, common portion size would be 30g, which means 1 bowl). The reference should be in easily understandable terms like "2 biscuits," "1 handful of namkeen," "1 slice of bread," etc.
    
    The response should only contain the following JSON format:

    {
      
      "positive": [<list of positive impacts>],  // Example: ['High Protein', 'Low Fat']
      "negative": [<list of negative impacts>],  // Example: ['High sugar', 'Low Fiber']
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

Future<String> dataPreprocessing(String barcode, String frontText,
    String ingredients, String nutritionalValue) async {
  final String prompt = '''
  You will be given information scanned from a packaged product. 
  This information will include:
  1. Barcode: The barcode of the product
  2. FrontText: The scanned text from the front of the product
  3. Ingredients: The scanned text which includes ingredients
  4. NutritionalValue: The scanned text which includes nutritional values
  
  Your task is Extract the product's name, category, list of ingredients, and nutritional values, and format them in JSON. The structure must follow this format strictly:
  
  {
    "productName": <product name>,  // Example: "Kissan Tomato Ketchup"
    "productBarcode": <barcode>,  // Example: "82893849"
    "productCategory": <product category>,  // Example: "Beverage", "Dairy Product", "Chocolate"
    "ingredients": [<list of all valid ingredients>],  // Example: ["Water", "Tomato", "Sugar", ...],
    "nutritionalValue": [
      {
        "nutrient_name": <valuesPer100g>,  // where name = "nutrient name" & valuesPer100g = "decimal value of nutrient per 100g"  Example: "energy-kcal" : 223, 
      }
    ]
  }
  
    Guidelines:
    1. Product Name: Extract from FrontText. Remove promotional slogans or non-essential details.
    2. Product Category: Classify the product based on the FrontText or ingredients list. For example, categories might include "Beverage," "Dairy Product," "Snack," etc.
    3. Ingredients: Extract all valid ingredients from the Ingredients text, separating each item. Exclude non-ingredient text.
    4. Nutritional Values: From NutritionalValue, extract nutrient names and their corresponding values per 100g. Map the data to specific nutrient names as follows:
        - "Total Sugars" → "sugars"
        - "Total Fat" → "fat"
        - "Energy" → "energy-kcal"
        - "Proteins" → "proteins"
        - Add other nutrients similarly if listed.
    
  The product information is as follows:
  Barcode: $barcode
  FrontText: $frontText
  Ingredients: $ingredients
  NutritionalValue: $nutritionalValue
  ''';

  final response = await getResponse(prompt);
  return response ?? "";
}

Future<String> identifyProductName(String extractedText) async {
  final String prompt = '''
    You are given text extracted through OCR. Your task is to identify the name of any packaged food product from the given text. Strictly return the name of a packaged food product only. Do not include clothing, electronics, or any non-food items in your response. If no food product is identified, return "None". Ensure the response contains only the name of the food product without additional words or irrelevant details. If more than one packaged food items are identified then return "Multiple".
    
    Extracted Text: $extractedText
    ''';
  final response = await getResponse(prompt);
  return response ?? "";
}
