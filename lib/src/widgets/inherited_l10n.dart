import 'package:flutter/widgets.dart';
import 'package:flutter_chat_ui/src/chat_strings.dart';

/// Used to make provided [ChatL10n] class available through the whole package
class InheritedL10n extends InheritedWidget {
  /// Creates [InheritedWidget] from a provided [ChatL10n] class
  const InheritedL10n({
    Key? key,
    required this.chatStrings,
    required Widget child,
  }) : super(key: key, child: child);

  /// Represents localized copy
  final ChatStrings chatStrings;

  static InheritedL10n of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<InheritedL10n>()!;
  }

  @override
  bool updateShouldNotify(InheritedL10n oldWidget) =>
      chatStrings.hashCode != oldWidget.chatStrings.hashCode;
}
