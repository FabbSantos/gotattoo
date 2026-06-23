import 'package:flutter/widgets.dart';

/// App-wide route observer so pages (e.g. the home) can refresh when a pushed
/// route is popped and they become visible again.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
