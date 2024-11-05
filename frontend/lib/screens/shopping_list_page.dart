import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // 使用 addPostFrameCallback 确保在 widget 树构建完成后再调用
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShoppingListProvider>(context, listen: false).initializeShoppingList();
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

  Future<void> _editItem(BuildContext context, Map<String, dynamic> item) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: EditShoppingItemPage(item: item),
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Shopping List', style: TextStyle(color: Colors.white)),
        backgroundColor: appBarColor,
      ),
      body: Consumer<ShoppingListProvider>(
        builder: (context, provider, child) {
          // 将购物清单划分为未购买和已购买
          final unpurchasedItems = provider.shoppingList
              .where((item) => !item['isPurchased'])
              .toList();
          final purchasedItems = provider.shoppingList
              .where((item) => item['isPurchased'])
              .toList();

          if (provider.shoppingList.isEmpty) {
            return const Center(
              child: Text(
                'Your shopping list is empty!',
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
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Items to Purchase',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: unpurchasedItems.length,
                  itemBuilder: (context, index) {
                    final item = unpurchasedItems[index];
                    return _buildShoppingListItem(context, item, provider);
                  },
                ),
              ],
              if (purchasedItems.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Purchased Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildShoppingListItem(BuildContext context, Map<String, dynamic> item,
      ShoppingListProvider provider,
      {bool isPurchasedSection = false}) {
    return Card(
      color: card,
      child: ListTile(
        title: Text(
          item['name'],
          style: const TextStyle(color: cardnametext),
        ),
        subtitle: Text(
          'Quantity: ${item['baseQuantity']} ${item['unit']}',
          style: const TextStyle(color: cardexpirestext),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isPurchasedSection ? Icons.undo : Icons.check,
                color: isPurchasedSection ? Colors.blue : blackTextColor,
              ),
              onPressed: () {
                if (isPurchasedSection) {
                  // 将已购买的项目重新标记为未购买
                  provider.togglePurchasedStatus(item['foodId'],
                      isPurchased: false);
                } else {
                  // 将未购买的项目标记为已购买
                  provider.togglePurchasedStatus(item['foodId'],
                      isPurchased: true);
                }
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
                // Show confirmation dialog before deleting
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
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.deleteItem(
                                item['foodId']); // Proceed with deletion
                            Navigator.of(context)
                                .pop(); // Close the dialog after deletion
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
