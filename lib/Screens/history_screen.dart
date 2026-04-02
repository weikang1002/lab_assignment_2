import 'package:flutter/material.dart';
import '../../services/participation_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Participation History"), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ParticipationService.getHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No records found."));
          }
          final logs = snapshot.data!.reversed.toList();
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final item = logs[index];
              return ListTile(
                leading: const Icon(Icons.stars, color: Colors.orange),
                title: Text(item['name'] ?? "Fair"),
                subtitle: Text("${item['address'] ?? 'No Address'}\n${item['time']}"),
                isThreeLine: true,
                trailing: Text("+${item['points']} pts", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}