import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_empty_state.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/features/filter/pages/filter_screen.dart';
import 'package:booking_app/features/home/cubit/app_states.dart';

class ViewFilterList extends StatelessWidget {
  const ViewFilterList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screen,
                      AppSpacing.lg, AppSpacing.screen, AppSpacing.md),
                  child: Row(
                    children: [
                      LuxuryIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        semanticLabel: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'filter_txt'.tr(context),
                          style: AppTypography.headingMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredHotelList.isEmpty
                      ? const LuxuryEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'No matches found',
                          message:
                              'Try adjusting your address, price range, or facilities to see more stays.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(AppSpacing.screen,
                              AppSpacing.sm, AppSpacing.screen, AppSpacing.xxl),
                          itemCount: filteredHotelList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) =>
                              _FilterResultCard(hotel: filteredHotelList[index]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterResultCard extends StatelessWidget {
  const _FilterResultCard({Key? key, required this.hotel}) : super(key: key);

  final dynamic hotel;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 0.9,
              child: Image(
                image: NetworkImage(
                    'http://api.mahmoudtaha.com/images/${hotel.hotelImages!.first.image}'),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.divider,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: AppColors.textMuted),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${hotel.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.sectionTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${hotel.address}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: AppColors.accent),
                        const SizedBox(width: AppSpacing.xs),
                        Text('${hotel.rate}', style: AppTypography.label),
                        const Spacer(),
                        Text(
                          '\$${hotel.price}',
                          style: AppTypography.sectionTitle
                              .copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
