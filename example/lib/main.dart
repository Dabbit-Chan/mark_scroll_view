import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:mark_scroll_view/mark_scroll_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Mask Scroll View'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // 数据
  List<String> dataList = [];
  Map<String, List<String>> showMap = {};
  List<MarkScrollModel> modelList = [];

  @override
  void initState() {
    super.initState();
    addWords();
  }

  void decAdd(String value) {
    if (dataList.contains(value)) {
      String newValue = all[Random().nextInt(all.length - 1)];
      decAdd(newValue);
    } else {
      dataList.add(value.toLowerCase());
    }
  }

  void addWords() {
    dataList.clear();
    showMap.clear();
    modelList.clear();
    for (int i = 0; i < 50; i++) {
      String value = all[Random().nextInt(all.length - 1)];
      decAdd(value);
    }
    handleList();
  }

  void handleList() {
    dataList.sort((a, b) => a.compareTo(b));
    for (String value in dataList) {
      if (showMap.keys.contains(value[0])) {
        showMap[value[0]]!.add(value);
      } else {
        showMap[value[0]] = [value];
      }
    }

    showMap.forEach((key, value) {
      MarkScrollModel model = MarkScrollModel(tag: key, children: value);
      modelList.add(model);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
      ),
      body: MarkScrollView(
        dataList: modelList,
        susBuilder: (context, index) {
          return Container(
            color: Theme.of(context).primaryColorLight,
            padding: const EdgeInsets.all(12),
            child: Text(
              modelList[index].tag.toUpperCase(),
            ),
          );
        },
        itemBuilder: (context, mainIndex, index) {
          String text = modelList[mainIndex].children[index];
          text = '${text[0].toUpperCase()}${text.substring(1)}';
          return Container(
            height: 60,
            padding: const EdgeInsets.only(left: 12),
            alignment: Alignment.centerLeft,
            color: Theme.of(context).secondaryHeaderColor,
            child: Text(text),
          );
        },
        markBuilder: (context, index) {
          return Text(
            modelList[index].tag.toUpperCase(),
          );
        },
        markBarOption: const MarkBarOption(
          defaultColor: Colors.white,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            addWords();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
