// // import 'package:banner_carousel/banner_carousel.dart';
// import 'package:flutter/material.dart';

// import 'banner_model.dart';
// import 'banner_widget.dart';
// import 'indicator_model.dart';
// import 'indicators_widget.dart';

// /// Creates a horizontal scrollable list that works from an explicit
// /// [PageView] of BannerModel or Widget.
// ///
// /// Along with a row of indicators and as an animation for each page change.
// class BannerCarousel extends StatefulWidget {
//   static const IndicatorModel _indicatorModel = IndicatorModel.animation(
//     width: 10,
//     height: 10,
//     spaceBetween: 3.0,
//   );

//   /// [banners] List of BannerModel.
//   /// The [imagePath] can be assert Path or Network Path
//   ///
//   /// List banners = [
//   ///     BannerModel(imagePath: '/assets/banner1.png', id: "1"),
//   ///     BannerModel(imagePath: '"https://picjumbo.com/wp-content/uploads/the-golden-gate-bridge-sunset-1080x720.jpg"', id: "2"),
//   /// ]
//   final List<BannerModel>? banners;

//   /// [animation] teh indicator.
//   /// Default value [true]
//   final bool animation;

//   /// [indicatorBottom]
//   ///
//   /// if the IndicatorRow gonna be Bottom of the carousel = true
//   ///
//   /// IndicatorRow superimposed on carousel = false
//   ///
//   /// Default value [true]
//   final bool indicatorBottom;

//   final bool showIndicator;

//   /// The [height] is banner carousel height.
//   ///
//   /// Default value [150]
//   final double height;

//   /// The [width] is banner carousel height.
//   ///
//   /// Default value [double.maxFinite]
//   ///
//   /// In the FullScreen Carousel this field is not available
//   final double width;

//   /// Default value [0]
//   final int initialPage;

//   /// The fraction of the viewport that each page should occupy.
//   ///
//   /// Defaults to 1.0, which means each page fills the viewport in the scrolling
//   /// direction.
//   final double viewportFraction;

//   /// Default value [5]
//   ///
//   ///  In full screen is [0]
//   final double borderRadius;

//   /// The [margin] around the component.
//   ///
//   /// Default value [EdgeInsets.symmetric(horizontal: 16.0)]
//   final EdgeInsetsGeometry? margin;

//   /// Default value [Color(0xFF10306D)]
//   final Color? activeColor;

//   /// Default value [Color(0xFFC4C4C4)]
//   final Color? disableColor;

//   /// Default value [IndicatorModel.animation(width: 10, height: 10, spaceBetween: 3.0)]
//   final IndicatorModel customizedIndicators;

//   /// Called whenever the page in the center of the viewport changes.
//   /// Return a [int]
//   final ValueChanged<int>? onPageChanged;

//   /// Called whenever the Banner is Tap.
//   final Function(String id)? onTap;

//   ///When you need to create your own Widget banners
//   final List<Widget>? customizedBanners;

//   /// Margin between the banner
//   final double spaceBetween;

//   /// Margin between the banner
//   final PageController? pageController;

//   /// ```dart
//   ///  BannersCarousel(banners: BannerImages.listBanners)
//   /// ```
//   const BannerCarousel({
//     Key? key,
//     this.banners,
//     this.height = 150,
//     this.borderRadius = 5,
//     this.width = double.maxFinite,
//     this.margin,
//     this.indicatorBottom = true,
//     this.showIndicator = true,
//     this.disableColor,
//     this.onTap,
//     this.viewportFraction = 1.0,
//     this.onPageChanged,
//     this.initialPage = 0,
//     this.activeColor,
//     this.animation = true,
//     this.customizedIndicators = _indicatorModel,
//     this.customizedBanners,
//     this.spaceBetween = 0,
//     this.pageController,
//   })  : assert(banners != null || customizedBanners != null,
//             'banners or customizedBanners need to be implemented'),
//         assert(
//             banners == null || customizedBanners == null,
//             'Cannot provide both a banners and a customizedBanners\n'
//             'Choose only one to implement'),
//         super(key: key);

