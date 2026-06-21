import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const WeddingApp());
}

// ─── App root ───────────────────────────────────────────────
class WeddingApp extends StatelessWidget {
  const WeddingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wedding RSVP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6F5E),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.cormorantTextTheme(),
        useMaterial3: true,
      ),
      home: const EventDetailsPage(),
      routes: {'/admin': (context) => const AdminLoginPage()},
    );
  }
}

// ─── Page 1: Event details ────────────────────────────────────
class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero banner
            Container(
              width: double.infinity,
              height: 320,
              decoration: const BoxDecoration(color: Color(0xFF8B6F5E)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Together Forever',
                    style: GoogleFonts.cormorant(
                      fontSize: 16,
                      color: Color(0xFFE8D5C4),
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dr.Safrina PM\n&\nMarvan M',
                    textAlign: TextAlign.center, // ← Change to your names
                    style: GoogleFonts.pinyonScript(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'are getting married',
                    style: GoogleFonts.cormorant(
                      fontSize: 18,
                      color: Color(0xFFE8D5C4),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Details cards
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Join us to celebrate',
                    style: GoogleFonts.cormorant(
                      fontSize: 22,
                      color: Color(0xFF5C3D2E),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.calendar_today_outlined,
                          title: 'Date',
                          value: 'August 29, 2026', // ← Change
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.access_time_outlined,
                          title: 'Time',
                          value: '10.00 a.m onwards', // ← Change
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Venue',
                    value:
                        'M S Convention Centre, Paruthipully, Palakkad', // ← Change
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: Color(0xFFD4B5A0)),
                  const SizedBox(height: 24),

                  Text(
                    'We would be overjoyed to have you celebrate\nthis special day with us.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorant(
                      fontSize: 16,
                      color: Color(0xFF7A5C4F),
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // RSVP button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RsvpFormPage(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF8B6F5E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'RSVP Now',
                        style: GoogleFonts.cormorant(
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.white,
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
    );
  }
}

// Small info card widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D5C4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF8B6F5E), size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.cormorant(
              fontSize: 12,
              color: const Color(0xFFB0927E),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.cormorant(
              fontSize: 15,
              color: const Color(0xFF5C3D2E),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page 2: RSVP Form ───────────────────────────────────────
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
    'No preference',
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
          SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF8B6F5E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'RSVP',
          style: GoogleFonts.cormorant(
            fontSize: 22,
            color: const Color(0xFF5C3D2E),
          ),
        ),
      ),
      body: _submitted ? _buildSuccessView() : _buildForm(),
    );
  }

  // ── Thank-you screen shown after submission ──
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite, color: Color(0xFF8B6F5E), size: 64),
            const SizedBox(height: 24),
            Text(
              _isAttending ? 'See you there!' : 'We\'ll miss you!',
              style: GoogleFonts.cormorant(
                fontSize: 32,
                color: const Color(0xFF5C3D2E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isAttending
                  ? 'Your RSVP has been received.\nWe can\'t wait to celebrate with you.'
                  : 'Your response has been noted.\nThank you for letting us know.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorant(
                fontSize: 16,
                color: const Color(0xFF7A5C4F),
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── The actual form ──
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kindly reply by November 30', // ← Change deadline
              style: GoogleFonts.cormorant(
                fontSize: 14,
                color: const Color(0xFFB0927E),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 24),

            // Name field
            _buildLabel('Your full name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('e.g. Rahul Menon'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter your name'
                  : null,
            ),
            const SizedBox(height: 24),

            // Attending toggle
            _buildLabel('Will you be attending?'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _ToggleButton(
                    label: '💚  Joyfully accepts',
                    selected: _isAttending,
                    onTap: () => setState(() => _isAttending = true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ToggleButton(
                    label: '🙁  Regretfully declines',
                    selected: !_isAttending,
                    onTap: () => setState(() => _isAttending = false),
                  ),
                ),
              ],
            ),

            // Attending-only fields
            if (_isAttending) ...[
              const SizedBox(height: 24),
              _buildLabel('Number of guests (including yourself)'),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_guestCount > 1) setState(() => _guestCount--);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                    color: const Color(0xFF8B6F5E),
                  ),
                  Text(
                    '$_guestCount',
                    style: GoogleFonts.cormorant(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5C3D2E),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_guestCount < 10) setState(() => _guestCount++);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    color: const Color(0xFF8B6F5E),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Meal preference'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _mealPreference,
                decoration: _inputDecoration(''),
                items: _mealOptions
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _mealPreference = v!),
              ),
            ],

            const SizedBox(height: 24),
            _buildLabel('Message for the couple (optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: _inputDecoration('Write a warm wish...'),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitRsvp,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF8B6F5E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Send my RSVP',
                        style: GoogleFonts.cormorant(
                          fontSize: 18,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cormorant(
        fontSize: 13,
        color: const Color(0xFFB0927E),
        letterSpacing: 1.2,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.cormorant(color: const Color(0xFFCDB5A6)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF8B6F5E), width: 1.5),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

// Reusable toggle button
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF8B6F5E) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF8B6F5E) : const Color(0xFFE8D5C4),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cormorant(
            fontSize: 13,
            color: selected ? Colors.white : const Color(0xFF7A5C4F),
          ),
        ),
      ),
    );
  }
}

