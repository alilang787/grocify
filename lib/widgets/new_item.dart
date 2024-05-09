import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:grocify/data/categories.dart';
import 'package:grocify/models/category_model.dart';
import 'package:grocify/providers/grocery_provider.dart';

class NewItem extends ConsumerStatefulWidget {
  const NewItem({super.key});

  @override
  ConsumerState<NewItem> createState() => _NewItemState();
}

class _NewItemState extends ConsumerState<NewItem> {
  bool _isSeding = false;
  var grocery_name;
  var grocery_amount;
  var grocery_category_init = categories[Categories.vegetables];
  var grocery_category = categories[Categories.vegetables];

  final _formKey = GlobalKey<FormState>();

  void addItem(BuildContext context) async {
    final items = ref.watch(grocery_provider.notifier);
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSeding = true;
      });
      Response response =
          await items.addItem(grocery_name, grocery_amount, grocery_category!);

      if (response.statusCode == 200) {
        _formKey.currentState!.reset();
        setState(() {
          _isSeding = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('new entery has been saved successfully... '),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog.adaptive(
              title: Text('Someting went wrong...'),
              content: Text('be sure your internet is working!'),
              actions: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        _isSeding = false;
                      });
                      return Navigator.pop(context);
                    },
                    child: Text('Okey'))
              ],
            );
          },
        );
      }

      // print('Response status: ${response.statusCode}');
      // print('Response body: ${response.body}');
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('please enter valid input....'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 22),
              TextFormField(
                onSaved: (newValue) {
                  grocery_name = newValue;
                },
                maxLength: 45,
                decoration: const InputDecoration(
                  labelText: 'Grocery Name',
                  helperText: 'Enter grocery name here',
                  helperStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      value.isEmpty ||
                      value.trim().length < 3) return 'invalid input';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextFormField(
                        onSaved: (newValue) {
                          grocery_amount = int.parse(newValue!);
                        },
                        maxLength: 8,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          helperText: 'Enter quantity here ',
                          helperStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! < 1) return 'invalid amount';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                  Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: DropdownButtonFormField(
                        onTap: () => FocusScope.of(context).unfocus(),
                        onSaved: (newValue) {
                          grocery_category = newValue;
                        },
                        value: grocery_category,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                              value: category.value,
                              child: FittedBox(
                                child: Row(
                                  children: [
                                    Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: category.value.color,
                                          shape: BoxShape.circle,
                                        )),
                                    const SizedBox(width: 8),
                                    FittedBox(
                                      child: Text(
                                        category.value.name,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        ],
                        onChanged: (value) {},
                        decoration: const InputDecoration(
                          helperText: 'select categoy according to',
                          helperStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSeding
                        ? null
                        : () {
                            FocusScope.of(context).unfocus();
                            setState(() {
                              grocery_category = grocery_category_init;
                            });
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isSeding ? null : () => addItem(context),
                    child: _isSeding
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
