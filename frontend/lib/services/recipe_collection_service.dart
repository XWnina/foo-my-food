import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeCollectionService {
  final String baseApiUrl;

  RecipeCollectionService({required this.baseApiUrl});

  Future<void> addFavorite(
      String userId, String? recipeId, String? presetRecipeId) async {
    print(userId);
    print(recipeId);
    print(presetRecipeId);
    final url = Uri.parse('$baseApiUrl/my-recipe-collection/add');
    final body = jsonEncode({
      'user_id': userId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (presetRecipeId != null) 'preset_recipe_id': presetRecipeId,
    });

    print('Sending POST request to $url');
    print('Request body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to add to favorites');
      }
    } catch (e) {
      print('Error in addFavorite: $e');
    }
  }

  Future<void> removeFavorite(
      String userId, String? recipeId, String? presetRecipeId) async {
    final url = Uri.parse('$baseApiUrl/my-recipe-collection/remove');
    final body = jsonEncode({
      'user_id': userId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (presetRecipeId != null) 'preset_recipe_id': presetRecipeId,
    });

    print('Sending POST request to $url');
    print('Request body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode != 200) {
        throw Exception('Failed to remove from favorites');
      }
    } catch (e) {
      print('Error in removeFavorite: $e');
    }
  }

  Future<List<dynamic>> getUserFavorites(String userId) async {
    final url = Uri.parse('$baseApiUrl/my-recipe-collection/user/$userId');
    print('Sending GET request to $url');

    try {
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      print('Error in getUserFavorites: $e');
      return [];
    }
  }
}
