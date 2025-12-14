import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bab_page.dart';
import 'add_mapel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9CEAF),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // TITLE
              const Text(
                "NOTELEARN",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE57C23),
                ),
              ),

              const SizedBox(height: 5),

              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5B344),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 25),

              // SEARCH BAR
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black26),
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => searchQuery = value.toLowerCase());
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, size: 28),
                    hintText: "Cari catatan...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "\"PENDIDIKAN ADALAH PASPOR KE MASA DEPAN, "
                "KARENA BESOK MILIK MEREKA "
                "YANG MEMPERSIAPKANNYA HARI INI\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 25),

              // LIST SUBJECTS
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("subjects")
                      .orderBy("name")
                      .snapshots(),

                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    final filtered = docs.where((data) {
                      final name = data['name'].toString().toLowerCase();
                      return name.contains(searchQuery);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text(
                          "Tidak ada mata pelajaran",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final data = filtered[i];
                        final subjectId = data.id;
                        final subjectName = data["name"];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: InkWell(
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

                            // TEKAN LAMA = HAPUS
                            onLongPress: () {
                              _showDeleteDialog(subjectId, subjectName);
                            },

                            child: Container(
                              height: 55,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5CC6BA),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(2, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                subjectName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
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
            heroTag: "bookmark",
            backgroundColor: const Color(0xFFF7D358),
            child: const Icon(Icons.bookmark, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 15),
          FloatingActionButton(
            heroTag: "add",
            backgroundColor: const Color(0xFFF7D358),
            child: const Icon(Icons.add, color: Colors.black),
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

  // 🔥 DIALOG HAPUS MAPEL
  void _showDeleteDialog(String id, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Mata Pelajaran"),
          content: Text("Yakin ingin menghapus '$name'?"),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection("subjects")
                    .doc(id)
                    .delete();

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}