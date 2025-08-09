import 'package:flutter/material.dart';
import 'dart:async';
import 'package:spots/core/services/logger.dart';
import 'package:get_it/get_it.dart';
import 'package:spots_network/spots_network.dart';
import 'package:spots_core/spots_core.dart';
import 'package:spots/core/services/ai2ai_realtime_service.dart';
import 'package:spots/core/ml/inference_orchestrator.dart';
import 'package:spots/core/ml/embedding_service.dart';
import 'dart:typed_data';

/// Test page to verify Supabase integration
class SupabaseTestPage extends StatefulWidget {
  final bool auto;
  const SupabaseTestPage({super.key, this.auto = false});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  final AppLogger _logger = const AppLogger(defaultTag: 'SPOTS', minimumLevel: LogLevel.debug);
  final DataBackend _data = GetIt.instance<DataBackend>();
  final RealtimeBackend _realtimeBackend = GetIt.instance<RealtimeBackend>();
  final AuthBackend _auth = GetIt.instance<AuthBackend>();
  final AI2AIRealtimeService _realtime = GetIt.instance<AI2AIRealtimeService>();
  bool _isLoading = false;
  String _status = 'Ready to test';
  List<Spot> _spots = [];
  List<SpotList> _lists = [];
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _presence = [];
  StreamSubscription? _sub1;
  StreamSubscription? _sub2;
  StreamSubscription? _sub3;
  StreamSubscription<List<Map<String, dynamic>>>? _dmSub;
  Map<String, dynamic>? _lastProfileSummary;

