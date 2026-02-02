import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DocumentManagerScreen extends StatefulWidget {
  const DocumentManagerScreen({super.key});

  @override
  State<DocumentManagerScreen> createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  
  final List<Map<String, dynamic>> _allDocuments = [
    {
      'id': 'DOC001',
      'name': 'Identity Document',
      'requestId': 'REQ001',
      'requestService': 'ISEE',
      'status': 'approved',
      'uploadDate': '2026-01-08',
      'fileSize': '2.1 MB',
      'fileType': 'PDF',
    },
    {
      'id': 'DOC002',
      'name': 'Tax Code',
      'requestId': 'REQ001',
      'requestService': 'ISEE',
      'status': 'approved',
      'uploadDate': '2026-01-08',
      'fileSize': '1.5 MB',
      'fileType': 'PDF',
    },
    {
      'id': 'DOC003',
      'name': 'Income Statement',
      'requestId': 'REQ001',
      'requestService': 'ISEE',
      'status': 'pending',
      'uploadDate': '2026-01-09',
      'fileSize': '3.2 MB',
      'fileType': 'PDF',
    },
    {
      'id': 'DOC004',
      'name': 'CU Form',
      'requestId': 'REQ002',
      'requestService': 'Modello 730',
      'status': 'rejected',
      'uploadDate': '2026-01-05',
      'fileSize': '1.8 MB',
      'fileType': 'PDF',
    },
  ];

  List<Map<String, dynamic>> get filteredDocuments {
    if (_selectedFilter == 'All') return _allDocuments;
    return _allDocuments.where((doc) => 
      doc['status'].toLowerCase() == _selectedFilter.toLowerCase()
    ).toList();
  }

  Map<String, List<Map<String, dynamic>>> get groupedDocuments {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final doc in filteredDocuments) {
      final key = '${doc['requestService']} (${doc['requestId']})';
      grouped.putIfAbsent(key, () => []).add(doc);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B5E20),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Document Manager',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showUploadDialog(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: filteredDocuments.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: groupedDocuments.entries.map((entry) =>
                        _buildRequestGroup(entry.key, entry.value)
                      ).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = filter == _selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedFilter = filter);
                },
                selectedColor: const Color(0xFF1B5E20),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestGroup(String title, List<Map<String, dynamic>> documents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20),
            ),
          ),
        ),
        ...documents.map((doc) => _buildDocumentCard(doc)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatusIcon(document['status']),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document['fileType']} • ${document['fileSize']} • ${document['uploadDate']}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(document['status']),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleDocumentAction(value, document),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                const PopupMenuItem(value: 'download', child: Text('Download')),
                if (document['status'] == 'rejected')
                  const PopupMenuItem(value: 'replace', child: Text('Replace')),
              ],
              child: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'approved':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'pending':
      default:
        icon = Icons.schedule;
        color = Colors.orange;
    }
    return Icon(icon, color: color, size: 32);
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      case 'pending':
      default:
        color = Colors.orange;
        label = 'Pending Review';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Documents Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload documents for your service requests',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _handleDocumentAction(String action, Map<String, dynamic> document) {
    switch (action) {
      case 'view':
        _viewDocument(document);
        break;
      case 'download':
        _downloadDocument(document);
        break;
      case 'replace':
        _replaceDocument(document);
        break;
    }
  }

  void _viewDocument(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.picture_as_pdf, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Document preview would open here'),
            const SizedBox(height: 8),
            Text(
              '${document['fileType']} • ${document['fileSize']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _downloadDocument(Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading ${document['name']}...'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
    );
  }

  void _replaceDocument(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Replace Document'),
        content: Text('Replace ${document['name']}? The current document will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document replaced successfully')),
              );
            },
            child: const Text('Replace', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upload Document'),
        content: const Text('Select a document to upload for your service requests.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Document uploaded successfully')),
              );
            },
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}