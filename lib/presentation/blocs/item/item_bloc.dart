import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/items/delete_item.dart' as delete_uc;
import '../../../domain/usecases/items/get_item_by_id.dart' as get_by_id_uc;
import '../../../domain/usecases/items/get_items_by_category.dart' as usecase;
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final usecase.GetItemsByCategory _getItemsByCategory;
  final get_by_id_uc.GetItemById? _getItemById;
  final delete_uc.DeleteItem? _deleteItem;

  ItemBloc(
    this._getItemsByCategory, {
    get_by_id_uc.GetItemById? getItemById,
    delete_uc.DeleteItem? deleteItem,
  })  : _getItemById = getItemById,
        _deleteItem = deleteItem,
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
  }
}
