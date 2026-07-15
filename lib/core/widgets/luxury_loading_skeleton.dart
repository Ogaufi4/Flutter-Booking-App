import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:flutter/material.dart';

/// A single subtle pulsing placeholder box built from existing token colors.
///
/// The animation is a slow (~1s) opacity pulse between [AppColors.divider] and
/// [AppColors.border]. No bounce, no third-party shimmer dependency, matching
/// the Travel365 animation restraint.
class LuxurySkeleton extends StatefulWidget {
  const LuxurySkeleton({
    Key? key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.small,
  }) : super(key: key);

  final double? width;
  final double height;
  final double radius;

  @override
  State<LuxurySkeleton> createState() => _LuxurySkeletonState();
}

class _LuxurySkeletonState extends State<LuxurySkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final color = Color.lerp(
            AppColors.divider,
            AppColors.border,
            Curves.easeInOut.transform(_controller.value),
          );
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          );
        },
      ),
    );
  }
}

/// Renders [count] placeholder rows that mirror a simple list-card layout
/// (thumbnail, title, and two supporting lines), so the loading state keeps the
/// same spacing as the populated list and avoids a layout jump.
class LuxurySkeletonList extends StatelessWidget {
  const LuxurySkeletonList({
    Key? key,
    this.count = 4,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.screen,
      12,
      AppSpacing.screen,
      32,
    ),
  }) : super(key: key);

  final int count;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: ListView.separated(
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, __) => const _SkeletonRowCard(),
      ),
    );
  }
}

class _SkeletonRowCard extends StatelessWidget {
  const _SkeletonRowCard();

  @override
  Widget build(BuildContext context) {
    return const LuxuryCard(
      padding: EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LuxurySkeleton(width: 74, height: 22, radius: AppRadius.pill),
                SizedBox(height: 14),
                LuxurySkeleton(height: 18),
                SizedBox(height: 10),
                LuxurySkeleton(width: 140, height: 12),
              ],
            ),
          ),
          SizedBox(width: 14),
          LuxurySkeleton(
            width: 86,
            height: 86,
            radius: AppRadius.medium,
          ),
        ],
      ),
    );
  }
}
