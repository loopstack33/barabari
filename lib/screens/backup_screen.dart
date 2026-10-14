import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/budget_controller.dart';
import '../theme/app_theme.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final controller = Get.find<BudgetController>();
  bool _busy = false;

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Writes the backup to a file and opens the share sheet so the user can
  /// save it to Drive / WhatsApp / email / Files — somewhere outside the app.
  Future<void> _exportFile() async {
    setState(() => _busy = true);
    try {
      final dir = await getTemporaryDirectory();
      final stamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final file = File('${dir.path}/barabri_backup_$stamp.json');
      await file.writeAsString(controller.exportBackupJson(), flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Barabri backup $stamp',
      );
    } catch (e) {
      _snack('Export failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: controller.exportBackupJson()));
    _snack('Backup copied. Paste it into a note or message to keep it safe.');
  }

  Future<bool> _confirmReplace() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Replace all data?'),
        content: const Text(
          'Restoring replaces everything currently in the app (history, goals, spending, payments, settings) with the backup. This can\'t be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.use),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _restoreFromRaw(String raw) async {
    if (!await _confirmReplace()) return;
    final err = await controller.importBackupJson(raw);
    _snack(err ?? 'Backup restored successfully.');
  }

  /*Future<void> _importFile() async {
    setState(() => _busy = true);
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (res == null || res.isEmpty) return;
      final f = res.first;
      final bytes = f.bytes ?? (f.path != null ? await File(f.path!).readAsBytes() : null);
      if (bytes == null) {
        _snack('Could not read the selected file.');
        return;
      }
      await _restoreFromRaw(utf8.decode(bytes, allowMalformed: true));
    } catch (e) {
      _snack('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }*/

  Future<void> _importFile() async {
    setState(() => _busy = true);
    try {
      final f = await FilePicker.pickFile();
      if (f == null) return;
      final bytes = await f.readAsBytes();
      await _restoreFromRaw(utf8.decode(bytes, allowMalformed: true));
    } catch (e) {
      _snack('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFromPaste() async {
    final ctrl = TextEditingController();
    final raw = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Paste backup'),
        content: TextField(
          controller: ctrl,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Paste the backup text here',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final d = await Clipboard.getData('text/plain');
              ctrl.text = d?.text ?? '';
            },
            child: const Text('Paste'),
          ),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Continue')),
        ],
      ),
    );
    if (raw == null || raw.trim().isEmpty) return;
    await _restoreFromRaw(raw);
  }

  Widget _tile(IconData icon, Color color, String title, String sub, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        enabled: !_busy,
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
        subtitle: Text(sub, style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
        trailing: Icon(Icons.chevron_right, color: AppColors.muted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.lifestyle.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Your data lives only on this phone. Uninstalling the app or clearing its storage erases it. '
              'Save a backup file somewhere outside the app (Google Drive, email, WhatsApp to yourself) and restore it any time.',
              style: TextStyle(fontSize: 13, color: AppColors.ink),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          _tile(Icons.upload_file, AppColors.invest, 'Export backup file',
              'Save or share a .json backup', _exportFile),
          _tile(Icons.copy_all, AppColors.lifestyle, 'Copy backup as text',
              'Paste it into a note or chat', _copyToClipboard),
          _tile(Icons.download, AppColors.use, 'Restore from file',
              'Pick a Barabri .json backup', _importFile),
          _tile(Icons.content_paste, AppColors.emergency, 'Restore from pasted text',
              'Paste copied backup text', _importFromPaste),
        ],
      ),
    );
  }
}
