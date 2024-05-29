import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:prime/utils/navigate_with_animation.dart';
import 'package:prime/views/common/full_images_viewer_screen.dart';
import '../../models/car.dart';
import '../../utils/carousel/indicator_model.dart';
import '../../utils/carousel/indicators_widget.dart';
import '../car_status_indicator.dart';
import '../custom_progress_indicator.dart';

class CarImagesCarousel extends StatefulWidget {
  final List<String>? imagesUrl;
  final CarStatus carStatus;
  final bool showCarStatus;
  const CarImagesCarousel({
    super.key,
    required this.imagesUrl,
    required this.carStatus,
    this.showCarStatus = false,
  });

  @override
  State<CarImagesCarousel> createState() => _CarImagesCarouselState();
}

class _CarImagesCarouselState extends State<CarImagesCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 250,
          child: widget.imagesUrl != null && widget.imagesUrl!.isNotEmpty
              ? PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imagesUrl!.length,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.0),
                              child: GestureDetector(
                                onTap: () => animatedPushNavigation(
                                  context: context,
                                  screen: FullImagesViewerScreen(
                                    imagesUrl: widget.imagesUrl!,
                                    appBarTitle: 'Car Images',
                                    heroTag: 'car-image-$index',
                                    initialIndex: index,
                                  ),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.imagesUrl![index],
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CustomProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Center(child: Icon(Icons.error)),
                                ),
                              ),
                            ),
                          ),
                          if (index == 0 && widget.showCarStatus)
                            Positioned(
                              top: 10.0,
                              right: 10.0,
                              child: CarStatusIndicator(
                                carStatus: widget.carStatus,
                              ),
                            ),
                        ],
                      ),
                    );
                  })
              : const Center(
                  child: Text('Error loading image'),
                ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imagesUrl!.length,
                (index) => CarouselIndicatorWidget(
                  key: Key("Indicator$index"),
                  active: _currentPage == index,
                  color: _currentPage == index
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.tertiaryContainer,
                  animation: true,
                  sizeIndicator: const IndicatorModel.animation(
                    width: 15.0,
                    widthAnimation: 25.0,
                    height: 3.0,
                    heightAnimation: 3.0,
                    spaceBetween: 1.0,
                    spaceBetweenAnimation: 2.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
