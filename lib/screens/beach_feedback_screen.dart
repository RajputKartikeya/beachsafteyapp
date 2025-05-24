import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/beach_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeachFeedbackScreen extends StatefulWidget {
  final String beachId;
  final String beachName;

  const BeachFeedbackScreen({
    super.key,
    required this.beachId,
    required this.beachName,
  });

  @override
  State<BeachFeedbackScreen> createState() => _BeachFeedbackScreenState();
}

class _BeachFeedbackScreenState extends State<BeachFeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();
  bool _isSafe = true;
  final List<String> _selectedConditions = [];
  bool _isLoading = false;
  List<BeachUpdate> _recentUpdates = [];

  final List<String> _availableConditions = [
    'Clean Water',
    'Strong Currents',
    'High Waves',
    'Good Weather',
    'Poor Visibility',
    'Marine Life Present',
    'Crowded',
    'Lifeguards Present',
  ];

  @override
  void initState() {
    super.initState();
    _loadBeachUpdates();
  }

  Future<void> _loadBeachUpdates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load updates from local storage
      final prefs = await _prefs;
      final updatesJson =
          prefs.getStringList('beach_updates_${widget.beachId}') ?? [];
      setState(() {
        _recentUpdates = updatesJson
            .map((json) => BeachUpdate.fromJson(jsonDecode(json)))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading beach updates: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final update = BeachUpdate(
          id: DateTime.now().toString(),
          beachId: widget.beachId,
          userId: 'local_user',
          userName: 'Anonymous',
          description: _feedbackController.text,
          isSafe: _isSafe,
          timestamp: DateTime.now(),
          conditions: {
            for (var condition in _selectedConditions) condition: true,
          },
        );

        // Save update locally
        final prefs = await _prefs;
        final updatesJson =
            prefs.getStringList('beach_updates_${widget.beachId}') ?? [];
        updatesJson.insert(0, jsonEncode(update.toJson()));
        await prefs.setStringList(
            'beach_updates_${widget.beachId}', updatesJson);

        // Clear form
        _feedbackController.clear();
        setState(() {
          _selectedConditions.clear();
          _isSafe = true;
          _isLoading = false;
        });

        // Reload updates
        _loadBeachUpdates();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback posted successfully!')),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error posting feedback: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.beachName} Feedback')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green),
                              const SizedBox(width: 8),
                              Text(
                                'Safe for Swimming',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Last updated: 2 hours ago'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add Feedback Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Your Feedback',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _feedbackController,
                              decoration: const InputDecoration(
                                labelText: 'Your Feedback',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your feedback';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Text('Current Status:'),
                                const SizedBox(width: 16),
                                Switch(
                                  value: _isSafe,
                                  onChanged: (value) {
                                    setState(() {
                                      _isSafe = value;
                                    });
                                  },
                                ),
                                Text(_isSafe ? 'Safe' : 'Not Safe'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Conditions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: _availableConditions.map((condition) {
                                final isSelected =
                                    _selectedConditions.contains(condition);
                                return FilterChip(
                                  label: Text(condition),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedConditions.add(condition);
                                      } else {
                                        _selectedConditions.remove(condition);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _submitFeedback,
                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('Submit Feedback'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Updates
                  const Text(
                    'Recent Updates',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _recentUpdates.isEmpty
                      ? const Center(
                          child: Text('No updates yet'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _recentUpdates.length,
                          itemBuilder: (context, index) {
                            final update = _recentUpdates[index];
                            return Card(
                              child: ListTile(
                                title: Text(update.description),
                                subtitle: Text(
                                  '${update.isSafe ? 'Safe' : 'Not Safe'} - ${update.timestamp.toString()}',
                                ),
                                leading: const Icon(Icons.beach_access),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}
