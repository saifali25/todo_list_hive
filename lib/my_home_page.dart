// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'data_model.dart';

const String dataBoxName = "data";

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// ignore: constant_identifier_names
enum DataFilter { ALL, COMPLETED, PROGRESS }

class _MyHomePageState extends State<MyHomePage> {
  late Box<DataModel> dataBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DataFilter filter = DataFilter.ALL;

  @override
  void initState() {
    super.initState();
    dataBox = Hive.box<DataModel>(dataBoxName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[500],
        title: const Text("TODO Diary"),
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value.compareTo("All") == 0) {
                setState(() {
                  filter = DataFilter.ALL;
                });
              } else if (value.compareTo("Compeleted") == 0) {
                setState(() {
                  filter = DataFilter.COMPLETED;
                });
              } else {
                setState(() {
                  filter = DataFilter.PROGRESS;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return ["All", "Compeleted", "Progress"].map((option) {
                return PopupMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          )
        ],
      ),
      body: RawScrollbar(
        thickness: 5,
        thumbVisibility: true,
        thumbColor: Colors.blueAccent,
        radius: const Radius.circular(15),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: dataBox.listenable(),
                builder: (context, Box<DataModel> items, _) {
                  List<int> keys;

                  if (filter == DataFilter.ALL) {
                    keys = items.keys.cast<int>().toList();
                  } else if (filter == DataFilter.COMPLETED) {
                    keys = items.keys
                        .cast<int>()
                        .where((key) => items.get(key)!.isCompleted)
                        .toList();
                  } else {
                    keys = items.keys
                        .cast<int>()
                        .where((key) => !items.get(key)!.isCompleted)
                        .toList();
                  }

                  return ListView.separated(
                    separatorBuilder: (_, index) => const Divider(),
                    itemCount: keys.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (_, index) {
                      final int key = keys[index];
                      final DataModel? data = items.get(key);
                      return Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          right: 5.0,
                          top: 5.0,
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              data!.title,
                              style: const TextStyle(
                                  fontSize: 22, color: Colors.black),
                            ),
                            subtitle: Text(data.description,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.black38)),
                            leading: Text(
                              "$key",
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                            trailing: Icon(
                              Icons.check,
                              color: data.isCompleted
                                  ? Colors.blue[800]
                                  : Colors.red,
                            ),
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                        backgroundColor: Colors.white,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  DataModel mData = DataModel(
                                                      data.title,
                                                      data.description,
                                                      true);
                                                  dataBox.put(key, mData);
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  width: 140,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                    color:
                                                        Colors.blueAccent[100],
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "Mark as complete",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ));
                                  });
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[500],
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    backgroundColor: Colors.blueGrey[100],
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextField(
                              decoration:
                                  const InputDecoration(hintText: "Title"),
                              controller: titleController,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            TextField(
                              decoration: const InputDecoration(
                                  hintText: "Description"),
                              controller: descriptionController,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            InkWell(
                              onTap: () {
                                final String title = titleController.text;
                                final String description =
                                    descriptionController.text;
                                titleController.clear();
                                descriptionController.clear();
                                DataModel data =
                                    DataModel(title, description, false);
                                dataBox.add(data);
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 80.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.red,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Add Data",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          ]),
                    ));
              });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
