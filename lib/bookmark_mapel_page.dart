import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_page.dart';

class BookmarkMapelPage extends StatelessWidget {
  const BookmarkMapelPage({super.key});

  static const Color orangeMain = Color(0xFFE57C23);
  static const Color yellowSolid = Color(0xFFF7D358);
  static const Color bgCream = Color(0xFFE9CEAF);

  @override
  Widget build(BuildContext context) {
    final db = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text("Bookmark Catatan"),
        backgroundColor: yellowSolid,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: db
            .collection("bookmarks")
            .orderBy("created_at", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error:\n${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Belum ada teks yang dibookmark."),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();

              final subjectId = (data["subjectId"] ?? "").toString();
              final babId = (data["babId"] ?? "").toString();
              final subBabId = (data["subBabId"] ?? "").toString();
              final subBabName = (data["subBabName"] ?? "Catatan").toString();

              final selStart = (data["selStart"] ?? 0) as int;
              final selEnd = (data["selEnd"] ?? 0) as int;
              final text = (data["text"] ?? "").toString();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: orangeMain, width: 1.1),
                ),
                child: ListTile(
                  leading: const Icon(Icons.bookmark, color: orangeMain),
                  title: Text(
                    subBabName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: orangeMain,
                    ),
                  ),
                  subtitle: Text(
                    text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    tooltip: "Hapus bookmark",
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async => doc.reference.delete(),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotePage(
                          subjectId: subjectId,
                          babId: babId,
                          subBabId: subBabId,
                          subBabName: subBabName,
                          initialSelStart: selStart,
                          initialSelEnd: selEnd,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