//   ///
//   /// ```dart
//   /// BannersCarousel.fullScreen(banners: BannerImages.listBanners),
//   /// ```
//   const BannerCarousel.fullScreen({
//     Key? key,
//     this.banners,
//     this.height = 150,
//     this.borderRadius = 0,
//     this.viewportFraction = 1.0,
//     this.initialPage = 0,
//     this.disableColor,
//     this.onPageChanged,
//     this.indicatorBottom = true,
//     this.onTap,
//     this.showIndicator = true,
//     this.activeColor,
//     this.animation = true,
//     this.customizedBanners,
//     this.customizedIndicators = _indicatorModel,
//     this.pageController,
//   })  : this.width = double.maxFinite,
//         this.spaceBetween = 0.0,
//         this.margin = EdgeInsets.zero,
//         assert(banners != null || customizedBanners != null,
//             'banners or customizedBanners need to be implemented'),
//         assert(
//             banners == null || customizedBanners == null,
//             'Cannot provide both a banners and a customizedBanners\n'
//             'Choose only one to implement'),
//         super(key: key);

//   @override
//   _BannerCarouselState createState() => _BannerCarouselState();
// }

// class _BannerCarouselState extends State<BannerCarousel> {
//   late int _page;

//   @override
//   void initState() {
//     _page = widget.initialPage;
//     super.initState();
//   }

//   /// Shadow Banner
//   bool get _showShadow =>
//       widget.viewportFraction == 1 && widget.customizedBanners == null;
//   Color get _shadowColor => Colors.black.withOpacity(_showShadow ? 0.25 : 0.0);

//   Color get _activeColor => widget.activeColor ?? const Color(0xFF10306D);
//   Color get _disableColor => widget.disableColor ?? const Color(0xFFC4C4C4);

//   List<dynamic> get _banners => widget.customizedBanners ?? widget.banners!;

//   List<Widget> get _listBanners =>
//       widget.customizedBanners ??
//       widget.banners!
//           .map((banner) => BannerWidget(
//                 key: Key("Banner${banner.id}"),
//                 bannerModel: banner,
//                 spaceBetween: widget.spaceBetween,
//                 onTap: widget.onTap != null
//                     ? () => widget.onTap!(banner.id)
//                     : () => print("Double Tap Banner ${banner.id}"),
//                 borderRadius: widget.borderRadius,
//               ))
//           .toList();

//   List<Widget> get rowIndicator => _banners
//       .asMap()
//       .entries
//       .map((e) => CarouselIndicatorWidget(
//             key: Key("Indicator${e.key}"),
//             active: _page == e.key,
//             color: _page == e.key ? _activeColor : _disableColor,
//             animation: widget.animation,
//             sizeIndicator: widget.customizedIndicators,
//           ))
//       .toList();

//   double get _totalHeigth => widget.indicatorBottom && widget.showIndicator
//       ? widget.height + widget.customizedIndicators.heightExpanded + 15
//       : widget.height;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: _totalHeigth,
//       width: widget.width,
//       margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Stack(
//         children: [
//           Container(
//             decoration: _boxDecoration,
//             height: widget.height,
//             child: PageView(
//               controller: widget.pageController ??
//                   PageController(
//                     initialPage: widget.initialPage,
//                     viewportFraction: widget.viewportFraction,
//                   ),
//               onPageChanged: (index) => _onChangePage(index),
//               children: _listBanners,
//             ),
//           ),
//           widget.showIndicator ? _indicatorRow : const SizedBox()
//         ],
//       ),
//     );
//   }

//   Align get _indicatorRow => Align(
//         alignment: Alignment.bottomCenter,
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: rowIndicator,
//           ),
//         ),
//       );

//   BoxDecoration get _boxDecoration => BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: _shadowColor,
//             spreadRadius: 0,
//             blurRadius: 4,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       );

//   /// Method for when to change the page
//   /// returning an integer value
//   void _onChangePage(int index) {
//     if (widget.onPageChanged != null) {
//       widget.onPageChanged!(index);
//     }
//     setState(() => _page = index);
//   }
// }

// import 'package:banner_carousel/banner_carousel.dart';
import 'package:flutter/material.dart';

// TODO: Add below packages to dependencies
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';

import 'banner_model.dart';
import 'banner_widget.dart';
import 'indicator_model.dart';
import 'indicators_widget.dart';
import 'dart:math' as math;

/// Creates a horizontal scrollable list that works from an explicit
/// [PageView] of BannerModel or Widget.
///
/// Along with a row of indicators and as an animation for each page change.
class BannerCarousel extends StatefulWidget {
  static const IndicatorModel _indicatorModel = IndicatorModel.animation(
    width: 10,
    height: 10,
    spaceBetween: 3.0,
  );

