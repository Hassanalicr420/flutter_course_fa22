import 'package:flutter/material.dart';
import '../widgets/skeleton_loading.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'A+', 'A', 'B+', 'B', 'C'];
  bool _isLoading = true;

  // Sample data - In real app, this would come from a database
  List<Map<String, dynamic>> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _allStudents = [
        {
          'name': 'John Smith',
          'rollNo': '2023001',
          'class': 'Mathematics 101',
          'attendance': 85,
          'grade': 'A',
        },
        {
          'name': 'Emma Wilson',
          'rollNo': '2023002',
          'class': 'Mathematics 101',
          'attendance': 92,
          'grade': 'A+',
        },
        {
          'name': 'Michael Brown',
          'rollNo': '2023003',
          'class': 'Mathematics 101',
          'attendance': 78,
          'grade': 'B+',
        },
        {
          'name': 'Sarah Davis',
          'rollNo': '2023004',
          'class': 'Mathematics 101',
          'attendance': 88,
          'grade': 'A',
        },
        {
          'name': 'David Miller',
          'rollNo': '2023005',
          'class': 'Mathematics 101',
          'attendance': 95,
          'grade': 'A+',
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredStudents {
    return _allStudents.where((student) {
      final matchesSearch = student['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student['rollNo'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || student['grade'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: StudentSearchDelegate(_allStudents),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _filters.map((String filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: Row(
                    children: [
                      if (_selectedFilter == filter)
                        Icon(Icons.check, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(filter),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStudents,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedFilter = selected ? filter : 'All';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Statistics Cards
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Students',
                        '${filteredStudents.length}',
                        Icons.people,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Average Grade',
                        _calculateAverageGrade(),
                        Icons.grade,
                        colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Attendance',
                        '${_calculateAverageAttendance()}%',
                        Icons.calendar_today,
                        colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            // Students List
            Expanded(
              child: _isLoading
                  ? const SkeletonList()
                  : filteredStudents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: colorScheme.secondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No students found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = filteredStudents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    student['name'][0],
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  student['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Roll No: ${student['rollNo']}',
                                      style: TextStyle(
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      student['class'] as String,
                                      style: TextStyle(
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildGradeChip(
                                      context,
                                      student['grade'] as String,
                                    ),
                                    const SizedBox(width: 8),
                                    _buildAttendanceChip(
                                      context,
                                      student['attendance'] as int,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _showStudentDetails(context, student);
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddStudentDialog(context);
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }

  String _calculateAverageGrade() {
    if (filteredStudents.isEmpty) return 'N/A';
    
    final gradeValues = {
      'A+': 4.0,
      'A': 3.7,
      'B+': 3.3,
      'B': 3.0,
      'C+': 2.3,
      'C': 2.0,
    };

    double total = 0;
    for (var student in filteredStudents) {
      total += gradeValues[student['grade']] ?? 0;
    }
    
    final average = total / filteredStudents.length;
    
    if (average >= 3.7) return 'A+';
    if (average >= 3.3) return 'A';
    if (average >= 3.0) return 'B+';
    if (average >= 2.7) return 'B';
    if (average >= 2.3) return 'C+';
    return 'C';
  }

  int _calculateAverageAttendance() {
    if (filteredStudents.isEmpty) return 0;
    
    int total = 0;
    for (var student in filteredStudents) {
      total += student['attendance'] as int;
    }
    
    return (total / filteredStudents.length).round();
  }

  void _showStudentDetails(BuildContext context, Map<String, dynamic> student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            student['name'][0],
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem('Name', student['name']),
                    _buildDetailItem('Roll Number', student['rollNo']),
                    _buildDetailItem('Class', student['class']),
                    _buildDetailItem('Grade', student['grade']),
                    _buildDetailItem('Attendance', '${student['attendance']}%'),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          context,
                          Icons.edit,
                          'Edit',
                          () {
                            Navigator.pop(context);
                            // TODO: Implement edit functionality
                          },
                        ),
                        _buildActionButton(
                          context,
                          Icons.delete,
                          'Delete',
                          () {
                            Navigator.pop(context);
                            // TODO: Implement delete functionality
                          },
                        ),
                        _buildActionButton(
                          context,
                          Icons.message,
                          'Message',
                          () {
                            Navigator.pop(context);
                            // TODO: Implement messaging functionality
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter student name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Roll Number',
                    hintText: 'Enter roll number',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    hintText: 'Enter class name',
                  ),
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
              onPressed: () {
                // TODO: Implement add student functionality
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeChip(BuildContext context, String grade) {
    Color color;
    switch (grade) {
      case 'A+':
        color = Colors.green;
        break;
      case 'A':
        color = Colors.lightGreen;
        break;
      case 'B+':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        grade,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttendanceChip(BuildContext context, int attendance) {
    Color color;
    if (attendance >= 90) {
      color = Colors.green;
    } else if (attendance >= 75) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        '$attendance%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class StudentSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> students;

  StudentSearchDelegate(this.students);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = students.where((student) {
      return student['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          student['rollNo'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final student = results[index];
        return ListTile(
          title: Text(student['name']),
          subtitle: Text('Roll No: ${student['rollNo']}'),
          onTap: () {
            close(context, student);
          },
        );
      },
    );
  }
} 