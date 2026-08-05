import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rest_api/core/models/user_model.dart';
import 'package:flutter_rest_api/core/providers/core_providers.dart';
import 'package:flutter_rest_api/features/users/providers/user_provider.dart';
import 'package:flutter_rest_api/shared/widgets/custom_button.dart';
import 'package:flutter_rest_api/shared/widgets/custom_text_field.dart';

class UserFormDialog extends ConsumerStatefulWidget {
  final UserModel? userToEdit;

  const UserFormDialog({super.key, this.userToEdit});

  static Future<void> show(BuildContext context, {UserModel? user}) async {
    await showDialog(
      context: context,
      builder: (context) => UserFormDialog(userToEdit: user),
    );
  }

  @override
  ConsumerState<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends ConsumerState<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  bool _isLoading = false;

  bool get isEditing => widget.userToEdit != null;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.userToEdit?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.userToEdit?.lastName ?? '');
    _emailController = TextEditingController(text: widget.userToEdit?.email ?? '');
    _usernameController = TextEditingController(text: widget.userToEdit?.username ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userRepository = ref.read(userRepositoryProvider);
    final userListNotifier = ref.read(userListProvider.notifier);

    if (isEditing) {
      final updates = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'username': _usernameController.text.trim(),
      };

      final result = await userRepository.updateUser(widget.userToEdit!.id, updates);
      result.when(
        success: (updatedUser) {
          userListNotifier.updateUserLocal(updatedUser);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User updated successfully!')),
            );
          }
        },
        failure: (msg, code, ex) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: $msg')),
            );
          }
        },
      );
    } else {
      final newUser = UserModel(
        id: 0,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        role: 'User',
      );

      final result = await userRepository.createUser(newUser);
      result.when(
        success: (createdUser) {
          userListNotifier.addUserLocal(createdUser);
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('User created successfully!')),
            );
          }
        },
        failure: (msg, code, ex) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed: $msg')),
            );
          }
        },
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isEditing ? 'Edit User (PUT/PATCH)' : 'Create User (POST)'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || !val.contains('@') ? 'Invalid Email' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
                prefixIcon: Icons.alternate_email,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: isEditing ? 'Save Changes' : 'Create',
          isLoading: _isLoading,
          onPressed: _handleSubmit,
        ),
      ],
    );
  }
}
