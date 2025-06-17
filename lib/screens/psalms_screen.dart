import 'package:flutter/material.dart';
import '../models/hymn.dart';
import 'hymn_detail_screen.dart';

class PsalmsScreen extends StatelessWidget {
  const PsalmsScreen({super.key});

  static const List<Hymn> psalms = [
    Hymn(
      id: 1,
      title: 'Psalm 23',
      lyrics: 'The Lord is my shepherd, I shall not want...',
      tune: 'Crimond',
      audioUrl: 'assets/audio/psalm_23.mp3',
      sheetUrl: 'assets/sheets/psalm_23.pdf',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Psalms')),
      body: ListView.builder(
        itemCount: psalms.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Text('${psalms[index].id}'),
            title: Text(psalms[index].title),
            subtitle: Text('Tune: ${psalms[index].tune}'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HymnDetailScreen(hymn: psalms[index])),
            ),
          );
        },
      ),
    );
  }
}