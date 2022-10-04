import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StackNotification extends StatefulWidget {
  StackNotification({
    required this.checkOffset,
    required this.atTop,
    required this.atBottom,
    required this.scrollDirection,
    required this.scrollController,
    required this.child,
    this.dragY = 16,
    Key? key,
  }) : super(key: key);

  Function(ScrollDirection direction) scrollDirection;
  Function(double offset) checkOffset;
  Function atTop;
  Function atBottom;
  ScrollController scrollController;
  Widget child;
  int dragY;

  @override
  State<StackNotification> createState() => _StackNotificationState();
}

class _StackNotificationState extends State<StackNotification>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ScrollController get scrollController => widget.scrollController;

  Function(double offset) get checkOffset => widget.checkOffset;

  Function(ScrollDirection direction) get scrollDirection =>
      widget.scrollDirection;

  Function get atTop => widget.atTop;

  Function get atBottom => widget.atBottom;

  Widget get child => widget.child;

  int get dragY => widget.dragY;

  double _touchY = 0;

  _initTouchY() => _touchY = 0;

  double beforeScroll = 0;

  @override
  void initState() {
    try {
      scrollController.addListener(() {
        if ((beforeScroll - scrollController.offset).abs() > 10) {
          checkOffset(scrollController.offset);
          beforeScroll = scrollController.offset;
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('StackNotification initState e : $e');
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return notification(
      scrollDirection: scrollDirection,
      atTop: atTop,
      atBottom: atBottom,
      child: _dragDetector(child, atTop, atBottom),
    );
  }

  NotificationListener<UserScrollNotification> notification({
    required Function(ScrollDirection direction) scrollDirection,
    required Function atTop,
    required Function atBottom,
    required Widget child,
  }) {
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        final ScrollDirection direction = notification.direction;
        scrollDirection(notification.direction);
        final metrics = notification.metrics;
        if (metrics.atEdge) {
          if (metrics.pixels == 0) {
            if (direction == ScrollDirection.reverse) {
              return true;
            }
            atTop();
          } else {
            if (direction == ScrollDirection.forward) {
              return true;
            }
            atBottom();
          }
        }
        return true;
      },
      child: child,
    );
  }

  Widget _dragDetector(
    Widget child,
    Function atTop,
    Function atBottom,
  ) {
    return GestureDetector(
      child: child,
      onVerticalDragStart: (details) => _initTouchY(),
      onVerticalDragCancel: () => _initTouchY(),
      onVerticalDragDown: (details) => _initTouchY(),
      onVerticalDragUpdate: (details) {
        if (details.delta.dy > 0) {
          _touchY += details.delta.dy;
        } else {
          _touchY += details.delta.dy;
        }
        if (_touchY > dragY) {
          atTop();
          return;
        } else if (_touchY < -dragY) {
          atBottom();
          return;
        }
      },
    );
  }
}
