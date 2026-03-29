import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    // Debug logging
    print('ProfileTab - User: ${user?.username}, Email: ${user?.email}');
    print('ProfileTab - Full user data: ${user?.toJson()}');

    // Show loading if user is being loaded
    if (authProvider.isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error if user is null
    if (user == null) {
      print('ProfileTab - User is null!');
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Please try logging in again',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Radiant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.initialize();
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile refreshed')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Profile Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surfaceContainerLow.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: user.avatar != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.avatar!,
                                    width: 128,
                                    height: 128,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.person,
                                      size: 64,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 64,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Debug info
                    if (user.username.isEmpty && user.email.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Debug Info',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'User ID: ${user.id}',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Username: "${user.username}"',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'Email: "${user.email}"',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'FullName: "${user.fullName}"',
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName?.isNotEmpty == true 
                          ? user.fullName! 
                          : (user.username.isNotEmpty ? user.username : 'User'),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.username.isNotEmpty)
                      Text(
                        '@${user.username}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (user.email.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                user.bio!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Edit profile
                              },
                              child: const Text('Edit Profile'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: IconButton(
                            onPressed: () {
                              // TODO: Share profile
                            },
                            icon: const Icon(Icons.share),
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        Icons.badge_outlined,
                        'User ID',
                        user.id,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        context,
                        Icons.calendar_today_outlined,
                        'Member Since',
                        _formatDate(user.createdAt),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Menu Sections
              _buildMenuSection(
                context,
                'Account Settings',
                [
                  _MenuItem(
                    icon: Icons.person,
                    title: 'Personal Info',
                    subtitle: 'Update your name and bio',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.alternate_email,
                    title: 'Account Access',
                    subtitle: 'Email, password and login',
                    onTap: () {},
                  ),
                ],
              ),

              _buildMenuSection(
                context,
                'Security & Privacy',
                [
                  _MenuItem(
                    icon: Icons.shield,
                    title: 'Privacy Settings',
                    subtitle: 'Who can see your presence',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.block,
                    title: 'Blocked Users',
                    subtitle: 'Manage your restrictions',
                    onTap: () {},
                  ),
                ],
              ),

              _buildMenuSection(
                context,
                'Preferences',
                [
                  _MenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Alerts and sound settings',
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.palette,
                    title: 'Appearance',
                    subtitle: 'Theme and chat wallpapers',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sign Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextButton.icon(
                  onPressed: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.logout,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: items.map((item) {
                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.icon,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.trailing != null)
                          item.trailing!
                        else
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    Color? statusColor,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: statusColor ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
