import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/usecases/items/add_item.dart' as add_uc;
import '../../../domain/usecases/items/delete_item.dart' as delete_uc;
import '../../../domain/usecases/items/get_item_by_id.dart' as get_by_id_uc;
import '../../../domain/usecases/items/get_items_by_category.dart' as usecase;
import '../../../domain/usecases/items/update_item.dart' as update_uc;
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final usecase.GetItemsByCategory _getItemsByCategory;
  final get_by_id_uc.GetItemById? _getItemById;
  final delete_uc.DeleteItem? _deleteItem;
  final add_uc.AddItem? _addItem;
  final update_uc.UpdateItem? _updateItem;

  ItemBloc(
    this._getItemsByCategory, {
    get_by_id_uc.GetItemById? getItemById,
    delete_uc.DeleteItem? deleteItem,
    add_uc.AddItem? addItem,
    update_uc.UpdateItem? updateItem,
  })  : _getItemById = getItemById,
        _deleteItem = deleteItem,
        _addItem = addItem,
        _updateItem = updateItem,
        super(const ItemInitial()) {
    on<GetItemsByCategoryEvent>((event, emit) async {
      try {
        final items = await _getItemsByCategory(
          categoryId: event.categoryId,
          offset: event.offset ?? 0,
          limit: event.limit ?? 50,
        );

        if (items.isNotEmpty) {
          emit(ItemLoaded(items: items));
        } else {
          emit(const ItemEmpty());
        }
      } catch (e) {
        emit(ItemError(message: e.toString()));
      }
    });

    on<GetItemByIdEvent>((event, emit) async {
      final useCase = _getItemById;
      if (useCase == null) {
        emit(const ItemError(message: 'GetItemById use case not provided'));
        return;
      }

      try {
        final item = await useCase(event.itemId);
        emit(SingleItemLoaded(item: item));
      } catch (e) {
        emit(ItemError(message: e.toString()));
      }
    });

    on<DeleteItemEvent>((event, emit) async {
      final useCase = _deleteItem;
      if (useCase == null) {
        emit(const ItemError(message: 'DeleteItem use case not provided'));
        return;
      }

      try {
        await useCase(event.itemId);
        emit(const ItemDeleted());
      } catch (e) {
        emit(ItemError(message: e.toString()));
      }
    });

    on<LoadItemForEditEvent>((event, emit) async {
      final useCase = _getItemById;
      if (useCase == null) {
        emit(const ItemFormError(message: 'GetItemById use case not provided'));
        return;
      }

      emit(const ItemFormLoading());

      try {
        final item = await useCase(event.itemId);
        emit(ItemFormLoaded(item: item));
      } catch (e) {
        emit(ItemFormError(message: e.toString()));
      }
    });

    on<SaveItemEvent>((event, emit) async {
      emit(const ItemFormLoading());

      try {
        if (event.itemId == null) {
          // Create new item
          final addUseCase = _addItem;
          if (addUseCase == null) {
            emit(const ItemFormError(message: 'AddItem use case not provided'));
            return;
          }

          await addUseCase(
            categoryId: event.categoryId,
            title: event.title,
            description: event.description,
            launchPath: event.launchPath,
            posterPath: event.posterPath,
            year: event.year,
            itemType: event.itemType,
          );
        } else {
          // Update existing item
          final updateUseCase = _updateItem;
          final getByIdUseCase = _getItemById;

          if (updateUseCase == null || getByIdUseCase == null) {
            emit(const ItemFormError(
                message: 'UpdateItem or GetItemById use case not provided'));
            return;
          }

          final existingItem = await getByIdUseCase(event.itemId!);
          final updatedItem = existingItem.copyWith(
            categoryId: event.categoryId,
            title: event.title,
            description: event.description ?? '',
            launchPath: event.launchPath ?? '',
            posterPath: event.posterPath,
            year: event.year ?? 0,
            itemType: event.itemType,
            updatedAt: DateTime.now(),
          );

          await updateUseCase(updatedItem);
        }

        emit(const ItemSaved());
      } catch (e) {
        emit(ItemFormError(message: e.toString()));
      }
    });
  }
}
