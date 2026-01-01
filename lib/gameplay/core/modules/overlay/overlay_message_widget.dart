import 'dart:async';

import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_service.dart';
import 'package:flutter/material.dart';

class OverlayMessageWidget extends StatefulWidget {
  const OverlayMessageWidget({super.key});

  @override
  State<OverlayMessageWidget> createState() => _OverlayMessageWidgetState();
}

class _OverlayMessageWidgetState extends State<OverlayMessageWidget>
    with SingleTickerProviderStateMixin {
  StreamSubscription<OverlayMessage>? _subscription;
  OverlayMessage? _currentMessage;
  Timer? _hideTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _subscription = OverlayMessageService.instance.messageStream.listen(
      _handleNewMessage,
    );
  }

  void _handleNewMessage(OverlayMessage message) {
    _hideTimer?.cancel();

    setState(() {
      _currentMessage = message;
    });

    _animationController.forward(from: 0.0);

    _hideTimer = Timer(message.duration, () {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _currentMessage = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _hideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor(OverlayMessageType type) {
    switch (type) {
      case OverlayMessageType.warning:
        return Colors.orange.withOpacity(0.95);
      case OverlayMessageType.error:
        return Colors.red.withOpacity(0.95);
      case OverlayMessageType.info:
        return Colors.blue.withOpacity(0.95);
      case OverlayMessageType.success:
        return Colors.green.withOpacity(0.95);
    }
  }

  IconData _getIcon(OverlayMessageType type) {
    switch (type) {
      case OverlayMessageType.warning:
        return Icons.warning_rounded;
      case OverlayMessageType.error:
        return Icons.error_rounded;
      case OverlayMessageType.info:
        return Icons.info_rounded;
      case OverlayMessageType.success:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentMessage == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                  minWidth: 200,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(_currentMessage!.type),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(_currentMessage!.type),
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _currentMessage!.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Normal',
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
