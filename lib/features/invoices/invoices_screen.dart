import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ApiClient>().list('/invoices');
  }

  void _refresh() {
    setState(() {
      _future = context.read<ApiClient>().list('/invoices');
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final invoices = snapshot.data ?? [];
        if (invoices.isEmpty) return const Center(child: Text('No invoices found.'));

        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                child: ListTile(
                  title: Text('${invoice['invoice_number'] ?? '-'}'),
                  subtitle: Text('Status: ${invoice['payment_status'] ?? invoice['status'] ?? '-'}'),
                  trailing: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text('JMD ${invoice['total_jmd'] ?? invoice['total'] ?? ''}'),
                      IconButton(
                        tooltip: 'Upload receipt',
                        icon: const Icon(Icons.upload_file),
                        onPressed: () => _uploadReceipt(context, invoice),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _uploadReceipt(BuildContext context, Map<String, dynamic> invoice) async {
    final invoiceId = invoice['id'];
    if (invoiceId == null) return;

    final amountController = TextEditingController(text: '${invoice['total_jmd'] ?? ''}');
    final referenceController = TextEditingController(text: '${invoice['invoice_number'] ?? ''}');
    PlatformFile? selectedFile;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Upload payment receipt'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount paid'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: referenceController,
                      decoration: const InputDecoration(labelText: 'Reference number'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() => selectedFile = result.files.first);
                        }
                      },
                      icon: const Icon(Icons.attach_file),
                      label: Text(selectedFile?.name ?? 'Choose receipt file'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: selectedFile?.path == null ? null : () => Navigator.of(context).pop(true),
                  child: const Text('Upload'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true || selectedFile?.path == null || !context.mounted) return;

    try {
      await context.read<ApiClient>().uploadFile(
        '/invoices/$invoiceId/receipt',
        fieldName: 'receipt',
        filePath: selectedFile!.path!,
        data: {
          'amount': amountController.text,
          'reference_number': referenceController.text,
        },
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt uploaded for review.')));
      _refresh();
    } catch (exception) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $exception')));
    }
  }
}