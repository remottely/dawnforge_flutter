import 'package:flutter/material.dart';

import '../time_hud_adapter.dart';
import '../time_manager.dart';

/// Small HUD panel showing current time, day, season, and weather.
class TimeHudPanel extends StatefulWidget {
  final TimeManager timeManager;

  const TimeHudPanel({super.key, required this.timeManager});

  @override
  State<TimeHudPanel> createState() => _TimeHudPanelState();
}

class _TimeHudPanelState extends State<TimeHudPanel> {
  late final TimeHudAdapter _adapter;

  @override
  void initState() {
    super.initState();
    _adapter = TimeHudAdapter(widget.timeManager);
  }

  @override
  void dispose() {
    _adapter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder<String>(
            valueListenable: _adapter.timeLabel,
            builder: (_, value, __) {
              return Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          ValueListenableBuilder<String>(
            valueListenable: _adapter.dayLabel,
            builder: (_, value, __) {
              return Text(
                value,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: _adapter.seasonLabel,
                builder: (_, value, __) {
                  return Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              ValueListenableBuilder<String>(
                valueListenable: _adapter.weatherLabel,
                builder: (_, value, __) {
                  return Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
