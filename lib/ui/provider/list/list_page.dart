import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_homework_25_2/ui/provider/list/list_model.dart';
import 'package:provider/provider.dart';

import '../../../network/user_item.dart';

class ListPageProvider extends StatefulWidget {
  const ListPageProvider({Key? key}) : super(key: key);

  @override
  State<ListPageProvider> createState() => _ListPageProviderState();
}

class _ListPageProviderState extends State<ListPageProvider> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initializePage());
  }

  //TODO: Fetch user list from model
  void _initializePage() async {
    try {
      await context.read<ListModel>().loadUsers();
    } on ListException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final model = context.read<ListModel>();
    await model.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final listModel = context.watch<ListModel>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Felhasználók listája'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Kijelentkezés',
              onPressed: _handleLogout,
            ),
          ],
        ),
      body: _buildBody(listModel),
    );
  }

  Widget _buildBody(ListModel listModel) {
    if (listModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (listModel.users.isEmpty) {
      return const Center(
        child: Text('Nincsenek felhasználók.'),
      );
    }

    return ListView.builder(
      itemCount: listModel.users.length,
      itemBuilder: (context, index) {
        final UserItem user = listModel.users[index];
        return ListTile(
          leading: CircleAvatar(
            child: ClipOval(
              child: Image.network(
                user.avatarUrl,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
              ),
            ),
          ),
          title: Text(user.name),
        );
      },
    );
  }
}
