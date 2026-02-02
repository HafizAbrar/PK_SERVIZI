import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/api_client.dart';
import 'package:go_router/go_router.dart';

final coursesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiClient = ref.read(apiClientProvider);
  final response = await apiClient.get('/courses');
  return List<Map<String, dynamic>>.from(response.data['data']);
});

class CoursesScreen extends ConsumerWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Courses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/courses/my-enrollments'),
            icon: const Icon(Icons.school, color: Colors.white),
          ),
        ],
      ),
      body: Container(
        decoration: AppTheme.cardDecoration.copyWith(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: coursesAsync.when(
          data: (courses) => _buildCoursesList(context, courses),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: AppTheme.spacingMedium),
                Text('Error loading courses', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: AppTheme.spacingSmall),
                ElevatedButton(
                  onPressed: () => ref.refresh(coursesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoursesList(BuildContext context, List<Map<String, dynamic>> courses) {
    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(
              'No courses available',
              style: TextStyle(fontSize: AppTheme.fontSizeLarge, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            onTap: () => context.push('/courses/${course['id']}'),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course['title'] ?? 'Course',
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  if (course['description'] != null)
                    Text(
                      course['description'],
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: AppTheme.fontSizeRegular,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      if (course['duration'] != null) ...[
                        Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text('${course['duration']}h', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(width: 16),
                      ],
                      if (course['level'] != null) ...[
                        Icon(Icons.signal_cellular_alt, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(course['level'], style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                      const Spacer(),
                      if (course['price'] != null)
                        Text(
                          '€${course['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}