  @override
  void initState() {
    super.initState();
    _testConnection();
    _wireRealtime();
    _wirePrivateMessages();
    // Ensure AI2AI service subscribes/join channels
    _realtime.initialize();
    if (widget.auto) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          await _createTestSpot();
          await _createTestList();
          await _loadSpots();
          await _loadLists();
          await _realtime.sendAnonymousMessage('auto_test', {'note': 'auto-driven'});
        } catch (_) {}
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      final backend = GetIt.instance<BackendInterface>();
      final ok = backend.isInitialized;
      setState(() {
        _status = ok ? '✅ Backend initialized!' : '❌ Backend not initialized';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _isLoading = false;
      });
    }
  }

  void _wireRealtime() {
    _sub1 = _realtime.listenToPersonalityDiscovery().listen((m) {
      setState(() => _messages.insert(0, {
              'type': m.type,
              'content': m.content,
              'metadata': m.metadata,
          }));
    });
    _sub2 = _realtime.listenToVibeLearning().listen((m) {
      setState(() => _messages.insert(0, {
              'type': m.type,
              'content': m.content,
              'metadata': m.metadata,
          }));
    });
    _sub3 = _realtime.listenToAnonymousCommunication().listen((m) {
      setState(() => _messages.insert(0, {
              'type': m.type,
              'content': m.content,
              'metadata': m.metadata,
          }));
    });
    _refreshPresence();
  }

  void _wirePrivateMessages() {
    _auth.getCurrentUser().then((user) {
      if (!mounted || user == null) return;
      _dmSub = _realtimeBackend
          .subscribeToCollection<Map<String, dynamic>>(
            'private_messages',
            (row) => row,
          )
          .listen((rows) {
        final mine = rows.where((r) => r['to_user_id'] == user.id).toList();
        if (mine.isEmpty) return;
        final payload = (mine.last['payload'] as Map<String, dynamic>?);
        if (payload == null) return;
        if (payload['type'] == 'profile_summary') {
          setState(() => _lastProfileSummary = payload);
        }
      });
    });
  }

  Future<void> _refreshPresence() async {
    final presenceStream = _realtime.watchAINetworkPresence();
    presenceStream.listen((p) {
      setState(() => _presence = p
          .map((e) => {
                'userId': e.userId,
                'userName': e.userName,
                'lastSeen': e.lastSeen.toIso8601String(),
              })
          .toList());
    });
  }

  Future<void> _loadSpots() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading spots...';
    });

    try {
      final res = await _data.getSpots(limit: 50);
      final spots = res.success && res.data != null ? res.data! : <Spot>[];
      setState(() {
        _spots = spots;
        _status = '✅ Loaded ${spots.length} spots';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to load spots: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLists() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading lists...';
    });

    try {
      final res = await _data.getSpotLists(limit: 50);
      final lists = res.success && res.data != null ? res.data! : <SpotList>[];
      setState(() {
        _lists = lists;
        _status = '✅ Loaded ${lists.length} lists';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Failed to load lists: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestSpot() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test spot...';
    });

    try {
      final user = await _auth.getCurrentUser();
      final now = DateTime.now();
      final spot = Spot(
        id: '', // allow DB to generate
        name: 'Test Spot ${now.second}',
        description: 'A test spot created from the app',
        latitude: 37.7749,
        longitude: -122.4194,
        category: 'general',
        createdBy: user?.id ?? 'anonymous',
        createdAt: now,
        updatedAt: now,
        tags: const ['test', 'demo'],
      );
      await _data.createSpot(spot);
      
      setState(() {
        _status = '✅ Test spot created!';
        _isLoading = false;
      });
      
      // Reload spots
      await _loadSpots();
    } catch (e) {
      setState(() {
        _status = '❌ Failed to create spot: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestList() async {
    setState(() {
      _isLoading = true;
      _status = 'Creating test list...';
    });

    try {
      final user = await _auth.getCurrentUser();
      final now = DateTime.now();
      final list = SpotList(
        id: '', // allow DB to generate
        title: 'Test List ${now.second}',
        description: 'A test list created from the app',
        category: ListCategory.general,
        type: ListType.public,
        curatorId: user?.id ?? 'anonymous',
        createdAt: now,
        updatedAt: now,
        tags: const ['test', 'demo'],
      );
      await _data.createSpotList(list);
      
      setState(() {
        _status = '✅ Test list created!';
        _isLoading = false;
      });
      
      // Reload lists
      await _loadLists();
    } catch (e) {
      setState(() {
        _status = '❌ Failed to create list: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Test (Realtime + DB)'),
        // Use global ButtonTheme; keep default colors
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Realtime Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _realtime.sendAnonymousMessage('test_message', {'content': 'Hello AI2AI'});
                      },
                      child: const Text('Send Test Message'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _refreshPresence,
                      child: Text('Presence: ${_presence.length}')
                    ),
                  ],
                ),
              ),
            ),
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _testConnection,
                          child: const Text('Test Connection'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createTestSpot,
                          child: const Text('Create Test Spot'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _createTestList,
                          child: const Text('Create Test List'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final embedService = await GetIt.instance.getAsync<EmbeddingService>();
                              final vec = await embedService.embed('Hola mundo, bonjour le monde, hello world');
                              if (!context.mounted) return;
                              final preview = vec.length >= 6
                                  ? '[${vec[0].toStringAsFixed(3)}, ${vec[1].toStringAsFixed(3)}, ${vec[2].toStringAsFixed(3)}, …, ${vec[vec.length-3].toStringAsFixed(3)}, ${vec[vec.length-2].toStringAsFixed(3)}, ${vec[vec.length-1].toStringAsFixed(3)}]'
                                  : vec.toString();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Embedding ok (dim=${vec.length}): $preview')),
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Embedding failed: $e')),
                              );
                            }
                          },
                          child: const Text('Run Embedding Test (Multilingual BERT)'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Latest Profile Summary (from coordinator)
            if (_lastProfileSummary != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latest Profile Summary', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(_lastProfileSummary.toString()),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            // Realtime Messages
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Realtime Messages (${_messages.length})', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    if (_messages.isEmpty)
                      const Text('No realtime messages yet')
                    else
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final item = _messages[index];
                            return ListTile(
                              dense: true,
                              title: Text('[${item['channel']}] ${item['event']}'),
                              subtitle: Text(item['payload'].toString()),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Spots Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spots (${_spots.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _loadSpots,
                          child: const Text('Load Spots'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                      if (_spots.isEmpty)
                      const Text('No spots found. Create one to test!')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _spots.length,
                        itemBuilder: (context, index) {
                          final spot = _spots[index];
                          return ListTile(
                            title: Text(spot.name),
                            subtitle: Text(spot.description),
                            trailing: Text(
                              spot.createdAt.toString().substring(0, 19),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lists Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lists (${_lists.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _loadLists,
                          child: const Text('Load Lists'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                      if (_lists.isEmpty)
                      const Text('No lists found. Create one to test!')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _lists.length,
                        itemBuilder: (context, index) {
                          final list = _lists[index];
                          return ListTile(
                            title: Text(list.title),
                            subtitle: Text(list.description),
                            trailing: Text(
                              list.createdAt.toString().substring(0, 19),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