  /// [banners] List of BannerModel.
  /// The [imagePath] can be assert Path or Network Path
  ///
  /// List banners = [
  ///     BannerModel(imagePath: '/assets/banner1.png', id: "1"),
  ///     BannerModel(imagePath: '"https://picjumbo.com/wp-content/uploads/the-golden-gate-bridge-sunset-1080x720.jpg"', id: "2"),
  /// ]
  final List<BannerModel>? banners;

  /// [animation] teh indicator.
  /// Default value [true]
  final bool animation;

  /// [indicatorBottom]
  ///
  /// if the IndicatorRow gonna be Bottom of the carousel = true
  ///
  /// IndicatorRow superimposed on carousel = false
  ///
  /// Default value [true]
  final bool indicatorBottom;

  final bool showIndicator;

  /// The [height] is banner carousel height.
  ///
  /// Default value [150]
  final double height;

  /// The [width] is banner carousel height.
  ///
  /// Default value [double.maxFinite]
  ///
  /// In the FullScreen Carousel this field is not available
  final double width;

  /// Default value [0]
  final int initialPage;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  /// Default value [5]
  ///
  ///  In full screen is [0]
  final double borderRadius;

  /// The [margin] around the component.
  ///
  /// Default value [EdgeInsets.symmetric(horizontal: 16.0)]
  final EdgeInsetsGeometry? margin;

  /// Default value [Color(0xFF10306D)]
  final Color? activeColor;

  /// Default value [Color(0xFFC4C4C4)]
  final Color? disableColor;

  /// Default value [IndicatorModel.animation(width: 10, height: 10, spaceBetween: 3.0)]
  final IndicatorModel customizedIndicators;

  /// Called whenever the page in the center of the viewport changes.
  /// Return a [int]
  final ValueChanged<int>? onPageChanged;

  /// Called whenever the Banner is Tap.
  final Function(int id)? onTap;

  ///When you need to create your own Widget banners
  final List<Widget>? customizedBanners;

  /// Margin between the banner
  final double spaceBetween;

  /// Margin between the banner
  final PageController? pageController;
  final double scaleFactor;
  final Alignment? verticalAlignment;
  final bool cachedNetworkImage;

  /// ```dart
  ///  BannersCarousel(banners: BannerImages.listBanners)
  /// ```
  const BannerCarousel({
    Key? key,
    this.banners,
    this.height = 150,
    this.borderRadius = 5,
    this.width = double.maxFinite,
    this.margin,
    this.indicatorBottom = true,
    this.showIndicator = true,
    this.disableColor,
    this.onTap,
    this.viewportFraction = 1.0,
    this.onPageChanged,
    this.initialPage = 0,
    this.activeColor,
    this.animation = true,
    this.customizedIndicators = _indicatorModel,
    this.customizedBanners,
    this.spaceBetween = 0,
    this.pageController,
    required this.scaleFactor,
    this.verticalAlignment,
    required this.cachedNetworkImage,
  })  : assert(banners != null || customizedBanners != null,
            'banners or customizedBanners need to be implemented'),
        assert(
            banners == null || customizedBanners == null,
            'Cannot provide both a banners and a customizedBanners\n'
            'Choose only one to implement'),
        super(key: key);

  ///
  /// ```dart
  /// BannersCarousel.fullScreen(banners: BannerImages.listBanners),
  /// ```
  const BannerCarousel.fullScreen({
    Key? key,
    this.banners,
    this.height = 150,
    this.borderRadius = 0,
    this.viewportFraction = 1.0,
    this.initialPage = 0,
    this.disableColor,
    this.onPageChanged,
    this.indicatorBottom = true,
    this.onTap,
    this.showIndicator = true,
    this.activeColor,
    this.animation = true,
    this.customizedBanners,
    this.customizedIndicators = _indicatorModel,
    this.pageController,
    required this.scaleFactor,
    this.verticalAlignment,
    required this.cachedNetworkImage,
  })  : this.width = double.maxFinite,
        this.spaceBetween = 0.0,
        this.margin = EdgeInsets.zero,
        assert(banners != null || customizedBanners != null,
            'banners or customizedBanners need to be implemented'),
        assert(
            banners == null || customizedBanners == null,
            'Cannot provide both a banners and a customizedBanners\n'
            'Choose only one to implement'),
        super(key: key);

  @override
  _BannerCarouselState createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late int _page;
  late PageController _pageController;
  double _currentPageValue = 0.0;

