import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../blocs/category/category_bloc.dart';
import '../../widgets/common/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String? _newCategoryName;

  void _showAddCategoryDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Новая категория'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Введите название категории',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                Navigator.of(dialogContext).pop(value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                final name = dialogContext.read<String?>() ?? '';
                if (name.isNotEmpty) {
                  _newCategoryName = name;
                  context.read<CategoryBloc>().add(AddCategoryEvent(name: name));
                  Navigator.of(dialogContext).pop();
                }
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
                        DeleteCategoryEvent(categoryId: category.id),
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
