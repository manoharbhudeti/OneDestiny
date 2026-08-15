import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animation style options for the Logo Animation Explorer
enum LogoAnimationStyle {
  symbolDrawIn,
  staggeredTextReveal,
  pulsingLogo,
  orbitingStar,
  masterSequence,
}

/// Target element focus modes
enum LogoElementFocus {
  all,
  symbol,
  brandText,
  tagline,
}

/// Preset Background Color Option
class BackgroundColorPreset {
  final String name;
  final Color color;
  final Color textColor;

  const BackgroundColorPreset({
    required this.name,
    required this.color,
    required this.textColor,
  });
}

/// Interactive Flutter Widget: Logo Animation Explorer (Simulator Archetype A)
/// Allows real-time dynamic parameter adjustment, custom canvas animation,
/// staggered letter reveals, and color matching.
class LogoAnimationExplorer extends StatefulWidget {
  final VoidCallback? onClose;

  const LogoAnimationExplorer({
    super.key,
    this.onClose,
  });

  @override
  State<LogoAnimationExplorer> createState() => _LogoAnimationExplorerState();
}

class _LogoAnimationExplorerState extends State<LogoAnimationExplorer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Preset color swatches
  static const List<BackgroundColorPreset> _presetColors = [
    BackgroundColorPreset(name: 'Deep Burgundy', color: Color(0xFF4A081C), textColor: Colors.white),
    BackgroundColorPreset(name: 'Midnight Onyx', color: Color(0xFF111116), textColor: Colors.white),
    BackgroundColorPreset(name: 'Imperial Navy', color: Color(0xFF0D1B2A), textColor: Colors.white),
    BackgroundColorPreset(name: 'Emerald Elegance', color: Color(0xFF09281E), textColor: Colors.white),
    BackgroundColorPreset(name: 'Rose Champagne', color: Color(0xFF2E1720), textColor: Colors.white),
    BackgroundColorPreset(name: 'Slate Grey', color: Color(0xFF1E293B), textColor: Colors.white),
    BackgroundColorPreset(name: 'Warm Ivory', color: Color(0xFFF7F3EE), textColor: Color(0xFF1D1D1D)),
  ];

  // Interactive State Parameters
  Color _selectedBgColor = const Color(0xFF4A081C);
  LogoAnimationStyle _activeStyle = LogoAnimationStyle.masterSequence;
  LogoElementFocus _focusedElement = LogoElementFocus.all;
  double _animationSpeed = 1.0; // 0.2x to 3.0x
  double _scaleFactor = 1.0; // 0.5x to 2.0x
  bool _isPlaying = true;
  bool _isLooping = true;
  double _hueValue = 345.0; // Dynamic HSV slider

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isLooping && _isPlaying) {
        _controller.repeat();
      }
    });

    if (_isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _resetAnimation() {
    setState(() {
      _controller.reset();
      if (_isPlaying) {
        _controller.repeat();
      }
    });
  }

  void _updateSpeed(double speed) {
    setState(() {
      _animationSpeed = speed;
      // Adjust duration according to speed multiplier
      final baseMs = 3200;
      final newMs = (baseMs / _animationSpeed).round().clamp(500, 15000);
      _controller.duration = Duration(milliseconds: newMs);
      if (_isPlaying) {
        _controller.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkBg = ThemeData.estimateBrightnessForColor(_selectedBgColor) == Brightness.dark;
    final primaryTextColor = isDarkBg ? const Color(0xFFFFF8F4) : const Color(0xFF1A1A1A);
    final secondaryTextColor = isDarkBg ? const Color(0xFFE5C158) : const Color(0xFF9E7A1C);

    return Scaffold(
      backgroundColor: _selectedBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Simulator Header Controls
            _buildSimulatorHeader(isDarkBg),

            // 2. Interactive Main Canvas Viewport
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final animValue = _controller.value;
                        return Transform.scale(
                          scale: _scaleFactor,
                          child: _buildLogoCanvasGroup(animValue, secondaryTextColor),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 3. Interactive Parameter Studio Control Panel
            _buildStudioControlPanel(isDarkBg, primaryTextColor),
          ],
        ),
      ),
    );
  }

  /// Top Navigation Header
  Widget _buildSimulatorHeader(bool isDarkBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (isDarkBg ? Colors.white : Colors.black).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDarkBg ? Colors.white : Colors.black).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: isDarkBg ? AppColors.accentGoldLight : AppColors.primaryBurgundy,
                ),
                const SizedBox(width: 6),
                Text(
                  'LOGO SIMULATOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDarkBg ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _resetAnimation,
            icon: Icon(
              Icons.refresh_rounded,
              color: isDarkBg ? Colors.white70 : Colors.black54,
            ),
            tooltip: 'Reset Animation',
          ),
          if (widget.onClose != null)
            IconButton(
              onPressed: widget.onClose,
              icon: Icon(
                Icons.close_rounded,
                color: isDarkBg ? Colors.white70 : Colors.black54,
              ),
              tooltip: 'Close Explorer',
            ),
        ],
      ),
    );
  }

  /// Logo Canvas Rendering Group
  Widget _buildLogoCanvasGroup(double animValue, Color goldAccentColor) {
    // Determine opacity/focus dimming factors based on _focusedElement
    final symbolOpacity = (_focusedElement == LogoElementFocus.all || _focusedElement == LogoElementFocus.symbol) ? 1.0 : 0.25;
    final brandTextOpacity = (_focusedElement == LogoElementFocus.all || _focusedElement == LogoElementFocus.brandText) ? 1.0 : 0.25;
    final taglineOpacity = (_focusedElement == LogoElementFocus.all || _focusedElement == LogoElementFocus.tagline) ? 1.0 : 0.25;

    // Animation progress derivations
    double drawInProgress = 1.0;
    double textRevealProgress = 1.0;
    double pulseFactor = 1.0;
    double orbitAngle = animValue * 2 * math.pi;

    switch (_activeStyle) {
      case LogoAnimationStyle.symbolDrawIn:
        drawInProgress = Curves.easeInOutCubic.transform(animValue);
        textRevealProgress = animValue > 0.6 ? (animValue - 0.6) / 0.4 : 0.0;
        pulseFactor = 1.0;
        orbitAngle = 0.0;
        break;
      case LogoAnimationStyle.staggeredTextReveal:
        drawInProgress = 1.0;
        textRevealProgress = Curves.easeInOut.transform(animValue);
        pulseFactor = 1.0;
        orbitAngle = 0.0;
        break;
      case LogoAnimationStyle.pulsingLogo:
        drawInProgress = 1.0;
        textRevealProgress = 1.0;
        pulseFactor = 1.0 + 0.08 * math.sin(animValue * 2 * math.pi);
        orbitAngle = 0.0;
        break;
      case LogoAnimationStyle.orbitingStar:
        drawInProgress = 1.0;
        textRevealProgress = 1.0;
        pulseFactor = 1.0;
        orbitAngle = animValue * 2 * math.pi;
        break;
      case LogoAnimationStyle.masterSequence:
        // Continuous master sequence combining all features gracefully
        drawInProgress = (animValue < 0.3) ? (animValue / 0.3) : 1.0;
        textRevealProgress = (animValue < 0.3)
            ? 0.0
            : ((animValue - 0.3) / 0.4).clamp(0.0, 1.0);
        pulseFactor = 1.0 + 0.06 * math.sin(animValue * 2 * math.pi);
        orbitAngle = animValue * 2 * math.pi;
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A. Gold Symbol + Orbiting Star with Radial Aura Bloom
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: symbolOpacity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radial Aura Warm Light Bloom
              if (_activeStyle == LogoAnimationStyle.pulsingLogo || _activeStyle == LogoAnimationStyle.masterSequence)
                Container(
                  width: 180 * pulseFactor,
                  height: 180 * pulseFactor,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accentGoldLight.withValues(alpha: 0.35 * (pulseFactor - 0.9)),
                        AppColors.accentGold.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

              // Custom Painted Interlocking Swoosh Symbol & Central Orbiting Star
              SizedBox(
                width: 220,
                height: 160,
                child: CustomPaint(
                  painter: _GoldSymbolCanvasPainter(
                    drawProgress: drawInProgress,
                    orbitAngle: orbitAngle,
                    pulseFactor: pulseFactor,
                    isOrbiting: _activeStyle == LogoAnimationStyle.orbitingStar ||
                        _activeStyle == LogoAnimationStyle.masterSequence,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // B. Brand Text: "ONE DESTINY"
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: brandTextOpacity,
          child: _StaggeredTextRevealWidget(
            text: 'ONE DESTINY',
            progress: textRevealProgress,
            style: TextStyle(
              fontFamily: 'Serif',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 6.0,
              color: goldAccentColor,
              shadows: [
                Shadow(
                  color: AppColors.accentGold.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Gold Accent Divider Line
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: (brandTextOpacity + taglineOpacity) / 2,
          child: Container(
            width: 60 * textRevealProgress,
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  goldAccentColor,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // C. Tagline: "MAKE EVERY CELEBRATION IN ONE PLACE"
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: taglineOpacity,
          child: _StaggeredTextRevealWidget(
            text: 'MAKE EVERY CELEBRATION IN ONE PLACE',
            progress: (textRevealProgress * 1.3 - 0.3).clamp(0.0, 1.0),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
              color: goldAccentColor.withValues(alpha: 0.9),
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Interactive Studio Control Panel
  Widget _buildStudioControlPanel(bool isDarkBg, Color textColor) {
    final panelBg = isDarkBg ? const Color(0xEE1E1E26) : const Color(0xEEFFFFFF);
    final borderClr = isDarkBg ? Colors.white12 : Colors.black12;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: panelBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderClr),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar Indicator
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkBg ? Colors.white30 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Tab Navigation Bar
            TabBar(
              labelColor: AppColors.accentGold,
              unselectedLabelColor: isDarkBg ? Colors.white60 : Colors.black54,
              indicatorColor: AppColors.accentGold,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Color Match'),
                Tab(icon: Icon(Icons.animation_rounded, size: 18), text: 'Animation'),
                Tab(icon: Icon(Icons.tune_rounded, size: 18), text: 'Controls'),
              ],
            ),

            const Divider(height: 1),

            // Tab Pages
            SizedBox(
              height: 185,
              child: TabBarView(
                children: [
                  // Tab 1: Background Color Selection Tool
                  _buildColorMatchTab(isDarkBg, textColor),

                  // Tab 2: Animation Sequence & Style Menu
                  _buildAnimationStyleTab(isDarkBg, textColor),

                  // Tab 3: Speed, Scale, Focus Sliders
                  _buildControlsTab(isDarkBg, textColor),
                ],
              ),
            ),

            // Bottom Playback & Scrubber Bar
            _buildPlaybackBar(isDarkBg, textColor),
          ],
        ),
      ),
    );
  }

  /// Tab 1: Background Color Selection Tool
  Widget _buildColorMatchTab(bool isDarkBg, Color textColor) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Preset Matching Backgrounds',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
            Text(
              '#${_selectedBgColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'Monospace',
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Color Swatches
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _presetColors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final item = _presetColors[index];
              final isSelected = _selectedBgColor == item.color;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBgColor = item.color;
                    final hsv = HSVColor.fromColor(item.color);
                    _hueValue = hsv.hue;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.accentGoldLight : Colors.white24,
                      width: isSelected ? 2.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accentGold.withValues(alpha: 0.4),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: item.textColor,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Dynamic HSV Background Color Slider
        Row(
          children: [
            Text(
              'Hue Match',
              style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.7)),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 8,
                  activeTrackColor: HSVColor.fromAHSV(1.0, _hueValue, 0.7, 0.3).toColor(),
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  thumbColor: AppColors.accentGold,
                ),
                child: Slider(
                  value: _hueValue,
                  min: 0.0,
                  max: 360.0,
                  onChanged: (val) {
                    setState(() {
                      _hueValue = val;
                      final prevHsv = HSVColor.fromColor(_selectedBgColor);
                      _selectedBgColor = HSVColor.fromAHSV(
                        1.0,
                        _hueValue,
                        prevHsv.saturation.clamp(0.2, 0.9),
                        prevHsv.value.clamp(0.15, 0.95),
                      ).toColor();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tab 2: Animation Style Menu
  Widget _buildAnimationStyleTab(bool isDarkBg, Color textColor) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        Text(
          'Choose Dynamic Animation Style',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: LogoAnimationStyle.values.map((style) {
            final isSelected = _activeStyle == style;
            String label;
            IconData icon;

            switch (style) {
              case LogoAnimationStyle.symbolDrawIn:
                label = 'Symbol Draw-in';
                icon = Icons.gesture_rounded;
                break;
              case LogoAnimationStyle.staggeredTextReveal:
                label = 'Text Reveal';
                icon = Icons.text_fields_rounded;
                break;
              case LogoAnimationStyle.pulsingLogo:
                label = 'Pulsing Light';
                icon = Icons.blur_circular_rounded;
                break;
              case LogoAnimationStyle.orbitingStar:
                label = 'Orbiting Star';
                icon = Icons.stars_rounded;
                break;
              case LogoAnimationStyle.masterSequence:
                label = 'Master Sequence';
                icon = Icons.auto_awesome_motion_rounded;
                break;
            }

            return ChoiceChip(
              avatar: Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.black : (isDarkBg ? Colors.white70 : Colors.black87),
              ),
              label: Text(label),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : (isDarkBg ? Colors.white70 : Colors.black87),
              ),
              selected: isSelected,
              selectedColor: AppColors.accentGoldLight,
              backgroundColor: isDarkBg ? Colors.white10 : Colors.black12,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _activeStyle = style;
                    _resetAnimation();
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Tab 3: Sliders & Focus Controls
  Widget _buildControlsTab(bool isDarkBg, Color textColor) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // 1. Element Focus Segmented Buttons
        Row(
          children: [
            Text(
              'Element Focus:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SegmentedButton<LogoElementFocus>(
                segments: const [
                  ButtonSegment(value: LogoElementFocus.all, label: Text('All', style: TextStyle(fontSize: 10))),
                  ButtonSegment(value: LogoElementFocus.symbol, label: Text('Symbol', style: TextStyle(fontSize: 10))),
                  ButtonSegment(value: LogoElementFocus.brandText, label: Text('Brand', style: TextStyle(fontSize: 10))),
                  ButtonSegment(value: LogoElementFocus.tagline, label: Text('Tagline', style: TextStyle(fontSize: 10))),
                ],
                selected: {_focusedElement},
                onSelectionChanged: (set) {
                  setState(() {
                    _focusedElement = set.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.accentGold.withValues(alpha: 0.3),
                  selectedForegroundColor: AppColors.accentGold,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // 2. Animation Speed Slider
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                'Speed: ${_animationSpeed.toStringAsFixed(1)}x',
                style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.8)),
              ),
            ),
            Expanded(
              child: Slider(
                value: _animationSpeed,
                min: 0.2,
                max: 3.0,
                divisions: 14,
                activeColor: AppColors.accentGold,
                onChanged: _updateSpeed,
              ),
            ),
          ],
        ),

        // 3. Logo Scale Slider
        Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                'Scale: ${(_scaleFactor * 100).toInt()}%',
                style: TextStyle(fontSize: 11, color: textColor.withValues(alpha: 0.8)),
              ),
            ),
            Expanded(
              child: Slider(
                value: _scaleFactor,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                activeColor: AppColors.accentGold,
                onChanged: (val) {
                  setState(() {
                    _scaleFactor = val;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Bottom Playback & Scrubber Controls
  Widget _buildPlaybackBar(bool isDarkBg, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Animation Progress Scrubber Line
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return LinearProgressIndicator(
                value: _controller.value,
                backgroundColor: isDarkBg ? Colors.white10 : Colors.black12,
                color: AppColors.accentGold,
                minHeight: 3,
              );
            },
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              IconButton(
                onPressed: _togglePlayPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                  color: AppColors.accentGold,
                  size: 28,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isLooping = !_isLooping;
                  });
                },
                icon: Icon(
                  Icons.loop_rounded,
                  color: _isLooping ? AppColors.accentGold : (isDarkBg ? Colors.white30 : Colors.black26),
                  size: 20,
                ),
                tooltip: _isLooping ? 'Loop Enabled' : 'Loop Disabled',
              ),
              const Spacer(),
              Text(
                _activeStyle.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom Painter for the Golden Interlocking Swoosh Symbol & Central Orbiting Star
class _GoldSymbolCanvasPainter extends CustomPainter {
  final double drawProgress;
  final double orbitAngle;
  final double pulseFactor;
  final bool isOrbiting;

  _GoldSymbolCanvasPainter({
    required this.drawProgress,
    required this.orbitAngle,
    required this.pulseFactor,
    required this.isOrbiting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width;
    final height = size.height;

    // 1. Build Interlocking Infinity / Swoosh Symbol Vector Path
    final path = Path();
    path.moveTo(center.dx - width * 0.35, center.dy);
    
    // Left loop curve
    path.cubicTo(
      center.dx - width * 0.45, center.dy - height * 0.4,
      center.dx - width * 0.1, center.dy - height * 0.45,
      center.dx, center.dy,
    );

    // Right loop curve
    path.cubicTo(
      center.dx + width * 0.1, center.dy + height * 0.45,
      center.dx + width * 0.45, center.dy + height * 0.4,
      center.dx + width * 0.35, center.dy,
    );

    // Right return curve
    path.cubicTo(
      center.dx + width * 0.45, center.dy - height * 0.4,
      center.dx + width * 0.1, center.dy - height * 0.45,
      center.dx, center.dy,
    );

    // Left return curve
    path.cubicTo(
      center.dx - width * 0.1, center.dy + height * 0.45,
      center.dx - width * 0.45, center.dy + height * 0.4,
      center.dx - width * 0.35, center.dy,
    );

    // 2. Dynamic Gold Shimmer Shader Paint
    final goldGradient = ui.Gradient.linear(
      Offset(0, center.dy - height * 0.5),
      Offset(width, center.dy + height * 0.5),
      [
        const Color(0xFFF9E498), // Bright Metallic Gold
        const Color(0xFFC9A227), // Deep Rich Gold
        const Color(0xFFFFF6D3), // Highlighting Sparkle
        const Color(0xFF9E7A1C), // Shadow Gold
      ],
      [0.0, 0.4, 0.7, 1.0],
    );

    final strokePaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * pulseFactor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glowPaint = Paint()
      ..shader = goldGradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14.0 * pulseFactor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // 3. Draw Path (with Symbol Draw-In capability using PathMetrics)
    if (drawProgress < 1.0) {
      final metrics = path.computeMetrics();
      final extractedPath = Path();
      for (final metric in metrics) {
        final extractLen = metric.length * drawProgress;
        extractedPath.addPath(metric.extractPath(0, extractLen), Offset.zero);
      }
      canvas.drawPath(extractedPath, glowPaint..color = glowPaint.color.withValues(alpha: 0.3));
      canvas.drawPath(extractedPath, strokePaint);
    } else {
      canvas.drawPath(path, glowPaint..color = glowPaint.color.withValues(alpha: 0.3));
      canvas.drawPath(path, strokePaint);
    }

    // 4. Central Shimmering Star & Orbiting Motion
    Offset starPosition = center;
    if (isOrbiting) {
      final rx = width * 0.22;
      final ry = height * 0.22;
      starPosition = Offset(
        center.dx + math.cos(orbitAngle) * rx,
        center.dy + math.sin(orbitAngle * 2) * ry * 0.6,
      );
    }

    _drawShimmeringStar(canvas, starPosition, 16.0 * pulseFactor);
  }

  /// Draws a 4-point golden star with radial shine lines
  void _drawShimmeringStar(Canvas canvas, Offset center, double size) {
    final starPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        size * 1.5,
        [
          const Color(0xFFFFFFFF),
          const Color(0xFFFFF1B0),
          const Color(0xFFC9A227),
        ],
        [0.0, 0.4, 1.0],
      )
      ..style = PaintingStyle.fill;

    final path = Path();
    const points = 4;
    final outerRadius = size;
    final innerRadius = size * 0.28;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * math.pi / points) - (math.pi / 2);
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Star Aura Glow
    final starGlowPaint = Paint()
      ..color = const Color(0xFFFFE885).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, size * 0.8, starGlowPaint);
    canvas.drawPath(path, starPaint);
  }

  @override
  bool shouldRepaint(covariant _GoldSymbolCanvasPainter oldDelegate) {
    return oldDelegate.drawProgress != drawProgress ||
        oldDelegate.orbitAngle != orbitAngle ||
        oldDelegate.pulseFactor != pulseFactor ||
        oldDelegate.isOrbiting != isOrbiting;
  }
}

/// Animated Widget for Letter-by-Letter Staggered Typography Reveal
class _StaggeredTextRevealWidget extends StatelessWidget {
  final String text;
  final double progress;
  final TextStyle style;

  const _StaggeredTextRevealWidget({
    required this.text,
    required this.progress,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final charCount = text.length;

    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(charCount, (index) {
        final char = text[index];
        if (char == ' ') {
          return SizedBox(width: style.fontSize != null ? style.fontSize! * 0.4 : 8);
        }

        // Calculate individual letter reveal threshold
        final letterStart = (index / charCount) * 0.7;
        final letterEnd = letterStart + 0.3;
        final letterProgress = ((progress - letterStart) / (letterEnd - letterStart)).clamp(0.0, 1.0);
        final opacity = Curves.easeOut.transform(letterProgress);
        final offsetY = (1.0 - Curves.easeOutBack.transform(letterProgress)) * 14.0;

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, offsetY),
            child: Text(char, style: style),
          ),
        );
      }),
    );
  }
}
