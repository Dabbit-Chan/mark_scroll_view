library mark_scroll_view;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class MarkScrollModel<T> {
  final String tag;
  final List<T> children;

  const MarkScrollModel({
    required this.tag,
    required this.children,
  });
}

class MarkBarOption {
  final AlignmentGeometry? alignment;
  final Decoration Function(int focusIndex, int index)? decorationBuilder;
  final ShapeBorder? shape;
  final Color? focusColor;
  final Color? defaultColor;
  final EdgeInsetsGeometry? margin;
  final Size? size;

  const MarkBarOption({
    this.alignment,
    this.decorationBuilder,
    this.shape,
    this.focusColor,
    this.defaultColor,
    this.margin,
    this.size,
  });
}

class MarkScrollView<T> extends StatefulWidget {
  const MarkScrollView({
    Key? key,
    required this.dataList,
    required this.susBuilder,
    required this.itemBuilder,
    required this.markBuilder,
    this.markBarBuilder,
    this.markBarOption = const MarkBarOption(),
  }) : super(key: key);

  final List<MarkScrollModel<T>> dataList;
  final Widget Function(BuildContext context, int index) susBuilder;
  final Widget Function(BuildContext context, int mainIndex, int index) itemBuilder;
  final Widget Function(BuildContext context, int index) markBuilder;
  final Widget Function(BuildContext context)? markBarBuilder;
  final MarkBarOption markBarOption;

  @override
  State<MarkScrollView> createState() => _MarkScrollViewState();
}

class _MarkScrollViewState extends State<MarkScrollView> {
  late final SliverObserverController sliverObserverController;
  final scrollController = ScrollController();
  List<BuildContext> contextList = [];

  ValueNotifier<int> focusIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    sliverObserverController = SliverObserverController(controller: scrollController);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliverViewObserver(
          controller: sliverObserverController,
          sliverContexts: () => contextList,
          child: CustomScrollView(
            controller: scrollController,
            slivers: List.generate(widget.dataList.length, (mainIndex) {
              return SliverStickyHeader.builder(
                builder: (context, state) {
                  if (state.isPinned && focusIndex.value != mainIndex) {
                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      focusIndex.value = mainIndex;
                    });
                  }
                  return widget.susBuilder(context, mainIndex);
                },
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (contextList.length < mainIndex + 1) {
                        contextList.add(context);
                      }
                      return widget.itemBuilder(context, mainIndex, index);
                    },
                    childCount: widget.dataList[mainIndex].children.length,
                  ),
                ),
              );
            }),
          ),
        ),
        Align(
          alignment: widget.markBarOption.alignment ?? Alignment.centerRight,
          child: ValueListenableBuilder<int>(
            valueListenable: focusIndex,
            builder: (_, __, ___) {
              double itemHeight =
                  (widget.markBarOption.size?.height ?? 20) + (widget.markBarOption.margin?.vertical ?? 10);
              return GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragDown: (detail) {
                  double dy = detail.localPosition.dy;
                  int value = dy % ((widget.dataList.length) * itemHeight) ~/ itemHeight;
                  sliverObserverController.jumpTo(
                    sliverContext: contextList[value],
                    index: 0,
                  );
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    focusIndex.value = value;
                  });
                },
                onVerticalDragUpdate: (detail) {
                  double dy = detail.localPosition.dy;
                  int value = dy %
                      ((widget.dataList.length) * itemHeight) ~/
                      itemHeight;
                  sliverObserverController.jumpTo(
                    sliverContext: contextList[value],
                    index: 0,
                  );
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    focusIndex.value = value;
                  });
                },
                child: widget.markBarBuilder != null
                    ? widget.markBarBuilder!(context)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(widget.dataList.length, (index) {
                          return Container(
                            decoration:
                                widget.markBarOption.decorationBuilder != null
                                    ? widget.markBarOption.decorationBuilder!(focusIndex.value, index)
                                    : ShapeDecoration(
                                        shape: widget.markBarOption.shape ?? const CircleBorder(),
                                        color: focusIndex.value == index
                                            ? widget.markBarOption.focusColor ?? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                                            : widget.markBarOption.defaultColor ?? Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                                      ),
                            margin: widget.markBarOption.margin ?? const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
                            width: widget.markBarOption.size?.width ?? 20,
                            height: widget.markBarOption.size?.height ?? 20,
                            alignment: Alignment.center,
                            child: widget.markBuilder(context, index),
                          );
                        }),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
