import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../models/beach_update.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import 'beach_management_screen.dart';
import 'notifications_screen.dart';
import 'login_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _prefs = SharedPreferences.getInstance();
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();

  bool _isEditingProfile = false;
  XFile? _profileImage;
  bool _isLoading = false;
  String _userName = 'User';
  String _userEmail = '';
  List<BeachUpdate> _userUpdates = [];
  bool _areNotificationsEnabled = false;
  int _subscribedBeachesCount = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await _prefs;
      final subscribedBeaches =
          await _notificationService.getSubscribedBeaches();
      final notificationsEnabled =
          await _notificationService.areNotificationsEnabled();

      // Get Firebase Auth user data if available
      String userName = 'User';
      String userEmail = '';

      if (_authService.isUserLoggedIn()) {
        final firebaseDisplayName = _authService.getUserDisplayName();
        final firebaseEmail = _authService.getUserEmail();

        userName = firebaseDisplayName ?? prefs.getString('userName') ?? 'User';
        userEmail = firebaseEmail ?? '';

        // Save the Firebase email to controller, but make it read-only if from Firebase
        _emailController.text = userEmail;
      } else {
        // Fallback to shared preferences
        userName = prefs.getString('userName') ?? 'User';
        userEmail = prefs.getString('userEmail') ?? '';
      }

      setState(() {
        _userName = userName;
        _userEmail = userEmail;
        _nameController.text = _userName;
        _emailController.text = _userEmail;
        _userUpdates = _loadUserUpdates();
        _areNotificationsEnabled = notificationsEnabled;
        _subscribedBeachesCount = subscribedBeaches.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user data: $e')));
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();

      if (mounted) {
        // Navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  List<BeachUpdate> _loadUserUpdates() {
    // TODO: Implement local storage for updates
    return [];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _saveUserProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Save to shared preferences
        final prefs = await _prefs;
        await prefs.setString('userName', _nameController.text);

        // Save displayName to Firebase Auth if user is logged in
        if (_authService.isUserLoggedIn()) {
          await _authService.updateUserProfile(
            displayName: _nameController.text,
          );
        } else {
          // If not using Firebase auth, still save email to shared prefs
          await prefs.setString('userEmail', _emailController.text);
        }

        setState(() {
          _userName = _nameController.text;
          _userEmail = _emailController.text;
          _isEditingProfile = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating profile: $e')));
      }
    }
  }

  void _toggleNotifications() async {
    try {
      final enabled = await _notificationService.toggleNotifications();

      setState(() {
        _areNotificationsEnabled = enabled;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enabled ? 'Notifications enabled' : 'Notifications disabled',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling notifications: $e')),
      );
    }
  }

  void _navigateToBeachManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BeachManagementScreen()),
    ).then((_) => _loadUserData());
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        _isEditingProfile ? 'Edit Profile' : 'My Profile',
                      ),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade500,
                            ],
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      if (!_isEditingProfile)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            setState(() {
                              _isEditingProfile = true;
                            });
                          },
                          tooltip: 'Edit Profile',
                        ),
                    ],
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Header
                          Center(
                            child: Column(
                              children: [
                                // Profile image with edit button
                                Stack(
                                  children: [
                                    // Profile image
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          _profileImage != null
                                              ? FileImage(
                                                File(_profileImage!.path),
                                              )
                                              : null,
                                      child:
                                          _profileImage == null
                                              ? const Icon(
                                                Icons.person,
                                                size: 50,
                                              )
                                              : null,
                                    ),
                                    if (_isEditingProfile)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.add_a_photo,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            onPressed: _pickImage,
                                            tooltip: 'Change Photo',
                                            constraints: const BoxConstraints(
                                              minHeight: 40,
                                              minWidth: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Profile details or edit form
                                if (_isEditingProfile)
                                  _buildEditProfileForm()
                                else
                                  Column(
                                    children: [
                                      Text(
                                        _userName,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_userEmail.isNotEmpty)
                                        Text(
                                          _userEmail,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Beach Management Section
                          _buildSectionCard(
                            title: 'Beach Management',
                            icon: Icons.beach_access,
                            color: Colors.blue,
                            children: [
                              _buildActionTile(
                                icon: Icons.waves,
                                title: 'Manage Beaches',
                                subtitle:
                                    'Subscribe and add updates to beaches',
                                trailingText:
                                    '$_subscribedBeachesCount subscribed',
                                onTap: _navigateToBeachManagement,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Notifications Section
                          _buildSectionCard(
                            title: 'Notifications',
                            icon: Icons.notifications,
                            color: Colors.orange,
                            children: [
                              _buildSwitchTile(
                                icon: Icons.notifications_active,
                                title: 'Enable Notifications',
                                subtitle: 'Get alerts about beach conditions',
                                value: _areNotificationsEnabled,
                                onChanged: (value) => _toggleNotifications(),
                              ),
                              _buildActionTile(
                                icon: Icons.history,
                                title: 'Notification History',
                                subtitle: 'View past beach alerts',
                                trailingText: 'View All',
                                onTap: _navigateToNotifications,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Settings Section
                          _buildSectionCard(
                            title: 'Settings',
                            icon: Icons.settings,
                            color: Colors.grey,
                            children: [
                              _buildActionTile(
                                icon: Icons.delete,
                                title: 'Clear Saved Data',
                                subtitle:
                                    'Remove all cached info and preferences',
                                textColor: Colors.red,
                                onTap: () {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Clear All Data?'),
                                          content: const Text(
                                            'This will remove all your saved preferences and subscriptions. This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                // TODO: Implement clear data
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'All data cleared',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Clear Data',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // App Info
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'BeachSafe India',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Version 1.0.0',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),

                  // Add Logout Button at the end
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _logout,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEditProfileForm() {
    // Check if user is authenticated with Firebase
    final isFirebaseUser = _authService.isUserLoggedIn();

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email field
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: const OutlineInputBorder(),
              // Show hint about Firebase auth if user is logged in with Firebase
              helperText:
                  isFirebaseUser
                      ? 'Email cannot be changed directly when using Firebase authentication'
                      : null,
              suffixIcon:
                  isFirebaseUser ? const Icon(Icons.lock, size: 16) : null,
            ),
            keyboardType: TextInputType.emailAddress,
            // Make email field read-only if using Firebase auth
            readOnly: isFirebaseUser,
            enabled: !isFirebaseUser,
            validator: (value) {
              if (value != null && value.isNotEmpty && !isFirebaseUser) {
                // Simple email validation
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEditingProfile = false;
                    _nameController.text = _userName;
                    _emailController.text = _userEmail;
                  });
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _saveUserProfile,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Section content
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      trailing:
          trailingText != null
              ? Chip(
                label: Text(trailingText, style: const TextStyle(fontSize: 12)),
                backgroundColor: Colors.grey[200],
              )
              : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
