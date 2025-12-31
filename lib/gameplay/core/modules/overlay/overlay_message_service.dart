import 'dart:async';

enum OverlayMessageType {
  warning,
  error,
  info,
  success,
}

class OverlayMessage {
  final String text;
  final OverlayMessageType type;
  final Duration duration;

  const OverlayMessage({
    required this.text,
    required this.type,
    this.duration = const Duration(milliseconds: 1500),
  });
}

class OverlayMessageService {
  OverlayMessageService._();

  static final OverlayMessageService instance = OverlayMessageService._();

  final StreamController<OverlayMessage> _messageController =
      StreamController<OverlayMessage>.broadcast();

  Stream<OverlayMessage> get messageStream => _messageController.stream;

  void showWarning(String text, {Duration? duration}) {
    _messageController.add(
      OverlayMessage(
        text: text,
        type: OverlayMessageType.warning,
        duration: duration ?? const Duration(milliseconds: 1500),
      ),
    );
  }

  void showError(String text, {Duration? duration}) {
    _messageController.add(
      OverlayMessage(
        text: text,
        type: OverlayMessageType.error,
        duration: duration ?? const Duration(milliseconds: 2000),
      ),
    );
  }

  void showInfo(String text, {Duration? duration}) {
    _messageController.add(
      OverlayMessage(
        text: text,
        type: OverlayMessageType.info,
        duration: duration ?? const Duration(milliseconds: 1500),
      ),
    );
  }

  void showSuccess(String text, {Duration? duration}) {
    _messageController.add(
      OverlayMessage(
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
