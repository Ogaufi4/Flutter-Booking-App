import 'dart:math' as math;

import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/data/models/explore_model.dart';
import 'package:booking_app/features/book_hotel.dart';
import 'package:booking_app/features/home/cubit/app_states.dart';

class HotelDetailsScreen extends StatefulWidget {
  const HotelDetailsScreen({Key? key, required this.model}) : super(key: key);

  final Datum? model;

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  bool isFavorite = false;

  Datum get hotel => widget.model ?? Datum();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final heroHeight = math.min(math.max(height * 0.48, 330.0), 440.0);
    final image = _hotelImage(hotel);

    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(24, 10, 24, 18),
            child: LuxuryButton(
              label: 'View availability',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookHotel(
                    hotelName: hotel.name ?? 'Travel365 stay',
                    hotelId: hotel.id ?? 0,
                  ),
                ),
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: heroHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _NetworkPhoto(url: image, height: heroHeight),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 12,
                        left: 20,
                        child: LuxuryIconButton(
                          icon: Icons.arrow_back_rounded,
                          semanticLabel: 'Back',
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 12,
                        right: 20,
                        child: LuxuryIconButton(
                          icon: isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color:
                              isFavorite ? AppColors.accent : AppColors.primary,
                          semanticLabel: 'Save stay',
                          onPressed: () {
                            setState(() => isFavorite = !isFavorite);
                            AppCubit.get(context).insertDatabase(
                              name: hotel.name ?? '',
                              address: hotel.address ?? '',
                              price: hotel.price ?? '',
                              rate: hotel.rate ?? '',
                              image: hotel.hotelImages?.isNotEmpty == true
                                  ? hotel.hotelImages!.first.image ?? ''
                                  : '',
                            );
                          },
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            math.min(hotel.hotelImages?.length ?? 1, 5),
                            (index) => Container(
                              width: index == 0 ? 18 : 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withAlpha(index == 0 ? 242 : 140),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  26,
                  AppSpacing.screen,
                  34,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name ?? 'Travel365 stay',
                        style: AppTypography.displayMedium,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        hotel.address ?? 'Curated location',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.accent, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${hotel.rate ?? '4.9'} (128 reviews)',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const _AmenityRow(),
                      const SizedBox(height: 28),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: 24),
                      Text('About this stay',
                          style: AppTypography.sectionTitle),
                      const SizedBox(height: 12),
                      Text(
                        hotel.description?.trim().isNotEmpty == true
                            ? hotel.description!
                            : 'A refined stay selected by Travel365 for comfort, location and reliable service.',
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      _PriceCard(price: hotel.price ?? '-'),
                      const SizedBox(height: 24),
                      _PhotoStrip(hotel: hotel),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow();

  static const items = [
    _Amenity(Icons.wifi_rounded, 'Free Wi-Fi'),
    _Amenity(Icons.pool_rounded, 'Pool'),
    _Amenity(Icons.local_cafe_outlined, 'Breakfast'),
    _Amenity(Icons.spa_outlined, 'Spa'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: Column(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(item.icon, size: 21, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.price});
  final String price;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('From', style: AppTypography.caption),
                const SizedBox(height: 5),
                Text('P $price / night', style: AppTypography.headingMedium),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(Icons.king_bed_outlined, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.hotel});
  final Datum hotel;

  @override
  Widget build(BuildContext context) {
    final photos = hotel.hotelImages ?? <Hotel>[];
    if (photos.length < 2) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photos', style: AppTypography.sectionTitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: _NetworkPhoto(
                  url: _imageUrl(photos[index].image),
                  width: 116,
                  height: 92,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NetworkPhoto extends StatelessWidget {
  const _NetworkPhoto({
    required this.url,
    required this.height,
    this.width = double.infinity,
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

class _Amenity {
  const _Amenity(this.icon, this.label);
  final IconData icon;
  final String label;
}

String _hotelImage(Datum hotel) {
  final image = hotel.hotelImages?.isNotEmpty == true
      ? hotel.hotelImages!.first.image
      : null;
  return _imageUrl(image);
}

String _imageUrl(String? image) {
  if (image == null || image.isEmpty) return '';
  if (image.startsWith('http')) return image;
  return 'http://api.mahmoudtaha.com/images/$image';
}
