import 'package:flutter/material.dart';
import 'package:lokaloka/features/auth/models/user.dart';

class AccountTab extends StatefulWidget {
  final UserNormal user;

  AccountTab({required this.user});

  @override
  _AccountTabState createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  bool isEditing = false; // Trạng thái chỉnh sửa

  // Controllers quản lý dữ liệu nhập
  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController(text: widget.user.full_name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    addressController = TextEditingController(text: widget.user.address);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Bọc trong SingleChildScrollView để có thể cuộn
      child: Column(
        children: [
          _buildTextField("Full Name", fullNameController, isEditing, true),
          _buildTextField("Email", emailController, isEditing, false),
          _buildTextField("Phone", phoneController, isEditing, false),
          _buildTextField("Address", addressController, isEditing, true),

          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool enabled, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label + (isRequired ? " *" : ""),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isEditing
          ? Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isEditing = false;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text("Save"),
          ),
        ],
      )
          : ElevatedButton(
        onPressed: () {
          setState(() {
            isEditing = true;
          });
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
        child: Text("Update"),
      ),
    );
  }
}
