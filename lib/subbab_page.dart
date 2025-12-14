import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'note_page.dart';
import 'theme/app_colors.dart';

class SubBabPage extends StatefulWidget {
  final String subjectId;
  final String babId;
  final String babName;

  const SubBabPage({
    super.key,
    required this.subjectId,
    required this.babId,
    required this.babName,
  });

  @override
  State<SubBabPage> createState() => _SubBabPageState();
}

class _SubBabPageState extends State<SubBabPage> {
  List<String> subBabList = [];
  List<String> subBabIdList = [];

  final FirebaseFirestore db = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot> subBabListener;

  @override
  void initState() {
    super.initState();
    _loadSubBab();
  }

  @override
  void dispose() {
    subBabListener.cancel();
    super.dispose();
  }

  void _loadSubBab() {
    subBabListener = db
        .collection("subjects")
        .doc(widget.subjectId)
        .collection("bab")
        .doc(widget.babId)
        .collection("subbab")
        .orderBy("created_at")
        .snapshots()
        .listen(
      (snap) {
        if (!mounted) return;
        setState(() {
          subBabList = snap.docs
              .map((e) => (e.data() as Map)["name"] as String)
              .toList();
          subBabIdList = snap.docs.map((e) => e.id).toList();
        });
      },
      onError: (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat SubBab: $e")),
        );
      },
    );
  }

  Future<void> _tambahSubBab(String nama) async {
    setState(() {
      subBabList.add(nama);
      subBabIdList.add("TEMP");
    });

    await db
        .collection("subjects")
        .doc(widget.subjectId)
        .collection("bab")
        .doc(widget.babId)
        .collection("subbab")
        .add({
      "name": nama,
      "created_at": Timestamp.now(),
    });
  }

  Future<void> _hapusSubBab(int index) async {
    final id = subBabIdList[index];

    setState(() {
      subBabList.removeAt(index);
      subBabIdList.removeAt(index);
    });

    if (id != "TEMP") {
      await db
          .collection("subjects")
          .doc(widget.subjectId)
          .collection("bab")
          .doc(widget.babId)
          .collection("subbab")
          .doc(id)
          .delete();
    }
  }

  void _showAddSubBabSheet() {
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
                "Tambah SubBab",
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
                  labelText: "Nama SubBab",
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
                  await _tambahSubBab(t);
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
                        await _tambahSubBab(t);
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
          "Hapus SubBab",
          style: TextStyle(
            color: AppColors.orangeMain,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text("Yakin ingin menghapus '${subBabList[index]}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.orangeMain),
            child: const Text("Batal"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _hapusSubBab(index);
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
          "SubBab - ${widget.babName}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.orangeMain, // ✅ judul oren
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubBabSheet,
        backgroundColor: AppColors.orangeMain, // ✅ FAB oren
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: subBabList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada SubBab.\nTekan + untuk menambahkan.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              itemCount: subBabList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final title = subBabList[index];

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
                          builder: (_) => NotePage(
                            subjectId: widget.subjectId,
                            babId: widget.babId,
                            subBabId: subBabIdList[index],
                            subBabName: subBabList[index],
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
