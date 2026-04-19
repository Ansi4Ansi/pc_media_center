import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/category.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../widgets/common/category_card.dart';
import '../category/category_screen.dart';

class HomeScreen extends StatefulWidget {
  final CategoryBloc? categoryBloc;

  const HomeScreen({super.key, this.categoryBloc});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  void _showAddCategoryDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    final bloc = widget.categoryBloc ?? getIt<CategoryBloc>();
    
    showDialog<String>(
      context: parentContext,
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
                  bloc.add(AddCategoryEvent(name: name));
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

  void _showEditCategoryDialog(BuildContext parentContext, CategoryEntity category) {
    final controller = TextEditingController(text: category.name);
    String? errorText;

    showDialog<void>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Редактировать категорию'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Название',
                  hintText: 'Введите название категории',
                  errorText: errorText,
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
                    final newName = controller.text.trim();

                    // Validate empty name
                    if (newName.isEmpty) {
                      setDialogState(() {
                        errorText = 'Название не может быть пустым';
                      });
                      return;
                    }

                    // Check if name hasn't changed
                    if (newName == category.name) {
                      Navigator.of(dialogContext).pop();
                      controller.dispose();
                      return;
                    }

                    // Check for duplicates against current categories
                    final bloc = widget.categoryBloc ?? getIt<CategoryBloc>();
                    final currentState = bloc.state;
                    if (currentState is CategoryLoaded) {
                      final exists = currentState.categories.any(
                        (c) => c.name.toLowerCase() == newName.toLowerCase() && c.id != category.id,
                      );
                      if (exists) {
                        setDialogState(() {
                          errorText = 'Категория с таким названием уже существует';
                        });
                        return;
                      }
                    }

                    // Dispatch update event
                    bloc.add(
                      UpdateCategoryEvent(
                        categoryId: category.id,
                        name: newName,
                      ),
                    );

                    Navigator.of(dialogContext).pop();
                    controller.dispose();
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext parentContext, CategoryEntity category) {
    final bloc = widget.categoryBloc ?? getIt<CategoryBloc>();
    
    showDialog<void>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Удалить категорию'),
          content: Text('Вы уверены, что хотите удалить категорию "${category.name}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                bloc.add(
                  DeleteCategoryEvent(category.id),
                );
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCategory(BuildContext context, CategoryEntity category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryScreen(
          categoryId: category.id.toString(),
          categoryName: category.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.categoryBloc ?? getIt<CategoryBloc>();
    
    return BlocProvider(
      create: (_) => bloc..add(LoadCategories()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Категории')),
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
              if (state.categories.isEmpty) {
                return const Center(child: Text('Нет категорий'));
              }
              return ListView.builder(
                itemCount: state.categories.length,
                itemBuilder: (context, index) {
                  final category = state.categories[index];
                  return CategoryCard(
                    category: category,
                    onTap: () => _navigateToCategory(context, category),
                    onEdit: () => _showEditCategoryDialog(context, category),
                    onDelete: () => _showDeleteConfirmation(context, category),
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}