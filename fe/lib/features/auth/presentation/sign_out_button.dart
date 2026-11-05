import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/secondary_button.dart';
import 'auth_providers.dart';

/// Signs out and stays busy until the route guard takes the user to sign-in.
class SignOutButton extends ConsumerStatefulWidget {
  const SignOutButton({super.key, this.isExpanded = true});

  final bool isExpanded;

  @override
  ConsumerState<SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends ConsumerState<SignOutButton> {
  bool isBusy = false;

  Future<void> signOut() async {
    setState(() => isBusy = true);
    try {
      await ref.read(signOutProvider)();
    } on AppException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      label: 'Sign out',
      onPressed: signOut,
      isBusy: isBusy,
      isExpanded: widget.isExpanded,
    );
  }
}
