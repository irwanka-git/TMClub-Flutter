// ignore_for_file: use_key_in_widget_constructors

import 'package:skeletons/skeletons.dart';
import 'package:flutter/material.dart';

class CardSkeleton extends StatelessWidget {
  @override
  const CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonItem(
        child: Column(
      children: [
        SkeletonParagraph(
          style: SkeletonParagraphStyle(
              lines: 3,
              spacing: 6,
              lineStyle: SkeletonLineStyle(
                randomLength: true,
                height: 10,
                borderRadius: BorderRadius.circular(8),
              )),
        ),
        const SizedBox(height: 12),
        SkeletonAvatar(
          style: SkeletonAvatarStyle(
            width: double.infinity,
            minHeight: MediaQuery.of(context).size.height / 6,
            maxHeight: MediaQuery.of(context).size.height / 3,
          ),
        ),
        const SizedBox(height: 8),
      ],
    ));
  }
}
