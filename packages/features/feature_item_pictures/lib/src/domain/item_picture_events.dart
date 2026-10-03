import 'package:core_events/core_events.dart';

import 'item_picture.dart';

/// A picture was attached to a product or a stock batch, possibly replacing
/// an earlier one.
final class ItemPictureAttached extends DomainEvent {
  const ItemPictureAttached({
    required this.itemPictureIdentifier,
    required this.owner,
    required super.occurredAt,
  });

  final ItemPictureIdentifier itemPictureIdentifier;
  final ItemPictureOwner owner;
}

/// A picture was removed by the user or because its item went away.
final class ItemPictureRemoved extends DomainEvent {
  const ItemPictureRemoved({required this.owner, required super.occurredAt});

  final ItemPictureOwner owner;
}
