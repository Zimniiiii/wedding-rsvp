import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:html' as html;
import 'dart:math';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WeddingApp());
}

// ── Colors ──────────────────────────────────────────────────
const kGreen = Color(0xFF4A7C59);
const kGreenLight = Color(0xFF7FAF8A);
const kGreenPale = Color(0xFFEBF3ED);
const kCream = Color(0xFFFAF8F4);
const kGold = Color(0xFFB8975A);
const kText = Color(0xFF2D4A35);
const kTextLight = Color(0xFF6B8F72);

// ── App ─────────────────────────────────────────────────────
class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding Invitation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
        textTheme: GoogleFonts.cormorantTextTheme(),
        useMaterial3: true,
      ),
      home: const BloomLandingPage(),
      routes: {
        '/admin': (context) => const AdminLoginPage(),
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BLOOM LANDING PAGE
// ══════════════════════════════════════════════════════════════
class BloomLandingPage extends StatefulWidget {
  const BloomLandingPage({super.key});
  @override
  State<BloomLandingPage> createState() => _BloomLandingPageState();
}

class _BloomLandingPageState extends State<BloomLandingPage>
    with TickerProviderStateMixin {
  late AnimationController _bloomController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _bloomAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _pulseAnim;

  bool _opened = false;

  @override
  void initState() {
    super.initState();
    _bloomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _bloomAnim = CurvedAnimation(
      parent: _bloomController,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _onTap() {
    if (_opened) return;
    setState(() => _opened = true);
    _pulseController.stop();
    _bloomController.forward().then((_) {
      _fadeController.forward().then((_) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const EventDetailsPage(),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _bloomController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: Stack(
        children: [
          // Subtle background pattern
          Positioned.fill(
            child: CustomPaint(painter: _LeafPatternPainter()),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Tap hint text
                AnimatedOpacity(
                  opacity: _opened ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'tap to open your invitation',
                    style: GoogleFonts.cormorant(
                      fontSize: 14,
                      color: kTextLight,
                      letterSpacing: 2,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // The flower
                GestureDetector(
                  onTap: _onTap,
                  child: AnimatedBuilder(
                    animation:
                        Listenable.merge([_bloomAnim, _pulseAnim, _fadeAnim]),
                    builder: (context, _) {
                      return Opacity(
                        opacity: 1 - _fadeAnim.value,
                        child: Transform.scale(
                          scale:
                              _opened ? _bloomAnim.value * 3 : _pulseAnim.value,
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: CustomPaint(
                              painter: _FlowerPainter(
                                bloom: _bloomAnim.value,
                                opened: _opened,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
                AnimatedOpacity(
                  opacity: _opened ? 0 : 1,
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      Text(
                        'You are invited',
                        style: GoogleFonts.cormorant(
                          fontSize: 28,
                          color: kText,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 1,
                        color: kGold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Flower painter
class _FlowerPainter extends CustomPainter {
  final double bloom;
  final bool opened;
  _FlowerPainter({required this.bloom, required this.opened});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final petalCount = 8;
    final petalLength = size.width * 0.38;
    final petalWidth = size.width * 0.13;

    // Petals
    for (int i = 0; i < petalCount; i++) {
      final angle = (2 * pi / petalCount) * i;
      final petalPaint = Paint()
        ..color =
            i % 2 == 0 ? kGreen.withOpacity(0.85) : kGreenLight.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petalPath = Path()
        ..moveTo(0, 0)
        ..cubicTo(
          petalWidth,
          -petalLength * 0.3 * bloom,
          petalWidth,
          -petalLength * 0.7 * bloom,
          0,
          -petalLength * bloom,
        )
        ..cubicTo(
          -petalWidth,
          -petalLength * 0.7 * bloom,
          -petalWidth,
          -petalLength * 0.3 * bloom,
          0,
          0,
        );

      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Inner petals
    for (int i = 0; i < petalCount; i++) {
      final angle = (2 * pi / petalCount) * i + pi / petalCount;
      final petalPaint = Paint()
        ..color = Colors.white.withOpacity(0.8 * bloom)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petalPath = Path()
        ..moveTo(0, 0)
        ..cubicTo(
          petalWidth * 0.5,
          -petalLength * 0.2 * bloom,
          petalWidth * 0.5,
          -petalLength * 0.4 * bloom,
          0,
          -petalLength * 0.5 * bloom,
        )
        ..cubicTo(
          -petalWidth * 0.5,
          -petalLength * 0.4 * bloom,
          -petalWidth * 0.5,
          -petalLength * 0.2 * bloom,
          0,
          0,
        );

      canvas.drawPath(petalPath, petalPaint);
      canvas.restore();
    }

    // Center circle
    final centerPaint = Paint()
      ..color = kGold
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 18 * (bloom == 0 ? 1 : bloom), centerPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8 * (bloom == 0 ? 1 : bloom), dotPaint);
  }

  @override
  bool shouldRepaint(_FlowerPainter old) => true;
}

// Subtle leaf background
class _LeafPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kGreen.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 12; i++) {
      final x = (size.width / 4) * (i % 4);
      final y = (size.height / 3) * (i ~/ 4);
      canvas.save();
      canvas.translate(x + 40, y + 40);
      canvas.rotate(i * 0.5);
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(20, -30, 40, -30, 40, 0)
        ..cubicTo(40, 30, 20, 30, 0, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
// EVENT DETAILS PAGE
// ══════════════════════════════════════════════════════════════
class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              decoration: const BoxDecoration(
                color: kGreen,
              ),
              child: Column(
                children: [
                  Text(
                    'Together in Love',
                    style: GoogleFonts.cormorant(
                      fontSize: 13,
                      color: Colors.white70,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dr.Safrina P M', // ← your name
                    style: GoogleFonts.italianno(
                      fontSize: 48,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '&',
                    style: GoogleFonts.cormorant(
                      fontSize: 28,
                      color: kGold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  Text(
                    'Marvan M', // ← partner name
                    style: GoogleFonts.italianno(
                      fontSize: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(width: 60, height: 1, color: kGold),
                  const SizedBox(height: 16),
                  Text(
                    'are joyfully united in marriage',
                    style: GoogleFonts.cormorant(
                      fontSize: 16,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'With the blessings of our families,\nwe invite you to celebrate with us',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorant(
                      fontSize: 17,
                      color: kTextLight,
                      height: 1.8,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'DATE',
                          value: 'August 29,2026', // ← change
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.access_time_outlined,
                          title: 'TIME',
                          value: '11:00 AM onwards', // ← change
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'VENUE',
                    value:
                        'M S Convention Centre, Paruthipulli, Palakkad', // ← change
                  ),
                  const SizedBox(height: 36),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kGreenPale,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kGreenLight.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.favorite, color: kGreen, size: 20),
                        const SizedBox(height: 8),
                        Text(
                          'Your presence is the greatest gift.\nKindly reply by July 30.', // ← change date
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorant(
                            fontSize: 15,
                            color: kText,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RsvpFormPage()),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kGreen,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'RSVP Now',
                        style: GoogleFonts.cormorant(
                          fontSize: 20,
                          letterSpacing: 3,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard(
      {required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGreenLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kGreen, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cormorant(
              fontSize: 11,
              color: kGold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cormorant(
              fontSize: 15,
              color: kText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RSVP FORM PAGE
// ══════════════════════════════════════════════════════════════
class RsvpFormPage extends StatefulWidget {
  const RsvpFormPage({super.key});
  @override
  State<RsvpFormPage> createState() => _RsvpFormPageState();
}

class _RsvpFormPageState extends State<RsvpFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isAttending = true;
  int _guestCount = 1;
  String _mealPreference = 'Vegetarian';
  bool _isSubmitting = false;
  bool _submitted = false;

  final List<String> _mealOptions = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'No preference'
  ];

  Future<void> _submitRsvp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await FirebaseFirestore.instance.collection('rsvps').add({
        'name': _nameController.text.trim(),
        'attending': _isAttending,
        'guestCount': _isAttending ? _guestCount : 0,
        'mealPreference': _isAttending ? _mealPreference : 'N/A',
        'message': _messageController.text.trim(),
        'submittedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _submitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'RSVP',
          style: GoogleFonts.cormorant(fontSize: 24, color: kText),
        ),
      ),
      body: _submitted ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kGreenPale,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: kGreen, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              _isAttending ? 'See you there!' : 'We\'ll miss you!',
              style: GoogleFonts.pinyonScript(fontSize: 42, color: kText),
            ),
            const SizedBox(height: 12),
            Text(
              _isAttending
                  ? 'Your RSVP has been received.\nWe can\'t wait to celebrate with you.'
                  : 'Your response has been noted.\nThank you for letting us know.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorant(
                fontSize: 17,
                color: kTextLight,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('YOUR FULL NAME'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDeco('e.g. Rahul Menon'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 24),
            _label('WILL YOU BE ATTENDING?'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _Toggle(
                  label: '💚  Joyfully Accepts',
                  selected: _isAttending,
                  onTap: () => setState(() => _isAttending = true),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _Toggle(
                  label: '🙁  Regretfully Declines',
                  selected: !_isAttending,
                  onTap: () => setState(() => _isAttending = false),
                )),
              ],
            ),
            if (_isAttending) ...[
              const SizedBox(height: 24),
              _label('NUMBER OF GUESTS'),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_guestCount > 1) setState(() => _guestCount--);
                    },
                    icon:
                        const Icon(Icons.remove_circle_outline, color: kGreen),
                  ),
                  Text('$_guestCount',
                      style: GoogleFonts.cormorant(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: kText)),
                  IconButton(
                    onPressed: () {
                      if (_guestCount < 10) setState(() => _guestCount++);
                    },
                    icon: const Icon(Icons.add_circle_outline, color: kGreen),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _label('MEAL PREFERENCE'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _mealPreference,
                decoration: _inputDeco(''),
                items: _mealOptions
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _mealPreference = v!),
              ),
            ],
            const SizedBox(height: 24),
            _label('A MESSAGE FOR THE COUPLE'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: _inputDeco('Write a warm wish...'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitRsvp,
                style: FilledButton.styleFrom(
                  backgroundColor: kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Send my RSVP',
                        style: GoogleFonts.cormorant(
                            fontSize: 20,
                            letterSpacing: 2,
                            color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style:
          GoogleFonts.cormorant(fontSize: 11, color: kGold, letterSpacing: 2));

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.cormorant(color: kGreenLight),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kGreenLight.withOpacity(0.4))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: kGreenLight.withOpacity(0.4))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kGreen, width: 1.5)),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Toggle(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? kGreen : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? kGreen : kGreenLight.withOpacity(0.4)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorant(
                fontSize: 13, color: selected ? Colors.white : kTextLight)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ADMIN PAGES (unchanged from before)
// ══════════════════════════════════════════════════════════════
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});
  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _passwordController = TextEditingController();
  bool _wrongPassword = false;
  final String _adminPassword = 'wedding2025'; // ← change this

  void _login() {
    if (_passwordController.text == _adminPassword) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AdminPage()));
    } else {
      setState(() => _wrongPassword = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Admin Access',
                  style: GoogleFonts.cormorant(
                      fontSize: 32, color: kText, fontWeight: FontWeight.w600)),
              const SizedBox(height: 32),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: kGreenLight)),
                  errorText: _wrongPassword ? 'Wrong password' : null,
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _login,
                  style: FilledButton.styleFrom(
                    backgroundColor: kGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Login',
                      style: GoogleFonts.cormorant(
                          fontSize: 18, color: Colors.white, letterSpacing: 2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  void _downloadCSV(List<QueryDocumentSnapshot> docs) {
    final buffer = StringBuffer();
    buffer.writeln('Name,Attending,Guests,Meal,Message,Submitted At');
    for (final doc in docs) {
      final d = doc.data() as Map<String, dynamic>;
      final name = d['name'] ?? '';
      final attending = (d['attending'] == true) ? 'Yes' : 'No';
      final guests = d['guestCount']?.toString() ?? '0';
      final meal = d['mealPreference'] ?? '';
      final message = (d['message'] ?? '').toString().replaceAll(',', ' ');
      final time = d['submittedAt'] != null
          ? (d['submittedAt'] as Timestamp).toDate().toString()
          : '';
      buffer.writeln('$name,$attending,$guests,$meal,$message,$time');
    }
    final bytes = buffer.toString().codeUnits;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'rsvp_responses.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _deleteEntry(String docId) async {
    await FirebaseFirestore.instance.collection('rsvps').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kGreen,
        title: Text('RSVP Responses',
            style: GoogleFonts.cormorant(fontSize: 22, color: Colors.white)),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rsvps').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                onPressed: () => _downloadCSV(snapshot.data!.docs),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rsvps')
            .orderBy('submittedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: kGreen));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No responses yet',
                    style: GoogleFonts.cormorant(fontSize: 20, color: kGreen)));
          }
          final docs = snapshot.data!.docs;
          final attending =
              docs.where((d) => (d.data() as Map)['attending'] == true).length;
          final totalGuests = docs.fold<int>(0,
              (sum, d) => sum + ((d.data() as Map)['guestCount'] as int? ?? 0));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatCard(label: 'Total RSVPs', value: '${docs.length}'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Attending', value: '$attending'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Total Guests', value: '$totalGuests'),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final d = doc.data() as Map<String, dynamic>;
                    final isAttending = d['attending'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kGreenLight.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(d['name'] ?? '',
                                      style: GoogleFonts.cormorant(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: kText)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isAttending
                                          ? kGreenPale
                                          : const Color(0xFFFCEBEB),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isAttending ? 'Attending' : 'Declined',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: isAttending
                                              ? kGreen
                                              : const Color(0xFFA32D2D)),
                                    ),
                                  ),
                                ]),
                                if (isAttending) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                      '${d['guestCount']} guest(s) · ${d['mealPreference']}',
                                      style: GoogleFonts.cormorant(
                                          fontSize: 14, color: kTextLight)),
                                ],
                                if ((d['message'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('"${d['message']}"',
                                      style: GoogleFonts.cormorant(
                                          fontSize: 14,
                                          color: kTextLight,
                                          fontStyle: FontStyle.italic)),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Color(0xFFA32D2D)),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete response?'),
                                content: Text('Remove ${d['name']}\'s RSVP?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteEntry(doc.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: Color(0xFFA32D2D))),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kGreenLight.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(value,
              style: GoogleFonts.cormorant(
                  fontSize: 28, fontWeight: FontWeight.w600, color: kGreen)),
          Text(label,
              style: GoogleFonts.cormorant(fontSize: 12, color: kGold),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
