import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_talk/providers/user_provider.dart';

class Demo extends ConsumerStatefulWidget {
  const Demo({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DemoState();
}

class _DemoState extends ConsumerState<Demo> {
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách người dùng')),
      body: Column(
        children: [
          ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                // leading: Text('${user.id}'),
                title: Text(user.name),
                subtitle: Text(user.email),
              );
            },
          ),
          TextField(
            controller: idController,
            decoration: InputDecoration(labelText: 'ID'),
          ),
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Tên'),
          ),
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),

          ElevatedButton(
            onPressed: () {
              final id = int.parse(idController.text);
              final name = nameController.text;
              final email = emailController.text;
              ref.read(userProvider.notifier).updateUserById(id, name, email);
            },
            child: Text('Cập nhật user'),
          ),
        ],
      ),
    );
  }
}
