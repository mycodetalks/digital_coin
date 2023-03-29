import 'dart:ui' as ui show window;

import 'package:flutter/material.dart';

@immutable
class PhoneTabletBuilder extends StatefulWidget {
  const PhoneTabletBuilder({
    super.key,
    required this.builder,
    this.child,
  });

  final Widget Function(BuildContext context, bool isPhone, bool isPortrait, Widget? child) builder;
  final Widget? child;

  @override
  State<PhoneTabletBuilder> createState() => _PhoneTabletBuilderState();
}

class _PhoneTabletBuilderState extends State<PhoneTabletBuilder> with WidgetsBindingObserver {
  bool? _lastIsPhone;
  bool? _lastIsPortrait;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastIsPhone = _platformIsPhone();
    _lastIsPortrait = platformIsPortrait();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _platformIsPhone() {
    final mediaQueryData = MediaQueryData.fromWindow(ui.window);
    return mediaQueryData.size.shortestSide < 600.0;
  }

  bool platformIsPortrait() {
    final mediaQueryData = MediaQueryData.fromWindow(ui.window);
    return mediaQueryData.size.aspectRatio < 1.0;
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final isPhone = _platformIsPhone();
    if (isPhone != _lastIsPhone) {
      setState(() => _lastIsPhone = isPhone);
    }
    final isPortrait = platformIsPortrait();
    if (isPortrait != _lastIsPortrait) {
      setState(() => _lastIsPortrait = isPortrait);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _lastIsPhone!, _lastIsPortrait!, widget.child);
  }
}
