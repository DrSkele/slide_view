part of slideview;

class SlideController {
  final bool autoSlide;
  final Duration slideInterval;
  final Duration slideDuration;
  final Curve slideCurve;

  late final PageController pageController;
  int _index = 0;

  int get index => _index;

  SlideController({
    this.autoSlide = false,
    this.slideInterval = const Duration(seconds: 3),
    this.slideDuration = const Duration(milliseconds: 500),
    this.slideCurve = Curves.fastOutSlowIn,
  });

  void dispose() {
    pageController.dispose();
  }

  Timer? startAutoSlide() {
    return Timer.periodic(slideInterval, (timer) {
      pageController.nextPage(
        duration: slideDuration,
        curve: slideCurve,
      );
    });
  }

  Future nextSlide({Duration? duration}) {
    return pageController.nextPage(
      duration: duration ?? slideDuration,
      curve: slideCurve,
    );
  }

  Future previousSlide({Duration? duration}) {
    return pageController.previousPage(
      duration: duration ?? slideDuration,
      curve: slideCurve,
    );
  }
}
