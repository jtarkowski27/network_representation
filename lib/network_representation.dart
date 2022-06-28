library network_representation;

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:network_representation/src/network_force.dart';

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
