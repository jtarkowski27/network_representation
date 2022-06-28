library network_representation;

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class NodeComponent extends Component {
  static final Paint _paint = Paint()..color = Colors.black;

  Vector2 get velocity => _currVelocity;
  Vector2 get position => _currPosition;

  set velocity(Vector2 value) => _nextVelocity = value;
  set position(Vector2 value) => _nextPosition = value;

  Vector2 _currVelocity = Vector2(0, 0);
  Vector2 _currPosition = Vector2(0, 0);
  Vector2 _nextVelocity = Vector2(0, 0);
  Vector2 _nextPosition = Vector2(0, 0);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset(position.x, position.y), 5, _paint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _currVelocity = _nextVelocity;
    _currPosition = _nextPosition;
  }
}

class NetworkSimaultion extends FlameGame {
  NetworkSimaultion({
    required this.network,
    required this.force,
    Iterable<Component>? children,
    Camera? camera,
  }) : super();

  final NetworkData network;
  final ForceSimulation force;

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(force);
    addAll(network.nodes.data);
  }

  @override
  void onRemove() {
    super.onRemove();

    remove(force);
    removeAll(network.nodes.data);
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(canvasSize.x / 2, canvasSize.y / 2);
    super.render(canvas);
  }
}

class NodesData {
  NodesData(this.data);

  List<NodeComponent> data;
}

class NetworkData {
  NetworkData({required this.nodes});

  final NodesData nodes;
}

class ForceSimulation extends Component {
  ForceSimulation({
    required this.network,
  });

  static final _random = Random();
  static const maxAcceleration = 100;

  final NetworkData network;

  Vector2 center(NodeComponent node) {
    double k = 1;

    Vector2 origin = Vector2(0, 0);
    Vector2 position = node.position;
    Vector2 offset = origin - position;
    Vector2 center = offset * k;

    return center;
  }

  Vector2 resistance(Vector2 velocity) {
    double rho = 1;

    Vector2 resistance = -velocity * rho;

    return resistance;
  }

  Vector2 _separation(NodeComponent node, NodeComponent other) {
    double factor = 20000;
    Vector2 offset = node.position - other.position;
    double distance = offset.length;

    if (distance <= 0) {
      offset = Vector2(_random.nextDouble() * 10, _random.nextDouble() * 10);
      distance = offset.length;
    }

    Vector2 separation = offset * factor / (distance * distance * distance);

    return separation;
  }

  Vector2 separation(NodeComponent node) {
    Vector2 separation = Vector2(0, 0);

    for (var other in network.nodes.data) {
      if (node == other) {
        continue;
      }

      separation += _separation(node, other);
    }

    return separation;
  }

  void verlet(NodeComponent node, double dt) {
    double m = 1;

    final velocity = node.velocity;
    final position = node.position;

    Vector2 net = Vector2(0, 0);
    net += center(node);
    net += separation(node);
    net += resistance(velocity);

    Vector2 acceleration = net * m;

    if (acceleration.length > 200) {
      acceleration *= maxAcceleration / acceleration.length;
    }

    final nextPosition =
        position + velocity * dt + acceleration * dt * dt * 0.5;
    final nextVelocity = velocity + acceleration * dt;

    node.position = nextPosition;
    node.velocity = nextVelocity;
  }

  @override
  void update(double dt) {
    for (var node in network.nodes.data) {
      verlet(node, dt);
    }
  }
}

class NetworkRepresentation extends StatefulWidget {
  const NetworkRepresentation({Key? key}) : super(key: key);

  @override
  State<NetworkRepresentation> createState() => _NetworkRepresentationState();
}

class _NetworkRepresentationState extends State<NetworkRepresentation> {
  late NetworkData network;
  late ForceSimulation force;

  late NetworkSimaultion simulation;

  @override
  void initState() {
    super.initState();

    network = NetworkData(
      nodes: NodesData(
        [
          for (var i = 0; i < 100; i++) NodeComponent(),
        ],
      ),
    );

    force = ForceSimulation(
      network: network,
    );

    simulation = NetworkSimaultion(
      network: network,
      force: force,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => GameWidget(
        game: simulation,
      ),
    );
  }
}
