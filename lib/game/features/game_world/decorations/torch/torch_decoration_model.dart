import 'package:dawnforge/shared/framework/decorations/dd_input_receiver/dd_input_receiver_decoration_model.dart';

class TorchDecorationModel implements DDInputReceiverDecorationModel {
  bool _isDetectPlayer;
  bool _isOn;

  TorchDecorationModel({required bool initialIsOn})
    : _isDetectPlayer = false,
      _isOn = initialIsOn;

  @override
  bool get isDetectPlayer => _isDetectPlayer;
  @override
  void setIsDetectPlayer(bool value) => _isDetectPlayer = value;

  @override
  bool get canInteract => _isDetectPlayer;

  bool get isOn => _isOn;

  void _turnOff() => _isOn = false;
  void _turnOn() => _isOn = true;
  void toggleIsOn() => _isOn ? _turnOff() : _turnOn();
}
