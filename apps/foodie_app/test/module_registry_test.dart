import 'dart:io';

import 'package:core_foundation/core_foundation.dart';
import 'package:core_module_contract/core_module_contract.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodie_app/src/application_version.dart';
import 'package:foodie_app/src/modules/module_registry.dart';
import 'package:go_router/go_router.dart';

final class _ModuleWithRoute extends FeatureModuleBase {
  const _ModuleWithRoute(this.moduleIdentifier, this.routePath);

  @override
  final String moduleIdentifier;
  final String routePath;

  @override
  List<RouteBase> buildRoutes() => [
    GoRoute(path: routePath, builder: (context, state) => const SizedBox()),
  ];
}

String _label(BuildContext context) => 'label';
String _numbered(BuildContext context, int number) => '$number';

/// A domain module with one kind and a small catalog, to build clashes from.
final class _DomainModule extends FeatureModuleBase {
  const _DomainModule(
    this.moduleIdentifier, {
    this.domain = 'testDomain',
    this.kindDomain,
    this.storageName = 'testKind',
    this.templateIdentifier = 'test.template',
    this.categoryKey = 'testCategory',
    this.productKey = 'testProduct',
    this.productCategoryKey,
  });

  @override
  final String moduleIdentifier;
  final String domain;
  final String? kindDomain;
  final String storageName;
  final String templateIdentifier;
  final String categoryKey;
  final String productKey;
  final String? productCategoryKey;

  @override
  ModuleAvailability get availability =>
      const ModuleAvailability.optional(isEnabledByDefault: true);

  @override
  StorageDomainContribution get storageDomain => StorageDomainContribution(
    identifier: StorageDomainIdentifier(domain),
    sortOrder: 10,
    iconEmoji: '📦',
    labelBuilder: _label,
    descriptionBuilder: _label,
    storedOnLabelBuilder: _label,
    countsDiscardsAsWaste: true,
  );

  @override
  List<StorageKindContribution> get storageKinds => [
    StorageKindContribution(
      storageName: storageName,
      domainIdentifier: StorageDomainIdentifier(kindDomain ?? domain),
      sortOrder: 10,
      iconEmoji: '📦',
      placeNameBuilder: _label,
      kindDescriptionBuilder: _label,
      compartmentNameBuilder: _numbered,
      compartmentCountBuilder: _numbered,
      addCompartmentLabelBuilder: _label,
      templates: [
        StorageTemplateContribution(
          identifier: templateIdentifier,
          sortOrder: 10,
          compartmentCount: 1,
          labelBuilder: _label,
        ),
      ],
    ),
  ];

  @override
  CatalogContribution get catalog => CatalogContribution(
    categories: [
      SeededCategoryContribution(
        catalogKey: categoryKey,
        domainIdentifier: StorageDomainIdentifier(domain),
        shelfLifeDays: 7,
        iconEmoji: '📦',
      ),
    ],
    products: [
      SeededProductContribution(
        catalogKey: productKey,
        categoryCatalogKey: productCategoryKey ?? categoryKey,
        canonicalUnit: QuantityUnit.piece,
        defaultPackageDisplayAmount: 1,
        iconEmoji: '📦',
      ),
    ],
    categoryNameBuilder: (locale, catalogKey) => null,
    productNameBuilder: (locale, catalogKey) => null,
  );
}

void main() {
  test('the registered modules are consistent', () {
    expect(() => verifyModuleRegistry(createRegisteredFeatureModules()), returnsNormally);
  });

  test('rejects duplicate module identifiers', () {
    expect(
      () => verifyModuleRegistry(const [
        _ModuleWithRoute('inventory', '/inventory'),
        _ModuleWithRoute('inventory', '/inventory/other'),
      ]),
      throwsA(isA<ModuleRegistryException>()),
    );
  });

  test('rejects routes outside the module prefix', () {
    expect(
      () => verifyModuleRegistry(const [_ModuleWithRoute('restock', '/shopping')]),
      throwsA(isA<ModuleRegistryException>()),
    );
    expect(
      () => verifyModuleRegistry(const [_ModuleWithRoute('restock', '/restocking')]),
      throwsA(isA<ModuleRegistryException>()),
    );
  });

  test('storage contributions must be unique and refer to known entries', () {
    const valid = _DomainModule('first');
    expect(() => verifyModuleRegistry(const [valid]), returnsNormally);
    expect(
      () => verifyModuleRegistry(const [
        valid,
        _DomainModule(
          'second',
          domain: 'other',
          storageName: 'otherKind',
          templateIdentifier: 'other.template',
          categoryKey: 'otherCategory',
          productKey: 'otherProduct',
          productCategoryKey: 'testCategory',
        ),
      ]),
      returnsNormally,
      reason: 'a product may live in another module\'s category',
    );
    for (final clash in const [
      _DomainModule('second', templateIdentifier: 'b', categoryKey: 'b', productKey: 'b'),
      _DomainModule(
        'second',
        domain: 'b',
        templateIdentifier: 'b',
        categoryKey: 'b',
        productKey: 'b',
      ),
      _DomainModule('second', domain: 'b', storageName: 'b', categoryKey: 'b', productKey: 'b'),
      _DomainModule(
        'second',
        domain: 'b',
        storageName: 'b',
        templateIdentifier: 'b',
        productKey: 'b',
      ),
      _DomainModule(
        'second',
        domain: 'b',
        storageName: 'b',
        templateIdentifier: 'b',
        categoryKey: 'b',
      ),
    ]) {
      expect(() => verifyModuleRegistry([valid, clash]), throwsA(isA<ModuleRegistryException>()));
    }
    expect(
      () => verifyModuleRegistry(const [_DomainModule('first', kindDomain: 'missing')]),
      throwsA(isA<ModuleRegistryException>()),
    );
    expect(
      () => verifyModuleRegistry(const [_DomainModule('first', productCategoryKey: 'missing')]),
      throwsA(isA<ModuleRegistryException>()),
    );
  });

  test('the application version matches pubspec.yaml', () {
    final pubspecText = File('pubspec.yaml').readAsStringSync();
    final versionMatch = RegExp(r'^version: ([0-9.]+)\+', multiLine: true).firstMatch(pubspecText);
    expect(versionMatch?.group(1), applicationVersion);
  });
}
