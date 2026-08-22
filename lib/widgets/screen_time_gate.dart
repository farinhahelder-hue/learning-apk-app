import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screen_time.dart';
import '../screens/active_break_screen.dart';

/// Enveloppe l'app pour suivre le temps d'écran (règle 3-6-9-12) et
/// proposer une pause active après 15 minutes de session continue.
/// Jamais bloquant côté enfant au-delà de la pause elle-même : le cumul
/// quotidien n'est qu'informatif, affiché uniquement côté parents.
class ScreenTimeGate extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const ScreenTimeGate({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<ScreenTimeGate> createState() => _ScreenTimeGateState();
}

class _ScreenTimeGateState extends State<ScreenTimeGate> {
  Timer? _ticker;
  bool _breakShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final svc = context.read<ScreenTimeService>();
      await svc.loadToday();
      svc.startSession();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) context.read<ScreenTimeService>().tick();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _showBreak(ScreenTimeService svc) {
    _breakShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.navigatorKey.currentState?.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => ActiveBreakScreen(
            onBreakDone: () {
              svc.resetSession();
              widget.navigatorKey.currentState?.pop();
              _breakShowing = false;
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ScreenTimeService>();
    if (svc.pauseRequested && !_breakShowing) {
      _showBreak(svc);
    }
    return widget.child;
  }
}
