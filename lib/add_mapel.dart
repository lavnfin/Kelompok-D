import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_colors.dart';

class AddMapelPage extends StatefulWidget {
  const AddMapelPage({super.key});

  @override
  State<AddMapelPage> createState() => _AddMapelPageState();
}

class _AddMapelPageState extends State<AddMapelPage> {
  final TextEditingController controller = TextEditingController();
  bool isSaving = false;

  Future<void> _save() async {
    final name = controller.text.trim();
    if (name.isEmpty) return;

    setState(() => isSaving = true);

    await FirebaseFirestore.instance.collection('subjects').add({
      'name': name,
      'created_at': FieldValue.serverTimestamp(),
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream, // ✅ cream
      appBar: AppBar(
        backgroundColor: AppColors.yellowSolid, // ✅ kuning solid
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Tambah Mata Pelajaran",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.orangeMain, // ✅ teks oren
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.orangeMain, // ✅ back arrow oren
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.yellowSolid, // ✅ kuning solid
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.orangeMain,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: "Nama Mata Pelajaran",
                      labelStyle: TextStyle(color: AppColors.orangeMain),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.orangeMain,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    onSubmitted: (_) => isSaving ? null : _save(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _save,
                      icon: isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangeMain, // ✅ tombol oren
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
