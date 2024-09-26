import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:foo_my_food_app/utils/colors.dart';
import 'package:foo_my_food_app/datasource/temp_db.dart'; // For food categories and storage methods

class AddIngredientPage extends StatefulWidget {
  @override
  _AddIngredientPageState createState() => _AddIngredientPageState();
}

class _AddIngredientPageState extends State<AddIngredientPage> {
  File? _image;
  String? _selectedCategory;
  String? _selectedStorageMethod;
  int _quantity = 1;
  DateTime _expirationDate = DateTime.now();
  String _ingredientName = ''; // Store ingredient name

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // Update image file
      });
    }
  }

  // Function to handle date picker for expiration date
  Future<void> _selectExpirationDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Add food'),
        backgroundColor: appBarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Centered Transparent TextField for Ingredient Name
            Center(
              child: SizedBox(
                width: 300, // Set width of the text field
                child: TextField(
                  textAlign: TextAlign.center, // Center the text inside the field
                  decoration: InputDecoration(
                    hintText: 'Enter Ingredient Name',
                    hintStyle: TextStyle(color: Colors.grey), // Placeholder color
                    filled: true,
                    fillColor: Colors.transparent, // Transparent background
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded border
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.grey, // Border color
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.blue, // Focused border color
                        width: 2.0,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _ingredientName = value; // Capture the entered name
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // Display uploaded image or placeholder
            GestureDetector(
              onTap: _pickImage,
              child: _image != null
                  ? Image.file(_image!,
                      height: 100, width: 100, fit: BoxFit.cover)
                  : Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey[300],
                      child: Icon(Icons.camera_alt),
                    ),
            ),
            SizedBox(height: 16),

            // Dropdown for category
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: foodCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(labelText: 'Category'),
            ),
            SizedBox(height: 16),

            // Dropdown for storage method
            DropdownButtonFormField<String>(
              value: _selectedStorageMethod,
              items: storageMethods.map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStorageMethod = value;
                });
              },
              decoration: InputDecoration(labelText: 'Storage method'),
            ),
            SizedBox(height: 16),

            // Quantity input
            Row(
              children: [
                Text('Quantity:'),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: _quantity,
                  items:
                      List.generate(10, (index) => index + 1).map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _quantity = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),

            // Expiration date picker
            GestureDetector(
              onTap: () => _selectExpirationDate(context),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expiration time: ${_expirationDate.toLocal()}'
                        .split(' ')[0],
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Add button
            ElevatedButton(
              onPressed: () {
                // Display a Snackbar message when the button is pressed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ingredient added successfully!'),
                    duration: Duration(
                        seconds: 2), // You can adjust the display duration
                  ),
                );

                // Code to handle the "Add" button logic, such as saving the data
              },
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
