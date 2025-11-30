import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

typedef TutorialCardBuilder =
    Widget Function(
      BuildContext context,
      TutorialCoachMarkController controller,
    );

TargetFocus buildTutorialTarget({
  required String id,
  required GlobalKey key,
  required TutorialCardBuilder cardBuilder,
  ContentAlign contentAlign = ContentAlign.bottom,
  Alignment alignSkip = Alignment.topLeft,
}) {
  return TargetFocus(
    identify: id,
    keyTarget: key,
    alignSkip: alignSkip,
    contents: [
      TargetContent(
        align: contentAlign,
        builder: (context, controller) => cardBuilder(context, controller),
      ),
    ],
  );
}
