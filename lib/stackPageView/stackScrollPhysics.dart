import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class StackScrollPhysics extends ScrollPhysics {
  const StackScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  StackScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return StackScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 70,
        stiffness: 100,
        damping: 0.8,
      );
}
