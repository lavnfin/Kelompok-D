import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bab_page.dart';
import 'add_mapel.dart';
import 'bookmark_mapel_page.dart';
import 'theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";

  Future<void> _deleteSubject(String id, String name) async {
    await FirebaseFirestore.instance.collection("subjects").doc(id).delete();

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Mapel '$name' dihapus"),
        duration: const Duration(milliseconds: 1100),
      ),
    );
  }

  void _showDeleteSheet(String id, String name) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 18,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              const Icon(Icons.delete_outline, size: 34, color: Colors.redAccent),
              const SizedBox(height: 10),
              const Text(
                "Hapus Mata Pelajaran?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                "Yakin ingin menghapus:\n$name",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withOpacity(0.65)),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _deleteSubject(id, name);
                      },
                      style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: const Text("Hapus", style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final horizontal = w < 420 ? 16.0 : 30.0;

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Column(
            // ✅ bikin child “ngembang” selebar parent
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // ✅ tetap ditengah
              const Center(
                child: Text(
                  "NOTELEARN",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeMain,
                  ),
                ),
              ),

              const SizedBox(height: 3),

              Center(
                child: Container(
                  width: 100,
                  height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.orangeMain,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ✅ SEARCH BAR FULL (ngikut lebar parent)
              SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.orangeMain.withOpacity(0.5),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                    decoration: const InputDecoration(
                      icon: Icon(Icons.search, size: 24, color: AppColors.orangeMain),
                      hintText: "Cari catatan...",
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("subjects").orderBy("name").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;
                    final filtered = docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final name = (data["name"] ?? "").toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                    final itemCount = 1 + (filtered.isEmpty ? 1 : filtered.length);

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 6, bottom: 110),
                      separatorBuilder: (_, __) => const SizedBox(height: 15),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.black.withOpacity(0.06)),
                            ),
                            child: const Text(
                              "\"PENDIDIKAN ADALAH PASPOR KE MASA DEPAN, "
                              "KARENA BESOK MILIK MEREKA YANG MEMPERSIAPKANNYA HARI INI\"",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.orangeMain,
                              ),
                            ),
                          );
                        }

                        if (filtered.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Center(
                              child: Text("Tidak ada mata pelajaran", style: TextStyle(fontSize: 16)),
                            ),
                          );
                        }

                        final doc = filtered[index - 1];
                        final data = doc.data() as Map<String, dynamic>;
                        final subjectId = doc.id;
                        final subjectName = (data["name"] ?? "Tanpa Nama").toString();

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(40),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BabPage(
                                    subjectId: subjectId,
                                    subjectName: subjectName,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () => _showDeleteSheet(subjectId, subjectName),
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.yellowSolid,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: AppColors.orangeMain, width: 1.4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.14),
                                    blurRadius: 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 18),
                                  child: Text(
                                    subjectName,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.orangeMain,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "bookmark_notes",
            backgroundColor: AppColors.orangeMain,
            foregroundColor: Colors.white,
            child: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarkMapelPage()),
              );
            },
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: AppColors.orangeMain,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMapelPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
