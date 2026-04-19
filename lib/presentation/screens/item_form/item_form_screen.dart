import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/item.dart';
import '../../blocs/category/category_bloc.dart';
import '../../blocs/category/category_event.dart';
import '../../blocs/category/category_state.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../widgets/file_picker_button.dart';

class ItemFormScreen extends StatefulWidget {
  final String? itemId;
  final int? initialCategoryId;

  const ItemFormScreen({
    super.key,
    this.itemId,
    this.initialCategoryId,
  });

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();

  int? _selectedCategoryId;
  ItemType _selectedItemType = ItemType.movie;
  String? _filePath;
  String? _posterPath;
  bool _isLoading = false;

  bool get _isEditing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;

    if (_isEditing) {
      context.read<ItemBloc>().add(LoadItemForEditEvent(int.parse(widget.itemId!)));
    }

    // Load categories
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onItemBlocStateChanged(BuildContext context, ItemState state) {
    if (state is ItemFormLoaded) {
      setState(() {
        _isLoading = false;
        if (state.item != null) {
          final item = state.item!;
          _titleController.text = item.title;
          _descriptionController.text = item.description;
          _yearController.text = item.year > 0 ? item.year.toString() : '';
          _selectedCategoryId = item.categoryId;
          _selectedItemType = item.itemType;
          _filePath = item.launchPath.isNotEmpty ? item.launchPath : null;
          _posterPath = item.posterPath;
        }
      });
    } else if (state is ItemFormLoading) {
      setState(() => _isLoading = true);
    } else if (state is ItemSaved) {
      Navigator.of(context).pop(true);
    } else if (state is ItemFormError) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Название обязательно';
    }
    return null;
  }

  String? _validateCategory(int? value) {
    if (value == null) {
      return 'Выберите категорию';
    }
    return null;
  }

  String? _validateYear(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Year is optional
    }
    final year = int.tryParse(value);
    if (year == null) {
      return 'Некорректный год';
    }
    final currentYear = DateTime.now().year;
    if (year < 1900 || year > currentYear + 1) {
      return 'Некорректный год';
    }
    return null;
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate file path separately (required field)
    if (_filePath == null || _filePath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите файл'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate file exists
    if (!File(_filePath!).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Файл не существует'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final yearText = _yearController.text.trim();
    final year = yearText.isNotEmpty ? int.parse(yearText) : null;

    context.read<ItemBloc>().add(SaveItemEvent(
          itemId: _isEditing ? int.parse(widget.itemId!) : null,
          categoryId: _selectedCategoryId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          launchPath: _filePath,
          posterPath: _posterPath,
          year: year,
          itemType: _selectedItemType,
        ));
  }

  void _cancel() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemBloc, ItemState>(
      listener: _onItemBlocStateChanged,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Редактировать элемент' : 'Добавить элемент'),
        ),
        body: _isLoading && _isEditing
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Название',
                          hintText: 'Введите название',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validateTitle,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Описание',
                          hintText: 'Введите описание (необязательно)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Year field
                      TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(
                          labelText: 'Год',
                          hintText: 'Например, 2024',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: _validateYear,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Category dropdown
                      BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          if (state is CategoryLoaded) {
                            return DropdownButtonFormField<int>(
                              value: _selectedCategoryId,
                              decoration: const InputDecoration(
                                labelText: 'Категория',
                                hintText: 'Выберите категорию',
                                border: OutlineInputBorder(),
                              ),
                              items: state.categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: _isLoading
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _selectedCategoryId = value;
                                      });
                                    },
                              validator: (value) => _validateCategory(value),
                            );
                          }
                          return DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Категория',
                              hintText: 'Загрузка...',
                              border: OutlineInputBorder(),
                            ),
                            items: [],
                            onChanged: null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Item type dropdown
                      DropdownButtonFormField<ItemType>(
                        value: _selectedItemType,
                        decoration: const InputDecoration(
                          labelText: 'Тип элемента',
                          border: OutlineInputBorder(),
                        ),
                        items: ItemType.values.map((type) {
                          String label;
                          switch (type) {
                            case ItemType.movie:
                              label = 'Фильм';
                              break;
                            case ItemType.tvShow:
                              label = 'Сериал';
                              break;
                            case ItemType.episode:
                              label = 'Эпизод';
                              break;
                          }
                          return DropdownMenuItem<ItemType>(
                            value: type,
                            child: Text(label),
                          );
                        }).toList(),
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedItemType = value;
                                  });
                                }
                              },
                      ),
                      const SizedBox(height: 24),

                      // File picker for launch path
                      FilePickerButton(
                        label: 'Файл для запуска',
                        selectedPath: _filePath,
                        onPathSelected: (path) {
                          setState(() {
                            _filePath = path;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // File picker for poster
                      FilePickerButton(
                        label: 'Постер (изображение)',
                        selectedPath: _posterPath,
                        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
                        onPathSelected: (path) {
                          setState(() {
                            _posterPath = path;
                          });
                        },
                      ),
                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveForm,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isEditing ? 'Сохранить' : 'Добавить'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isLoading ? null : _cancel,
                              icon: const Icon(Icons.cancel),
                              label: const Text('Отмена'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
