import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../widgets/common/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Новая категория'),
          content: TextField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Введите название категории',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                controller.dispose();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text;
                if (name.isNotEmpty) {
                  context.read<CategoryBloc>().add(AddCategoryEvent(name: name));
                }
                Navigator.of(dialogContext).pop();
                controller.dispose();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CategoryBloc>()..add(LoadCategories()),
      child: Scaffold(
        appBar: AppBar(title: Text('Категории')),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              if (state.categories.isEmpty) {
                return Center(child: Text('Нет категорий'));
              }
              return ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: () {},
                    onEdit: () {},
                    onDelete: () {
                      context.read<CategoryBloc>().add(
                        DeleteCategoryEvent(category.id),
                      );
                    },
                  );
                },
              );
            } else if (state is CategoryError) {
              return Center(child: Text(state.message));
            }
            return Container();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddCategoryDialog(context),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
