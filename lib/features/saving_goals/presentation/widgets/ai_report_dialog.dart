import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/goal_bloc.dart';
import '../bloc/goal_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiReportDialog extends StatelessWidget {
  const AiReportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state is GoalReportLoading) {
          return AlertDialog(
            backgroundColor: kBgCard,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: kTeal),
                const SizedBox(height: 16),
                Text('Yapay Zeka Analiz Ediyor...', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              ],
            ),
          );
        }

        if (state is GoalReportSuccess) {
          return AlertDialog(
            backgroundColor: kBgCard,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.psychology_rounded, color: kTeal, size: 28),
                const SizedBox(width: 8),
                const Text('AI Ay Sonu Raporu', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            content: Text(
              state.report,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15, height: 1.4),
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: kTeal),
                child: const Text('Tamam, Anladım'),
              ),
            ],
          );
        }

        if (state is GoalError) {
          return AlertDialog(
            backgroundColor: kBgCard,
            title: const Text('Hata', style: TextStyle(color: kRed)),
            content: Text(state.message, style: const TextStyle(color: Colors.white)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
