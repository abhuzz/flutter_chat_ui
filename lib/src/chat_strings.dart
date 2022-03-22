import 'package:flutter/material.dart';

/// All language strings
@immutable
class ChatStrings {
  const ChatStrings({
    this.attachmentButtonAccessibilityLabel = 'Send media',
    this.emptyChatPlaceholder = 'No messages here yet',
    this.fileButtonAccessibilityLabel = 'File',
    this.inputPlaceholder = 'Message',
    this.sendButtonAccessibilityLabel = 'Send',

    this.pendingTitleForOtherUser = 'Someone requested you to start chat',
    this.pendingTitleForMe = 'You have sent chat request',
    this.acceptButtonText = 'Accept',
    this.rejectButtonText = 'Reject',
    this.blockButtonText = 'Block',
    this.cancelRequestButtonText = 'Cancel request',

    this.rejectTitleForOtherUser = 'Your request was rejected',
    this.rejectTitleForMe = 'Your request got rejected',
    this.sendRequestButtonText = 'Send Chat Request',


    this.blockTitleForOtherUser = 'Other person blocked you for chat',
    this.blockTitleForMe = 'You have blocked chat',
    this.unBlockButtonText = 'UnBlock',

    this.cancelTitleForOtherUser = 'To start chat send request',
    this.cancelTitleForMe = 'You Have canceled chat request. Do you want to send back?',
    this.sendRequestButtonOnCancelText = 'Request',
  });

  final String attachmentButtonAccessibilityLabel;
  final String emptyChatPlaceholder;
  final String fileButtonAccessibilityLabel;
  final String inputPlaceholder;
  final String sendButtonAccessibilityLabel;

  final String pendingTitleForOtherUser;
  final String pendingTitleForMe;
  final String acceptButtonText;
  final String rejectButtonText;
  final String blockButtonText;
  final String cancelRequestButtonText;

  final String rejectTitleForOtherUser;
  final String rejectTitleForMe;
  final String sendRequestButtonText;

  final String blockTitleForOtherUser;
  final String blockTitleForMe;
  final String unBlockButtonText;

  final String cancelTitleForOtherUser;
  final String cancelTitleForMe;
  final String sendRequestButtonOnCancelText;
}