import 'package:flutter/material.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/data/models/announcement_model.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/domain/usecases/get_all_broadcasts.dart';
import 'package:flutter_developer_technical_test/src/infrastructure/presentation/widgets/announcement_card.dart';
import 'package:get_it/get_it.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _getAllBroadcasts = GetIt.I<GetAllBroadcasts>();
  List<AnnouncementModel> _broadcasts = [];

  @override
  void initState() {
    super.initState();
    _loadBroadcasts();
  }

  Future<void> _loadBroadcasts() async {
    final broadcasts = await _getAllBroadcasts();
    setState(() {
      _broadcasts = broadcasts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast History')),
      body: RefreshIndicator(
        onRefresh: _loadBroadcasts,
        child: _broadcasts.isEmpty
            ? const Center(child: Text('No broadcast history available'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _broadcasts.length,
                itemBuilder: (context, index) {
                  return AnnouncementCard(announcement: _broadcasts[index]);
                },
              ),
      ),
    );
  }
}
