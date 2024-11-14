import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 导入 Provider
import 'package:foo_my_food_app/models/collection_item.dart';
import 'package:foo_my_food_app/screens/settings_page.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:foo_my_food_app/services/recipe_collection_service.dart';
import 'package:http/http.dart' as http;

class UserMainPage extends StatefulWidget {
  @override
  _UserMainPageState createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  String? _username = 'Username';
  String? _avatarUrl;
  List<CollectionItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadFavorites();
  }

  // 从后端加载用户数据
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    final url = '$baseApiUrl/user/$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        if (userData.isNotEmpty) {
          setState(() {
            _username = userData["userName"] ?? 'Unknown User';
            _avatarUrl = userData["imageURL"];
          });
        } else {
          throw Exception('User data is empty.');
        }
      } else {
        throw Exception(
            'Failed to retrieve user data, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load user data')),
      );
    }
  }

  // 从后端加载收藏数据
  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    final recipeCollectionService = RecipeCollectionService();
    try {
      final favorites =
          await recipeCollectionService.getUserFavoritesAll(userId);
      setState(() {
        _favorites = favorites;
      });
      print("Loaded favorites: $_favorites");
    } catch (e) {
      print('Error loading favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Main Page',
          style: TextStyle(color: AppColors.textColor(context)),
        ),
        backgroundColor: AppColors.appBarColor(context),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: AppColors.textColor(context)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            tooltip: 'Setting',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.25,
            color: AppColors.appBarColor(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                  child: _avatarUrl == null
                      ? Icon(Icons.person,
                          size: 50, color: Colors.grey.shade700)
                      : null,
                ),
                const SizedBox(height: 10),
                Text(
                  _username ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: const Center(
              child: Text("Collections",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 9,
                childAspectRatio: 0.85,
              ),
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final item = _favorites[index];
                return Card(
                  color: AppColors.cardColor(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Display image or placeholder
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                height: 116,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 116,
                                color: Colors.grey,
                                child: Icon(Icons.image, color: Colors.white),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(
                                color: AppColors.cardNameTextColor(context),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Calories: ${item.calories} kcal",
                              style: TextStyle(
                                color: AppColors.cardExpiresTextColor(context),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              alignment: WrapAlignment.center,
                              children: item.tags.isNotEmpty
                                  ? item.tags.map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.lablebackground(
                                              context),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          tag,
                                          style: TextStyle(
                                            color:
                                                AppColors.cardExpiresTextColor(
                                                    context),
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  : [
                                      const Text(
                                        "No labels",
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
