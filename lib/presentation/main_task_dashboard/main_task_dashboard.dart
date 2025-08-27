import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dashboard_header_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/quick_add_fab_widget.dart';
import './widgets/statistics_bar_widget.dart';
import './widgets/task_section_widget.dart';

class MainTaskDashboard extends StatefulWidget {
  const MainTaskDashboard({Key? key}) : super(key: key);

  @override
  State<MainTaskDashboard> createState() => _MainTaskDashboardState();
}

class _MainTaskDashboardState extends State<MainTaskDashboard>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock user data
  final String _userName = "Sarah Johnson";

  // Mock task data
  final List<Map<String, dynamic>> _mockTasks = [
    {
      "id": 1,
      "title": "Review quarterly reports",
      "description":
          "Analyze Q3 performance metrics and prepare summary for board meeting",
      "priority": "high",
      "category": "work",
      "dueDate": DateTime.now().add(const Duration(hours: 2)),
      "isCompleted": false,
    },
    {
      "id": 2,
      "title": "Team standup meeting",
      "description": "Daily sync with development team",
      "priority": "medium",
      "category": "work",
      "dueDate": DateTime.now().add(const Duration(hours: 1)),
      "isCompleted": false,
    },
    {
      "id": 3,
      "title": "Grocery shopping",
      "description": "Buy ingredients for weekend dinner party",
      "priority": "low",
      "category": "shopping",
      "dueDate": DateTime.now().add(const Duration(hours: 4)),
      "isCompleted": false,
    },
    {
      "id": 4,
      "title": "Submit expense report",
      "description": "Upload receipts and submit monthly expenses",
      "priority": "high",
      "category": "work",
      "dueDate": DateTime.now().subtract(const Duration(days: 1)),
      "isCompleted": false,
    },
    {
      "id": 5,
      "title": "Call dentist",
      "description": "Schedule routine cleaning appointment",
      "priority": "medium",
      "category": "personal",
      "dueDate": DateTime.now().add(const Duration(days: 2)),
      "isCompleted": false,
    },
    {
      "id": 6,
      "title": "Finish project proposal",
      "description": "Complete the client presentation slides",
      "priority": "high",
      "category": "work",
      "dueDate": DateTime.now().add(const Duration(days: 1)),
      "isCompleted": true,
    },
    {
      "id": 7,
      "title": "Morning workout",
      "description": "30-minute cardio session at the gym",
      "priority": "medium",
      "category": "health",
      "dueDate": DateTime.now().subtract(const Duration(hours: 2)),
      "isCompleted": true,
    },
  ];

  List<Map<String, dynamic>> get _todayTasks {
    final today = DateTime.now();
    return _mockTasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day &&
          !(task['isCompleted'] as bool? ?? false);
    }).toList();
  }

  List<Map<String, dynamic>> get _overdueTasks {
    final now = DateTime.now();
    return _mockTasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.isBefore(now) && !(task['isCompleted'] as bool? ?? false);
    }).toList();
  }

  List<Map<String, dynamic>> get _upcomingTasks {
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    return _mockTasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      return dueDate.isAfter(now) &&
          dueDate.isBefore(nextWeek) &&
          !(task['isCompleted'] as bool? ?? false) &&
          !_todayTasks.contains(task);
    }).toList();
  }

  List<Map<String, dynamic>> get _completedTasks {
    return _mockTasks
        .where((task) => task['isCompleted'] as bool? ?? false)
        .toList();
  }

  int get _completionStreak => 7; // Mock streak data

  double get _todayProgress {
    final totalTodayTasks = _todayTasks.length +
        _completedTasks.where((task) {
          final dueDate = task['dueDate'] as DateTime?;
          if (dueDate == null) return false;
          final today = DateTime.now();
          return dueDate.year == today.year &&
              dueDate.month == today.month &&
              dueDate.day == today.day;
        }).length;

    if (totalTodayTasks == 0) return 1.0;

    final completedTodayTasks = _completedTasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;
      final today = DateTime.now();
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).length;

    return completedTodayTasks / totalTodayTasks;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle scroll events for potential future features
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();

    // Simulate cloud sync
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    HapticFeedback.mediumImpact();
  }

  void _onTaskTap(Map<String, dynamic> task) {
    HapticFeedback.lightImpact();
    // Navigate to task details or edit
    Navigator.pushNamed(context, '/add-edit-task');
  }

  void _onTaskComplete(Map<String, dynamic> task) {
    setState(() {
      final index = _mockTasks.indexWhere((t) => t['id'] == task['id']);
      if (index != -1) {
        _mockTasks[index]['isCompleted'] =
            !(task['isCompleted'] as bool? ?? false);
      }
    });
    HapticFeedback.mediumImpact();
  }

  void _onTaskDelete(Map<String, dynamic> task) {
    setState(() {
      _mockTasks.removeWhere((t) => t['id'] == task['id']);
    });
    HapticFeedback.heavyImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task "${task['title']}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _mockTasks.add(task);
            });
          },
        ),
      ),
    );
  }

  void _onTaskEdit(Map<String, dynamic> task) {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/add-edit-task');
  }

  void _onSearchTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/search-and-filter');
  }

  void _onProfileTap() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/settings-and-preferences');
  }

  void _onAddTask() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/add-edit-task');
  }

  void _onVoiceInput() {
    HapticFeedback.mediumImpact();
    // Implement voice input functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input feature coming soon!'),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {
        HapticFeedback.lightImpact();
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            Navigator.pushNamed(context, '/task-list-view');
            break;
          case 2:
            Navigator.pushNamed(context, '/calendar-view');
            break;
          case 3:
            Navigator.pushNamed(context, '/analytics-dashboard');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 24,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'list',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'calendar_today',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          label: 'Analytics',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyTasks = _todayTasks.isNotEmpty ||
        _overdueTasks.isNotEmpty ||
        _upcomingTasks.isNotEmpty ||
        _completedTasks.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: hasAnyTasks
            ? RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.lightTheme.colorScheme.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          DashboardHeaderWidget(
                            userName: _userName,
                            onSearchTap: _onSearchTap,
                            onProfileTap: _onProfileTap,
                          ),
                          StatisticsBarWidget(
                            completionStreak: _completionStreak,
                            todayProgress: _todayProgress,
                            completedTasks: _completedTasks.length,
                            totalTasks: _mockTasks.length,
                          ),
                        ],
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        _overdueTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Overdue',
                                tasks: _overdueTasks,
                                accentColor: const Color(0xFFDC2626),
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        _todayTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Today',
                                tasks: _todayTasks,
                                accentColor:
                                    AppTheme.lightTheme.colorScheme.primary,
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        _upcomingTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Upcoming',
                                tasks: _upcomingTasks,
                                accentColor: const Color(0xFFD97706),
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        _completedTasks.isNotEmpty
                            ? TaskSectionWidget(
                                title: 'Recently Completed',
                                tasks: _completedTasks.take(5).toList(),
                                accentColor: const Color(0xFF059669),
                                onTaskTap: _onTaskTap,
                                onTaskComplete: _onTaskComplete,
                                onTaskDelete: _onTaskDelete,
                                onTaskEdit: _onTaskEdit,
                              )
                            : const SizedBox.shrink(),
                        SizedBox(height: 10.h), // Space for FAB
                      ]),
                    ),
                  ],
                ),
              )
            : EmptyStateWidget(
                title: 'Welcome to TaskFlow Pro!',
                subtitle:
                    'Start organizing your life by adding your first task. Tap the button below to get started.',
                buttonText: 'Add Your First Task',
                onButtonTap: _onAddTask,
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: QuickAddFabWidget(
        onAddTask: _onAddTask,
        onVoiceInput: _onVoiceInput,
      ),
    );
  }
}