// ─── Admin Login Page ────────────────────────────────────────
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _passwordController = TextEditingController();
  bool _wrongPassword = false;

  // ← Change this to your own secret password
  final String _adminPassword = 'safri2026';

  void _login() {
    if (_passwordController.text == _adminPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      setState(() => _wrongPassword = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Admin Access',
                style: GoogleFonts.cormorant(
                  fontSize: 32,
                  color: const Color(0xFF5C3D2E),
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                    borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE8D5C4)),
                  ),
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
                    backgroundColor: const Color(0xFF8B6F5E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: GoogleFonts.cormorant(
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Admin Dashboard Page ─────────────────────────────────────
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Convert Firestore data to CSV and trigger download
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

    // Download in web
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
      backgroundColor: const Color(0xFFFDF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B6F5E),
        title: Text(
          'RSVP Responses',
          style: GoogleFonts.cormorant(
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('rsvps').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.download, color: Colors.white),
                tooltip: 'Download CSV',
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
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No responses yet',
                style: GoogleFonts.cormorant(
                  fontSize: 20,
                  color: const Color(0xFF8B6F5E),
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final total = docs.length;
          final attending =
              docs.where((d) => (d.data() as Map)['attending'] == true).length;
          final totalGuests = docs.fold<int>(0,
              (sum, d) => sum + ((d.data() as Map)['guestCount'] as int? ?? 0));

          return Column(
            children: [
              // Summary cards
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _StatCard(label: 'Total RSVPs', value: '$total'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Attending', value: '$attending'),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Total Guests', value: '$totalGuests'),
                  ],
                ),
              ),

              // Response list
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
                        border: Border.all(color: const Color(0xFFE8D5C4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      d['name'] ?? '',
                                      style: GoogleFonts.cormorant(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF5C3D2E),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAttending
                                            ? const Color(0xFFEAF3DE)
                                            : const Color(0xFFFCEBEB),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isAttending ? 'Attending' : 'Declined',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isAttending
                                              ? const Color(0xFF3B6D11)
                                              : const Color(0xFFA32D2D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isAttending) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${d['guestCount']} guest(s) · ${d['mealPreference']}',
                                    style: GoogleFonts.cormorant(
                                      fontSize: 14,
                                      color: const Color(0xFF8B6F5E),
                                    ),
                                  ),
                                ],
                                if ((d['message'] ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '"${d['message']}"',
                                    style: GoogleFonts.cormorant(
                                      fontSize: 14,
                                      color: const Color(0xFF7A5C4F),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
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

// Small stat card for admin summary
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
          border: Border.all(color: const Color(0xFFE8D5C4)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.cormorant(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8B6F5E),
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cormorant(
                fontSize: 12,
                color: const Color(0xFFB0927E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
