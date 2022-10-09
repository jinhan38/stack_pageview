import 'package:flutter/material.dart';

class PageItem extends StatefulWidget {
  PageItem({
    required this.text,
    required this.scrollController,
    Key? key,
  }) : super(key: key);
  String text;
  ScrollController scrollController;

  @override
  _PageItemState createState() => _PageItemState();
}

class _PageItemState extends State<PageItem> {
  int itemCount = 30;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      controller: widget.scrollController,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == itemCount - 1) addData();
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: Text("${widget.text} : ${index.toString()}"),
        );
      },
    );
  }

  addData() async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {
      itemCount += 20;
    });
  }
}
