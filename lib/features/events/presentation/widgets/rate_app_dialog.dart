import 'dart:ui';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:viora/core/theme/app_colors.dart';
import 'package:viora/core/theme/app_text_styles.dart';

void showRateAppDialog(BuildContext context) async {

  final box = Hive.box('settings');
  final alreadyShown = box.get('rate_shown', defaultValue: false);
  if (alreadyShown) return;

  await box.put('rate_shown', true);

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => const RateAppDialog(),
  );
}

class RateAppDialog extends StatefulWidget {
  const RateAppDialog({super.key});

  @override
  State<RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog> {
  int _stars = 4;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 54.37, sigmaY: 54.37),
          child: Container(
            width: 270,
            height: 274,
            padding: const EdgeInsets.only(top: 22),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/ocenka.png',
                  height: 64,
                  width: 64,
                ),
                const SizedBox(height: 26),
                Text('Rate the app', style: AppTextStyles.title),
                const SizedBox(height: 11),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Tap a star to rate. You can also leave a \ncomment',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.footnote,
                  ),
                ),
                const SizedBox(height: 15),
                const Divider(color: AppColors.bgLevel2, height: 1,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    final filled = i < _stars;
                    return IconButton(
                      onPressed: () => setState(() => _stars = i + 1),
                      icon: Icon(
                        filled ? Icons.star : Icons.star_border,
                        color: const Color(0xFF0A84FF),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 8,),
                const Divider(color: AppColors.bgLevel2, height: 2,),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Cancel', 
                            style: TextStyle(
                              color: Color(0xFF0A84FF),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(color: AppColors.bgLevel2,),
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                            overlayColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              color: Color(0xFF0A84FF), 
                              fontWeight: FontWeight.w600,
                              fontSize: 17
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}