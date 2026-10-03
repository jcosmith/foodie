import 'package:meta/meta.dart';

/// Whether a module can be switched off by the user in the Config tab.
@immutable
final class ModuleAvailability {
  /// Core functionality that is always on.
  const ModuleAvailability.alwaysEnabled() : isOptional = false, isEnabledByDefault = true;

  /// An optional module; its contributions disappear without a restart when
  /// switched off.
  const ModuleAvailability.optional({required this.isEnabledByDefault}) : isOptional = true;

  final bool isOptional;
  final bool isEnabledByDefault;

  @override
  bool operator ==(Object other) =>
      other is ModuleAvailability &&
      other.isOptional == isOptional &&
      other.isEnabledByDefault == isEnabledByDefault;

  @override
  int get hashCode => Object.hash(isOptional, isEnabledByDefault);
}
