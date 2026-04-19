import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/items/get_items_by_category.dart';
import '../../../domain/entities/item.dart';
import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final GetItemsByCategory _getItemsByCategory;

  ItemBloc(this._getItemsByCategory) : super(const ItemInitial()) {
    on<GetItemsByCategory>((event, emit) async {
      try {
        final items = await _getItemsByCategory(
          categoryId: event.categoryId,
          offset: event.offset ?? 0,
          limit: event.limit ?? 50,
        );

        if (items.isNotEmpty) {
          emit(ItemLoaded(items: items));
        } else {
          emit(ItemEmpty());
        }
      } catch (e) {
        emit(ItemError(message: e.toString()));
      }
    });
  }
}
