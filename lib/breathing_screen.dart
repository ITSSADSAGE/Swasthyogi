import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';

enum BreathingTechnique {
  box,
  relax, // 4-7-8
  calm,
  energise
}

class BreathingScreen extends StatefulWidget {
  final String language;
  final BreathingTechnique initialTechnique;
  
  const BreathingScreen({
    super.key, 
    required this.language,
    this.initialTechnique = BreathingTechnique.calm,
  });

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  BreathingTechnique _technique = BreathingTechnique.calm;
  String _status = "Get Ready";
  int _seconds = 0;
  Timer? _timer;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _technique = widget.initialTechnique;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _seconds = 0;
    });
    _runCycle();
  }

  void _stopBreathing() {
    _timer?.cancel();
    _controller.stop();
    setState(() {
      _isActive = false;
      _status = "Paused";
    });
  }

  void _runCycle() {
    if (!_isActive) return;

    switch (_technique) {
      case BreathingTechnique.box:
        _boxCycle();
        break;
      case BreathingTechnique.relax:
        _relaxCycle();
        break;
      case BreathingTechnique.calm:
        _calmCycle();
        break;
      case BreathingTechnique.energise:
        _energiseCycle();
        break;
    }
  }

  // 4-4-4-4
  void _boxCycle() async {
    if (!_isActive) return;
    setState(() => _status = "Inhale");
    _controller.duration = const Duration(seconds: 4);
    _controller.forward();
    await Future.delayed(const Duration(seconds: 4));

    if (!_isActive) return;
    setState(() => _status = "Hold");
    await Future.delayed(const Duration(seconds: 4));

    if (!_isActive) return;
    setState(() => _status = "Exhale");
    _controller.reverse();
    await Future.delayed(const Duration(seconds: 4));

    if (!_isActive) return;
    setState(() => _status = "Hold");
    await Future.delayed(const Duration(seconds: 4));
    
    _runCycle();
  }

  // 4-7-8
  void _relaxCycle() async {
    if (!_isActive) return;
    setState(() => _status = "Inhale");
    _controller.duration = const Duration(seconds: 4);
    _controller.forward();
    await Future.delayed(const Duration(seconds: 4));

    if (!_isActive) return;
    setState(() => _status = "Hold");
    await Future.delayed(const Duration(seconds: 7));

    if (!_isActive) return;
    setState(() => _status = "Exhale");
    _controller.duration = const Duration(seconds: 8);
    _controller.reverse();
    await Future.delayed(const Duration(seconds: 8));
    
    _runCycle();
  }

  // 5-5
  void _calmCycle() async {
    if (!_isActive) return;
    setState(() => _status = "Inhale");
    _controller.duration = const Duration(seconds: 5);
    _controller.forward();
    await Future.delayed(const Duration(seconds: 5));

    if (!_isActive) return;
    setState(() => _status = "Exhale");
    _controller.reverse();
    await Future.delayed(const Duration(seconds: 5));
    
    _runCycle();
  }

  // 2-1
  void _energiseCycle() async {
    if (!_isActive) return;
    setState(() => _status = "Inhale");
    _controller.duration = const Duration(seconds: 2);
    _controller.forward();
    await Future.delayed(const Duration(seconds: 2));

    if (!_isActive) return;
    setState(() => _status = "Exhale");
    _controller.duration = const Duration(seconds: 1);
    _controller.reverse();
    await Future.delayed(const Duration(seconds: 1));
    
    _runCycle();
  }

  bool get isHindi => widget.language == "हिंदी" || widget.language == "Hindi";
  bool get isMarathi => widget.language == "मराठी" || widget.language == "Marathi";

  String _getTranslatedStatus(String status) {
    if (isMarathi) {
      if (status == "Inhale") return "श्वास घ्या";
      if (status == "Hold") return "श्वास रोखा";
      if (status == "Exhale") return "श्वास सोडा";
      return "तयार व्हा";
    }
    if (isHindi) {
      if (status == "Inhale") return "सांस लें";
      if (status == "Hold") return "सांस रोकें";
      if (status == "Exhale") return "सांस छोड़ें";
      return "तैयार हो जाइए";
    }
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isMarathi ? "श्वसन व्यायाम" : (isHindi ? "प्राणायाम" : "Breathing Exercise")),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTypeSelector(isDark),
            const Spacer(),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 150 * _animation.value,
                  height: 150 * _animation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.medicalBlue.withOpacity(0.4),
                        AppTheme.medicalBlue.withOpacity(0.0),
                      ],
                    ),
                    border: Border.all(color: AppTheme.medicalBlue.withOpacity(0.5), width: 2),
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.medicalBlue,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            Text(
              _getTranslatedStatus(_status),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(40),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isActive ? _stopBreathing : _startBreathing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive ? Colors.red.withOpacity(0.1) : AppTheme.medicalBlue,
                    foregroundColor: _isActive ? Colors.red : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isActive 
                      ? (isMarathi ? "थांबवा" : (isHindi ? "रोकें" : "Stop"))
                      : (isMarathi ? "सुरू करा" : (isHindi ? "शुरू करें" : "Start")),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _techChip(BreathingTechnique.calm, isMarathi ? "शांत" : "Calm"),
          _techChip(BreathingTechnique.relax, isMarathi ? "४-७-८ विश्रांती" : "4-7-8 Relax"),
          _techChip(BreathingTechnique.box, isMarathi ? "बॉक्स" : "Box"),
          _techChip(BreathingTechnique.energise, isMarathi ? "ऊर्जा" : "Energise"),
        ],
      ),
    );
  }

  Widget _techChip(BreathingTechnique tech, String label) {
    bool isSelected = _technique == tech;
    return GestureDetector(
      onTap: () {
        if (!_isActive) setState(() => _technique = tech);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.medicalBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.medicalBlue : Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
