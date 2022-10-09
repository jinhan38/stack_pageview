import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'stackPageViewInterface.dart';

class StackListenerWidget extends StatefulWidget {

  StackListenerWidget({
    required this.header,
    required this.headerHeight,
    required this.interface,
    required this.scrollDirection,
    required this.defaultTabController,
    required this.timerPeriodic,
    required this.scrollController,
    this.scrollUp,
    this.scrollDown,
    Key? key,
  }) : super(key: key);
  final Widget header;
  final double headerHeight;
  final Function(StackPageViewInterface interface) interface;
  ScrollDirection? scrollDirection;
  final DefaultTabController defaultTabController;
  final int timerPeriodic;
  final ScrollController scrollController;
  Function(double offset)? scrollUp;
  Function(double offset)? scrollDown;

  @override
  _StackListenerWidgetState createState() => _StackListenerWidgetState();
}

class _StackListenerWidgetState extends State<StackListenerWidget>
    with SingleTickerProviderStateMixin, StackPageViewInterface {
  Widget get header => widget.header;

  double get headerHeight => widget.headerHeight;

  Function(StackPageViewInterface interface) get interface => widget.interface;

  ScrollDirection? get scrollDirection => widget.scrollDirection;

  DefaultTabController get defaultTabController => widget.defaultTabController;

  int get timerPeriodic => widget.timerPeriodic;

  ScrollController get scrollController => widget.scrollController;

  Function(double offset)? get scrollUp => widget.scrollUp;

  Function(double offset)? get scrollDown => widget.scrollDown;

  final ValueNotifier<double> _headerTop = ValueNotifier<double>(0);
  bool headerAnimating = false;

  @override
  void initState() {
    interface(this);
    super.initState();
  }

  @override
  void dispose() {
    _headerTop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _headerTop,
      builder: (_, value, __) {
        final screenHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          width: double.infinity,
          height: screenHeight,
          child: Stack(
            children: [
              Positioned(left: 0, right: 0, top: value, child: header),
              Positioned(
                left: 0,
                right: 0,
                top: value + headerHeight,
                bottom: 0,
                child: defaultTabController,
              ),
            ],
          ),
        );
      },
    );
  }

  /// 페이지뷰 아이템 위젯들에서 스크롤뷰 리스너가 발동되면 호출됨
  /// 스크롤 offset 과 스크롤 방향에 따라서 다르게 설정해줌
  @override
  checkScrollOffset(double offset) {
    try {
      if (headerAnimating) return;
      if (scrollDirection == null) return;

      switch (scrollDirection) {
        case ScrollDirection.reverse:
          if (_headerTop.value.abs() == 0) atBottomAnimation();
          if (scrollDown != null) scrollDown!(offset);

          break;
        case ScrollDirection.forward:
          if (_headerTop.value.abs() == headerHeight) atTopAnimation();
          if (scrollUp != null) scrollUp!(offset);

          break;
        case ScrollDirection.idle:
          break;
        default:
          break;
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('checkScrollOffset e : $e');
      }
    }
  }

  /// 페이지뷰 아이템의 리스트뷰가 상단에 도달했을 때 호출
  @override
  atTopAnimation() {
    try {
      if (headerAnimating) return;
      headerAnimating = true;
      if (_headerTop.value.abs() <= headerHeight) {
        Timer.periodic(Duration(milliseconds: timerPeriodic), (timer) {
          var value = _headerTop.value + 2;
          if (value >= 0) {
            _headerTop.value = 0;
            timer.cancel();
            headerAnimating = false;
          } else {
            _headerTop.value = value;
          }
        });
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('atTopAnimation e : $e');
      }
    }
  }

  /// 페이지뷰 아이템의 리스트뷰가 바닥에 도달한 경우 호출
  @override
  atBottomAnimation() {
    try {
      if (headerAnimating) return;
      headerAnimating = true;
      Timer.periodic(Duration(milliseconds: timerPeriodic), (timer) {
        var value = _headerTop.value - 2;
        if (value <= (headerHeight * -1)) {
          _headerTop.value = -headerHeight;
          timer.cancel();
          headerAnimating = false;
        } else {
          _headerTop.value = value;
        }
      });
    } on Exception catch (e) {
      if (kDebugMode) {
        print('atBottomAnimation e : $e');
      }
    }
  }

  @override
  void goTop() {
    try {
      print('scrollController : $scrollController');
      scrollController.jumpTo(0);
      atTopAnimation();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('goTop e : $e');
      }
    }
  }

  @override
  void goBottom() {
    try {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      atBottomAnimation();
    } on Exception catch (e) {
      if (kDebugMode) {
        print('goBottom e : $e');
      }
    }
  }
}
