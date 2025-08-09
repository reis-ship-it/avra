import 'package:flutter/material.dart';
import 'package:spots/core/models/unified_models.dart';import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spots/presentation/blocs/auth/auth_bloc.dart';
import 'package:spots/presentation/blocs/lists/lists_bloc.dart';
import 'package:spots/presentation/blocs/spots/spots_bloc.dart';
import 'package:spots/core/theme/app_theme.dart';
import 'package:spots/presentation/pages/lists/list_details_page.dart';
import 'package:spots/presentation/widgets/lists/spot_list_card.dart';
import 'package:spots/presentation/widgets/map/map_view.dart';
import 'package:spots/presentation/widgets/common/search_bar.dart';
import 'package:spots/presentation/widgets/common/chat_message.dart';
import 'package:spots/presentation/widgets/common/universal_ai_search.dart';
import 'package:spots/presentation/widgets/common/ai_command_processor.dart';

class HomePage extends StatefulWidget {
  final int initialTabIndex;

  const HomePage({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const MapTab(),
    const SpotsTab(),
    const ExploreTab(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTabIndex;
    // Load lists when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListsBloc>().add(LoadLists());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/');
        }
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is Authenticated) {
            return _buildAuthenticatedContent(context, state);
          }

          return _buildUnauthenticatedContent(context);
        },
      ),
    );
  }

  Widget _buildAuthenticatedContent(BuildContext context, Authenticated state) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Spots'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        ],
      ),
      // Remove the invasive offline FAB - offline status is now shown in profile page
    );
  }

  Widget _buildUnauthenticatedContent(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome to SPOTS',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Create lists of places and share them with others',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

// Tab Widgets
class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapView(
      showAppBar: true,
      appBarTitle: 'Map',
    );
  }
}

class SpotsTab extends StatefulWidget {
  const SpotsTab({super.key});

  @override
  State<SpotsTab> createState() => _SpotsTabState();
}

class _SpotsTabState extends State<SpotsTab> {
  @override
  void initState() {
    super.initState();
    // Load lists when this tab is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListsBloc>().add(LoadLists());
      // Also load spots from respected lists
      context.read<SpotsBloc>().add(LoadSpotsWithRespected());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lists'),
        leading: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    (state.user.displayName ?? state.user.name).substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  _showProfileMenu(context);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: Column(
        children: [
          // Search bar below app bar
          CustomSearchBar(
            hintText: 'Search lists...',
            onChanged: (value) {
              context.read<ListsBloc>().add(SearchLists(value));
            },
          ),
          // Content with tabs
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tab bar
                  Container(
                    color: Colors.grey[100],
                    child: const TabBar(
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.primaryColor,
                      tabs: [
                        Tab(text: 'My Lists'),
                        Tab(text: 'Respected Lists'),
                      ],
                    ),
                  ),
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // My Lists Tab
                        BlocBuilder<ListsBloc, ListsState>(
                          builder: (context, state) {
                            if (state is ListsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (state is ListsLoaded) {
                              if (state.filteredLists.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.list,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No lists yet. Create your first list!',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: state.filteredLists.length,
                                itemBuilder: (context, index) {
                                  final list = state.filteredLists[index];
                                  return SpotListCard(
                                    list: list,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ListDetailsPage(list: list),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            }

                            if (state is ListsError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error,
                                        size: 64, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text('Error: ${state.message}'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<ListsBloc>()
                                            .add(LoadLists());
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return const Center(child: Text('No lists loaded'));
                          },
                        ),
                        // Respected Lists Tab
                        BlocBuilder<SpotsBloc, SpotsState>(
                          builder: (context, state) {
                            if (state is SpotsLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (state is SpotsLoaded) {
                              if (state.respectedSpots.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.favorite_border,
                                          size: 64, color: Colors.grey),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'No respected lists yet',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Respect some lists during onboarding to see them here',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                itemCount: state.respectedSpots.length,
                                itemBuilder: (context, index) {
                                  final spot = state.respectedSpots[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                        child: Icon(
                                          _getCategoryIcon(spot.category),
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      title: Text(spot.name),
                                      subtitle: Text(spot.description),
                                      trailing: const Icon(Icons.favorite,
                                          color: Colors.red),
                                    ),
                                  );
                                },
                              );
                            }

                            if (state is SpotsError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error,
                                        size: 64, color: Colors.red),
                                    const SizedBox(height: 16),
                                    Text('Error: ${state.message}'),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        context
                                            .read<SpotsBloc>()
                                            .add(LoadSpotsWithRespected());
                                      },
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return const Center(
                                child: Text('No respected spots loaded'));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        state.user.displayName?.substring(0, 1).toUpperCase() ??
                            state.user.email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(state.user.displayName ?? 'User'),
                    subtitle: Text(state.user.email),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & drink':
        return Icons.restaurant;
      case 'activities':
        return Icons.sports_soccer;
      case 'outdoor & nature':
        return Icons.nature;
      case 'culture & arts':
        return Icons.museum;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.place;
    }
  }
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        leading: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return IconButton(
                icon: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    state.user.displayName?.substring(0, 1).toUpperCase() ??
                        state.user.email.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  _showProfileMenu(context);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.smart_toy), text: 'AI'),
            Tab(icon: Icon(Icons.event), text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          UsersSubTab(),
          AISubTab(),
          EventsSubTab(),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        state.user.displayName?.substring(0, 1).toUpperCase() ??
                            state.user.email.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(state.user.displayName ?? 'User'),
                    subtitle: Text(state.user.email),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Sign Out'),
                    onTap: () {
                      Navigator.pop(context);
                      context.read<AuthBloc>().add(SignOutRequested());
                    },
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class UsersSubTab extends StatelessWidget {
  const UsersSubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Discover Users',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Find and follow other SPOTS users',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 14, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}

class AISubTab extends StatefulWidget {
  const AISubTab({super.key});

  @override
  State<AISubTab> createState() => _AISubTabState();
}

class _AISubTabState extends State<AISubTab> {
  final List<Map<String, dynamic>> _messages = [];
  bool _isProcessingCommand = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add({
      'message':
          "Hi! I'm your SPOTS AI assistant. I can help you create lists, add spots, find places, discover events, connect with users, and much more! Just tell me what you'd like to do.",
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  void _handleAICommand(String command) {
    if (command.trim().isEmpty) return;

    // Add user command
    setState(() {
      _messages.add({
        'message': command,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _isProcessingCommand = true;
    });

    // Process command and get response
    final response = AICommandProcessor.processCommand(command, context);

    // Simulate processing time
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isProcessingCommand = false;
          _messages.add({
            'message': response,
            'isUser': false,
            'timestamp': DateTime.now(),
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              return ChatMessage(
                message: message['message'],
                isUser: message['isUser'],
                timestamp: message['timestamp'],
              );
            },
          ),
        ),
        // Loading indicator
        if (_isProcessingCommand)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor,
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.grey[200]
                        : Colors.grey[700],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Processing your request...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        // Universal AI Search
        UniversalAISearch(
          hintText: 'Ask me anything... (create lists, find spots, etc.)',
          onCommand: _handleAICommand,
          isLoading: _isProcessingCommand,
        ),
      ],
    );
  }
}

class EventsSubTab extends StatelessWidget {
  const EventsSubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Events',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Discover local events and meetups',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'Coming Soon',
            style: TextStyle(fontSize: 14, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
