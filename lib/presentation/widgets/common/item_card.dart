import 'package:flutter/material.dart';
import '../../../domain/entities/item.dart';

/// Карточка элемента с постером и информацией.
class ItemCard extends StatelessWidget {
  final ItemEntity item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.posterUrl != null
                  ? Image.network(
                      item.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.movie),
                        );
                      },
                    )
                  : Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.movie),
                    ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '1',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}