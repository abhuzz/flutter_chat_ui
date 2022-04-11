import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:intl/intl.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../flutter_chat_ui.dart';
import '../models/emoji_enlargement_behavior.dart';
import '../models/preview_tap_options.dart';
import '../util.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'text_message.dart';
import 'user_avatar.dart';

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.avatarBuilder,
    this.bubbleBuilder,
    this.customMessageBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageMessageBuilder,
    required this.isTextMessageTextSelectable,
    required this.message,
    // required this.messageStatus,
    // this.messageRendering,
    required this.messageWidth,
    this.nameBuilder,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.previewTapOptions,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.usePreviewData,
    this.dateFormat,
    this.dateLocale,
    this.timeFormat,
  }) : super(key: key);

  /// This is to allow custom user avatar builder
  /// By using this we can fetch newest user info based on id
  final Widget Function(String userId)? avatarBuilder;

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author)
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Build a custom message inside predefined bubble
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// Build an image message inside predefined bubble
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// See [TextMessage.isTextMessageTextSelectable]
  final bool isTextMessageTextSelectable;

  /// Any message type
  final types.Message message;

  // final Stream<List<types.Status>> Function(types.Message) messageStatus;

  /// returns message which populating in screen
  // final Function(types.Message, List<types.Status>?)? messageRendering;
  // final Function(types.Message)? messageRendering;

  /// Maximum message width
  final int messageWidth;

  /// See [TextMessage.nameBuilder]
  final Widget Function(String userId)? nameBuilder;

  /// See [UserAvatar.onAvatarTap]
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on status icon in any message
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message
  final void Function(BuildContext context, types.Message)? onMessageTap;

  /// Called when the message's visibility changes
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [TextMessage.previewTapOptions]
  final PreviewTapOptions previewTapOptions;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName]
  final bool showName;

  /// Show message's status
  final bool showStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  final DateFormat? dateFormat;
  final String? dateLocale;
  final DateFormat? timeFormat;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.usePreviewData]
  final bool usePreviewData;

  Widget _avatarBuilder() => showAvatar
      ? avatarBuilder?.call(message.author.id) ??
          UserAvatar(author: message.author, onAvatarTap: onAvatarTap)
      : const SizedBox(width: 40);

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) {
    return Column(
      crossAxisAlignment: currentUserIsAuthor
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        bubbleBuilder != null
            ? bubbleBuilder!(
                _messageBuilder(),
                message: message,
                nextMessageInGroup: roundBorder,
              )
            : enlargeEmojis && hideBackgroundOnEmojiMessages
                ? _messageBuilder()
                : Container(
                    // padding:
                    //     const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      color: !currentUserIsAuthor ||
                              message.type == types.MessageType.image
                          ? InheritedChatTheme.of(context).theme.secondaryColor
                          : InheritedChatTheme.of(context).theme.primaryColor,
                    ),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: _messageBuilder(),
                    ),
                  ),
        const SizedBox(
          height: 2,
        ),
        if (message.createdAt != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                messageTime(
                  DateTime.fromMillisecondsSinceEpoch(message.createdAt!),
                  dateLocale: dateLocale,
                  timeFormat: timeFormat,
                ),
                textAlign: TextAlign.end,
                style:
                    InheritedChatTheme.of(context).theme.messageTimeTextStyle,
              ),
              const SizedBox(
                width: 8,
              ),
            ],
          ),
        const SizedBox(
          height: 2,
        ),
      ],
    );
  }

  Widget _messageBuilder() {
    switch (message.type) {
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(message: fileMessage);
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(message: imageMessage, messageWidth: messageWidth);
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                isTextMessageTextSelectable: isTextMessageTextSelectable,
                message: textMessage,
                nameBuilder: nameBuilder,
                onPreviewDataFetched: onPreviewDataFetched,
                previewTapOptions: previewTapOptions,
                showName: showName,
                usePreviewData: usePreviewData,
              );
      default:
        return const SizedBox();
    }
  }

  types.StatusType? calculateStatus(List<types.Status> statusList) {
    int count = 100;
    for (var status in statusList) {
      types.StatusType? type = status.status;
      if (count > 0 && type == types.StatusType.error) {
        count = 1;
      } else if (count > 1 && type == types.StatusType.sending) {
        count = 2;
      } else if (count > 2 && type == types.StatusType.sent) {
        count = 3;
      } else if (count > 3 && type == types.StatusType.delivered) {
        count = 4;
      } else if (count > 4 && type == types.StatusType.seen) {
        count = 5;
      }
    }

    if (count == 1) {
      return types.StatusType.error;
    } else if (count == 2) {
      return types.StatusType.sending;
    } else if (count == 3) {
      return types.StatusType.sent;
    } else if (count == 4) {
      return types.StatusType.delivered;
    } else if (count == 5) {
      return types.StatusType.seen;
    }

    return null;
  }

  Widget _statusBuilderForInnerStatus(BuildContext context, types.StatusType? latestStatus) {
    switch (latestStatus) {
      case types.StatusType.delivered:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : Image.asset(
                'assets/icon-delivered.png',
                color: InheritedChatTheme.of(context)
                    .theme
                    .deliveredMessageIconColor,
                package: 'flutter_chat_ui',
              );
      case types.StatusType.sent:
        return InheritedChatTheme.of(context).theme.sentIcon != null
            ? InheritedChatTheme.of(context).theme.sentIcon!
            : Image.asset(
                'assets/icon-delivered.png',
                color:
                    InheritedChatTheme.of(context).theme.sentMessageIconColor,
                package: 'flutter_chat_ui',
              );
      case types.StatusType.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : Image.asset(
                'assets/icon-error.png',
                color: InheritedChatTheme.of(context).theme.errorColor,
                package: 'flutter_chat_ui',
              );
      case types.StatusType.seen:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : Image.asset(
                'assets/icon-seen.png',
                color:
                    InheritedChatTheme.of(context).theme.seenMessageIconColor,
                package: 'flutter_chat_ui',
              );
      case types.StatusType.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      InheritedChatTheme.of(context)
                          .theme
                          .sendingMessageIconColor!,
                    ),
                  ),
                ),
              );
      default:
        return const SizedBox();
    }
  }

  Widget _statusBuilder(BuildContext context) {
    switch (message.status) {
      case types.StatusType.delivered:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : Image.asset(
          'assets/icon-delivered.png',
          color: InheritedChatTheme.of(context)
              .theme
              .deliveredMessageIconColor,
          package: 'flutter_chat_ui',
        );
      case types.StatusType.sent:
        return InheritedChatTheme.of(context).theme.sentIcon != null
            ? InheritedChatTheme.of(context).theme.sentIcon!
            : Image.asset(
          'assets/icon-delivered.png',
          color:
          InheritedChatTheme.of(context).theme.sentMessageIconColor,
          package: 'flutter_chat_ui',
        );
      case types.StatusType.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : Image.asset(
          'assets/icon-error.png',
          color: InheritedChatTheme.of(context).theme.errorColor,
          package: 'flutter_chat_ui',
        );
      case types.StatusType.seen:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : Image.asset(
          'assets/icon-seen.png',
          color: InheritedChatTheme.of(context).theme.primaryColor,
          package: 'flutter_chat_ui',
        );
      case types.StatusType.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : Center(
          child: SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                InheritedChatTheme.of(context).theme.primaryColor,
              ),
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;
    final _currentUserIsAuthor = _user.id == message.author.id;
    final _enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
                emojiEnlargementBehavior, message as types.TextMessage);
    final _messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    final _borderRadius = BorderRadiusDirectional.only(
      bottomEnd: Radius.circular(
        _currentUserIsAuthor
            ? roundBorder
                ? _messageBorderRadius
                : 0
            : _messageBorderRadius,
      ),
      bottomStart: Radius.circular(
        _currentUserIsAuthor || roundBorder ? _messageBorderRadius : 0,
      ),
      topEnd: Radius.circular(_messageBorderRadius),
      topStart: Radius.circular(_messageBorderRadius),
    );

    return Container(
      alignment: _currentUserIsAuthor
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      margin: const EdgeInsetsDirectional.only(
        bottom: 4,
        start: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_currentUserIsAuthor && showUserAvatars) _avatarBuilder(),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: messageWidth.toDouble(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onDoubleTap: () => onMessageDoubleTap?.call(context, message),
                  onLongPress: () => onMessageLongPress?.call(context, message),
                  onTap: () => onMessageTap?.call(context, message),
                  child: onMessageVisibilityChanged != null
                      ? VisibilityDetector(
                          key: Key(message.id),
                          onVisibilityChanged: (visibilityInfo) =>
                              onMessageVisibilityChanged!(message,
                                  visibilityInfo.visibleFraction > 0.1),
                          child: _bubbleBuilder(
                            context,
                            _borderRadius.resolve(Directionality.of(context)),
                            _currentUserIsAuthor,
                            _enlargeEmojis,
                          ),
                        )
                      : _bubbleBuilder(
                          context,
                          _borderRadius.resolve(Directionality.of(context)),
                          _currentUserIsAuthor,
                          _enlargeEmojis,
                        ),
                ),
              ],
            ),
          ),
          if (_currentUserIsAuthor)
          Padding(
            padding: _currentUserIsAuthor
                ? InheritedChatTheme.of(context).theme.statusIconPadding
                : const EdgeInsets.all(0),
            child: GestureDetector(
              onLongPress: () =>
                  onMessageStatusLongPress?.call(context, message),
              onTap: () => onMessageStatusTap?.call(context, message),
              child: _statusBuilder(context),
              // child: message.status != null &&
              //         message.status == types.StatusType.seen
              //     ? _currentUserIsAuthor && showStatus
              //         ? _statusBuilder(context, types.StatusType.seen)
              //         : const SizedBox()
              //     : StreamBuilder<List<types.Status>>(
              //         initialData: const [],
              //         stream: messageStatus(message),
              //         builder: (context, snapshot) {
              //           if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //             return const SizedBox();
              //           }
              //
              //           List<types.Status> statusList = snapshot.data!;
              //           types.StatusType? latestStatus =
              //               calculateStatus(statusList);
              //
              //           if (messageRendering != null) {
              //             messageRendering!(message, statusList);
              //           }
              //
              //           if (_currentUserIsAuthor && showStatus) {
              //             return _statusBuilder(context, latestStatus);
              //           }
              //
              //           return const SizedBox();
              //         },
              //       ),
            ),
          ),
        ],
      ),
    );
  }
}
