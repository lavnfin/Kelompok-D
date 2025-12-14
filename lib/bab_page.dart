import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subbab_page.dart';
import 'theme/app_colors.dart';

class BabPage extends StatefulWidget {
  final String subjectId;
  final String subjectName;

  const BabPage({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<BabPage> createState() => _BabPageState();
}

class _BabPageState extends State<BabPage> {
  List<String> babList = [];
  List<String> babIdList = [];

  late StreamSubscription<QuerySnapshot> babListener;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadBab();
  }

  @override
  void dispose() {
    babListener.cancel();
    super.dispose();
  }

  void _loadBab() {
    babListener = db
        .collection("subjects")
        .doc(widget.subjectId)
        .collection("bab")
        .orderBy("created_at")
        .snapshots()
        .listen(
      (snap) {
        if (!mounted) return;
        setState(() {
          babList = snap.docs
              .map((e) => (e.data() as Map)["name"] as String)
              .toList();
          babIdList = snap.docs.map((e) => e.id).toList();
        });
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat Bab: $e")),
        );
      },
    );
  }

  Future<void> _tambahBab(String nama) async {
    setState(() {
      babList.add(nama);
      babIdList.add("TEMP");
    });

    await db.collection("subjects").doc(widget.subjectId).collection("bab").add({
      "name": nama,
      "created_at": Timestamp.now(),
    });
  }

  Future<void> _hapusBab(int index) async {
    final id = babIdList[index];

    setState(() {
      babList.removeAt(index);
      babIdList.removeAt(index);
    });

    if (id != "TEMP") {
      await db
          .collection("subjects")
          .doc(widget.subjectId)
          .collection("bab")
          .doc(id)
          .delete();
    }
  }

  void _showAddBabSheet() {
    final c = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Tambah Bab",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orangeMain,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: c,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: "Nama Bab",
                  labelStyle: const TextStyle(color: AppColors.orangeMain),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: AppColors.orangeMain,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onSubmitted: (_) async {
                  final t = c.text.trim();
                  if (t.isEmpty) return;
                  await _tambahBab(t);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.orangeMain,
                        side: const BorderSide(color: AppColors.orangeMain),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.orangeMain,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        final t = c.text.trim();
                        if (t.isEmpty) return;
                        await _tambahBab(t);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text("Tambah"),
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

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Hapus Bab",
          style: TextStyle(color: AppColors.orangeMain, fontWeight: FontWeight.w800),
        ),
        content: Text("Yakin ingin menghapus '${babList[index]}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.orangeMain),
            child: const Text("Batal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _hapusBab(index);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream, // ✅ cream
      appBar: AppBar(
        backgroundColor: AppColors.yellowSolid, // ✅ kuning solid
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.orangeMain), // ✅ back oren
        title: Text(
          "Bab - ${widget.subjectName}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.orangeMain, // ✅ teks oren
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBabSheet,
        backgroundColor: AppColors.orangeMain, // ✅ FAB oren
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: babList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada Bab.\nTekan + untuk menambahkan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: babList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final title = babList[index];
                return Card(
                  elevation: 0,
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SubBabPage(
                            subjectId: widget.subjectId,
                            babId: babIdList[index],
                            babName: babList[index],
                          ),
                        ),
                      );
                    },
                    onLongPress: () => _showDeleteDialog(index),
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: AppColors.yellowSolid, // ✅ kuning solid
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.orangeMain, width: 1.4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 38),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.orangeMain, // ✅ teks oren
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Positioned(
                            right: 0,
                            child: Icon(
                              Icons.chevron_right,
                              color: AppColors.orangeMain, // ✅ panah oren
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
