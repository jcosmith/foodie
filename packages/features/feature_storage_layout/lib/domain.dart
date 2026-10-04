/// The pure Dart part of the storage layout's public API, for the domain
/// layers of other features (no Flutter, no Riverpod).
library;

export 'src/domain/compartment.dart' show Compartment, CompartmentIdentifier;
export 'src/domain/compartment_contents_port.dart';
export 'src/domain/compartment_display_name_resolver.dart';
export 'src/domain/layout_default_names.dart';
export 'src/domain/storage_kind.dart';
export 'src/domain/storage_layout.dart';
export 'src/domain/storage_layout_events.dart';
export 'src/domain/storage_place.dart';
export 'src/domain/storage_template.dart';
