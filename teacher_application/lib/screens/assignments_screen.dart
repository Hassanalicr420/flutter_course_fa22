import 'package:flutter/material.dart';
import '../widgets/skeleton_loading.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Completed', 'Overdue'];
  bool _isLoading = true;

  // Sample data - In real app, this would come from a database
  List<Map<String, dynamic>> _allAssignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _allAssignments = [
        {
          'title': 'Linear Algebra Project',
          'class': 'Mathematics 101',
          'dueDate': DateTime.now().add(const Duration(days: 3)),
          'submitted': 15,
          'total': 25,
          'status': 'pending',
          'description': 'Complete the linear algebra project covering matrices and determinants.',
          'attachments': ['project_guidelines.pdf', 'sample_solutions.pdf'],
        },
        {
          'title': 'Calculus Quiz',
          'class': 'Mathematics 101',
          'dueDate': DateTime.now().add(const Duration(days: 1)),
          'submitted': 20,
          'total': 25,
          'status': 'pending',
          'description': 'Quiz covering differential calculus and its applications.',
          'attachments': ['quiz_topics.pdf'],
        },
        {
          'title': 'Statistics Assignment',
          'class': 'Mathematics 101',
          'dueDate': DateTime.now().subtract(const Duration(days: 2)),
          'submitted': 25,
          'total': 25,
          'status': 'completed',
          'description': 'Statistical analysis of given dataset using various methods.',
          'attachments': ['dataset.csv', 'analysis_guidelines.pdf'],
        },
        {
          'title': 'Probability Problem Set',
          'class': 'Mathematics 101',
          'dueDate': DateTime.now().subtract(const Duration(days: 5)),
          'submitted': 22,
          'total': 25,
          'status': 'completed',
          'description': 'Problem set covering probability distributions and their applications.',
          'attachments': ['problem_set.pdf', 'formula_sheet.pdf'],
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredAssignments {
    return _allAssignments.where((assignment) {
      final matchesSearch = assignment['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          assignment['class'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'All' || 
          (_selectedFilter == 'Pending' && assignment['status'] == 'pending') ||
          (_selectedFilter == 'Completed' && assignment['status'] == 'completed') ||
          (_selectedFilter == 'Overdue' && 
           assignment['status'] == 'pending' && 
           assignment['dueDate'].isBefore(DateTime.now()));
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: AssignmentSearchDelegate(_allAssignments),
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
        onRefresh: _loadAssignments,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search assignments...',
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
            // Progress Overview
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildProgressCard(
                        context,
                        'Pending',
                        '${_countAssignmentsByStatus('pending')}',
                        Icons.pending_actions,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        context,
                        'Completed',
                        '${_countAssignmentsByStatus('completed')}',
                        Icons.check_circle,
                        colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProgressCard(
                        context,
                        'Submission Rate',
                        '${_calculateSubmissionRate()}%',
                        Icons.upload_file,
                        colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            // Assignments List
            Expanded(
              child: _isLoading
                  ? const SkeletonList()
                  : filteredAssignments.isEmpty
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
                                'No assignments found',
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
                          itemCount: filteredAssignments.length,
                          itemBuilder: (context, index) {
                            final assignment = filteredAssignments[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _showAssignmentDetails(context, assignment),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(assignment['status']).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.assignment,
                                              color: _getStatusColor(assignment['status']),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  assignment['title'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  assignment['class'],
                                                  style: TextStyle(
                                                    color: colorScheme.secondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          _buildStatusChip(assignment),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: colorScheme.secondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _formatDate(assignment['dueDate']),
                                                style: TextStyle(
                                                  color: colorScheme.secondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${assignment['submitted']}/${assignment['total']} Submitted',
                                            style: TextStyle(
                                              color: colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: assignment['submitted'] / assignment['total'],
                                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          _showAddAssignmentDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Assignment'),
      ),
    );
  }

  int _countAssignmentsByStatus(String status) {
    return _allAssignments.where((assignment) => assignment['status'] == status).length;
  }

  int _calculateSubmissionRate() {
    int totalSubmitted = 0;
    int totalStudents = 0;
    
    for (var assignment in _allAssignments) {
      totalSubmitted += assignment['submitted'] as int;
      totalStudents += assignment['total'] as int;
    }
    
    if (totalStudents == 0) return 0;
    return ((totalSubmitted / totalStudents) * 100).round();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(Map<String, dynamic> assignment) {
    final isOverdue = assignment['status'] == 'pending' && 
                      assignment['dueDate'].isBefore(DateTime.now());
    final status = isOverdue ? 'Overdue' : 
                  assignment['status'] == 'completed' ? 'Completed' : 'Pending';
    final color = isOverdue ? Colors.red : _getStatusColor(assignment['status']);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      return 'Due today';
    } else if (difference.inDays == 1) {
      return 'Due tomorrow';
    } else if (difference.inDays < 0) {
      return 'Overdue by ${-difference.inDays} days';
    } else {
      return 'Due in ${difference.inDays} days';
    }
  }

  void _showAssignmentDetails(BuildContext context, Map<String, dynamic> assignment) {
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getStatusColor(assignment['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.assignment,
                            size: 32,
                            color: _getStatusColor(assignment['status']),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment['title'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                assignment['class'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem('Due Date', _formatDate(assignment['dueDate'])),
                    _buildDetailItem('Status', assignment['status'].toString().toUpperCase()),
                    _buildDetailItem('Submitted', '${assignment['submitted']}/${assignment['total']}'),
                    _buildDetailItem('Description', assignment['description']),
                    const SizedBox(height: 16),
                    const Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(assignment['attachments'] as List<String>).map((attachment) {
                      return ListTile(
                        leading: const Icon(Icons.attachment),
                        title: Text(attachment),
                        trailing: IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            // TODO: Implement download functionality
                          },
                        ),
                      );
                    }).toList(),
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
                          Icons.share,
                          'Share',
                          () {
                            Navigator.pop(context);
                            // TODO: Implement share functionality
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

  void _showAddAssignmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter assignment title',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Class',
                    hintText: 'Enter class name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter assignment description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Total Students',
                    hintText: 'Enter total number of students',
                  ),
                  keyboardType: TextInputType.number,
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
                // TODO: Implement add assignment functionality
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressCard(
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
}

class AssignmentSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> assignments;

  AssignmentSearchDelegate(this.assignments);

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
    final results = assignments.where((assignment) {
      return assignment['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
          assignment['class'].toString().toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final assignment = results[index];
        return ListTile(
          title: Text(assignment['title']),
          subtitle: Text(assignment['class']),
          trailing: Text(
            '${assignment['submitted']}/${assignment['total']}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            close(context, assignment);
          },
        );
      },
    );
  }
} 