import 'package:flutter/material.dart';
import '../../../core/widgets/logo_animation_explorer.dart';

/// Studio Screen Wrapper for the Logo Animation Explorer
class LogoAnimationExplorerScreen extends StatelessWidget {
  const LogoAnimationExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LogoAnimationExplorer(
      onClose: () {
        Navigator.of(context).pop();
      },
    );
  }
}
