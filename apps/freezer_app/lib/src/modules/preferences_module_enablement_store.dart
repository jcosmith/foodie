import 'package:core_module_contract/core_module_contract.dart';
import 'package:core_preferences/core_preferences.dart';

/// Remembers which optional modules are switched on, one boolean preference
/// per module in the module's own namespace.
final class PreferencesModuleEnablementStore implements ModuleEnablementStore {
  const PreferencesModuleEnablementStore(this._preferencesStore);

  final PreferencesStore _preferencesStore;

  static PreferenceKey<bool> _enabledKeyFor(FeatureModule module) => PreferenceKey.boolean(
    moduleNamespace: module.moduleIdentifier,
    name: 'is_module_enabled',
    defaultValue: module.availability.isEnabledByDefault,
  );

  @override
  Stream<Set<String>> watchEnabledOptionalModuleIdentifiers(
    List<FeatureModule> optionalModules,
  ) async* {
    final enabledByIdentifier = <String, bool>{
      for (final module in optionalModules)
        module.moduleIdentifier: await _preferencesStore.read(_enabledKeyFor(module)),
    };
    Set<String> currentlyEnabled() => {
      for (final MapEntry(key: identifier, value: isEnabled) in enabledByIdentifier.entries)
        if (isEnabled) identifier,
    };
    yield currentlyEnabled();
    final changes = optionalModules.map(
      (module) => _preferencesStore
          .watch(_enabledKeyFor(module))
          .map((isEnabled) => (module.moduleIdentifier, isEnabled)),
    );
    await for (final (identifier, isEnabled) in _mergeStreams(changes)) {
      if (enabledByIdentifier[identifier] == isEnabled) continue;
      enabledByIdentifier[identifier] = isEnabled;
      yield currentlyEnabled();
    }
  }

  @override
  Future<void> setModuleEnabled(FeatureModule module, {required bool isEnabled}) =>
      _preferencesStore.write(_enabledKeyFor(module), isEnabled);

  static Stream<TValue> _mergeStreams<TValue>(Iterable<Stream<TValue>> streams) =>
      Stream.multi((controller) {
        final subscriptions = [
          for (final stream in streams) stream.listen(controller.add, onError: controller.addError),
        ];
        controller.onCancel = () async {
          for (final subscription in subscriptions) {
            await subscription.cancel();
          }
        };
      });
}
