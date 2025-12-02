import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

import '../utils/session.dart';

class OthersProfileViewPage extends StatefulWidget {
  // optional identifier (uuid or user id). If null, page shows placeholder/defaults.
  final String? userId;
  const OthersProfileViewPage({super.key, this.userId});

  @override
  State<OthersProfileViewPage> createState() => _OthersProfileViewPageState();
}

class _OthersProfileViewPageState extends State<OthersProfileViewPage> {
  String? name;
  String? uid;
  String? profilePicUrl;
  bool _loading = false;
  final String baseUrl = 'http://172.16.21.123:3000/api';

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) _fetchUser(widget.userId!);
  }

  Future<void> _fetchUser(String query) async {
    if (Session.authHeader == null) return;
    setState(() => _loading = true);
    try {
      final uri = Uri.parse(
        '$baseUrl/users/search?query=${Uri.encodeComponent(query)}',
      );
      final resp = await http.get(
        uri,
        headers: {
          'client': 'not-browser',
          'authorization': Session.authHeader!,
        },
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data['success'] == true &&
            data['users'] != null &&
            (data['users'] as List).isNotEmpty) {
          final u = data['users'][0];
          setState(() {
            name = u['name'] as String? ?? name;
            uid = u['uuid'] as String? ?? uid;
            profilePicUrl = u['profilePic'] as String? ?? profilePicUrl;
          });
        }
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;

    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);
    const Color backgroundColor = Color(0xFFFFFFFF);

    final displayName = name ?? "Ali Maqsood";
    final displayUid = uid ?? "ABCDE123";

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Spendee",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              height: constraints.maxHeight,
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: isLandscape ? 20 : 30,
                ),
                child: isLandscape
                    ? _buildLandscapeLayout(
                        displayName,
                        displayUid,
                        profilePicUrl,
                      )
                    : _buildPortraitLayout(
                        displayName,
                        displayUid,
                        profilePicUrl,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout(
    String displayName,
    String displayUid,
    String? profilePic,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Profile",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
          const SizedBox(height: 25),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: profilePic != null
                    ? NetworkImage(profilePic) as ImageProvider
                    : const AssetImage('assets/profile.jpg'),
              ),
            ],
          ),
          const SizedBox(height: 35),

          _buildFixedTile(label: "Name", value: displayName),
          const SizedBox(height: 20),

          _buildFixedTile(label: "UID", value: displayUid),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout(
    String displayName,
    String displayUid,
    String? profilePic,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundImage: profilePic != null
                    ? NetworkImage(profilePic) as ImageProvider
                    : const AssetImage('assets/profile.jpg'),
              ),
            ],
          ),
        ),

        // Vertical Divider Line
        Container(
          width: 1,
          margin: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFixedTile(label: "Name", value: displayName),
                const SizedBox(height: 20),
                _buildFixedTile(label: "UID", value: displayUid),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFixedTile({required String label, required String value}) {
    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 34,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}