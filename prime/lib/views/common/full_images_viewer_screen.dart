import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/carousel/indicator_model.dart';
import '../../utils/carousel/indicators_widget.dart';

class FullImagesViewerScreen extends StatefulWidget {
  final List<String> imagesUrl;
  final String appBarTitle;
  final String heroTag;
  final int initialIndex;

  const FullImagesViewerScreen({
    super.key,
    required this.imagesUrl,
    required this.appBarTitle,
    required this.heroTag,
    required this.initialIndex,
  });

  @override
  State<FullImagesViewerScreen> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullImagesViewerScreen> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPage = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appBarTitle),
      ),
      body: Hero(
        tag: widget.heroTag,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imagesUrl.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: widget.imagesUrl[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Center(child: Icon(Icons.error)),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imagesUrl.length,
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
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: List.generate(
              //     widget.imagesUrl.length,
              //     (index) => Container(
              //       width: 8,
              //       height: 8,
              //       margin: const EdgeInsets.symmetric(horizontal: 4),
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: _currentPage == index
              //             ? Theme.of(context).colorScheme.secondary
              //             : Theme.of(context).colorScheme.secondaryContainer,
              //       ),
              //     ),
              //   ),
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
