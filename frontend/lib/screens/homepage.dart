import 'package:flutter/material.dart';
import 'package:foo_my_food_app/providers/shopping_list_provider.dart';
import 'package:foo_my_food_app/screens/personal_main_page.dart';
import 'package:foo_my_food_app/screens/shopping_list_page.dart';
import 'package:foo_my_food_app/screens/add_shopping_item_page.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foo_my_food_app/models/ingredient.dart';
import 'ingredient_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foo_my_food_app/utils/constants.dart';
import 'login_page.dart';
import 'add_ingredient_manually.dart';
import 'user_info_page.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/providers/ingredient_provider.dart';
import 'recipepage.dart';
import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String userId = '';
  List<String> categories = [
    'Vegetables',
    'Fruits',
    'Meat',
    'Dairy',
    'Grains',
    'Spices',
    'Beverages'
  ];
  List<String> selectedCategories = [];
  String? selectedCategory;

  Future<void> _deleteIngredientsBatch(
      BuildContext context, String userId, List<Ingredient> ingredients) async {
    for (var ingredient in ingredients) {
      final response = await http.delete(
        Uri.parse(
            '$baseApiUrl/user_ingredients/$userId/${ingredient.ingredientId}'),
      );
      if (response.statusCode == 204) {
        Provider.of<IngredientProvider>(context, listen: false)
            .removeIngredient_F(ingredient); // 使用对象删除
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete ${ingredient.name}')),
        );
      }
    }

    _fetchUserIngredients(); // 刷新列表
    setState(() {});
  }

  late List<Widget> _pages;

  late GlobalKey<UserMainPageState> userMainPageKey;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    userMainPageKey =
        GlobalKey<UserMainPageState>(); // 设置 GlobalKey 类型为 UserMainPageState

    _pages = [
      MyFoodPage(fetchUserIngredientsCallback: _fetchUserIngredients),
      RecipePage(),
      const ShoppingListPage(),
      UserMainPage(key: userMainPageKey), // 传递 GlobalKey
    ];
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUserId = prefs.getString('userId');
    if (savedUserId != null) {
      setState(() {
        userId = savedUserId;
      });
      _fetchUserIngredients();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

// 获取提醒天数
  Future<int?> _getUserIngredientTrackingDays() async {
    final url = '$baseApiUrl/user/$userId/ingredient-tracking-days';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['ingredientTrackingDays'];
    } else {
      print("Failed to load ingredient tracking days");
      return null; // 无法获取时返回 null
    }
  }

