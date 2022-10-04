import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'stackScrollPhysics.dart';
import 'stackNotification.dart';
import 'stackPageViewInterface.dart';

import 'stackListenerWidget.dart';

class StackPageView extends StatefulWidget {
  StackPageView({
    required this.header,
    required this.headerHeight,
    required this.tabBar,
    required this.tabController,
    required this.scrollControllers,
    required this.tabBarViews,
    this.timerPeriodic = 2,
    this.dragY = 16,
    this.animationDuration = const Duration(milliseconds: 100),
    this.interface,
    this.controller,
    this.tabDrag = true,
    Key? key,
  }) : super(key: key);
  Widget header;
  double headerHeight;
  TabBar tabBar;
  TabController tabController;
  List<ScrollController> scrollControllers;
  List<Widget> tabBarViews;
  int timerPeriodic;
  int dragY;
  Duration animationDuration;
  Function(StackPageViewInterface? interface)? interface;
  Function(ScrollController controller)? controller;
  bool tabDrag;

  @override
  _StackPageViewState createState() => _StackPageViewState();
}

class _StackPageViewState extends State<StackPageView>
    with SingleTickerProviderStateMixin {
  StackPageViewInterface? stackPageViewInterface;

  ScrollDirection? scrollDirection;

  Widget get header => widget.header;

  double get headerHeight => widget.headerHeight;

  TabBar get tabBar => widget.tabBar;

  TabController get tabController => widget.tabController;

  List<ScrollController> get scrollControllers => widget.scrollControllers;

  List<Widget> get tabBarViews => widget.tabBarViews;

  int get timerPeriodic => widget.timerPeriodic;

  int get dragY => widget.dragY;

  Duration get animationDuration => widget.animationDuration;

  Function(StackPageViewInterface? interface)? get interface =>
      widget.interface;

  Function(ScrollController controller)? get controller => widget.controller;

  bool get tabDrag => widget.tabDrag;

  double _touchY = 0;

  _initTouchY() => _touchY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StackListenerWidget(
          header: _dragDetector(header),
          headerHeight: headerHeight,
          interface: setInterface,
          scrollDirection: scrollDirection,
          timerPeriodic: timerPeriodic,
          scrollController: scrollControllers[tabController.index],
          defaultTabController: DefaultTabController(
            animationDuration: animationDuration,
            length: tabBarViews.length,
            child: Column(
              children: [
                _dragDetector(tabBar),
                _tabBarView(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabBarView() {
    return Expanded(
      child: TabBarView(
        physics: const StackScrollPhysics(),
        controller: tabController,
        children: List.generate(tabBarViews.length, (index) {
          return StackNotification(
            scrollDirection: setScrollDirection,
            checkOffset: (offset) =>
                stackPageViewInterface?.checkScrollOffset(offset),
            atTop: () => stackPageViewInterface?.atTopAnimation(),
            atBottom: () => stackPageViewInterface?.atBottomAnimation(),
            scrollController: scrollControllers[index],
            dragY: dragY,
            child: tabBarViews[index],
          );
        }),
      ),
    );
  }

  setScrollDirection(ScrollDirection scrollDirection) {
    try {
      if (mounted) {
        setState(() {
          this.scrollDirection = scrollDirection;
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('setScrollDirection e : $e');
      }
    }
  }

  setInterface(StackPageViewInterface i) {
    stackPageViewInterface = i;
    if (interface == null) return;
    interface!(stackPageViewInterface);
  }

  /// 헤더와 탭바 드래그 했을 때 애니메이션 가능하도록 설정
  Widget _dragDetector(Widget child) {
    if (!tabDrag) return child;
    return GestureDetector(
      child: child,
      onVerticalDragStart: (details) => _initTouchY(),
      onVerticalDragCancel: () => _initTouchY(),
      onVerticalDragDown: (details) => _initTouchY(),
      onVerticalDragUpdate: (details) {
        try {
          if (details.delta.dy > 0) {
            _touchY += details.delta.dy;
          } else {
            _touchY += details.delta.dy;
          }
          if (_touchY > dragY) {
            stackPageViewInterface?.atTopAnimation();
            return;
          } else if (_touchY < -dragY) {
            stackPageViewInterface?.atBottomAnimation();
            return;
          }
        } on Exception catch (e) {
          if (kDebugMode) {
            print('_dragDetector e : $e');
          }
        }
      },
    );
  }
}
