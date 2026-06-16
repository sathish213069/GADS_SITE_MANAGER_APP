import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const GadsSiteManagerApp());
}

const navy = Color(0xFF0A1D3A);
const gold = Color(0xFFD4AF37);
const lightBg = Color(0xFFF5F7FB);

class GadsSiteManagerApp extends StatelessWidget {
  const GadsSiteManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GADS Site Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: navy),
        scaffoldBackgroundColor: lightBg,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class SupabaseConfig {
  static String url = '';
  static String key = '';

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    url = p.getString('supabase_url') ?? '';
    key = p.getString('supabase_key') ?? '';
  }

  static Future<void> save(String newUrl, String newKey) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('supabase_url', newUrl.trim());
    await p.setString('supabase_key', newKey.trim());
    url = newUrl.trim();
    key = newKey.trim();
  }

  static Map<String, String> get headers => {
    'apikey': key,
    'Authorization': 'Bearer $key',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation',
  };

  static String table(String name) => '${url.replaceAll(RegExp(r"/$"), "")}/rest/v1/$name';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userCtrl = TextEditingController(text: 'SUP001');
  final passCtrl = TextEditingController(text: '1234');
  bool loading = false;
  bool showPassword = false;
  String message = '';

  @override
  void initState() {
    super.initState();
    SupabaseConfig.load().then((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> login() async {
    if (SupabaseConfig.url.isEmpty || SupabaseConfig.key.isEmpty) {
      setState(() => message = 'Settings-la Supabase URL and Publishable Key save pannunga.');
      return;
    }
    setState(() {
      loading = true;
      message = '';
    });

    try {
      final url =
          '${SupabaseConfig.table('supervisor_login')}?username=eq.${Uri.encodeComponent(userCtrl.text.trim())}&password=eq.${Uri.encodeComponent(passCtrl.text.trim())}&status=eq.Active&select=*';
      final res = await http.get(Uri.parse(url), headers: SupabaseConfig.headers);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final list = jsonDecode(res.body) as List;
        if (list.isNotEmpty) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardScreen(supervisor: list.first)),
          );
        } else {
          setState(() => message = 'Wrong username/password.');
        }
      } else {
        setState(() => message = 'Login failed: ${res.body}');
      }
    } catch (e) {
      setState(() => message = 'Connection error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void openSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))
        .then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/gads_logo.png', height: 120, errorBuilder: (_, __, ___) {
                return const Icon(Icons.business, color: gold, size: 88);
              }),
              const SizedBox(height: 12),
              const Text('GADS Site Manager',
                  style: TextStyle(color: gold, fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Supervisor Mobile App',
                  style: TextStyle(color: Colors.white70, fontSize: 15)),
              const SizedBox(height: 30),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      TextField(
                        controller: userCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: passCtrl,
                        obscureText: !showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => showPassword = !showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (message.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(message, style: const TextStyle(color: Colors.red)),
                        ),
                      ElevatedButton(
                        onPressed: loading ? null : login,
                        child: loading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      TextButton(
                        onPressed: openSettings,
                        child: const Text('Cloud Settings'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Default: SUP001 / 1234',
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final urlCtrl = TextEditingController();
  final keyCtrl = TextEditingController();
  String msg = '';

  @override
  void initState() {
    super.initState();
    SupabaseConfig.load().then((_) {
      urlCtrl.text = SupabaseConfig.url;
      keyCtrl.text = SupabaseConfig.key;
      if (mounted) setState(() {});
    });
  }

  Future<void> save() async {
    await SupabaseConfig.save(urlCtrl.text, keyCtrl.text);
    setState(() => msg = 'Saved ✅');
  }

  Future<void> test() async {
    await SupabaseConfig.save(urlCtrl.text, keyCtrl.text);
    try {
      final res = await http.get(
        Uri.parse('${SupabaseConfig.table('mobile_entries')}?select=id&limit=1'),
        headers: SupabaseConfig.headers,
      );
      setState(() => msg = res.statusCode < 300
          ? 'Supabase connected ✅'
          : 'Failed: ${res.statusCode} ${res.body}');
    } catch (e) {
      setState(() => msg = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Cloud Settings',
      child: Column(
        children: [
          TextField(
            controller: urlCtrl,
            decoration: const InputDecoration(
              labelText: 'Supabase Project URL',
              hintText: 'https://xxxx.supabase.co',
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: keyCtrl,
            decoration: const InputDecoration(
              labelText: 'Publishable Key',
              hintText: 'sb_publishable_...',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: save, child: const Text('SAVE SETTINGS')),
          const SizedBox(height: 10),
          OutlinedButton(onPressed: test, child: const Text('TEST CONNECTION')),
          if (msg.isNotEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(msg)),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> supervisor;
  const DashboardScreen({super.key, required this.supervisor});

  @override
  Widget build(BuildContext context) {
    final name = supervisor['supervisor_name'] ?? 'Supervisor';
    return AppPage(
      title: 'Dashboard',
      showBack: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome, $name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Site Supervisor', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              ActionTile(icon: Icons.currency_rupee, title: 'Expense Entry',
                  onTap: () => openEntry(context, 'Expense')),
              ActionTile(icon: Icons.inventory_2, title: 'Material Entry',
                  onTap: () => openEntry(context, 'Material Purchase')),
              ActionTile(icon: Icons.groups, title: 'Labour Entry',
                  onTap: () => openEntry(context, 'Labour Entry')),
              ActionTile(icon: Icons.assignment, title: 'Work Report',
                  onTap: () => openEntry(context, 'Daily Work Report')),
            ],
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => EntriesScreen(supervisor: supervisor))),
            child: const Text('MY ENTRIES'),
          ),
        ],
      ),
    );
  }

  void openEntry(BuildContext context, String type) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => EntryScreen(supervisor: supervisor, entryType: type),
    ));
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ActionTile({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: navy, size: 42),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class EntryScreen extends StatefulWidget {
  final Map<String, dynamic> supervisor;
  final String entryType;
  const EntryScreen({super.key, required this.supervisor, required this.entryType});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  List projects = [];
  dynamic selectedProject;
  final categoryCtrl = TextEditingController();
  final supplierCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final remarksCtrl = TextEditingController();
  final gpsCtrl = TextEditingController();
  final billCtrl = TextEditingController();
  bool loading = false;
  String msg = '';

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    try {
      final res = await http.get(
        Uri.parse('${SupabaseConfig.table('projects')}?select=*&order=id.desc'),
        headers: SupabaseConfig.headers,
      );
      if (res.statusCode < 300) {
        setState(() {
          projects = jsonDecode(res.body);
          if (projects.isNotEmpty) selectedProject = projects.first;
        });
      } else {
        setState(() => msg = 'Projects load failed: ${res.body}');
      }
    } catch (e) {
      setState(() => msg = 'Projects error: $e');
    }
  }

  Future<void> submit() async {
    if (selectedProject == null) {
      setState(() => msg = 'Project select pannunga.');
      return;
    }
    setState(() { loading = true; msg = ''; });
    final data = {
      'project_id': selectedProject['id'],
      'supervisor_id': widget.supervisor['id'],
      'entry_type': widget.entryType,
      'category': categoryCtrl.text,
      'supplier_paid_to': supplierCtrl.text,
      'qty': double.tryParse(qtyCtrl.text),
      'amount': double.tryParse(amountCtrl.text),
      'payment_mode': 'Cash',
      'remarks': remarksCtrl.text,
      'gps_location': gpsCtrl.text,
      'bill_file': billCtrl.text,
      'approval_status': 'Pending',
    };
    try {
      final res = await http.post(
        Uri.parse(SupabaseConfig.table('mobile_entries')),
        headers: SupabaseConfig.headers,
        body: jsonEncode(data),
      );
      if (res.statusCode < 300) {
        setState(() {
          msg = 'Submitted ✅ Pending approval';
          categoryCtrl.clear(); supplierCtrl.clear(); qtyCtrl.clear(); amountCtrl.clear();
          remarksCtrl.clear(); gpsCtrl.clear(); billCtrl.clear();
        });
      } else {
        setState(() => msg = 'Submit failed: ${res.body}');
      }
    } catch (e) {
      setState(() => msg = 'Submit error: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.entryType,
      child: Column(
        children: [
          DropdownButtonFormField<dynamic>(
            value: selectedProject,
            items: projects.map<DropdownMenuItem<dynamic>>((p) {
              return DropdownMenuItem(value: p, child: Text(p['project_name'] ?? 'Project'));
            }).toList(),
            onChanged: (v) => setState(() => selectedProject = v),
            decoration: const InputDecoration(labelText: 'Project'),
          ),
          const SizedBox(height: 12),
          TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category / Material / Labour Type')),
          const SizedBox(height: 12),
          TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier / Paid To')),
          const SizedBox(height: 12),
          TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Qty / No. of Labour')),
          const SizedBox(height: 12),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount ₹')),
          const SizedBox(height: 12),
          TextField(controller: billCtrl, decoration: const InputDecoration(labelText: 'Bill Photo File Name')),
          const SizedBox(height: 12),
          TextField(controller: gpsCtrl, decoration: const InputDecoration(labelText: 'GPS / Location')),
          const SizedBox(height: 12),
          TextField(controller: remarksCtrl, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Remarks / Work Details')),
          const SizedBox(height: 16),
          if (msg.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(msg)),
          ElevatedButton(
            onPressed: loading ? null : submit,
            child: loading ? const CircularProgressIndicator() : const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}

class EntriesScreen extends StatefulWidget {
  final Map<String, dynamic> supervisor;
  const EntriesScreen({super.key, required this.supervisor});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  List entries = [];
  String msg = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  Future<void> loadEntries() async {
    try {
      final res = await http.get(
        Uri.parse('${SupabaseConfig.table('mobile_entries')}?supervisor_id=eq.${widget.supervisor['id']}&select=*&order=id.desc'),
        headers: SupabaseConfig.headers,
      );
      if (res.statusCode < 300) {
        setState(() { entries = jsonDecode(res.body); msg = ''; });
      } else {
        setState(() => msg = res.body);
      }
    } catch (e) {
      setState(() => msg = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'My Entries',
      child: Column(
        children: [
          ElevatedButton(onPressed: loadEntries, child: const Text('REFRESH')),
          if (msg.isNotEmpty) Text(msg),
          ...entries.map((e) => Card(
            child: ListTile(
              title: Text('${e['entry_type'] ?? ''} - ₹${e['amount'] ?? ''}'),
              subtitle: Text('${e['category'] ?? ''}\n${e['remarks'] ?? ''}'),
              trailing: Text(e['approval_status'] ?? 'Pending'),
            ),
          )),
        ],
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showBack;
  const AppPage({super.key, required this.title, required this.child, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: showBack,
        title: Text(title, style: const TextStyle(color: gold, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}