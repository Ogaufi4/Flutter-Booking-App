import 'package:booking_app/core/main_blocs/blocs.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_card.dart';
import 'package:booking_app/features/bookings/pages/book_trip_screen.dart';
import 'package:booking_app/features/search_screen/view_search_result.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();
  bool searching = false;

  static const List<_Destination> destinations = [
    _Destination('Cape Town', 'South Africa', 'assets/images/homeImage1.jpeg'),
    _Destination('Paris', 'France', 'assets/images/paris.jpg'),
    _Destination('City hotels', 'Popular stays', 'assets/images/hotel.jpg'),
    _Destination('Namibia', 'Desert escape', 'assets/images/homeImage3.jpg'),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = controller.text.trim();
    if (query.isEmpty) return;
    setState(() => searching = true);
    try {
      await AppCubit.get(context).getSearchBooking(name: query);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ViewSearchResult(query: query)),
      );
    } finally {
      if (mounted) setState(() => searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.of(context).size.width < 360
        ? AppSpacing.screenSmall
        : AppSpacing.screen;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(horizontal, 10, horizontal, 18),
        child: LuxuryButton(
          label: searching ? 'Searching...' : 'Search stays',
          icon: Icons.search_rounded,
          isLoading: searching,
          onPressed: searching ? null : _search,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 96),
        children: [
          Text('Where would\nyou like to go?',
              style: AppTypography.displayLarge),
          const SizedBox(height: 12),
          Text(
            'Search curated stays, cities and travel ideas.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Cape Town, Paris, hotel...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 32),
          Text('Popular searches', style: AppTypography.sectionTitle),
          const SizedBox(height: 14),
          ...destinations.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LuxuryCard(
                padding: const EdgeInsets.all(10),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookTripScreen(
                      initialDestination: item.title,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      child: Image.asset(
                        item.image,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: AppTypography.label),
                          const SizedBox(height: 4),
                          Text(item.subtitle, style: AppTypography.caption),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 19,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Destination {
  const _Destination(this.title, this.subtitle, this.image);
  final String title;
  final String subtitle;
  final String image;
}
