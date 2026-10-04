import 'package:core_foundation/core_foundation.dart';
import 'package:test/test.dart';

void main() {
  group('StorageDomainIdentifier', () {
    test('is a value: equal text means the same domain', () {
      expect(const StorageDomainIdentifier('cellar'), const StorageDomainIdentifier('cellar'));
      expect(
        const StorageDomainIdentifier('cellar').hashCode,
        const StorageDomainIdentifier('cellar').hashCode,
      );
      expect(StorageDomainIdentifier.fridge, isNot(StorageDomainIdentifier.pantry));
    });

    test('names the four domains of the plan without making them a closed list', () {
      expect(StorageDomainIdentifier.freezer.value, 'freezer');
      expect(StorageDomainIdentifier.fridge.value, 'fridge');
      expect(StorageDomainIdentifier.pantry.value, 'pantry');
      expect(StorageDomainIdentifier.household.value, 'household');
      // Any other module can bring its own domain.
      expect(const StorageDomainIdentifier('wine_cellar').value, 'wine_cellar');
    });

    test('rejects an empty identifier', () {
      expect(() => StorageDomainIdentifier.parse(''), throwsArgumentError);
      expect(StorageDomainIdentifier.parse('pantry'), StorageDomainIdentifier.pantry);
    });

    test('prints its value', () {
      expect(StorageDomainIdentifier.household.toString(), 'household');
    });
  });
}
