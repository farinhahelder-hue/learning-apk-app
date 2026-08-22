import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/screen_time.dart';
import '../screens/active_break_screen.dart';
import '../utils/app_theme.dart';

/// Suit le temps d'écran (règle 3-6-9-12) et PROPOSE une pause après
/// 15 minutes de session continue.
///
/// Important : la pause n'est jamais imposée et n'interrompt jamais
/// brutalement une activité. Emilie (ou l'adulte) reste décisionnaire :
/// continuer, faire une pause active, ou revenir au menu.
/// Le cumul quotidien n'est qu'informatif, affiché côté parents.
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
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
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

  void _offerBreak(ScreenTimeService svc) {
    _dialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) {
        _dialogShowing = false;
        return;
      }

      showDialog<void>(
        context: navigator.context,
        barrierDismissible: false,
        builder: (dialogContext) => _BreakChoiceDialog(
          onContinue: () {
            Navigator.of(dialogContext).pop();
            svc.resetSession();
            _dialogShowing = false;
          },
          onPause: () {
            Navigator.of(dialogContext).pop();
            navigator.push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => ActiveBreakScreen(
                  onBreakDone: () {
                    svc.resetSession();
                    navigator.pop();
                    _dialogShowing = false;
                  },
                ),
              ),
            );
          },
          onHome: () {
            Navigator.of(dialogContext).pop();
            svc.resetSession();
            _dialogShowing = false;
            navigator.popUntil((route) => route.isFirst);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ScreenTimeService>();
    if (svc.pauseRequested && !_dialogShowing) {
      _offerBreak(svc);
    }
    return widget.child;
  }
}

/// Proposition de pause, jamais imposée : trois choix clairs.
class _BreakChoiceDialog extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onPause;
  final VoidCallback onHome;

  const _BreakChoiceDialog({
    required this.onContinue,
    required this.onPause,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌙', style: TextStyle(fontSize: 54)),
            const SizedBox(height: 12),
            const Text(
              'Tu joues depuis un moment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Qu\'est-ce que tu préfères faire maintenant ?\nC\'est toi qui choisis.',
              style: TextStyle(fontSize: 14, color: AppTheme.textGrey, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            _ChoiceButton(
              emoji: '▶️',
              label: 'Continuer à jouer',
              color: AppTheme.primaryGreen,
              onTap: onContinue,
            ),
            const SizedBox(height: 10),
            _ChoiceButton(
              emoji: '🌊',
              label: 'Faire une pause calme',
              color: AppTheme.primaryBlue,
              onTap: onPause,
            ),
            const SizedBox(height: 10),
            _ChoiceButton(
              emoji: '🏠',
              label: 'Revenir au menu',
              color: AppTheme.primaryPurple,
              onTap: onHome,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}
