import 'package:event_bus/event_bus.dart';

/// Event
class EventUtil {
  /// 创建EventBus
  EventBus eventBus = EventBus();

  String message;
  Object object;

  EventUtil(this.message, this.object);
}