import 'package:dawnforge/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_model.dart';

class ChestDecorationModel implements DDInputReceiverDecorationModel {
  bool _isDetectPlayer;
  bool _isOpened;

  ChestDecorationModel({required bool initialIsOpened})
    : _isDetectPlayer = false,
      _isOpened = initialIsOpened;

  @override
  bool get isDetectPlayer => _isDetectPlayer;
  @override
  void setIsDetectPlayer(bool value) => _isDetectPlayer = value;

  @override
  bool get canInteract => _isDetectPlayer && !_isOpened;

  bool get isOpened => _isOpened;
  void markAsOpened() => _isOpened = true;
}
