import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamilyMembersScreen extends ConsumerStatefulWidget {
  const FamilyMembersScreen({super.key});

  @override
  ConsumerState<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends ConsumerState<FamilyMembersScreen> {
  final List<FamilyMember> _familyMembers = [
    FamilyMember(
      id: '1',
      name: 'Maria Rossi',
      relationship: 'Spouse',
      fiscalCode: 'RSSMRA80A01H501Z',
      dateOfBirth: DateTime(1980, 1, 1),
    ),
    FamilyMember(
      id: '2',
      name: 'Luca Rossi',
      relationship: 'Son',
      fiscalCode: 'RSSLCU10A01H501Z',
      dateOfBirth: DateTime(2010, 1, 1),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Members'),
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddFamilyMemberDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _familyMembers.length,
        itemBuilder: (context, index) {
          final member = _familyMembers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(member.name.substring(0, 1)),
              ),
              title: Text(member.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Relationship: ${member.relationship}'),
                  Text('Fiscal Code: ${member.fiscalCode}'),
                  Text('Born: ${_formatDate(member.dateOfBirth)}'),
                ],
              ),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) => _handleMemberAction(value, member),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddFamilyMemberDialog() {
    final nameController = TextEditingController();
    final relationshipController = TextEditingController();
    final fiscalCodeController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Family Member'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Relationship'),
                items: const [
                  DropdownMenuItem(value: 'Spouse', child: Text('Spouse')),
                  DropdownMenuItem(value: 'Son', child: Text('Son')),
                  DropdownMenuItem(value: 'Daughter', child: Text('Daughter')),
                  DropdownMenuItem(value: 'Father', child: Text('Father')),
                  DropdownMenuItem(value: 'Mother', child: Text('Mother')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => relationshipController.text = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: fiscalCodeController,
                decoration: const InputDecoration(labelText: 'Fiscal Code'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    selectedDate = date;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _addFamilyMember(
              nameController.text,
              relationshipController.text,
              fiscalCodeController.text,
              selectedDate,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addFamilyMember(String name, String relationship, String fiscalCode, DateTime? dateOfBirth) {
    if (name.isNotEmpty && relationship.isNotEmpty && fiscalCode.isNotEmpty && dateOfBirth != null) {
      setState(() {
        _familyMembers.add(FamilyMember(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          relationship: relationship,
          fiscalCode: fiscalCode,
          dateOfBirth: dateOfBirth,
        ));
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Family member added successfully')),
      );
    }
  }

  void _handleMemberAction(String action, FamilyMember member) {
    switch (action) {
      case 'edit':
        _showEditFamilyMemberDialog(member);
        break;
      case 'delete':
        _showDeleteConfirmation(member);
        break;
    }
  }

  void _showEditFamilyMemberDialog(FamilyMember member) {
    // Similar to add dialog but pre-filled with member data
    _showAddFamilyMemberDialog();
  }

  void _showDeleteConfirmation(FamilyMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Family Member'),
        content: Text('Are you sure you want to remove ${member.name} from your family members?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _familyMembers.removeWhere((m) => m.id == member.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Family member removed')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String relationship;
  final String fiscalCode;
  final DateTime dateOfBirth;

  FamilyMember({
    required this.id,
    required this.name,
    required this.relationship,
    required this.fiscalCode,
    required this.dateOfBirth,
  });
}