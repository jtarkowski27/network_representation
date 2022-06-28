library network_representation;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NodeComponent extends PositionComponent {
  static final Paint _paint = Paint()..color = Colors.black;
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

    canvas.drawCircle(Offset(x, y), 5, _paint);
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
  NetworkSimaultion({
    required this.constraints,
    Iterable<Component>? children,
    Camera? camera,
  }) : super();

  final BoxConstraints constraints;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    debugPrint('lol');

    add(NodeComponent());
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(constraints.maxWidth / 2, constraints.maxHeight / 2);
    super.render(canvas);
  }
}

class ForceNetwork extends StatelessWidget {
  const ForceNetwork({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => GameWidget(
        game: NetworkSimaultion(constraints: constraints),
      ),
    );
  }
}
