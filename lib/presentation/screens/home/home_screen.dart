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
  CategoryBloc? _bloc;

  void _showAddCategoryDialog(BuildContext parentContext) {
    final controller = TextEditingController();
    final bloc = _bloc ?? widget.categoryBloc ?? getIt<CategoryBloc>();
    
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
    showDialog<void>(
      context: parentContext,
      builder: (BuildContext dialogContext) {
        return _EditCategoryDialog(
          category: category,
          bloc: _bloc ?? widget.categoryBloc ?? getIt<CategoryBloc>(),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext parentContext, CategoryEntity category) {
    final bloc = _bloc ?? widget.categoryBloc ?? getIt<CategoryBloc>();
    
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
    // Use Builder to properly access context with BlocProvider
    return Builder(
      builder: (context) {
        // Try to get bloc from context first (for tests with BlocProvider.value)
        CategoryBloc bloc;
        bool isBlocFromContext = false;
        try {
          bloc = context.read<CategoryBloc>();
          _bloc = bloc;
          isBlocFromContext = true;
        } catch (_) {
          bloc = widget.categoryBloc ?? getIt<CategoryBloc>();
        }

        Widget buildScaffold() {
          return Scaffold(
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
          );
        }

        // If bloc is already in context, wrap with BlocProvider.value so BlocBuilder can find it
        if (isBlocFromContext) {
          return BlocProvider<CategoryBloc>.value(
            value: bloc,
            child: buildScaffold(),
          );
        }

        // Otherwise, provide the bloc with create
        return BlocProvider(
          create: (_) => bloc..add(LoadCategories()),
          child: buildScaffold(),
        );
      },
    );
  }
}

class _EditCategoryDialog extends StatefulWidget {
  final CategoryEntity category;
  final CategoryBloc bloc;

  const _EditCategoryDialog({
    required this.category,
    required this.bloc,
  });

  @override
  State<_EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<_EditCategoryDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    final newName = _controller.text.trim();

    // Validate empty name
    if (newName.isEmpty) {
      setState(() {
        _errorText = 'Название не может быть пустым';
      });
      return;
    }

    // Check if name hasn't changed
    if (newName == widget.category.name) {
      Navigator.of(context).pop();
      return;
    }

    // Check for duplicates against current categories
    final currentState = widget.bloc.state;
    if (currentState is CategoryLoaded) {
      final exists = currentState.categories.any(
        (c) => c.name.toLowerCase() == newName.toLowerCase() && c.id != widget.category.id,
      );
      if (exists) {
        setState(() {
          _errorText = 'Категория с таким названием уже существует';
        });
        return;
      }
    }

    // Dispatch update event
    widget.bloc.add(
      UpdateCategoryEvent(
        categoryId: widget.category.id,
        name: newName,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать категорию'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: 'Название',
          hintText: 'Введите название категории',
          errorText: _errorText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: _onSave,
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}