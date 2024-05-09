import 'dart:convert';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grocify/data/categories.dart';
import 'package:grocify/models/category_model.dart';
import 'package:grocify/models/grocery_model.dart';

class ItemsChangeNotify extends StateNotifier<List<GroceryItem>> {
  ItemsChangeNotify() : super([]);
  final url =
      Uri.https('your-firebase-realtime-database-link', 'shopping-list.json');

  fetchData() async {
    final List<GroceryItem> items = [];
    final Response response = await http.get(url);

    if (response.statusCode == 200 && response.body != 'null') {
      final Map<String, dynamic> fetched_data = json.decode(response.body);
      fetched_data.forEach((key, value) {
        final GroceryItem item = GroceryItem(
          id: key,
          name: value['name'],
          quantity: value['quantity'],
          category: categories.values
              .firstWhere((element) => element.name == value['category']),
        );
        items.add(item);
      });
      state = items;
    }

    return response;
  }

  addItem(var name, var amount, Category category) async {
    Response response = await http.post(
      url,
      headers: {'Content-type': 'application/json'},
      body: json.encode({
        'name': name,
        'quantity': amount,
        'category': category.name,
      }),
    );
    if (response.statusCode == 200) {
      final item = GroceryItem(
        id: json.decode(response.body)['name'],
        name: name,
        quantity: amount,
        category: category,
      );
      state = [...state, item];
    }

    return response;
  }

  int removeItemLocally(GroceryItem item) {
    int index = state.indexOf(item);
    state = state.where((element) => element != item).toList();
    return index;
  }

  void undoDelItem(GroceryItem item, int index) {
    final List<GroceryItem> newList = List.from(state);
    newList.insert(index, item);
    state = newList;
  }

  removeItemFromDatabase(GroceryItem item, int index) async {
    final url_delete = Uri.https('your-firebase-realtime-database-link',
        'shopping-list/${item.id}.json');
    Response response = await http.delete(url_delete);
    if (response.statusCode != 200) {
      final List<GroceryItem> newList = List.from(state);
      newList.insert(index, item);
      state = newList;
    }
    return response;
  }

  void cleanItems() {
    state = [];
  }
}

final grocery_provider =
    StateNotifierProvider<ItemsChangeNotify, List<GroceryItem>>((ref) {
  return ItemsChangeNotify();
});
