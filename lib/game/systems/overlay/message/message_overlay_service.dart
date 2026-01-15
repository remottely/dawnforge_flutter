import 'dart:async';

enum OverlayMessageType { warning, error, info, success }

class MessageOverlayData {
  final String text;
  final OverlayMessageType type;
  final Duration duration;

  const MessageOverlayData({
    required this.text,
    required this.type,
    this.duration = const Duration(milliseconds: 1500),
  });
}

class MessageOverlayService {
  MessageOverlayService._();

  static final instance = MessageOverlayService._();

  final StreamController<MessageOverlayData> _messageController =
      StreamController<MessageOverlayData>.broadcast();

  Stream<MessageOverlayData> get messageStream => _messageController.stream;

  void showWarning(String text, {Duration? duration}) {
    _messageController.add(
      MessageOverlayData(
        text: text,
        type: OverlayMessageType.warning,
        duration: duration ?? const Duration(milliseconds: 1500),
      ),
    );
  }

  void showError(String text, {Duration? duration}) {
    _messageController.add(
      MessageOverlayData(
        text: text,
        type: OverlayMessageType.error,
        duration: duration ?? const Duration(milliseconds: 2000),
      ),
    );
  }

  void showInfo(String text, {Duration? duration}) {
    _messageController.add(
      MessageOverlayData(
        text: text,
        type: OverlayMessageType.info,
        duration: duration ?? const Duration(milliseconds: 1500),
      ),
    );
  }

  void showSuccess(String text, {Duration? duration}) {
    _messageController.add(
      MessageOverlayData(
        text: text,
        type: OverlayMessageType.success,
        duration: duration ?? const Duration(milliseconds: 1500),
      ),
    );
  }

  void dispose() {
    _messageController.close();
  }
}
