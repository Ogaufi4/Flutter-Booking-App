import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_empty_state.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/data/models/explore_model.dart';
import 'package:booking_app/features/filter/pages/filter_screen.dart';
import 'package:booking_app/features/hotel_details/hotel_details.dart';
import 'package:booking_app/features/home/cubit/app_states.dart';
import 'package:booking_app/features/search_screen/search_screen.dart';

class ExploreScreen extends StatefulWidget {
  ExploreScreen({Key? key}) : super(key: key);

  final searchController = TextEditingController();

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final model = cubit.exploreModel;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Explore stays'),
            actions: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/map'),
                icon: const Icon(Icons.map_outlined),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: model == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _ExploreContent(model: model, cubit: cubit),
        );
      },
    );
  }
}

class _ExploreContent extends StatelessWidget {
  const _ExploreContent({required this.model, required this.cubit});

  final ExploreModel model;
  final AppCubit cubit;

  @override
  Widget build(BuildContext context) {
    final hotels = model.data?.data ?? <Datum>[];
    if (hotels.isEmpty) {
      return const LuxuryEmptyState(
        icon: Icons.hotel_outlined,
        title: 'No stays found',
        message: 'Try another destination or adjust your search filters.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        14,
        AppSpacing.screen,
        32,
      ),
      children: [
        _ExploreSearch(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        }),
        const SizedBox(height: 22),
        LuxuryCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: _MetaTile(
                  label: 'Choose date',
                  value: '27 Sep - 02 Oct',
                ),
              ),
              Container(width: 1, height: 38, color: AppColors.divider),
              Expanded(
                child: _MetaTile(
                  label: 'Rooms',
                  value: '1 Room - 2 People',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: Text(
                '${model.data?.total ?? hotels.length} stays found',
                style: AppTypography.sectionTitle,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FilterScreen()),
              ),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Filter'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(hotels.length, (index) {
          final hotel = hotels[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: _HotelCard(
              hotel: hotel,
              selected: index < cubit.exploreValues.length
                  ? cubit.exploreValues[index]
                  : false,
              onFavorite: () {
                if (index < cubit.exploreValues.length) {
                  cubit.exploreValues[index] = !cubit.exploreValues[index];
                }
                cubit.insertDatabase(
                  name: hotel.name ?? '',
                  address: hotel.address ?? '',
                  price: hotel.price ?? '',
                  rate: hotel.rate ?? '',
                  image: hotel.hotelImages?.isNotEmpty == true
                      ? hotel.hotelImages!.first.image ?? ''
                      : '',
                );
              },
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HotelDetailsScreen(model: hotel),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ExploreSearch extends StatelessWidget {
  const _ExploreSearch({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.medium),
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search hotels, cities or stays',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption),
          const SizedBox(height: 5),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label,
          ),
        ],
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  const _HotelCard({
    required this.hotel,
    required this.onTap,
    required this.onFavorite,
    required this.selected,
  });

  final Datum hotel;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.card),
                ),
                child: _NetworkPhoto(
                  url: _hotelImage(hotel),
                  height: 190,
                  width: double.infinity,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: LuxuryIconButton(
                  icon: selected
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: selected ? AppColors.accent : AppColors.primary,
                  semanticLabel: 'Save stay',
                  onPressed: onFavorite,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        hotel.name ?? 'Travel365 stay',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.sectionTitle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'P ${hotel.price ?? '-'}',
                      style: AppTypography.sectionTitle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 17, color: AppColors.accent),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        hotel.address ?? 'Curated location',
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.star_rounded,
                        size: 17, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(hotel.rate ?? '4.9', style: AppTypography.caption),
                  ],
                ),
                const SizedBox(height: 12),
                Text('/per night', style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto({
    required this.url,
    required this.height,
    required this.width,
  });

  final String url;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Image.asset(
        'assets/images/hotel.jpg',
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    }
    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/hotel.jpg',
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    );
  }
}

String _hotelImage(Datum hotel) {
  final image = hotel.hotelImages?.isNotEmpty == true
      ? hotel.hotelImages!.first.image
      : null;
  if (image == null || image.isEmpty) return '';
  if (image.startsWith('http')) return image;
  return 'http://api.mahmoudtaha.com/images/$image';
}
