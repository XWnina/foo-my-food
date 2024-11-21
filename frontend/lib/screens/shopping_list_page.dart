import 'package:flutter/material.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart';
import 'package:provider/provider.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/providers/shopping_list_provider.dart';
import 'add_shopping_item_page.dart';
import 'edit_shopping_item_page.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  _ShoppingListPageState createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final Set<String> _selectedCategories = {};
  String _searchQuery = "";
  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保在 widget 树构建完成后再调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingListProvider>(context, listen: false)
          .initializeShoppingList();
    });
  }

  void _navigateToAddShoppingItem() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const AddShoppingItemPage(),
      ),
    ).then((newItem) {
      if (newItem != null) {
        Provider.of<ShoppingListProvider>(context, listen: false).fetchItems();
      }
    });
  }

  Future<void> _editItem(
      BuildContext context, Map<String, dynamic> item) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // 设置圆角
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context), // 设置背景颜色
            borderRadius: BorderRadius.circular(15), // 确保圆角一致
          ),
          child: EditShoppingItemPage(item: item),
        ),
      ),
    ).then((updatedItem) {
      if (updatedItem != null) {
        Provider.of<ShoppingListProvider>(context, listen: false).fetchItems();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text(
          'Shopping List',
          style: TextStyle(color: AppColors.textColor(context)),
        ),
        backgroundColor: AppColors.appBarColor(context),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: AppColors.textColor(context)),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  enabled: false,
                  child: const Text(
                    'Select Categories:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...categories.map((category) {
                  return PopupMenuItem<String>(
                    value: category,
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(category),
                            Checkbox(
                              value: _selectedCategories.contains(category),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedCategories.add(category);
                                  } else {
                                    _selectedCategories.remove(category);
                                  }
                                });
                                this.setState(() {}); // 刷新界面以应用筛选
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }).toList(),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase(); // 更新搜索关键词
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<ShoppingListProvider>(
              builder: (context, provider, child) {
                // 过滤逻辑：根据搜索关键词和分类过滤项目
                final filteredItems = provider.shoppingList.where((item) {
                  final matchesSearchQuery = _searchQuery.isEmpty ||
                      item['name']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery);
                  final matchesCategory = _selectedCategories.isEmpty ||
                      (_selectedCategories.contains(item['category']));
                  return matchesSearchQuery && matchesCategory;
                }).toList();

                final unpurchasedItems = filteredItems
                    .where((item) => !item['isPurchased'])
                    .toList();
                final purchasedItems =
                    filteredItems.where((item) => item['isPurchased']).toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items match your criteria.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView(
                  children: [
                    if (unpurchasedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Items to Purchase',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cardNameTextColor(context)),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: unpurchasedItems.length,
                        itemBuilder: (context, index) {
                          final item = unpurchasedItems[index];
                          return _buildShoppingListItem(
                              context, item, provider);
                        },
                      ),
                    ],
                    if (purchasedItems.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Purchased Items',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.cardNameTextColor(context)),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: purchasedItems.length,
                        itemBuilder: (context, index) {
                          final item = purchasedItems[index];
                          return _buildShoppingListItem(context, item, provider,
                              isPurchasedSection: true);
                        },
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingListItem(BuildContext context, Map<String, dynamic> item,
      ShoppingListProvider provider,
      {bool isPurchasedSection = false}) {
    return Card(
      color: AppColors.cardColor(context),
      child: ListTile(
        title: Text(
          item['name'],
          style: TextStyle(color: AppColors.cardNameTextColor(context)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantity: ${item['baseQuantity']} ${item['unit']}',
              style: TextStyle(color: AppColors.cardExpiresTextColor(context)),
            ),
            if (item['category'] != null && item['category']!.isNotEmpty)
              Text(
                'Category: ${item['category']}',
                style:
                    TextStyle(color: AppColors.cardExpiresTextColor(context)),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPurchasedSection ? Icons.undo : Icons.check,
                color: isPurchasedSection
                    ? const Color.fromARGB(255, 71, 148, 211)
                    : AppColors.appBarColor(context),
              ),
              onPressed: () {
                provider.togglePurchasedStatus(item['foodId'],
                    isPurchased: !item['isPurchased']);
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _editItem(context, item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text(
                          'Are you sure you want to delete this item?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteItem(item['foodId']);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
