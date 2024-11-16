import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foo_my_food_app/providers/collection_provider.dart';
import 'package:provider/provider.dart'; // 导入 Provider
import 'package:foo_my_food_app/models/collection_item.dart';
import 'package:foo_my_food_app/screens/settings_page.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'package:foo_my_food_app/services/recipe_collection_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({Key? key}) : super(key: key);
  @override
  UserMainPageState createState() => UserMainPageState();
}

class UserMainPageState extends State<UserMainPage> {
  Future<void> loadFavorites() async {
    await _loadFavorites(); // 内部调用加载收藏的方法
  }

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
      // 调用服务获取收藏数据
      final favorites =
          await recipeCollectionService.getUserFavoritesAll(userId);

      // 获取 Provider 并更新收藏
      final favoritesProvider =
          Provider.of<CollectionProvider>(context, listen: false);
      favoritesProvider.setFavorites(favorites); // 更新 Provider 中的数据

      print("Loaded favorites: $favorites");
    } catch (e) {
      print('Error loading favorites: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load favorites')),
      );
    }
  }

  void _showRecipeDetails(BuildContext context, CollectionItem item) async {
    // 确保弹窗前数据最新
    await _loadFavorites();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.cardColor(context),
          title: Text(
            item.name,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.cardNameTextColor(context)),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // 限制对话框宽度
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 显示图片
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                    Image.network(
                      item.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    const Icon(Icons.image, size: 100),
                  const SizedBox(height: 30),

                  // 显示热量
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Calories: ", // 加粗的部分
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.cardNameTextColor(context),
                          ),
                        ),
                        TextSpan(
                          text: "${item.calories} kcal", // 普通字体部分
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.cardExpiresTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 显示配料
                  Text(
                    "Ingredients:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardNameTextColor(context)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.ingredients.join(', '),
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.cardExpiresTextColor(context)),
                  ),
                  const SizedBox(height: 10),

                  // 显示描述
                  Text(
                    "Description:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardNameTextColor(context)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.description.isNotEmpty
                        ? item.description
                        : "No description for this recipe", // 没有描述时显示默认文本
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.cardExpiresTextColor(context)),
                  ),
                  const SizedBox(height: 10),

                  // 显示标签
                  Text(
                    "Labels:",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardNameTextColor(context)),
                  ),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.tags.isNotEmpty
                        ? item.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 6),
                              decoration: BoxDecoration(
                                color: AppColors.lablebackground(context),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag.trim(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppColors.cardExpiresTextColor(context),
                                ),
                              ),
                            );
                          }).toList()
                        : [
                            Text(
                              "No labels",
                              style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      AppColors.cardExpiresTextColor(context)),
                            ),
                          ],
                  ),
                  const SizedBox(height: 10),

                  // 显示视频链接（如果有）
                  if (item.videoLink != null && item.videoLink!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Video Link:",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cardNameTextColor(context)),
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          onTap: () async {
                            final url = Uri.parse(item.videoLink!);

                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Could not launch ${item.videoLink}')),
                              );
                            }
                          },
                          child: Text(
                            item.videoLink!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: AppColors.cardNameTextColor(context)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<CollectionProvider>(context);
    final List<CollectionItem> favorites = favoritesProvider.favorites;
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
            height: MediaQuery.of(context).size.height * 0.2,
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
            child: favorites.isEmpty
                ? Center(
                    child: Text(
                      'No collections yet. Start adding your favorites!',
                      style: TextStyle(
                        color: AppColors.textColor(context),
                        fontSize: 16,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 每行展示 2 个卡片
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 9,
                      childAspectRatio: 0.8, // 调整宽高比例
                    ),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return GestureDetector(
                        onTap: () {
                          _showRecipeDetails(context, item);
                        },
                        child: Card(
                          color: AppColors.cardColor(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: (item.imageUrl != null &&
                                          item.imageUrl!.isNotEmpty)
                                      ? Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image, size: 35),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        color: AppColors.cardNameTextColor(
                                            context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Calories: ${item.calories} kcal",
                                      style: TextStyle(
                                        color: AppColors.cardExpiresTextColor(
                                            context),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: item.tags != null &&
                                              item.tags
                                                  .where((tag) =>
                                                      tag.trim().isNotEmpty)
                                                  .isNotEmpty
                                          ? item.tags
                                              .where((tag) =>
                                                  tag.trim().isNotEmpty)
                                              .map((tag) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2,
                                                        horizontal: 6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.lablebackground(
                                                          context),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  tag.trim(),
                                                  style: TextStyle(
                                                    color: AppColors
                                                        .cardExpiresTextColor(
                                                            context),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            }).toList()
                                          : [
                                              Text(
                                                "No label in this Recipe",
                                                style: TextStyle(
                                                    color: AppColors
                                                        .cardExpiresTextColor(
                                                            context),
                                                    fontSize: 12),
                                              ),
                                            ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
