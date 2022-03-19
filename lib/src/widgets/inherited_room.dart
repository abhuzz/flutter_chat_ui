import 'package:flutter/widgets.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// Used to make provided [types.Room] class available through the whole package
class InheritedRoom extends InheritedWidget {
  /// Creates [InheritedWidget] from a provided [types.Room] class
  const InheritedRoom({
    Key? key,
    required this.room,
    required Widget child,
  }) : super(key: key, child: child);

  /// Represents current logged in room. Used to determine message's author.
  final types.Room room;

  static InheritedRoom of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedRoom>()!;
  }

  @override
  bool updateShouldNotify(InheritedRoom oldWidget) =>
      room.id != oldWidget.room.id;
}
