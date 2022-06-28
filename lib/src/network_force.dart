library network_representation;

import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

class NodeComponent extends PositionComponent
    with Tappable, Hoverable, GestureHitboxes, Draggable {
  NodeComponent() : super(size: Vector2.all(10), position: Vector2(0, 0));

  final ShapeHitbox hitbox = CircleHitbox(radius: 5);
  Vector2 velocity = Vector2(0, 0);

  // update and render omitted

  Vector2? dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    const baseColor = Color(0xFF000000);
    hitbox.paint.color = baseColor;
    hitbox.renderShape = true;

    add(hitbox);
  }

  @override
  bool onDragStart(DragStartInfo startPosition) {
    dragDeltaPosition = startPosition.eventPosition.game - position;
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo event) {
    if (isDragging) {
      final localCoords = event.eventPosition.game;
      position = localCoords - dragDeltaPosition!;
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo event) {
    dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel() {
    dragDeltaPosition = null;
    return false;
  }
}

class NetworkSimaultion extends FlameGame
    with HasTappables, HasHoverables, HasDraggables {
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
    return Color(0x00000000);
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
    super.render(canvas);
    canvas.translate(canvasSize.x / 2, canvasSize.y / 2);
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
    double factor = 10;
    Vector2 offset = node.position - other.position;
    double distance = offset.length;

    if (distance <= 0) {
      offset = Vector2(_random.nextDouble() * 10, _random.nextDouble() * 10);
      distance = offset.length;
    }

    Vector2 separation = offset * factor / (sqrt(distance) * distance);

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
      if (!node.isDragged) verlet(node, dt);
    }
  }
}
