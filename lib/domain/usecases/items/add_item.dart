import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

class AddItem {
  final ItemRepository _repository;

  AddItem(this._repository);

  Future<int> call({
    required int categoryId,
    required String title,
    String? description,
    String? posterPath,
    String? posterUrl,
    String? launchPath,
    String? launchArgs,
    ItemType itemType = ItemType.movie,
    int? year,
    double? rating,
    String? externalId,
    String? metadataJson,
  }) {
    return _repository.addItem(
      categoryId: categoryId,
      title: title,
      description: description,
      posterPath: posterPath,
      posterUrl: posterUrl,
      launchPath: launchPath,
      launchArgs: launchArgs,
      itemType: itemType,
      year: year,
      rating: rating,
      externalId: externalId,
      metadataJson: metadataJson,
    );
  }
}
