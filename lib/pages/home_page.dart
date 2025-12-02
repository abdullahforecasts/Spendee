// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';
import '../services/api_service.dart';
import '../utils/user_model.dart';
import 'trip_details_page.dart';
import 'group_creation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  List<GroupModel> _myLeaderGroups = [];
  List<GroupModel> _myMemberGroups = [];
  UserModel? _currentUser;

  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load user profile
      final profileData = await _apiService.getProfile();
      _currentUser = UserModel.fromJson(profileData['user']);

      // Load groups
      final groupsData = await _apiService.getMyGroups();
      try {
        // debug: print raw groupsData returned from API
        // ignore: avoid_print
        print('getMyGroups response: ${groupsData}');
      } catch (_) {}

      final leaderGroups = (groupsData['asLeader'] as List)
          .map((g) => GroupModel.fromJson(g))
          .toList();

      final memberGroups = (groupsData['asMember'] as List)
          .map((g) => GroupModel.fromJson(g))
          .toList();

      setState(() {
        _myLeaderGroups = leaderGroups;
        _myMemberGroups = memberGroups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateGroup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupCreationPage()),
    );

    if (result == true) {
      _loadData(); // Refresh data after creating group
    }
  }

  // Public method used by parent navigator to refresh list after external events.
  Future<void> refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Stack(
          children: [
            Container(color: const Color(0xFF00D09E)),
            Positioned.fill(
              top: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F8F0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _currentUser != null
                        ? Text(
                            "Hi, ${_currentUser!.name} 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : Text(
                            "Hi, Welcome Back 👋",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Loading State
                    if (_isLoading)
                      const Expanded(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF00D09E),
                          ),
                        ),
                      ),

                    // Error State
                    if (_errorMessage.isNotEmpty && !_isLoading)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _errorMessage,
                                style: GoogleFonts.poppins(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D09E),
                                ),
                                child: Text(
                                  "Retry",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Groups List
                    if (!_isLoading && _errorMessage.isEmpty)
                      Expanded(
                        child:
                            _myLeaderGroups.isEmpty && _myMemberGroups.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.group_work_outlined,
                                      size: 80,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 15),
                                    Text(
                                      "No groups yet",
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Create your first group to get started",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                color: const Color(0xFF00D09E),
                                child: ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    // Groups as Leader
                                    ..._myLeaderGroups.map(
                                      (group) => _buildGroupCard(
                                        context,
                                        group,
                                        isCreator: true,
                                      ),
                                    ),

                                    // Groups as Member
                                    ..._myMemberGroups.map(
                                      (group) => _buildGroupCard(
                                        context,
                                        group,
                                        isCreator: false,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // FAB
      floatingActionButton: OpenContainer<bool>(
        transitionDuration: const Duration(milliseconds: 500),
        openElevation: 0,
        closedElevation: 6,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        closedColor: const Color(0xFF00B686),
        openColor: const Color(0xFFE6F8F0),
        openBuilder: (context, _) => const GroupCreationPage(),
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          heroTag: 'home_page_fab',
          backgroundColor: const Color(0xFF00B686),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    GroupModel group, {
    required bool isCreator,
  }) {
    // Find current user's payment status if member
    bool isPaid = false;
    if (!isCreator && _currentUser != null) {
      final myMember = group.members.firstWhere(
        (m) => m.user.id == _currentUser!.id,
        orElse: () => group.members.first,
      );
      isPaid = myMember.hasPaid;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, __, ___) => TripDetailsPage(groupId: group.id),
                transitionsBuilder: (_, animation, __, child) =>
                    FadeScaleTransition(animation: animation, child: child),
              ),
            )
            .then((value) {
              // Always refresh after returning from details to ensure
              // paid progress and amounts are up to date.
              _loadData();
              // debug: print returned value and tapped group id
              try {
                // ignore: avoid_print
                print(
                  'Returned from TripDetails (value=$value) for group id=${group.id}',
                );
              } catch (_) {}
            });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F8F0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.group_work,
                color: Color(0xFF00D09E),
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isCreator
                        ? "Created by You"
                        : "Created by ${group.leader.name}",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (isCreator) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: group.progressPercentage,
                        backgroundColor: const Color(0xFFF1F1F1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00D09E),
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "${group.paidCount}/${group.totalCount} paid • Rs. ${group.currentAmount.toStringAsFixed(0)}/${group.goalAmount.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFFE6F8F0)
                            : const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isPaid
                              ? const Color(0xFF00D09E)
                              : Colors.redAccent.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        isPaid ? "Status: Paid ✓" : "Status: Unpaid",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPaid
                              ? const Color(0xFF00D09E)
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isCreator)
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete group?'),
                        content: Text(
                          "Are you sure you want to delete '${group.name}'? This cannot be undone.",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await _apiService.deleteGroup(group.id);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Group deleted')),
                        );
                        _loadData();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete group: $e')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
              )
            else
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade300,
              ),
          ],
        ),
      ),
    );
  }
}
