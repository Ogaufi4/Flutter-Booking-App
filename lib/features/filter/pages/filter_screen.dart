import 'package:booking_app/core/localization/setup/app_localization.dart';
import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_radius.dart';
import 'package:booking_app/core/theme/app_spacing.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:booking_app/core/utils/network/remote/dio_helper.dart';
import 'package:booking_app/core/utils/network/remote/end_points.dart';
import 'package:booking_app/core/widgets/luxury_button.dart';
import 'package:booking_app/core/widgets/luxury_icon_button.dart';
import 'package:booking_app/core/widgets/luxury_text_field.dart';
import 'package:booking_app/data/database/facility_helper.dart';
import 'package:booking_app/data/models/facility_model.dart';
import 'package:booking_app/data/models/hotel_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
List<HotelDataModel> filteredHotelList = [];

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  @override
  List<HotelDataModel> hotelsLst = [];
  List<double> pricesLst = [];
  List<FacilityModel> facilitiesLst = [];
  List<int> selectedFacilitiesLst = [];
  double min = 0.0;
  double max = 10.0;
  late double low;
  late double high;
  TextEditingController address = TextEditingController();

  @override
  void initState() {
    super.initState();
    low = min;
    high = max;
    getWholeHotels();
    getFacilitiesDateLocal();
  }

  getWholeHotels() async {
    var resultJson = await DioHelper.get('search-hotels?count=100&page=1');
    // debugPrint('ress=');
    // debugPrint(resultJson);
    if (resultJson != false) {
      HotelModel tmp = HotelModel.fromJson(resultJson);
      setState(() {
        hotelsLst = tmp.data!.data!;
      });

      for (var item in hotelsLst) {
        if (!(pricesLst.contains(item.price))) {
          pricesLst.add(double.parse(item.price!));
        }
      }
      pricesLst.sort();
      pricesLst = pricesLst.toSet().toList();
      // debugPrint('prices==$pricesLst');
      setState(() {
        min = pricesLst.first;
        max = pricesLst.last;
        low = pricesLst.first;
        high = pricesLst.last;
      });
    }
  }

  getFacilitiesDate() async {
    var resultJson = await DioHelper.get('facilities');
    // print(resultJson);
    if (resultJson != false) {
      List<FacilityModel> tmp = [];
      for (var item in resultJson['data']) {
        tmp.add(FacilityModel.fromJson(item));
      }
      for (var item in tmp) {
        setState(() {
          item.isSelected = false;
        });
      }
      setState(() {
        facilitiesLst = tmp;
      });
      // debugPrint('facilitiesLstLength== ${facilitiesLst.length}');

      FacilitiesSaveLocal();
    }
  }

  FacilitiesSaveLocal() async {
    FacilityHelper db = FacilityHelper();
    await db.deleteAll();
    for (var row in facilitiesLst) {
      await db.savePost(row);
    }
  }

  Future<void> getFacilitiesDateLocal() async {
    FacilityHelper db = FacilityHelper();
    var tmp = await db.getAll();
    if (tmp.length == 0) {
      getFacilitiesDate();
    } else {
      for (var item in tmp) {
        setState(() {
          item.isSelected = false;
        });
      }
      setState(() {
        facilitiesLst = tmp;
      });

      // debugPrint('facilitiesLstLength== ${facilitiesLst.length}');

      getFacilitiesDate();
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen, AppSpacing.lg, AppSpacing.screen, AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: AppSpacing.xl),
              Text('address_txt'.tr(context), style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              LuxuryTextField(
                controller: address,
                label: '',
                hintText: 'address_desc'.tr(context),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('price_txt'.tr(context), style: AppTypography.label),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.accent,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: AppColors.accent,
                  overlayColor: AppColors.accentSoft,
                  valueIndicatorColor: AppColors.primary,
                ),
                child: RangeSlider(
                  min: min,
                  max: max,
                  values: RangeValues(low, high),
                  divisions: pricesLst.length > 0 ? pricesLst.length : 4,
                  labels: RangeLabels(
                      '\$${low.round()}', '\$${high.round()} EGP'),
                  onChanged: (values) => setState(() {
                    low = values.start;
                    high = values.end;
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('facilities_txt'.tr(context), style: AppTypography.label),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                childAspectRatio: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.md,
                children: [
                  ...facilitiesLst.map((e) => _FacilityTile(
                        model: e,
                        onTap: () {
                          if (selectedFacilitiesLst.contains(e.id)) {
                            selectedFacilitiesLst.remove(e.id);
                          } else {
                            selectedFacilitiesLst.add(e.id!);
                          }
                          setState(() {
                            e.isSelected = !e.isSelected!;
                          });
                        },
                      )),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              LuxuryButton(
                label: 'apply_txt'.tr(context),
                onPressed: () {
                  applyFilter();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  applyFilter() async {
    debugPrint('$selectedFacilitiesLst');
    String query = 'search-hotels?';
    if (address.text != '') query = '${query}address=${address.text}&';
    if (low != null) query = query = '${query}min_price=${low}&';
    if (high != null) query = query = '${query}max_price=${high}&';
    if (selectedFacilitiesLst.length > 0)
      for (var i = 0; i < selectedFacilitiesLst.length; i++) {
        query = query = '${query}facilities[$i]=${selectedFacilitiesLst[i]}&';
      }
    String finalQuery = query.substring(0, query.length - 1);
    debugPrint(baseUrl + finalQuery);
    var resultJson = await DioHelper.get(finalQuery);

    if (resultJson != false) {
      for (var item in resultJson['data']['data']) {
        filteredHotelList.add(HotelDataModel.fromJson(item));
      }
      debugPrint('filteredHotelList.length');
      debugPrint(filteredHotelList.length.toString());
      Navigator.pushReplacementNamed(context, '/viewFilter');
    }
  }
}

class _FacilityTile extends StatelessWidget {
  const _FacilityTile({Key? key, required this.model, required this.onTap})
      : super(key: key);

  final FacilityModel model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = model.isSelected == true;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentSoft,
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: CachedNetworkImage(imageUrl: '${model.image}'),
                ),
              ),
              if (selected)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withAlpha(140),
                  ),
                  child: const Icon(Icons.check,
                      size: 22, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${model.name}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
