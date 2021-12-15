import 'package:get_it/get_it.dart';

import '../utils/event_bus.dart';

final _locator = GetIt.instance..allowReassignment = true;
final _eventBus = EventBus();

GetIt get locator => _locator;
EventBus get eventBus => _eventBus;