  @override
  void initState() {
    _page = widget.initialPage;
    super.initState();
    _pageController = PageController(
        viewportFraction: widget.viewportFraction.clamp(0.5, 1.0));
    _pageController.addListener(() {
      setState(() {
        _currentPageValue = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  /// Shadow Banner
  bool get _showShadow =>
      widget.viewportFraction == 1 && widget.customizedBanners == null;
  Color get _shadowColor => Colors.black.withOpacity(_showShadow ? 0.25 : 0.0);

  Color get _activeColor => widget.activeColor ?? const Color(0xFF10306D);
  Color get _disableColor => widget.disableColor ?? const Color(0xFFC4C4C4);

  List<dynamic> get _banners => widget.customizedBanners ?? widget.banners!;

  List<Widget> get _listBanners =>
      widget.customizedBanners ??
      widget.banners!
          .map((banner) => BannerWidget(
                key: Key("Banner${banner.id}"),
                bannerModel: banner,
                spaceBetween: widget.spaceBetween,
                onTap: widget.onTap != null
                    ? () => widget.onTap!(banner.id as int)
                    : () => print("Double Tap Banner ${banner.id}"),
                borderRadius: widget.borderRadius,
              ))
          .toList();

  List<Widget> get rowIndicator => _banners
      .asMap()
      .entries
      .map((e) => CarouselIndicatorWidget(
            key: Key("Indicator${e.key}"),
            active: _page == e.key,
            color: _page == e.key ? _activeColor : _disableColor,
            animation: widget.animation,
            sizeIndicator: widget.customizedIndicators,
          ))
      .toList();

  double get _totalHeigth => widget.indicatorBottom && widget.showIndicator
      ? widget.height + widget.customizedIndicators.heightExpanded + 15
      : widget.height;

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: _totalHeigth,
      width: widget.width,
      // margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                return PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: widget.pageController ?? _pageController,
                  itemCount: _listBanners.length,
                  itemBuilder: (context, position) {
                    double value = (1 -
                            ((_currentPageValue - position).abs() *
                                (1 - widget.scaleFactor)))
                        .clamp(0.0, 1.0);
                    return Container(
                      margin: EdgeInsets.all(widget.spaceBetween),
                      child: Stack(
                        children: <Widget>[
                          SizedBox(
                            height:
                                Curves.ease.transform(value) * widget.height,
                            child: child,
                          ),
                          Align(
                            alignment: widget.verticalAlignment != null
                                ? widget.verticalAlignment!
                                : Alignment.center,
                            child: SizedBox(
                              height:
                                  Curves.ease.transform(value) * widget.height,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    widget.borderRadius != null
                                        ? widget.borderRadius!
                                        : 16.0),
                                child: Transform.translate(
                                  offset: Offset(
                                      (_currentPageValue - position) *
                                          _width /
                                          4 *
                                          math.pow(widget.viewportFraction, 3),
                                      0),
                                  child: widget.banners![position].imagePath
                                          .startsWith('http')
                                      ? widget.cachedNetworkImage
                                          ? CachedNetworkImage(
                                              imageUrl: widget
                                                  .banners![position].imagePath,
                                              // width: double.infinity,
                                              // height: double.infinity,
                                              imageBuilder: (context, image) =>
                                                  GestureDetector(
                                                onTap: () => widget.onTap !=
                                                        null
                                                    ? widget.onTap!(position)
                                                    : () {},
                                                child: Image(
                                                  image: image,
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () => widget.onTap != null
                                                  ? widget.onTap!(position)
                                                  : () {},
                                              child: FadeInImage.memoryNetwork(
                                                placeholder: kTransparentImage,
                                                image: widget.banners![position]
                                                    .imagePath,
                                                fit: BoxFit.cover,
                                                height: double.infinity,
                                                width: double.infinity,
                                              ),
                                            )
                                      : GestureDetector(
                                          onTap: () => widget.onTap != null
                                              ? widget.onTap!(position)
                                              : () {},
                                          child: Image.asset(
                                            widget.banners![position].imagePath,
                                            fit: BoxFit.cover,
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  onPageChanged: (index) => _onChangePage(index),
                );
              },
            ),
          ),
          widget.showIndicator ? _indicatorRow : const SizedBox()
        ],
      ),
    );
  }

  Align get _indicatorRow => Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowIndicator,
          ),
        ),
      );

  BoxDecoration get _boxDecoration => BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _shadowColor,
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      );

  /// Method for when to change the page
  /// returning an integer value
  void _onChangePage(int index) {
    if (widget.onPageChanged != null) {
      widget.onPageChanged!(index);
    }
    setState(() => _page = index);
  }
}
