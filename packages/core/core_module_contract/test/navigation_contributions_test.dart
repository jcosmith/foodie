import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter_test/flutter_test.dart';

final class _PlainModule extends FeatureModuleBase {
  const _PlainModule();

  @override
  String get moduleIdentifier => 'plain';
}

void main() {
  test('a module adds no tab, More entry or Lists segment unless it says so', () {
    const module = _PlainModule();
    expect(module.navigationDestination, isNull);
    expect(module.moreEntries, isEmpty);
    expect(module.listsSegments, isEmpty);
  });

  test('the shell owns Home, Lists and More; a domain tab is named after its domain', () {
    expect(ShellRoutePaths.home, '/home');
    expect(ShellRoutePaths.lists, '/lists');
    expect(ShellRoutePaths.more, '/more');
    expect(ShellRoutePaths.domainTab(StorageDomainIdentifier.freezer), '/freezer');
    expect(ShellRoutePaths.domainTab(StorageDomainIdentifier.household), '/household');
  });
}
