import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditingName = false;

  String name = "Israr Hussain";
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = name;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = screenWidth > screenHeight;

    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);
    const Color backgroundColor = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(
                                context,
                                '/main',
                              );
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
        actions: const [
          Icon(Icons.more_vert, color: Colors.black),
          SizedBox(width: 15),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              height: constraints.maxHeight, // Take full available height
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
                    ? _buildLandscapeLayout()
                    : _buildPortraitLayout(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Your Profile",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          const SizedBox(height: 25),

          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/img01.jpeg'),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 5,
                    )
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),

          _buildEditableTile(
            label: "Name",
            value: name,
            controller: nameController,
            isEditing: isEditingName,
            onToggle: () {
              setState(() {
                if (isEditingName) {
                  name = nameController.text.trim();
                }
                isEditingName = !isEditingName;
              });
            },
          ),
          const SizedBox(height: 20),

          _buildFixedTile(
            label: "UID",
            value: "ABCDE123",
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9F8DC),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Add Account",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 15,
            runSpacing: 10,
            children: [
              _buildPaymentChip("JC"),
              _buildPaymentChip("Nayapay"),
              _buildPaymentChip("Easypaisa"),
              _buildPaymentChip("Bank Alfalah"),
              _buildPaymentChip("HBL"),
              _buildPaymentChip("UBL"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
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
                "Your Profile",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/images/img01.jpeg'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black, size: 18),
                      onPressed: () {},
                    ),
                  ),
                ],
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
                _buildEditableTile(
                  label: "Name",
                  value: name,
                  controller: nameController,
                  isEditing: isEditingName,
                  onToggle: () {
                    setState(() {
                      if (isEditingName) {
                        name = nameController.text.trim();
                      }
                      isEditingName = !isEditingName;
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildFixedTile(
                  label: "UID",
                  value: "ABCDE123",
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9F8DC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Add Account",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 10,
                  children: [
                    _buildPaymentChip("JC"),
                    _buildPaymentChip("Nayapay"),
                    _buildPaymentChip("Easypaisa"),
                    _buildPaymentChip("Bank Alfalah"),
                    _buildPaymentChip("HBL"),
                    _buildPaymentChip("UBL"),
                    _buildPaymentChip("MCB"),
                    _buildPaymentChip("Allied Bank"),
                    _buildPaymentChip("Soneri Bank"),
                    _buildPaymentChip("Faysal Bank"),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableTile({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onToggle,
  }) {
    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
          ),
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
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: isEditing
                ? TextField(
              controller: controller,
              maxLength: 20,
              maxLines: 1,
              autofocus: true, // Automatically focus when editing starts
              textAlignVertical: TextAlignVertical.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isDense: true,
                contentPadding: EdgeInsets.zero, // Remove extra padding
                floatingLabelBehavior: FloatingLabelBehavior.never,
              ),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
              onSubmitted: (_) => onToggle(),
            )
                : Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.check_circle : Icons.edit,
              color: Colors.black54,
              size: 22,
            ),
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }

  Widget _buildFixedTile({
    required String label,
    required String value,
  }) {
    const Color primaryColor = Color(0xFF00D09E);
    const Color lightGreen = Color(0xFFC9F8DC);

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
          ),
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
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String label) {
    const Color primaryColor = Color(0xFF00D09E);
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

}
