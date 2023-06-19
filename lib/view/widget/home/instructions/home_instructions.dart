import 'package:farkha_app/view/widget/home/instructions/container_instruction.dart';
import 'package:flutter/material.dart';

class HomeInstructions extends StatelessWidget {
  const HomeInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContainerInstruction(),
        ContainerInstruction(),
      ],
    );
  }
}
