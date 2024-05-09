import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:grocify/providers/grocery_provider.dart';
import 'package:grocify/widgets/new_item.dart';

class GrocriesMain extends ConsumerStatefulWidget {
  const GrocriesMain({super.key});

  @override
  ConsumerState<GrocriesMain> createState() => _GrocriesMainState();
}

class _GrocriesMainState extends ConsumerState<GrocriesMain> {
  bool _isLoading = true;
  bool _connectionError = false;
  bool _isItemRestored = false;

  @override
  void initState() {
    super.initState();
    try {
      loadData();
    } catch (erro) {
      print('error ........................' + erro.toString());
    }
  }

  void loadData() async {
    final Response response =
        await ref.read(grocery_provider.notifier).fetchData();
    setState(() {
      _isLoading = false;
      if (response.statusCode != 200) _connectionError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext ctx = context;
    final items = ref.watch(grocery_provider);
    final items_notifier = ref.watch(grocery_provider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Items'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return const NewItem();
                },
              ));
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            maxLines: 1,
                            _connectionError
                                ? 'Something\'s worng...'
                                : ' ...Nothing here! ',
                            style: TextStyle(fontSize: 34),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(_connectionError
                            ? 'be sure your internet is working!'
                            : 'try to add some grocries!')
                      ],
                    ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final grocery = items[index];
                return Dismissible(
                  direction: DismissDirection.endToStart,
                  key: ObjectKey(grocery),
                  onDismissed: (direction) {
                    int index = items_notifier.removeItemLocally(grocery);

                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                          SnackBar(
                            duration: Duration(seconds: 2),
                            content: const Text('item is being removed...'),
                            action: SnackBarAction(
                                label: 'Undo',
                                textColor: Colors.amber,
                                onPressed: () {
                                  _isItemRestored = true;
                                  items_notifier.undoDelItem(grocery, index);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('item restored successfully...'),
                                    ),
                                  );
                                }),
                          ),
                        )
                        .closed
                        .then((value) async {
                      if (_isItemRestored) {
                        _isItemRestored = false;
                        return;
                      }

                      final response =
                          await items_notifier.removeItemFromDatabase(
                        grocery,
                        index,
                      );

                      if (response.statusCode != 200) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('something went wrong...'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content:
                                Text('item has been removed successfully...'),
                          ),
                        );
                      }
                    });
                  },
                  child: ListTile(
                    leading: Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: grocery.category.color,
                      ),
                    ),
                    title: Text(grocery.name),
                    trailing: Text(grocery.quantity.toString()),
                  ),
                );
              },
            ),
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   _animatedList.currentState!.insertItem(3);
      // }),
    );
  }
}
