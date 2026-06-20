import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intro_views_flutter/src/animation_gesture/animated_page_dragger.dart';
import 'package:intro_views_flutter/src/animation_gesture/page_dragger.dart';
import 'package:intro_views_flutter/src/animation_gesture/page_reveal.dart';
import 'package:intro_views_flutter/src/helpers/constants.dart';
import 'package:intro_views_flutter/src/models/page_view_model.dart';
import 'package:intro_views_flutter/src/models/pager_indicator_view_model.dart';
import 'package:intro_views_flutter/src/models/slide_update_model.dart';
import 'package:intro_views_flutter/src/ui/page.dart' as into_ui_page;
import 'package:intro_views_flutter/src/ui/page_indicator_buttons.dart';
import 'package:intro_views_flutter/src/ui/pager_indicator.dart';

class CustomIntroViews extends StatefulWidget {
  const CustomIntroViews(
    this.pages, {
    Key? key,
    this.onTapDoneButton,
    this.showSkipButton = true,
    this.pageButtonTextStyles,
    this.onTapBackButton,
    this.showNextButton = false,
    this.showBackButton = false,
    this.pageButtonTextSize = 18.0,
    this.pageButtonFontFamily,
    this.onTapSkipButton,
    this.onTapNextButton,
    this.pageButtonsColor = const Color(0x88FFFFFF),
    this.doneText = const Text('DONE'),
    this.nextText = const Text('NEXT'),
    this.skipText = const Text('SKIP'),
    this.backText = const Text('BACK'),
    this.doneButtonPersist = false,
    this.showPagerIndicator = true,
    this.initialPage = 0,
    this.columnMainAxisAlignment = MainAxisAlignment.spaceAround,
    this.fullTransition = FULL_TRANSITION_PX,
    this.background,
  })  : assert(
          pages.length > 0,
          "At least one 'PageViewModel' item of 'pages' argument is required.",
        ),
        super(key: key);

  final List<PageViewModel> pages;
  final VoidCallback? onTapDoneButton;
  final Color pageButtonsColor;
  final bool showSkipButton;
  final bool showNextButton;
  final bool showBackButton;
  final TextStyle? pageButtonTextStyles;
  final VoidCallback? onTapSkipButton;
  final VoidCallback? onTapNextButton;
  final VoidCallback? onTapBackButton;
  final double pageButtonTextSize;
  final String? pageButtonFontFamily;
  final Widget doneText;
  final Widget backText;
  final Widget nextText;
  final Widget skipText;
  final bool doneButtonPersist;
  final bool showPagerIndicator;
  final int initialPage;
  final MainAxisAlignment columnMainAxisAlignment;
  final double fullTransition;
  final Color? background;

  @override
  _CustomIntroViewsState createState() => _CustomIntroViewsState();
}

class CustomPage extends StatelessWidget {
  final PageViewModel pageViewModel;
  final double percentVisible;

  const CustomPage({
    super.key,
    required this.pageViewModel,
    this.percentVisible = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: pageViewModel.pageColor,
      child: Opacity(
        opacity: percentVisible,
        child: pageViewModel.body, // We'll put everything in body for now to have full control
      ),
    );
  }
}

class _CustomIntroViewsState extends State<CustomIntroViews>
    with TickerProviderStateMixin {
  late StreamController<SlideUpdate> slideUpdateStream;
  AnimatedPageDragger? animatedPageDragger;
  late int activePageIndex;
  late int nextPageIndex;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;
  StreamSubscription<SlideUpdate>? slideUpdateStreamListener;

  @override
  void initState() {
    super.initState();
    activePageIndex = widget.initialPage;
    nextPageIndex = widget.initialPage;
    slideUpdateStream = StreamController<SlideUpdate>();
    slideUpdateStreamListener =
        slideUpdateStream.stream.listen((SlideUpdate event) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
          if (slideDirection == SlideDirection.leftToRight) {
            nextPageIndex = max(0, activePageIndex - 1);
          } else if (slideDirection == SlideDirection.rightToLeft) {
            nextPageIndex = min(widget.pages.length - 1, activePageIndex + 1);
          } else {
            nextPageIndex = activePageIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          if (slidePercent > 0.5) {
            animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.open,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );
          } else {
            animatedPageDragger = AnimatedPageDragger(
              slideDirection: slideDirection,
              transitionGoal: TransitionGoal.close,
              slidePercent: slidePercent,
              slideUpdateStream: slideUpdateStream,
              vsync: this,
            );
            nextPageIndex = activePageIndex;
          }
          animatedPageDragger?.run();
        } else if (event.updateType == UpdateType.animating) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          activePageIndex = nextPageIndex;
          slideDirection = SlideDirection.none;
          slidePercent = 0.0;
        }
      });
    });
  }

  @override
  void dispose() {
    slideUpdateStreamListener?.cancel();
    animatedPageDragger?.dispose();
    slideUpdateStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: widget.pageButtonTextSize,
      color: widget.pageButtonsColor,
      fontFamily: widget.pageButtonFontFamily,
    ).merge(widget.pageButtonTextStyles);

    final pages = widget.pages;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: widget.background,
      body: Stack(
        children: <Widget>[
          CustomPage(
            pageViewModel: pages[activePageIndex],
            percentVisible: 1.0,
          ),
          PageReveal(
            revealPercent: slidePercent,
            child: CustomPage(
                pageViewModel: pages[nextPageIndex],
                percentVisible: slidePercent),
          ),
          if (widget.showPagerIndicator)
            PagerIndicator(
              viewModel: PagerIndicatorViewModel(
                pages,
                activePageIndex,
                slideDirection,
                slidePercent,
              ),
            ),
          PageIndicatorButtons(
            textStyle: textStyle,
            activePageIndex: activePageIndex,
            totalPages: pages.length,
            onPressedDoneButton: widget.onTapDoneButton,
            slidePercent: slidePercent,
            slideDirection: slideDirection,
            onPressedSkipButton: () {
              setState(() {
                activePageIndex = pages.length - 1;
                nextPageIndex = activePageIndex;
                if (widget.onTapSkipButton != null) {
                  widget.onTapSkipButton!();
                }
              });
            },
            showSkipButton: widget.showSkipButton,
            showNextButton: widget.showNextButton,
            showBackButton: widget.showBackButton,
            onPressedNextButton: () {
              setState(() {
                activePageIndex = min(pages.length - 1, activePageIndex + 1);
                nextPageIndex = min(pages.length - 1, nextPageIndex + 1);
                if (widget.onTapNextButton != null) {
                  widget.onTapNextButton!();
                }
              });
            },
            onPressedBackButton: () {
              setState(() {
                activePageIndex = max(0, activePageIndex - 1);
                nextPageIndex = max(0, nextPageIndex - 1);
                if (widget.onTapBackButton != null) {
                  widget.onTapBackButton!();
                }
              });
            },
            nextText: widget.nextText,
            doneText: widget.doneText,
            backText: widget.backText,
            skipText: widget.skipText,
            doneButtonPersist: widget.doneButtonPersist,
          ),
          PageDragger(
            fullTransitionPX: widget.fullTransition,
            canDragLeftToRight: activePageIndex > 0,
            canDragRightToLeft: activePageIndex < pages.length - 1,
            slideUpdateStream: slideUpdateStream,
          ),
        ],
      ),
    );
  }
}
