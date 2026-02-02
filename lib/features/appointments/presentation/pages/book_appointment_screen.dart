import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final String? serviceTypeId;
  
  const BookAppointmentScreen({super.key, this.serviceTypeId});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime selectedDate = DateTime(2023, 10, 5);
  String selectedType = 'In-person';
  String selectedTime = '10:30 AM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSection(),
                  _buildCalendar(),
                  _buildConsultationType(),
                  _buildAvailableTimes(),
                  _buildInfoCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back_ios, color: Color(0xFF111418)),
          ),
          const Expanded(
            child: Text(
              'Book Appointment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        'Select Date',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left, color: Color(0xFF111418)),
              ),
              const Text(
                'October 2023',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, color: Color(0xFF111418)),
              ),
            ],
          ),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final days = [
      [null, null, null, 1, 2, 3, null],
      [4, 5, 6, 7, 8, 9, 10],
      [11, 12, 13, 14, 15, null, null],
    ];

    return Column(
      children: [
        Row(
          children: weekDays.map((day) => Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              child: Text(
                day,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF637288)),
              ),
            ),
          )).toList(),
        ),
        ...days.map((week) => Row(
          children: week.map((day) => Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.all(2),
              child: day == null ? const SizedBox() : GestureDetector(
                onTap: day >= 4 ? () => setState(() => selectedDate = DateTime(2023, 10, day)) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: day == 5 ? const Color(0xFF186ADC) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    day.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: day < 4 ? const Color(0xFF9CA3AF) : 
                             day == 5 ? Colors.white : const Color(0xFF111418),
                    ),
                  ),
                ),
              ),
            ),
          )).toList(),
        )),
      ],
    );
  }

  Widget _buildConsultationType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Consultation Type',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedType = 'In-person'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedType == 'In-person' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: selectedType == 'In-person' ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 18,
                          color: selectedType == 'In-person' ? const Color(0xFF111418) : const Color(0xFF637288),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'In-person',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selectedType == 'In-person' ? const Color(0xFF111418) : const Color(0xFF637288),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedType = 'Video Call'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedType == 'Video Call' ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: selectedType == 'Video Call' ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: 18,
                          color: selectedType == 'Video Call' ? const Color(0xFF111418) : const Color(0xFF637288),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Video Call',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: selectedType == 'Video Call' ? const Color(0xFF111418) : const Color(0xFF637288),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableTimes() {
    final times = [
      {'time': '09:00', 'period': 'AM', 'available': true},
      {'time': '10:30', 'period': 'AM', 'available': true},
      {'time': '11:00', 'period': 'AM', 'available': true},
      {'time': '02:30', 'period': 'PM', 'available': true},
      {'time': '04:00', 'period': 'PM', 'available': true},
      {'time': '05:15', 'period': 'PM', 'available': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Available Times',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: times.length,
            itemBuilder: (context, index) {
              final time = times[index];
              final timeString = '${time['time']} ${time['period']}';
              final isSelected = selectedTime == timeString;
              final isAvailable = time['available'] as bool;
              
              return GestureDetector(
                onTap: isAvailable ? () => setState(() => selectedTime = timeString) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: !isAvailable ? const Color(0xFFF3F4F6) : 
                           isSelected ? const Color(0xFF186ADC) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !isAvailable ? const Color(0xFFE5E7EB) :
                             isSelected ? const Color(0xFF186ADC) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF186ADC).withValues(alpha: 0.2), blurRadius: 8)] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        time['time'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: !isAvailable ? const Color(0xFF637288) :
                                 isSelected ? Colors.white : const Color(0xFF111418),
                        ),
                      ),
                      Text(
                        time['period'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: !isAvailable ? const Color(0xFF637288) :
                                 isSelected ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF637288),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF186ADC).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: Color(0xFF186ADC), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiscal Documentation',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF186ADC)),
                ),
                SizedBox(height: 4),
                Text(
                  'Please bring your tax identification number and previous year\'s tax returns for this session.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF111418), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment confirmed!')),
            );
            context.pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF186ADC),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confirm Appointment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 8),
              Icon(Icons.calendar_today, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}