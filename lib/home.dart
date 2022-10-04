import 'package:flutter/material.dart';
import 'package:stack_pageview/stackPageView/stackPageViewInterface.dart';

import 'pageItem/pageItem.dart';
import 'stackPageView/stackPageView.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabLabels = ["탭 A", "탭 B", "탭 C"];

  List<ScrollController> scrollControllers = [];

  @override
  void initState() {
    _tabController = TabController(
        length: _tabLabels.length,
        vsync: this,
        animationDuration: Duration(milliseconds: 200));
    for (var o in _tabLabels) {
      scrollControllers.add(ScrollController());
    }
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (int i = 0; i < _tabLabels.length; i++) {
      scrollControllers[i].dispose();
    }
    super.dispose();
  }

  StackPageViewInterface? interface;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: StackPageView(
              header: _header(),
              headerHeight: 150,
              tabBar: _tabBar(),
              tabController: _tabController,
              scrollControllers: scrollControllers,
              interface: (interface) {
                this.interface = interface;
              },
              tabBarViews: [
                PageItem(
                  text: "탭 A",
                  scrollController: scrollControllers[0],
                ),
                PageItem(
                  text: "탭 B",
                  scrollController: scrollControllers[1],
                ),
                PageItem(
                  text: "탭 C",
                  scrollController: scrollControllers[2],
                ),
              ],
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    if (interface == null) return;
                    interface!.goTop();
                  },
                  child: const Text("Go top")),
              ElevatedButton(
                  onPressed: () {
                    if (interface == null) return;
                    interface!.goBottom();
                  },
                  child: const Text("Go bottom")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      color: Colors.blue,
      height: 150,
      child: const Center(
        child: Text(
          "Header",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }

  TabBar _tabBar() {
    return TabBar(
      controller: _tabController,
      indicatorColor: Colors.black,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      tabs: List.generate(_tabLabels.length, (index) {
        return SizedBox(
            height: 45, child: Center(child: Text(_tabLabels[index])));
      }),
    );
  }
}