// 主方法 - 获取食材并筛选过期提醒
  Future<void> _fetchUserIngredients() async {
    try {
      final response =
          await http.get(Uri.parse('$baseApiUrl/user_ingredients/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> userIngredientsData = json.decode(response.body);
        List<Ingredient> ingredients = [];
        List<Ingredient> expiringSoonIngredients = [];

        // 获取用户的 ingredientTrackingDays，如果未设置则默认使用3天
        int? ingredientTrackingDays = await _getUserIngredientTrackingDays();
        int trackingDays;
        if (ingredientTrackingDays != null) {
          trackingDays = ingredientTrackingDays - 1; // 如果设置了提醒天数，则使用该值减去 1
        } else {
          trackingDays = 2; // 如果未设置提醒天数，则使用默认值 2
        }

        for (var item in userIngredientsData) {
          int? ingredientId = item['ingredientId'];
          if (ingredientId == null) continue;

          final ingredientResponse = await http
              .get(Uri.parse('$baseApiUrl/ingredients/$ingredientId'));
          if (ingredientResponse.statusCode == 200) {
            final ingredientData = json.decode(ingredientResponse.body);
            Ingredient ingredient = Ingredient.fromJson(ingredientData);
            ingredients.add(ingredient);

            DateTime expirationDate = DateTime.parse(ingredient.expirationDate);

            // 检查是否在提醒范围内（小于 trackingDays）
            if (expirationDate.difference(DateTime.now()).inDays <
                trackingDays) {
              expiringSoonIngredients.add(ingredient);
            }
          }
        }

        setState(() {});

        final ingredientProvider =
            Provider.of<IngredientProvider>(context, listen: false);
        ingredientProvider.ingredients = ingredients;

        // 显示过期提醒
        if (expiringSoonIngredients.isNotEmpty) {
          _showExpirationAlert(expiringSoonIngredients);
        }
      } else {
        throw Exception('Failed to load user ingredients');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _showExpirationAlert(
      List<Ingredient> expiringIngredients) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alert!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: expiringIngredients.map((ingredient) {
              return Text(
                  '${ingredient.name} expires on ${ingredient.expirationDate}');
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text('Okay, I know now.'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteIngredientsBatch(
                    context, userId, expiringIngredients);
                Navigator.of(context).pop(); // 确保弹窗只关闭一次
                setState(() {});
              },
              child: const Text('Cleaned up already.'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToAddIngredient() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddIngredientPage()),
    ).then((_) {
      _fetchUserIngredients();
    });
  }

  // 导航到添加购物清单页面
  void _navigateToAddShoppingItem() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 设置圆角弧度
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context), // 设置背景颜色
            borderRadius: BorderRadius.circular(15), // 保持圆角一致
          ),
          child: const AddShoppingItemPage(), // 子页面
        ),
      ),
    ).then((newItem) {
      if (newItem != null) {
        print("New shopping item added: $newItem");
        // 刷新购物清单
        Provider.of<ShoppingListProvider>(context, listen: false).fetchItems();
      }
    });
  }

  // 页面切换函数
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 3) {
      final userMainPageState = userMainPageKey.currentState;
      if (userMainPageState != null) {
        userMainPageState.loadFavorites();
      }
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category); // 移除已选中的分类
      } else {
        selectedCategories.add(category); // 添加新选择的分类
      }
    });
    Provider.of<IngredientProvider>(context, listen: false).selectedCategories =
        selectedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Text(widget.title,
                  style: TextStyle(color: AppColors.textColor(context))),
              backgroundColor: AppColors.appBarColor(context),
            )
          : null,
      body: Column(
        children: [
          if (_selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // 将内容放置到右侧
                children: [
                  PopupMenuButton<String>(
                    tooltip: 'Filter Categories',
                    onSelected: (String category) {
                      _onCategorySelected(category); // 点击时更新选中状态
                    },
                    itemBuilder: (BuildContext context) {
                      return categories.map((String category) {
                        return PopupMenuItem<String>(
                          value: category,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return ListTile(
                                title: Text(category),
                                leading: Checkbox(
                                  value: selectedCategories.contains(category),
                                  onChanged: (bool? isSelected) {
                                    setState(() {
                                      _onCategorySelected(category); // 更新勾选状态
                                    });
                                  },
                                ),
                                onTap: () {
                                  setState(() {
                                    _onCategorySelected(category); // 点击项也更新勾选状态
                                  });
                                },
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Filter Categories', // 使用文字作为按钮
                          style: TextStyle(
                            color:
                                AppColors.cardNameTextColor(context), // 设置文字颜色
                            fontSize: 16, // 设置文字大小
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down, // 倒三角图标
                          color: Colors.black, // 设置图标颜色
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8), // 按钮和选中类别的间距
                  Expanded(
                    child: Text(
                      selectedCategories.isNotEmpty
                          ? selectedCategories.join(', ') // 显示选中类别
                          : 'All categories of food ', // 如果没有选中类别
                      style: TextStyle(
                        color: AppColors.cardNameTextColor(context),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis, // 处理过长的文字
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      floatingActionButton: (_selectedIndex == 0 || _selectedIndex == 2)
          ? FloatingActionButton(
              heroTag: "Add",
              onPressed: () {
                if (_selectedIndex == 0) {
                  _navigateToAddIngredient();
                } else if (_selectedIndex == 2) {
                  _navigateToAddShoppingItem();
                }
              },
              backgroundColor: AppColors.appBarColor(context),
              tooltip: 'Add Item',
              child: _selectedIndex == 2
                  ? const Icon(Icons.shopping_cart_checkout_outlined,
                      color: whiteTextColor)
                  : const Icon(Icons.add, color: whiteTextColor),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank_outlined),
            label: 'My Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_rounded),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Shopping List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.textColor(context),
        onTap: _onItemTapped,
        backgroundColor: AppColors.appBarColor(context),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class MyFoodPage extends StatefulWidget {
  final Future<void> Function() fetchUserIngredientsCallback;
  MyFoodPage({required this.fetchUserIngredientsCallback});
  @override
  _MyFoodPageState createState() => _MyFoodPageState();
}

class _MyFoodPageState extends State<MyFoodPage> {
  bool _sortByExpirationDate = false;
  bool _showExpiringIn7Days = false;
  List<Ingredient> _ingredients = [];
  late IngredientProvider ingredientProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ingredientProvider =
          Provider.of<IngredientProvider>(context, listen: false);
      ingredientProvider.addListener(_updateIngredients);
    });
  }

  @override
  void dispose() {
    ingredientProvider.removeListener(_updateIngredients);
    super.dispose();
  }

  void _updateIngredients() {
    if (!mounted) return;
    setState(() {
      _ingredients = List.from(ingredientProvider.ingredients);
      _sortIngredients();
    });
  }

  void _sortIngredients() {
    if (_sortByExpirationDate) {
      _ingredients.sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    } else {
      _ingredients.sort((a, b) => a.ingredientId.compareTo(b.ingredientId));
    }
    // 在此处应用筛选
    if (ingredientProvider.selectedCategories.isNotEmpty) {
      _ingredients = _ingredients
          .where((ingredient) => ingredientProvider.selectedCategories
              .contains(ingredient.category))
          .toList();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 确保 `ingredientProvider` 仅初始化一次
    ingredientProvider =
        Provider.of<IngredientProvider>(context, listen: false);
    ingredientProvider.addListener(_updateIngredients);
    _updateIngredients(); // 初始化时更新食材数据
  }

  void _navigateToFoodItemDetail(
      Ingredient ingredient, String userId, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodItemDetailPage(
          ingredient: ingredient,
          userId: userId,
          index: index,
          onUpdate: (updatedIngredient) async {
            // Update the ingredient in the provider
            Provider.of<IngredientProvider>(context, listen: false)
                .updateIngredient(index, updatedIngredient);
            // Refresh the ingredients list
            await widget.fetchUserIngredientsCallback();
          },
        ),
      ),
    );
  }

  Future<void> _deleteIngredient(
      BuildContext context, String userId, int ingredientId, int index) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseApiUrl/user_ingredients/$userId/$ingredientId'),
      );
      if (response.statusCode == 204) {
        Provider.of<IngredientProvider>(context, listen: false)
            .removeIngredient(index);

        // 删除成功后更新视图
        await widget.fetchUserIngredientsCallback();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );
      } else {
        throw Exception('Failed to delete ingredient');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting ingredient: $e')),
      );
    }
  }

  bool _isWithinSevenDays(String dateString) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expirationDate = DateTime.parse(dateString);
    final expirationDateOnly =
        DateTime(expirationDate.year, expirationDate.month, expirationDate.day);
    final difference = expirationDateOnly.difference(today).inDays;
    return difference >= 0 && difference <= 7;
  }

  @override
  Widget build(BuildContext context) {
    // highlight-start
    List<Ingredient> filteredIngredients = _ingredients;
    // highlight-end

    // Filter by categories
    if (ingredientProvider.selectedCategories.isNotEmpty) {
      filteredIngredients = filteredIngredients
          .where((ingredient) => ingredientProvider.selectedCategories
              .contains(ingredient.category))
          .toList();
    }

    // Filter ingredients expiring in 7 days if enabled
    if (_showExpiringIn7Days) {
      filteredIngredients = filteredIngredients
          .where((ingredient) => _isWithinSevenDays(ingredient.expirationDate))
          .toList();
    }

    return _ingredients.isEmpty
        ? const Center(
            child: Text(
              'Your food is empty',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Column(
            children: [
              // Add buttons for sorting and filtering
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sortByExpirationDate = !_sortByExpirationDate;
                        _sortIngredients();
                      });
                    },
                    child: Text(
                      _sortByExpirationDate ? 'Unsort' : 'Sort by Expiration',
                      style: TextStyle(color: AppColors.textColor(context)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showExpiringIn7Days = !_showExpiringIn7Days;
                      });
                    },
                    child: Text(
                        _showExpiringIn7Days
                            ? 'Show All'
                            : 'Expiring in 7 Days',
                        style: TextStyle(color: AppColors.textColor(context))),
                  ),
                ],
              ),
              Expanded(
                child: filteredIngredients.isEmpty
                    ? const Center(
                        child: Text(
                          "No matching ingredients found",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1,
                        ),
                        itemCount: filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = filteredIngredients[index];
                          return GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              String userId = prefs.getString('userId') ?? '';
                              _navigateToFoodItemDetail(
                                  ingredient, userId, index);
                            },
                            child: Card(
                              margin: const EdgeInsets.all(8.0),
                              color: AppColors.cardColor(context),
                              child: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (ingredient.imageURL.isNotEmpty)
                                          CircleAvatar(
                                            backgroundColor:
                                                greyBackgroundColor,
                                            backgroundImage: NetworkImage(
                                                ingredient.imageURL),
                                            radius: 40,
                                          ),
                                        const SizedBox(height: 10),
                                        Text(
                                          ingredient.name,
                                          style: TextStyle(
                                            color: AppColors.cardNameTextColor(
                                                context),
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Expires: ${ingredient.expirationDate}',
                                          style: TextStyle(
                                              color: AppColors
                                                  .cardExpiresTextColor(
                                                      context)),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'Category: ${ingredient.category}',
                                          style: TextStyle(
                                              color: AppColors
                                                  .cardExpiresTextColor(
                                                      context)),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                          Icons.delete_forever_rounded,
                                          color: Colors.red),
                                      onPressed: () async {
                                        bool confirmDelete = await showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete this ingredient?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(false),
                                                ),
                                                TextButton(
                                                  child: const Text('Delete'),
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirmDelete) {
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          String userId =
                                              prefs.getString('userId') ?? '';
                                          _deleteIngredient(context, userId,
                                              ingredient.ingredientId, index);
                                        }
                                      },
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
          );
  }
}
