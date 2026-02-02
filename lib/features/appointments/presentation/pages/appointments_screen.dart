import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen> {
  String selectedFilter = 'Upcoming';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Column(
        children: [
          _buildAppBar(),
          _buildFilterToggle(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAppointmentCard(
                    title: 'ISEE Consultation',
                    date: 'Oct 24, 2023 - 10:00 AM',
                    consultant: 'Marco Rossi',
                    type: 'Video Call',
                    icon: Icons.videocam,
                    buttonText: 'Join Meeting',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDVhK9BxiZbnvzSj4MAPQZUpCpvtLLHRRHqlTSvhM9iZ9xRSboRCd8sf1T7gOXXZG14FnviMNWK-p9domZwL5Cp-5S117H82aOg4Z0-wlWKLFkio7GIr4Wa7p_SyNLFrFCFf2P7JgVFHe6yn_xVtUTVeoMA40lBl5I-OnOTxZ9NaQFv1d_Nd3hgDRG0m1OSivGSchY7k157s0sYj369nc_vIe6CpOXaTsc8cXZPOUZGHWMiNeI-zSA87lI3zDUSJZzXxfkytIM11Q',
                  ),
                  const SizedBox(height: 16),
                  _buildAppointmentCard(
                    title: 'VAT Opening Support',
                    date: 'Nov 02, 2023 - 03:30 PM',
                    consultant: 'Elena Bianchi',
                    type: 'In-Person • Rome Office',
                    icon: Icons.location_on,
                    buttonText: 'View Location',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDuzv-Xa7HPA7LUAhYxXR_h1WOL2OXQbasL2Bu-0WlgVO9zE8eMlhu4v1xQjL6mj4PkqcDYKOy_-emzTjntA2ej87KSK6QkAn1xnfRmKt4WCE3KVy2sUESINiuSeAh1zFnTK2hpXtFv9uGLNP3_EE-_4UDHKR8X0nzwJpYV530zutjzMXD7hXbr7Febi9ykeCgqNvYoOOXIYNTkJifQYxltB8Q6cZgSgGUUTmiby69B3kzmHCbCV92j1Zs7tj-3EMfWUF0e5pq_7w',
                  ),
                  const SizedBox(height: 32),
                  _buildQuickActions(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
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
              'My Booked Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedFilter = 'Upcoming'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: selectedFilter == 'Upcoming' ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selectedFilter == 'Upcoming' ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                  ),
                  child: Text(
                    'Upcoming',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedFilter == 'Upcoming' ? const Color(0xFF186ADC) : const Color(0xFF637288),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedFilter = 'Past'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: selectedFilter == 'Past' ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: selectedFilter == 'Past' ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2)] : null,
                  ),
                  child: Text(
                    'Past',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selectedFilter == 'Past' ? const Color(0xFF186ADC) : const Color(0xFF637288),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String title,
    required String date,
    required String consultant,
    required String type,
    required IconData icon,
    required String buttonText,
    required String imageUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111418)),
                    ),
                    const Icon(Icons.more_vert, color: Color(0xFF637288)),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Color(0xFF186ADC)),
                        const SizedBox(width: 8),
                        Text(
                          date,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF186ADC)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18, color: Color(0xFF637288)),
                        const SizedBox(width: 8),
                        Text(
                          'Consultant: $consultant',
                          style: const TextStyle(fontSize: 14, color: Color(0xFF637288)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(icon, size: 18, color: const Color(0xFF637288)),
                        const SizedBox(width: 8),
                        Text(
                          type,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF637288)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF186ADC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF637288),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF186ADC).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.event_repeat, color: Color(0xFF186ADC)),
            ),
            title: const Text(
              'Reschedule Appointment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF111418)),
            ),
            subtitle: const Text(
              'Need to change time? Modify here.',
              style: TextStyle(fontSize: 14, color: Color(0xFF637288)),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF111418)),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}