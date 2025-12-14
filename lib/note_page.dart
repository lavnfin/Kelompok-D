import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_colors.dart';

class NotePage extends StatefulWidget {
  final String subjectId;
  final String babId;
  final String subBabId;
  final String subBabName;

  // optional: kalau dibuka dari halaman bookmark
  final int? initialSelStart;
  final int? initialSelEnd;

  const NotePage({
    super.key,
    required this.subjectId,
    required this.babId,
    required this.subBabId,
    required this.subBabName,
    this.initialSelStart,
    this.initialSelEnd,
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController _c = TextEditingController();
  final ScrollController _scroll = ScrollController();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;
  Timer? _debounce;

  String updatedAt = "";

  // selection state
  int _selStart = -1;
  int _selEnd = -1;

  // ✅ supaya selection dari bookmark cuma dipasang sekali
  bool _didApplyInitialSelection = false;

  DocumentReference<Map<String, dynamic>> get _noteDoc => db
      .collection("subjects")
      .doc(widget.subjectId)
      .collection("bab")
      .doc(widget.babId)
      .collection("subbab")
      .doc(widget.subBabId)
      .collection("notes")
      .doc("main");

  @override
  void initState() {
    super.initState();
    _listenNote();

    _c.addListener(() {
      final sel = _c.selection;
      if (!mounted) return;
      setState(() {
        _selStart = sel.start;
        _selEnd = sel.end;
      });
    });
  }

  void _listenNote() {
    _sub = _noteDoc.snapshots().listen((doc) {
      final data = doc.data();
      if (!mounted) return;

      final newText = (data?["content"] ?? "").toString();
      final newUpdated = (data?["updated_at"] ?? "").toString();

      // jangan ganggu user kalau text sama
      if (_c.text != newText) {
        final oldSel = _c.selection;
        _c.text = newText;

        // restore selection kalau memungkinkan
        final safeOffset = _c.text.length;
        final start = oldSel.start.clamp(0, safeOffset);
        final end = oldSel.end.clamp(0, safeOffset);
        _c.selection = TextSelection(baseOffset: start, extentOffset: end);
      }

      updatedAt = newUpdated;

      // ✅ apply initial selection sekali saja
      if (!_didApplyInitialSelection &&
          widget.initialSelStart != null &&
          widget.initialSelEnd != null) {
        _didApplyInitialSelection = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final max = _c.text.length;
          final s = widget.initialSelStart!.clamp(0, max);
          final e = widget.initialSelEnd!.clamp(0, max);
          _c.selection = TextSelection(baseOffset: s, extentOffset: e);
        });
      }

      setState(() {});
    }, onError: (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat catatan: $e")),
      );
    });
  }

  void _autoSave(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () async {
      try {
        final now = DateTime.now().toString();
        updatedAt = now;

        await _noteDoc.set({
          "content": text,
          "updated_at": now,
          "created_at": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) setState(() {});
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menyimpan: $e")),
        );
      }
    });
  }

  String _selectedText() {
    if (_selStart < 0 || _selEnd < 0) return "";
    if (_selStart == _selEnd) return "";
    final start = _selStart < _selEnd ? _selStart : _selEnd;
    final end = _selStart < _selEnd ? _selEnd : _selStart;
    if (start < 0 || end > _c.text.length) return "";
    return _c.text.substring(start, end).trim();
  }

  Future<void> _bookmarkSelection() async {
    final selected = _selectedText();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Blok teks dulu yang mau dibookmark.")),
      );
      return;
    }

    final start = _selStart < _selEnd ? _selStart : _selEnd;
    final end = _selStart < _selEnd ? _selEnd : _selStart;

    try {
      await db.collection("bookmarks").add({
        "subjectId": widget.subjectId,
        "babId": widget.babId,
        "subBabId": widget.subBabId,
        "subBabName": widget.subBabName,
        "selStart": start,
        "selEnd": end,
        "text": selected,
        "created_at": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Teks berhasil dibookmark ⭐")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal bookmark: $e")),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _sub?.cancel();
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedText().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white, // ✅ catatan putih
      appBar: AppBar(
        backgroundColor: AppColors.yellowSolid, // ✅ kuning solid
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.orangeMain), // ✅ back oren
        title: Text(
          "Catatan - ${widget.subBabName}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.orangeMain, // ✅ judul oren
          ),
        ),
        actions: [
          IconButton(
            tooltip: "Bookmark teks yang diblok",
            onPressed: _bookmarkSelection,
            icon: Icon(
              hasSelection ? Icons.bookmark : Icons.bookmark_border,
              color: AppColors.orangeMain, // ✅ bookmark oren
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // bar info kecil
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      updatedAt.isEmpty
                          ? "Mulai mengetik..."
                          : "Terakhir diubah: $updatedAt",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasSelection)
                    const Text(
                      "Teks diblok ✓",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.orangeMain,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                child: TextField(
                  controller: _c,
                  scrollController: _scroll,
                  onChanged: _autoSave,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: "Mulai mengetik",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
