import 'package:flutter/material.dart';
import 'package:billmate/features/reports/domain/repositories/reports_repository.dart';

class ExportButton extends StatelessWidget {
  final Function(ExportFormat) onExport;

  const ExportButton({super.key, required this.onExport});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ExportFormat>(
      icon: const Icon(Icons.file_download),
      onSelected: onExport,
      itemBuilder:
          (context) => [
            const PopupMenuItem(
              value: ExportFormat.pdf,
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Export as PDF'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: ExportFormat.csv,
              child: ListTile(
                leading: Icon(Icons.table_chart),
                title: Text('Export as CSV'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: ExportFormat.excel,
              child: ListTile(
                leading: Icon(Icons.grid_on),
                title: Text('Export as Excel'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: ExportFormat.json,
              child: ListTile(
                leading: Icon(Icons.code),
                title: Text('Export as JSON'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
    );
  }
}
