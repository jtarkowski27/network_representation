library network_representation;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NodeComponent extends PositionComponent {
  static final Paint _paint = Paint()..color = Colors.red;
  double radius = 100;
  double delta = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    x = 0;
    y = 100;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawCircle(Offset(x, y), 50, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    x = sin(delta) * radius;
    y = cos(delta) * radius;

    delta += dt;
  }
}

class NetworkSimaultion extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(NodeComponent());
  }
}

class ForceNetwork extends StatelessWidget {
  const ForceNetwork({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final simulation = NetworkSimaultion();

    return GameWidget(game: simulation);
  }
}
