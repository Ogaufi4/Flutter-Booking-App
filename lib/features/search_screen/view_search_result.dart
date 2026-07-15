import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_empty_state.dart';
import 'package:booking_app/data/models/search_model.dart' as search;
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/home/cubit/app_states.dart';

class ViewSearchResult extends StatelessWidget {
  const ViewSearchResult({Key? key, this.query = ''}) : super(key: key);

  final String query;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final results =
            AppCubit.get(context).searchModel?.data?.data ?? <search.Datum>[];
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Search Results'),
          ),
          body: results.isEmpty
              ? LuxuryEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No stays found',
                  message: query.isEmpty
                      ? 'Try another city, hotel or travel idea.'
                      : 'No stays matched "$query". Try another search.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    14,
                    AppSpacing.screen,
                    32,
                  ),
                  itemCount: results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return _SearchResultCard(result: item);
                  },
                ),
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});
  final search.Datum result;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookTripScreen(
            initialDestination: result.name ?? '',
            initialService: 'accommodation',
          ),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(AppRadius.card),
            ),
            child: _NetworkPhoto(url: _image(result), width: 118, height: 138),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name ?? 'Travel365 stay',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.sectionTitle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    result.address ?? 'Curated location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.accent, size: 17),
                      const SizedBox(width: 4),
                      Text(result.rate ?? '4.9', style: AppTypography.caption),
                      const Spacer(),
                      Text(
                        'P ${result.price ?? '-'}',
                        style: AppTypography.label,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('/per night', style: AppTypography.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _image(search.Datum result) {
    final image = result.hotelImages?.isNotEmpty == true
        ? result.hotelImages!.first.image
        : null;
    if (image == null || image.isEmpty) return '';
    if (image.startsWith('http')) return image;
    return 'http://api.mahmoudtaha.com/images/$image';
  }
}

class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Image.asset(
        'assets/images/hotel.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/hotel.jpg',
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }
}
