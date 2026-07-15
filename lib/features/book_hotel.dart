import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/utils/local/cash_helper.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/features/home/cubit/app_states.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BookHotel extends StatefulWidget {
  const BookHotel({
    Key? key,
    required this.hotelName,
    required this.hotelId,
  }) : super(key: key);

  final String hotelName;
  final int hotelId;

  @override
  State<BookHotel> createState() => _BookHotelState();
}

class _BookHotelState extends State<BookHotel> {
  final controllers = List.generate(5, (_) => PageController());

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, AppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = AppCubit.get(context);
        final rooms = [
          _RoomOption(
            name: 'Deluxe room',
            subtitle: 'King bed, city view, breakfast available',
            price: 'P 2,150',
            images: cubit.deluxeRoomImages.cast<String>(),
          ),
          _RoomOption(
            name: 'Premium room',
            subtitle: 'Ocean-facing suite with lounge area',
            price: 'P 2,890',
            images: cubit.premiumRoomImages.cast<String>(),
          ),
          _RoomOption(
            name: 'Queen room',
            subtitle: 'Warm private stay for two travellers',
            price: 'P 1,780',
            images: cubit.queenRoomImages.cast<String>(),
          ),
          _RoomOption(
            name: 'King room',
            subtitle: 'Large suite with refined finishes',
            price: 'P 3,450',
            images: cubit.kingRoomImages.cast<String>(),
          ),
          _RoomOption(
            name: 'Signature stay',
            subtitle: 'Quiet premium room with curated service',
            price: 'P 4,120',
            images: cubit.hollywoodRoomImages.cast<String>(),
          ),
        ];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(
              widget.hotelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              14,
              AppSpacing.screen,
              32,
            ),
            itemCount: rooms.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Choose your room',
                        style: AppTypography.displayMedium),
                    const SizedBox(height: 10),
                    Text(
                      'Select the stay that best matches your trip. Travel365 will confirm availability before final payment.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                );
              }
              final roomIndex = index - 1;
              return _RoomCard(
                room: rooms[roomIndex],
                controller: controllers[roomIndex],
                onBook: () => _book(cubit),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _book(AppCubit cubit) async {
    final token = '${CashHelper.getData(key: 'token') ?? ''}';
    final rawUserId = CashHelper.getData(key: 'userId');
    final userId =
        rawUserId is int ? rawUserId : int.tryParse('$rawUserId') ?? 0;
    await cubit.createBook(
      hotelId: widget.hotelId,
      token: token,
      userId: userId,
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.controller,
    required this.onBook,
  });

  final _RoomOption room;
  final PageController controller;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return LuxuryCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.card),
            ),
            child: SizedBox(
              height: 218,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: controller,
                    itemCount: room.images.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        room.images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/hotel.jpg',
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: controller,
                        count: room.images.length,
                        effect: WormEffect(
                          dotColor: Colors.white.withAlpha(140),
                          activeDotColor: Colors.white,
                          dotWidth: 7,
                          dotHeight: 7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(room.name, style: AppTypography.sectionTitle),
                          const SizedBox(height: 6),
                          Text(room.subtitle, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(room.price, style: AppTypography.sectionTitle),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: const [
                    _RoomAmenity(icon: Icons.wifi_rounded, label: 'Wi-Fi'),
                    SizedBox(width: 10),
                    _RoomAmenity(
                        icon: Icons.local_cafe_outlined, label: 'Breakfast'),
                    SizedBox(width: 10),
                    _RoomAmenity(
                        icon: Icons.king_bed_outlined, label: 'King bed'),
                  ],
                ),
                const SizedBox(height: 18),
                LuxuryButton(
                  label: 'Request this room',
                  onPressed: onBook,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomAmenity extends StatelessWidget {
  const _RoomAmenity({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.accent),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomOption {
  const _RoomOption({
    required this.name,
    required this.subtitle,
    required this.price,
    required this.images,
  });

  final String name;
  final String subtitle;
  final String price;
  final List<String> images;
}
