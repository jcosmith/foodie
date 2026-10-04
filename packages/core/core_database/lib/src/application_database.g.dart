// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_database.dart';

// ignore_for_file: type=lint
class $PreferenceEntriesTable extends PreferenceEntries
    with TableInfo<$PreferenceEntriesTable, PreferenceEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _preferenceKeyMeta = const VerificationMeta(
    'preferenceKey',
  );
  @override
  late final GeneratedColumn<String> preferenceKey = GeneratedColumn<String>(
    'preference_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encodedValueMeta = const VerificationMeta(
    'encodedValue',
  );
  @override
  late final GeneratedColumn<String> encodedValue = GeneratedColumn<String>(
    'encoded_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    preferenceKey,
    encodedValue,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preference_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreferenceEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('preference_key')) {
      context.handle(
        _preferenceKeyMeta,
        preferenceKey.isAcceptableOrUnknown(
          data['preference_key']!,
          _preferenceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferenceKeyMeta);
    }
    if (data.containsKey('encoded_value')) {
      context.handle(
        _encodedValueMeta,
        encodedValue.isAcceptableOrUnknown(
          data['encoded_value']!,
          _encodedValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encodedValueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {preferenceKey};
  @override
  PreferenceEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceEntryRow(
      preferenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preference_key'],
      )!,
      encodedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encoded_value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PreferenceEntriesTable createAlias(String alias) {
    return $PreferenceEntriesTable(attachedDatabase, alias);
  }
}

class PreferenceEntryRow extends DataClass
    implements Insertable<PreferenceEntryRow> {
  final String preferenceKey;

  /// The value encoded as text by the preference's codec.
  final String encodedValue;
  final DateTime updatedAt;
  const PreferenceEntryRow({
    required this.preferenceKey,
    required this.encodedValue,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['preference_key'] = Variable<String>(preferenceKey);
    map['encoded_value'] = Variable<String>(encodedValue);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PreferenceEntriesCompanion toCompanion(bool nullToAbsent) {
    return PreferenceEntriesCompanion(
      preferenceKey: Value(preferenceKey),
      encodedValue: Value(encodedValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory PreferenceEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceEntryRow(
      preferenceKey: serializer.fromJson<String>(json['preferenceKey']),
      encodedValue: serializer.fromJson<String>(json['encodedValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'preferenceKey': serializer.toJson<String>(preferenceKey),
      'encodedValue': serializer.toJson<String>(encodedValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PreferenceEntryRow copyWith({
    String? preferenceKey,
    String? encodedValue,
    DateTime? updatedAt,
  }) => PreferenceEntryRow(
    preferenceKey: preferenceKey ?? this.preferenceKey,
    encodedValue: encodedValue ?? this.encodedValue,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PreferenceEntryRow copyWithCompanion(PreferenceEntriesCompanion data) {
    return PreferenceEntryRow(
      preferenceKey: data.preferenceKey.present
          ? data.preferenceKey.value
          : this.preferenceKey,
      encodedValue: data.encodedValue.present
          ? data.encodedValue.value
          : this.encodedValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceEntryRow(')
          ..write('preferenceKey: $preferenceKey, ')
          ..write('encodedValue: $encodedValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(preferenceKey, encodedValue, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceEntryRow &&
          other.preferenceKey == this.preferenceKey &&
          other.encodedValue == this.encodedValue &&
          other.updatedAt == this.updatedAt);
}

class PreferenceEntriesCompanion extends UpdateCompanion<PreferenceEntryRow> {
  final Value<String> preferenceKey;
  final Value<String> encodedValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PreferenceEntriesCompanion({
    this.preferenceKey = const Value.absent(),
    this.encodedValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenceEntriesCompanion.insert({
    required String preferenceKey,
    required String encodedValue,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : preferenceKey = Value(preferenceKey),
       encodedValue = Value(encodedValue),
       updatedAt = Value(updatedAt);
  static Insertable<PreferenceEntryRow> custom({
    Expression<String>? preferenceKey,
    Expression<String>? encodedValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (preferenceKey != null) 'preference_key': preferenceKey,
      if (encodedValue != null) 'encoded_value': encodedValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenceEntriesCompanion copyWith({
    Value<String>? preferenceKey,
    Value<String>? encodedValue,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PreferenceEntriesCompanion(
      preferenceKey: preferenceKey ?? this.preferenceKey,
      encodedValue: encodedValue ?? this.encodedValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (preferenceKey.present) {
      map['preference_key'] = Variable<String>(preferenceKey.value);
    }
    if (encodedValue.present) {
      map['encoded_value'] = Variable<String>(encodedValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceEntriesCompanion(')
          ..write('preferenceKey: $preferenceKey, ')
          ..write('encodedValue: $encodedValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SchemaMetadataEntriesTable extends SchemaMetadataEntries
    with TableInfo<$SchemaMetadataEntriesTable, SchemaMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMetadataEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _singletonIdentifierMeta =
      const VerificationMeta('singletonIdentifier');
  @override
  late final GeneratedColumn<int> singletonIdentifier = GeneratedColumn<int>(
    'singleton_identifier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastMigratedByApplicationVersionMeta =
      const VerificationMeta('lastMigratedByApplicationVersion');
  @override
  late final GeneratedColumn<String> lastMigratedByApplicationVersion =
      GeneratedColumn<String>(
        'last_migrated_by_application_version',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _migratedAtMeta = const VerificationMeta(
    'migratedAt',
  );
  @override
  late final GeneratedColumn<DateTime> migratedAt = GeneratedColumn<DateTime>(
    'migrated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    singletonIdentifier,
    schemaVersion,
    lastMigratedByApplicationVersion,
    migratedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchemaMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('singleton_identifier')) {
      context.handle(
        _singletonIdentifierMeta,
        singletonIdentifier.isAcceptableOrUnknown(
          data['singleton_identifier']!,
          _singletonIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('last_migrated_by_application_version')) {
      context.handle(
        _lastMigratedByApplicationVersionMeta,
        lastMigratedByApplicationVersion.isAcceptableOrUnknown(
          data['last_migrated_by_application_version']!,
          _lastMigratedByApplicationVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastMigratedByApplicationVersionMeta);
    }
    if (data.containsKey('migrated_at')) {
      context.handle(
        _migratedAtMeta,
        migratedAt.isAcceptableOrUnknown(data['migrated_at']!, _migratedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_migratedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {singletonIdentifier};
  @override
  SchemaMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaMetadataRow(
      singletonIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}singleton_identifier'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      lastMigratedByApplicationVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_migrated_by_application_version'],
      )!,
      migratedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}migrated_at'],
      )!,
    );
  }

  @override
  $SchemaMetadataEntriesTable createAlias(String alias) {
    return $SchemaMetadataEntriesTable(attachedDatabase, alias);
  }
}

class SchemaMetadataRow extends DataClass
    implements Insertable<SchemaMetadataRow> {
  /// Always 1; the table holds a single row.
  final int singletonIdentifier;
  final int schemaVersion;
  final String lastMigratedByApplicationVersion;
  final DateTime migratedAt;
  const SchemaMetadataRow({
    required this.singletonIdentifier,
    required this.schemaVersion,
    required this.lastMigratedByApplicationVersion,
    required this.migratedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['singleton_identifier'] = Variable<int>(singletonIdentifier);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['last_migrated_by_application_version'] = Variable<String>(
      lastMigratedByApplicationVersion,
    );
    map['migrated_at'] = Variable<DateTime>(migratedAt);
    return map;
  }

  SchemaMetadataEntriesCompanion toCompanion(bool nullToAbsent) {
    return SchemaMetadataEntriesCompanion(
      singletonIdentifier: Value(singletonIdentifier),
      schemaVersion: Value(schemaVersion),
      lastMigratedByApplicationVersion: Value(lastMigratedByApplicationVersion),
      migratedAt: Value(migratedAt),
    );
  }

  factory SchemaMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaMetadataRow(
      singletonIdentifier: serializer.fromJson<int>(
        json['singletonIdentifier'],
      ),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      lastMigratedByApplicationVersion: serializer.fromJson<String>(
        json['lastMigratedByApplicationVersion'],
      ),
      migratedAt: serializer.fromJson<DateTime>(json['migratedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'singletonIdentifier': serializer.toJson<int>(singletonIdentifier),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'lastMigratedByApplicationVersion': serializer.toJson<String>(
        lastMigratedByApplicationVersion,
      ),
      'migratedAt': serializer.toJson<DateTime>(migratedAt),
    };
  }

  SchemaMetadataRow copyWith({
    int? singletonIdentifier,
    int? schemaVersion,
    String? lastMigratedByApplicationVersion,
    DateTime? migratedAt,
  }) => SchemaMetadataRow(
    singletonIdentifier: singletonIdentifier ?? this.singletonIdentifier,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    lastMigratedByApplicationVersion:
        lastMigratedByApplicationVersion ??
        this.lastMigratedByApplicationVersion,
    migratedAt: migratedAt ?? this.migratedAt,
  );
  SchemaMetadataRow copyWithCompanion(SchemaMetadataEntriesCompanion data) {
    return SchemaMetadataRow(
      singletonIdentifier: data.singletonIdentifier.present
          ? data.singletonIdentifier.value
          : this.singletonIdentifier,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      lastMigratedByApplicationVersion:
          data.lastMigratedByApplicationVersion.present
          ? data.lastMigratedByApplicationVersion.value
          : this.lastMigratedByApplicationVersion,
      migratedAt: data.migratedAt.present
          ? data.migratedAt.value
          : this.migratedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetadataRow(')
          ..write('singletonIdentifier: $singletonIdentifier, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write(
            'lastMigratedByApplicationVersion: $lastMigratedByApplicationVersion, ',
          )
          ..write('migratedAt: $migratedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    singletonIdentifier,
    schemaVersion,
    lastMigratedByApplicationVersion,
    migratedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaMetadataRow &&
          other.singletonIdentifier == this.singletonIdentifier &&
          other.schemaVersion == this.schemaVersion &&
          other.lastMigratedByApplicationVersion ==
              this.lastMigratedByApplicationVersion &&
          other.migratedAt == this.migratedAt);
}

class SchemaMetadataEntriesCompanion
    extends UpdateCompanion<SchemaMetadataRow> {
  final Value<int> singletonIdentifier;
  final Value<int> schemaVersion;
  final Value<String> lastMigratedByApplicationVersion;
  final Value<DateTime> migratedAt;
  const SchemaMetadataEntriesCompanion({
    this.singletonIdentifier = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.lastMigratedByApplicationVersion = const Value.absent(),
    this.migratedAt = const Value.absent(),
  });
  SchemaMetadataEntriesCompanion.insert({
    this.singletonIdentifier = const Value.absent(),
    required int schemaVersion,
    required String lastMigratedByApplicationVersion,
    required DateTime migratedAt,
  }) : schemaVersion = Value(schemaVersion),
       lastMigratedByApplicationVersion = Value(
         lastMigratedByApplicationVersion,
       ),
       migratedAt = Value(migratedAt);
  static Insertable<SchemaMetadataRow> custom({
    Expression<int>? singletonIdentifier,
    Expression<int>? schemaVersion,
    Expression<String>? lastMigratedByApplicationVersion,
    Expression<DateTime>? migratedAt,
  }) {
    return RawValuesInsertable({
      if (singletonIdentifier != null)
        'singleton_identifier': singletonIdentifier,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (lastMigratedByApplicationVersion != null)
        'last_migrated_by_application_version':
            lastMigratedByApplicationVersion,
      if (migratedAt != null) 'migrated_at': migratedAt,
    });
  }

  SchemaMetadataEntriesCompanion copyWith({
    Value<int>? singletonIdentifier,
    Value<int>? schemaVersion,
    Value<String>? lastMigratedByApplicationVersion,
    Value<DateTime>? migratedAt,
  }) {
    return SchemaMetadataEntriesCompanion(
      singletonIdentifier: singletonIdentifier ?? this.singletonIdentifier,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      lastMigratedByApplicationVersion:
          lastMigratedByApplicationVersion ??
          this.lastMigratedByApplicationVersion,
      migratedAt: migratedAt ?? this.migratedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (singletonIdentifier.present) {
      map['singleton_identifier'] = Variable<int>(singletonIdentifier.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (lastMigratedByApplicationVersion.present) {
      map['last_migrated_by_application_version'] = Variable<String>(
        lastMigratedByApplicationVersion.value,
      );
    }
    if (migratedAt.present) {
      map['migrated_at'] = Variable<DateTime>(migratedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetadataEntriesCompanion(')
          ..write('singletonIdentifier: $singletonIdentifier, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write(
            'lastMigratedByApplicationVersion: $lastMigratedByApplicationVersion, ',
          )
          ..write('migratedAt: $migratedAt')
          ..write(')'))
        .toString();
  }
}

class $StoragePlacesTable extends StoragePlaces
    with TableInfo<$StoragePlacesTable, StoragePlaceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoragePlacesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storagePlaceIdentifierMeta =
      const VerificationMeta('storagePlaceIdentifier');
  @override
  late final GeneratedColumn<String> storagePlaceIdentifier =
      GeneratedColumn<String>(
        'storage_place_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _defaultNameKeyMeta = const VerificationMeta(
    'defaultNameKey',
  );
  @override
  late final GeneratedColumn<String> defaultNameKey = GeneratedColumn<String>(
    'default_name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _storageKindMeta = const VerificationMeta(
    'storageKind',
  );
  @override
  late final GeneratedColumn<String> storageKind = GeneratedColumn<String>(
    'storage_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    storagePlaceIdentifier,
    defaultNameKey,
    customName,
    storageKind,
    sortOrder,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'storage_places';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoragePlaceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('storage_place_identifier')) {
      context.handle(
        _storagePlaceIdentifierMeta,
        storagePlaceIdentifier.isAcceptableOrUnknown(
          data['storage_place_identifier']!,
          _storagePlaceIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePlaceIdentifierMeta);
    }
    if (data.containsKey('default_name_key')) {
      context.handle(
        _defaultNameKeyMeta,
        defaultNameKey.isAcceptableOrUnknown(
          data['default_name_key']!,
          _defaultNameKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultNameKeyMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('storage_kind')) {
      context.handle(
        _storageKindMeta,
        storageKind.isAcceptableOrUnknown(
          data['storage_kind']!,
          _storageKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageKindMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {storagePlaceIdentifier};
  @override
  StoragePlaceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoragePlaceRow(
      storagePlaceIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_place_identifier'],
      )!,
      defaultNameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_name_key'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      storageKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_kind'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StoragePlacesTable createAlias(String alias) {
    return $StoragePlacesTable(attachedDatabase, alias);
  }
}

class StoragePlaceRow extends DataClass implements Insertable<StoragePlaceRow> {
  final String storagePlaceIdentifier;

  /// Translation key of the default name, used until the user renames it.
  final String defaultNameKey;
  final String? customName;

  /// The stored name of a storage kind contributed by a domain module, such
  /// as `upright`, `chest` or `fridgeFreezerCompartment`.
  final String storageKind;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  const StoragePlaceRow({
    required this.storagePlaceIdentifier,
    required this.defaultNameKey,
    this.customName,
    required this.storageKind,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['storage_place_identifier'] = Variable<String>(storagePlaceIdentifier);
    map['default_name_key'] = Variable<String>(defaultNameKey);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['storage_kind'] = Variable<String>(storageKind);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StoragePlacesCompanion toCompanion(bool nullToAbsent) {
    return StoragePlacesCompanion(
      storagePlaceIdentifier: Value(storagePlaceIdentifier),
      defaultNameKey: Value(defaultNameKey),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      storageKind: Value(storageKind),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory StoragePlaceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoragePlaceRow(
      storagePlaceIdentifier: serializer.fromJson<String>(
        json['storagePlaceIdentifier'],
      ),
      defaultNameKey: serializer.fromJson<String>(json['defaultNameKey']),
      customName: serializer.fromJson<String?>(json['customName']),
      storageKind: serializer.fromJson<String>(json['storageKind']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storagePlaceIdentifier': serializer.toJson<String>(
        storagePlaceIdentifier,
      ),
      'defaultNameKey': serializer.toJson<String>(defaultNameKey),
      'customName': serializer.toJson<String?>(customName),
      'storageKind': serializer.toJson<String>(storageKind),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StoragePlaceRow copyWith({
    String? storagePlaceIdentifier,
    String? defaultNameKey,
    Value<String?> customName = const Value.absent(),
    String? storageKind,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
  }) => StoragePlaceRow(
    storagePlaceIdentifier:
        storagePlaceIdentifier ?? this.storagePlaceIdentifier,
    defaultNameKey: defaultNameKey ?? this.defaultNameKey,
    customName: customName.present ? customName.value : this.customName,
    storageKind: storageKind ?? this.storageKind,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  StoragePlaceRow copyWithCompanion(StoragePlacesCompanion data) {
    return StoragePlaceRow(
      storagePlaceIdentifier: data.storagePlaceIdentifier.present
          ? data.storagePlaceIdentifier.value
          : this.storagePlaceIdentifier,
      defaultNameKey: data.defaultNameKey.present
          ? data.defaultNameKey.value
          : this.defaultNameKey,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      storageKind: data.storageKind.present
          ? data.storageKind.value
          : this.storageKind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoragePlaceRow(')
          ..write('storagePlaceIdentifier: $storagePlaceIdentifier, ')
          ..write('defaultNameKey: $defaultNameKey, ')
          ..write('customName: $customName, ')
          ..write('storageKind: $storageKind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    storagePlaceIdentifier,
    defaultNameKey,
    customName,
    storageKind,
    sortOrder,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoragePlaceRow &&
          other.storagePlaceIdentifier == this.storagePlaceIdentifier &&
          other.defaultNameKey == this.defaultNameKey &&
          other.customName == this.customName &&
          other.storageKind == this.storageKind &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class StoragePlacesCompanion extends UpdateCompanion<StoragePlaceRow> {
  final Value<String> storagePlaceIdentifier;
  final Value<String> defaultNameKey;
  final Value<String?> customName;
  final Value<String> storageKind;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StoragePlacesCompanion({
    this.storagePlaceIdentifier = const Value.absent(),
    this.defaultNameKey = const Value.absent(),
    this.customName = const Value.absent(),
    this.storageKind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoragePlacesCompanion.insert({
    required String storagePlaceIdentifier,
    required String defaultNameKey,
    this.customName = const Value.absent(),
    required String storageKind,
    required int sortOrder,
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : storagePlaceIdentifier = Value(storagePlaceIdentifier),
       defaultNameKey = Value(defaultNameKey),
       storageKind = Value(storageKind),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<StoragePlaceRow> custom({
    Expression<String>? storagePlaceIdentifier,
    Expression<String>? defaultNameKey,
    Expression<String>? customName,
    Expression<String>? storageKind,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storagePlaceIdentifier != null)
        'storage_place_identifier': storagePlaceIdentifier,
      if (defaultNameKey != null) 'default_name_key': defaultNameKey,
      if (customName != null) 'custom_name': customName,
      if (storageKind != null) 'storage_kind': storageKind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoragePlacesCompanion copyWith({
    Value<String>? storagePlaceIdentifier,
    Value<String>? defaultNameKey,
    Value<String?>? customName,
    Value<String>? storageKind,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StoragePlacesCompanion(
      storagePlaceIdentifier:
          storagePlaceIdentifier ?? this.storagePlaceIdentifier,
      defaultNameKey: defaultNameKey ?? this.defaultNameKey,
      customName: customName ?? this.customName,
      storageKind: storageKind ?? this.storageKind,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storagePlaceIdentifier.present) {
      map['storage_place_identifier'] = Variable<String>(
        storagePlaceIdentifier.value,
      );
    }
    if (defaultNameKey.present) {
      map['default_name_key'] = Variable<String>(defaultNameKey.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (storageKind.present) {
      map['storage_kind'] = Variable<String>(storageKind.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoragePlacesCompanion(')
          ..write('storagePlaceIdentifier: $storagePlaceIdentifier, ')
          ..write('defaultNameKey: $defaultNameKey, ')
          ..write('customName: $customName, ')
          ..write('storageKind: $storageKind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompartmentsTable extends Compartments
    with TableInfo<$CompartmentsTable, CompartmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompartmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _compartmentIdentifierMeta =
      const VerificationMeta('compartmentIdentifier');
  @override
  late final GeneratedColumn<String> compartmentIdentifier =
      GeneratedColumn<String>(
        'compartment_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _storagePlaceIdentifierMeta =
      const VerificationMeta('storagePlaceIdentifier');
  @override
  late final GeneratedColumn<String> storagePlaceIdentifier =
      GeneratedColumn<String>(
        'storage_place_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES storage_places (storage_place_identifier)',
        ),
      );
  static const VerificationMeta _defaultNumberMeta = const VerificationMeta(
    'defaultNumber',
  );
  @override
  late final GeneratedColumn<int> defaultNumber = GeneratedColumn<int>(
    'default_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorTagIndexMeta = const VerificationMeta(
    'colorTagIndex',
  );
  @override
  late final GeneratedColumn<int> colorTagIndex = GeneratedColumn<int>(
    'color_tag_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    compartmentIdentifier,
    storagePlaceIdentifier,
    defaultNumber,
    customName,
    colorTagIndex,
    sortOrder,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'compartments';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompartmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('compartment_identifier')) {
      context.handle(
        _compartmentIdentifierMeta,
        compartmentIdentifier.isAcceptableOrUnknown(
          data['compartment_identifier']!,
          _compartmentIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compartmentIdentifierMeta);
    }
    if (data.containsKey('storage_place_identifier')) {
      context.handle(
        _storagePlaceIdentifierMeta,
        storagePlaceIdentifier.isAcceptableOrUnknown(
          data['storage_place_identifier']!,
          _storagePlaceIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePlaceIdentifierMeta);
    }
    if (data.containsKey('default_number')) {
      context.handle(
        _defaultNumberMeta,
        defaultNumber.isAcceptableOrUnknown(
          data['default_number']!,
          _defaultNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultNumberMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('color_tag_index')) {
      context.handle(
        _colorTagIndexMeta,
        colorTagIndex.isAcceptableOrUnknown(
          data['color_tag_index']!,
          _colorTagIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_colorTagIndexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {compartmentIdentifier};
  @override
  CompartmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompartmentRow(
      compartmentIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compartment_identifier'],
      )!,
      storagePlaceIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_place_identifier'],
      )!,
      defaultNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_number'],
      )!,
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      colorTagIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_tag_index'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CompartmentsTable createAlias(String alias) {
    return $CompartmentsTable(attachedDatabase, alias);
  }
}

class CompartmentRow extends DataClass implements Insertable<CompartmentRow> {
  final String compartmentIdentifier;
  final String storagePlaceIdentifier;

  /// The number in the default name "Drawer {number}"; stays fixed when reordering.
  final int defaultNumber;
  final String? customName;

  /// Index into the design system's compartment colour palette.
  final int colorTagIndex;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  const CompartmentRow({
    required this.compartmentIdentifier,
    required this.storagePlaceIdentifier,
    required this.defaultNumber,
    this.customName,
    required this.colorTagIndex,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['compartment_identifier'] = Variable<String>(compartmentIdentifier);
    map['storage_place_identifier'] = Variable<String>(storagePlaceIdentifier);
    map['default_number'] = Variable<int>(defaultNumber);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['color_tag_index'] = Variable<int>(colorTagIndex);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CompartmentsCompanion toCompanion(bool nullToAbsent) {
    return CompartmentsCompanion(
      compartmentIdentifier: Value(compartmentIdentifier),
      storagePlaceIdentifier: Value(storagePlaceIdentifier),
      defaultNumber: Value(defaultNumber),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      colorTagIndex: Value(colorTagIndex),
      sortOrder: Value(sortOrder),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory CompartmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompartmentRow(
      compartmentIdentifier: serializer.fromJson<String>(
        json['compartmentIdentifier'],
      ),
      storagePlaceIdentifier: serializer.fromJson<String>(
        json['storagePlaceIdentifier'],
      ),
      defaultNumber: serializer.fromJson<int>(json['defaultNumber']),
      customName: serializer.fromJson<String?>(json['customName']),
      colorTagIndex: serializer.fromJson<int>(json['colorTagIndex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'compartmentIdentifier': serializer.toJson<String>(compartmentIdentifier),
      'storagePlaceIdentifier': serializer.toJson<String>(
        storagePlaceIdentifier,
      ),
      'defaultNumber': serializer.toJson<int>(defaultNumber),
      'customName': serializer.toJson<String?>(customName),
      'colorTagIndex': serializer.toJson<int>(colorTagIndex),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CompartmentRow copyWith({
    String? compartmentIdentifier,
    String? storagePlaceIdentifier,
    int? defaultNumber,
    Value<String?> customName = const Value.absent(),
    int? colorTagIndex,
    int? sortOrder,
    bool? isArchived,
    DateTime? createdAt,
  }) => CompartmentRow(
    compartmentIdentifier: compartmentIdentifier ?? this.compartmentIdentifier,
    storagePlaceIdentifier:
        storagePlaceIdentifier ?? this.storagePlaceIdentifier,
    defaultNumber: defaultNumber ?? this.defaultNumber,
    customName: customName.present ? customName.value : this.customName,
    colorTagIndex: colorTagIndex ?? this.colorTagIndex,
    sortOrder: sortOrder ?? this.sortOrder,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  CompartmentRow copyWithCompanion(CompartmentsCompanion data) {
    return CompartmentRow(
      compartmentIdentifier: data.compartmentIdentifier.present
          ? data.compartmentIdentifier.value
          : this.compartmentIdentifier,
      storagePlaceIdentifier: data.storagePlaceIdentifier.present
          ? data.storagePlaceIdentifier.value
          : this.storagePlaceIdentifier,
      defaultNumber: data.defaultNumber.present
          ? data.defaultNumber.value
          : this.defaultNumber,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      colorTagIndex: data.colorTagIndex.present
          ? data.colorTagIndex.value
          : this.colorTagIndex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompartmentRow(')
          ..write('compartmentIdentifier: $compartmentIdentifier, ')
          ..write('storagePlaceIdentifier: $storagePlaceIdentifier, ')
          ..write('defaultNumber: $defaultNumber, ')
          ..write('customName: $customName, ')
          ..write('colorTagIndex: $colorTagIndex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    compartmentIdentifier,
    storagePlaceIdentifier,
    defaultNumber,
    customName,
    colorTagIndex,
    sortOrder,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompartmentRow &&
          other.compartmentIdentifier == this.compartmentIdentifier &&
          other.storagePlaceIdentifier == this.storagePlaceIdentifier &&
          other.defaultNumber == this.defaultNumber &&
          other.customName == this.customName &&
          other.colorTagIndex == this.colorTagIndex &&
          other.sortOrder == this.sortOrder &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class CompartmentsCompanion extends UpdateCompanion<CompartmentRow> {
  final Value<String> compartmentIdentifier;
  final Value<String> storagePlaceIdentifier;
  final Value<int> defaultNumber;
  final Value<String?> customName;
  final Value<int> colorTagIndex;
  final Value<int> sortOrder;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CompartmentsCompanion({
    this.compartmentIdentifier = const Value.absent(),
    this.storagePlaceIdentifier = const Value.absent(),
    this.defaultNumber = const Value.absent(),
    this.customName = const Value.absent(),
    this.colorTagIndex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompartmentsCompanion.insert({
    required String compartmentIdentifier,
    required String storagePlaceIdentifier,
    required int defaultNumber,
    this.customName = const Value.absent(),
    required int colorTagIndex,
    required int sortOrder,
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : compartmentIdentifier = Value(compartmentIdentifier),
       storagePlaceIdentifier = Value(storagePlaceIdentifier),
       defaultNumber = Value(defaultNumber),
       colorTagIndex = Value(colorTagIndex),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt);
  static Insertable<CompartmentRow> custom({
    Expression<String>? compartmentIdentifier,
    Expression<String>? storagePlaceIdentifier,
    Expression<int>? defaultNumber,
    Expression<String>? customName,
    Expression<int>? colorTagIndex,
    Expression<int>? sortOrder,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (compartmentIdentifier != null)
        'compartment_identifier': compartmentIdentifier,
      if (storagePlaceIdentifier != null)
        'storage_place_identifier': storagePlaceIdentifier,
      if (defaultNumber != null) 'default_number': defaultNumber,
      if (customName != null) 'custom_name': customName,
      if (colorTagIndex != null) 'color_tag_index': colorTagIndex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompartmentsCompanion copyWith({
    Value<String>? compartmentIdentifier,
    Value<String>? storagePlaceIdentifier,
    Value<int>? defaultNumber,
    Value<String?>? customName,
    Value<int>? colorTagIndex,
    Value<int>? sortOrder,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CompartmentsCompanion(
      compartmentIdentifier:
          compartmentIdentifier ?? this.compartmentIdentifier,
      storagePlaceIdentifier:
          storagePlaceIdentifier ?? this.storagePlaceIdentifier,
      defaultNumber: defaultNumber ?? this.defaultNumber,
      customName: customName ?? this.customName,
      colorTagIndex: colorTagIndex ?? this.colorTagIndex,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (compartmentIdentifier.present) {
      map['compartment_identifier'] = Variable<String>(
        compartmentIdentifier.value,
      );
    }
    if (storagePlaceIdentifier.present) {
      map['storage_place_identifier'] = Variable<String>(
        storagePlaceIdentifier.value,
      );
    }
    if (defaultNumber.present) {
      map['default_number'] = Variable<int>(defaultNumber.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (colorTagIndex.present) {
      map['color_tag_index'] = Variable<int>(colorTagIndex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompartmentsCompanion(')
          ..write('compartmentIdentifier: $compartmentIdentifier, ')
          ..write('storagePlaceIdentifier: $storagePlaceIdentifier, ')
          ..write('defaultNumber: $defaultNumber, ')
          ..write('customName: $customName, ')
          ..write('colorTagIndex: $colorTagIndex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdentifierMeta =
      const VerificationMeta('categoryIdentifier');
  @override
  late final GeneratedColumn<String> categoryIdentifier =
      GeneratedColumn<String>(
        'category_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _catalogKeyMeta = const VerificationMeta(
    'catalogKey',
  );
  @override
  late final GeneratedColumn<String> catalogKey = GeneratedColumn<String>(
    'catalog_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendedMaximumStorageDaysMeta =
      const VerificationMeta('recommendedMaximumStorageDays');
  @override
  late final GeneratedColumn<int> recommendedMaximumStorageDays =
      GeneratedColumn<int>(
        'recommended_maximum_storage_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shelfLifeAfterOpeningDaysMeta =
      const VerificationMeta('shelfLifeAfterOpeningDays');
  @override
  late final GeneratedColumn<int> shelfLifeAfterOpeningDays =
      GeneratedColumn<int>(
        'shelf_life_after_opening_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _iconEmojiMeta = const VerificationMeta(
    'iconEmoji',
  );
  @override
  late final GeneratedColumn<String> iconEmoji = GeneratedColumn<String>(
    'icon_emoji',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storageDomainMeta = const VerificationMeta(
    'storageDomain',
  );
  @override
  late final GeneratedColumn<String> storageDomain = GeneratedColumn<String>(
    'storage_domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('freezer'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    categoryIdentifier,
    catalogKey,
    customName,
    recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays,
    iconEmoji,
    sortOrder,
    storageDomain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_identifier')) {
      context.handle(
        _categoryIdentifierMeta,
        categoryIdentifier.isAcceptableOrUnknown(
          data['category_identifier']!,
          _categoryIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryIdentifierMeta);
    }
    if (data.containsKey('catalog_key')) {
      context.handle(
        _catalogKeyMeta,
        catalogKey.isAcceptableOrUnknown(data['catalog_key']!, _catalogKeyMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('recommended_maximum_storage_days')) {
      context.handle(
        _recommendedMaximumStorageDaysMeta,
        recommendedMaximumStorageDays.isAcceptableOrUnknown(
          data['recommended_maximum_storage_days']!,
          _recommendedMaximumStorageDaysMeta,
        ),
      );
    }
    if (data.containsKey('shelf_life_after_opening_days')) {
      context.handle(
        _shelfLifeAfterOpeningDaysMeta,
        shelfLifeAfterOpeningDays.isAcceptableOrUnknown(
          data['shelf_life_after_opening_days']!,
          _shelfLifeAfterOpeningDaysMeta,
        ),
      );
    }
    if (data.containsKey('icon_emoji')) {
      context.handle(
        _iconEmojiMeta,
        iconEmoji.isAcceptableOrUnknown(data['icon_emoji']!, _iconEmojiMeta),
      );
    } else if (isInserting) {
      context.missing(_iconEmojiMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('storage_domain')) {
      context.handle(
        _storageDomainMeta,
        storageDomain.isAcceptableOrUnknown(
          data['storage_domain']!,
          _storageDomainMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryIdentifier};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      categoryIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_identifier'],
      )!,
      catalogKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_key'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      recommendedMaximumStorageDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recommended_maximum_storage_days'],
      ),
      shelfLifeAfterOpeningDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_life_after_opening_days'],
      ),
      iconEmoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_emoji'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      storageDomain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_domain'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String categoryIdentifier;

  /// Set for seeded categories (for example `vegetables`); the name is then
  /// translated until the user renames it.
  final String? catalogKey;
  final String? customName;

  /// The shelf life in days; `null` for things that keep no time, such as
  /// dish soap (allowed from schema version 9).
  final int? recommendedMaximumStorageDays;

  /// How long an opened package keeps, in days; `null` when opening makes
  /// no difference.
  final int? shelfLifeAfterOpeningDays;
  final String iconEmoji;
  final int sortOrder;

  /// The storage domain the category's products usually live in, such as
  /// `freezer` or `pantry`. Categories from before schema version 9 were all
  /// freezer categories.
  final String storageDomain;
  const CategoryRow({
    required this.categoryIdentifier,
    this.catalogKey,
    this.customName,
    this.recommendedMaximumStorageDays,
    this.shelfLifeAfterOpeningDays,
    required this.iconEmoji,
    required this.sortOrder,
    required this.storageDomain,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_identifier'] = Variable<String>(categoryIdentifier);
    if (!nullToAbsent || catalogKey != null) {
      map['catalog_key'] = Variable<String>(catalogKey);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    if (!nullToAbsent || recommendedMaximumStorageDays != null) {
      map['recommended_maximum_storage_days'] = Variable<int>(
        recommendedMaximumStorageDays,
      );
    }
    if (!nullToAbsent || shelfLifeAfterOpeningDays != null) {
      map['shelf_life_after_opening_days'] = Variable<int>(
        shelfLifeAfterOpeningDays,
      );
    }
    map['icon_emoji'] = Variable<String>(iconEmoji);
    map['sort_order'] = Variable<int>(sortOrder);
    map['storage_domain'] = Variable<String>(storageDomain);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      categoryIdentifier: Value(categoryIdentifier),
      catalogKey: catalogKey == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogKey),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      recommendedMaximumStorageDays:
          recommendedMaximumStorageDays == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedMaximumStorageDays),
      shelfLifeAfterOpeningDays:
          shelfLifeAfterOpeningDays == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLifeAfterOpeningDays),
      iconEmoji: Value(iconEmoji),
      sortOrder: Value(sortOrder),
      storageDomain: Value(storageDomain),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      categoryIdentifier: serializer.fromJson<String>(
        json['categoryIdentifier'],
      ),
      catalogKey: serializer.fromJson<String?>(json['catalogKey']),
      customName: serializer.fromJson<String?>(json['customName']),
      recommendedMaximumStorageDays: serializer.fromJson<int?>(
        json['recommendedMaximumStorageDays'],
      ),
      shelfLifeAfterOpeningDays: serializer.fromJson<int?>(
        json['shelfLifeAfterOpeningDays'],
      ),
      iconEmoji: serializer.fromJson<String>(json['iconEmoji']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      storageDomain: serializer.fromJson<String>(json['storageDomain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryIdentifier': serializer.toJson<String>(categoryIdentifier),
      'catalogKey': serializer.toJson<String?>(catalogKey),
      'customName': serializer.toJson<String?>(customName),
      'recommendedMaximumStorageDays': serializer.toJson<int?>(
        recommendedMaximumStorageDays,
      ),
      'shelfLifeAfterOpeningDays': serializer.toJson<int?>(
        shelfLifeAfterOpeningDays,
      ),
      'iconEmoji': serializer.toJson<String>(iconEmoji),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'storageDomain': serializer.toJson<String>(storageDomain),
    };
  }

  CategoryRow copyWith({
    String? categoryIdentifier,
    Value<String?> catalogKey = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    Value<int?> recommendedMaximumStorageDays = const Value.absent(),
    Value<int?> shelfLifeAfterOpeningDays = const Value.absent(),
    String? iconEmoji,
    int? sortOrder,
    String? storageDomain,
  }) => CategoryRow(
    categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
    catalogKey: catalogKey.present ? catalogKey.value : this.catalogKey,
    customName: customName.present ? customName.value : this.customName,
    recommendedMaximumStorageDays: recommendedMaximumStorageDays.present
        ? recommendedMaximumStorageDays.value
        : this.recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays.present
        ? shelfLifeAfterOpeningDays.value
        : this.shelfLifeAfterOpeningDays,
    iconEmoji: iconEmoji ?? this.iconEmoji,
    sortOrder: sortOrder ?? this.sortOrder,
    storageDomain: storageDomain ?? this.storageDomain,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      categoryIdentifier: data.categoryIdentifier.present
          ? data.categoryIdentifier.value
          : this.categoryIdentifier,
      catalogKey: data.catalogKey.present
          ? data.catalogKey.value
          : this.catalogKey,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      recommendedMaximumStorageDays: data.recommendedMaximumStorageDays.present
          ? data.recommendedMaximumStorageDays.value
          : this.recommendedMaximumStorageDays,
      shelfLifeAfterOpeningDays: data.shelfLifeAfterOpeningDays.present
          ? data.shelfLifeAfterOpeningDays.value
          : this.shelfLifeAfterOpeningDays,
      iconEmoji: data.iconEmoji.present ? data.iconEmoji.value : this.iconEmoji,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      storageDomain: data.storageDomain.present
          ? data.storageDomain.value
          : this.storageDomain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('categoryIdentifier: $categoryIdentifier, ')
          ..write('catalogKey: $catalogKey, ')
          ..write('customName: $customName, ')
          ..write(
            'recommendedMaximumStorageDays: $recommendedMaximumStorageDays, ',
          )
          ..write('shelfLifeAfterOpeningDays: $shelfLifeAfterOpeningDays, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('storageDomain: $storageDomain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    categoryIdentifier,
    catalogKey,
    customName,
    recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays,
    iconEmoji,
    sortOrder,
    storageDomain,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.categoryIdentifier == this.categoryIdentifier &&
          other.catalogKey == this.catalogKey &&
          other.customName == this.customName &&
          other.recommendedMaximumStorageDays ==
              this.recommendedMaximumStorageDays &&
          other.shelfLifeAfterOpeningDays == this.shelfLifeAfterOpeningDays &&
          other.iconEmoji == this.iconEmoji &&
          other.sortOrder == this.sortOrder &&
          other.storageDomain == this.storageDomain);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> categoryIdentifier;
  final Value<String?> catalogKey;
  final Value<String?> customName;
  final Value<int?> recommendedMaximumStorageDays;
  final Value<int?> shelfLifeAfterOpeningDays;
  final Value<String> iconEmoji;
  final Value<int> sortOrder;
  final Value<String> storageDomain;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.categoryIdentifier = const Value.absent(),
    this.catalogKey = const Value.absent(),
    this.customName = const Value.absent(),
    this.recommendedMaximumStorageDays = const Value.absent(),
    this.shelfLifeAfterOpeningDays = const Value.absent(),
    this.iconEmoji = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.storageDomain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String categoryIdentifier,
    this.catalogKey = const Value.absent(),
    this.customName = const Value.absent(),
    this.recommendedMaximumStorageDays = const Value.absent(),
    this.shelfLifeAfterOpeningDays = const Value.absent(),
    required String iconEmoji,
    required int sortOrder,
    this.storageDomain = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : categoryIdentifier = Value(categoryIdentifier),
       iconEmoji = Value(iconEmoji),
       sortOrder = Value(sortOrder);
  static Insertable<CategoryRow> custom({
    Expression<String>? categoryIdentifier,
    Expression<String>? catalogKey,
    Expression<String>? customName,
    Expression<int>? recommendedMaximumStorageDays,
    Expression<int>? shelfLifeAfterOpeningDays,
    Expression<String>? iconEmoji,
    Expression<int>? sortOrder,
    Expression<String>? storageDomain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryIdentifier != null) 'category_identifier': categoryIdentifier,
      if (catalogKey != null) 'catalog_key': catalogKey,
      if (customName != null) 'custom_name': customName,
      if (recommendedMaximumStorageDays != null)
        'recommended_maximum_storage_days': recommendedMaximumStorageDays,
      if (shelfLifeAfterOpeningDays != null)
        'shelf_life_after_opening_days': shelfLifeAfterOpeningDays,
      if (iconEmoji != null) 'icon_emoji': iconEmoji,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (storageDomain != null) 'storage_domain': storageDomain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? categoryIdentifier,
    Value<String?>? catalogKey,
    Value<String?>? customName,
    Value<int?>? recommendedMaximumStorageDays,
    Value<int?>? shelfLifeAfterOpeningDays,
    Value<String>? iconEmoji,
    Value<int>? sortOrder,
    Value<String>? storageDomain,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
      catalogKey: catalogKey ?? this.catalogKey,
      customName: customName ?? this.customName,
      recommendedMaximumStorageDays:
          recommendedMaximumStorageDays ?? this.recommendedMaximumStorageDays,
      shelfLifeAfterOpeningDays:
          shelfLifeAfterOpeningDays ?? this.shelfLifeAfterOpeningDays,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      sortOrder: sortOrder ?? this.sortOrder,
      storageDomain: storageDomain ?? this.storageDomain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryIdentifier.present) {
      map['category_identifier'] = Variable<String>(categoryIdentifier.value);
    }
    if (catalogKey.present) {
      map['catalog_key'] = Variable<String>(catalogKey.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (recommendedMaximumStorageDays.present) {
      map['recommended_maximum_storage_days'] = Variable<int>(
        recommendedMaximumStorageDays.value,
      );
    }
    if (shelfLifeAfterOpeningDays.present) {
      map['shelf_life_after_opening_days'] = Variable<int>(
        shelfLifeAfterOpeningDays.value,
      );
    }
    if (iconEmoji.present) {
      map['icon_emoji'] = Variable<String>(iconEmoji.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (storageDomain.present) {
      map['storage_domain'] = Variable<String>(storageDomain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('categoryIdentifier: $categoryIdentifier, ')
          ..write('catalogKey: $catalogKey, ')
          ..write('customName: $customName, ')
          ..write(
            'recommendedMaximumStorageDays: $recommendedMaximumStorageDays, ',
          )
          ..write('shelfLifeAfterOpeningDays: $shelfLifeAfterOpeningDays, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('storageDomain: $storageDomain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdentifierMeta = const VerificationMeta(
    'productIdentifier',
  );
  @override
  late final GeneratedColumn<String> productIdentifier =
      GeneratedColumn<String>(
        'product_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _categoryIdentifierMeta =
      const VerificationMeta('categoryIdentifier');
  @override
  late final GeneratedColumn<String> categoryIdentifier =
      GeneratedColumn<String>(
        'category_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES categories (category_identifier)',
        ),
      );
  static const VerificationMeta _catalogKeyMeta = const VerificationMeta(
    'catalogKey',
  );
  @override
  late final GeneratedColumn<String> catalogKey = GeneratedColumn<String>(
    'catalog_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _customNameMeta = const VerificationMeta(
    'customName',
  );
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
    'custom_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canonicalUnitMeta = const VerificationMeta(
    'canonicalUnit',
  );
  @override
  late final GeneratedColumn<String> canonicalUnit = GeneratedColumn<String>(
    'canonical_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultPackageQuantityMeta =
      const VerificationMeta('defaultPackageQuantity');
  @override
  late final GeneratedColumn<int> defaultPackageQuantity = GeneratedColumn<int>(
    'default_package_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendedMaximumStorageDaysMeta =
      const VerificationMeta('recommendedMaximumStorageDays');
  @override
  late final GeneratedColumn<int> recommendedMaximumStorageDays =
      GeneratedColumn<int>(
        'recommended_maximum_storage_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _shelfLifeAfterOpeningDaysMeta =
      const VerificationMeta('shelfLifeAfterOpeningDays');
  @override
  late final GeneratedColumn<int> shelfLifeAfterOpeningDays =
      GeneratedColumn<int>(
        'shelf_life_after_opening_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _iconEmojiMeta = const VerificationMeta(
    'iconEmoji',
  );
  @override
  late final GeneratedColumn<String> iconEmoji = GeneratedColumn<String>(
    'icon_emoji',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconImageMeta = const VerificationMeta(
    'iconImage',
  );
  @override
  late final GeneratedColumn<Uint8List> iconImage = GeneratedColumn<Uint8List>(
    'icon_image',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultCompartmentIdentifierMeta =
      const VerificationMeta('defaultCompartmentIdentifier');
  @override
  late final GeneratedColumn<String> defaultCompartmentIdentifier =
      GeneratedColumn<String>(
        'default_compartment_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES compartments (compartment_identifier)',
        ),
      );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productIdentifier,
    categoryIdentifier,
    catalogKey,
    customName,
    canonicalUnit,
    defaultPackageQuantity,
    recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays,
    iconEmoji,
    iconImage,
    defaultCompartmentIdentifier,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_identifier')) {
      context.handle(
        _productIdentifierMeta,
        productIdentifier.isAcceptableOrUnknown(
          data['product_identifier']!,
          _productIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productIdentifierMeta);
    }
    if (data.containsKey('category_identifier')) {
      context.handle(
        _categoryIdentifierMeta,
        categoryIdentifier.isAcceptableOrUnknown(
          data['category_identifier']!,
          _categoryIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryIdentifierMeta);
    }
    if (data.containsKey('catalog_key')) {
      context.handle(
        _catalogKeyMeta,
        catalogKey.isAcceptableOrUnknown(data['catalog_key']!, _catalogKeyMeta),
      );
    }
    if (data.containsKey('custom_name')) {
      context.handle(
        _customNameMeta,
        customName.isAcceptableOrUnknown(data['custom_name']!, _customNameMeta),
      );
    }
    if (data.containsKey('canonical_unit')) {
      context.handle(
        _canonicalUnitMeta,
        canonicalUnit.isAcceptableOrUnknown(
          data['canonical_unit']!,
          _canonicalUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalUnitMeta);
    }
    if (data.containsKey('default_package_quantity')) {
      context.handle(
        _defaultPackageQuantityMeta,
        defaultPackageQuantity.isAcceptableOrUnknown(
          data['default_package_quantity']!,
          _defaultPackageQuantityMeta,
        ),
      );
    }
    if (data.containsKey('recommended_maximum_storage_days')) {
      context.handle(
        _recommendedMaximumStorageDaysMeta,
        recommendedMaximumStorageDays.isAcceptableOrUnknown(
          data['recommended_maximum_storage_days']!,
          _recommendedMaximumStorageDaysMeta,
        ),
      );
    }
    if (data.containsKey('shelf_life_after_opening_days')) {
      context.handle(
        _shelfLifeAfterOpeningDaysMeta,
        shelfLifeAfterOpeningDays.isAcceptableOrUnknown(
          data['shelf_life_after_opening_days']!,
          _shelfLifeAfterOpeningDaysMeta,
        ),
      );
    }
    if (data.containsKey('icon_emoji')) {
      context.handle(
        _iconEmojiMeta,
        iconEmoji.isAcceptableOrUnknown(data['icon_emoji']!, _iconEmojiMeta),
      );
    }
    if (data.containsKey('icon_image')) {
      context.handle(
        _iconImageMeta,
        iconImage.isAcceptableOrUnknown(data['icon_image']!, _iconImageMeta),
      );
    }
    if (data.containsKey('default_compartment_identifier')) {
      context.handle(
        _defaultCompartmentIdentifierMeta,
        defaultCompartmentIdentifier.isAcceptableOrUnknown(
          data['default_compartment_identifier']!,
          _defaultCompartmentIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productIdentifier};
  @override
  ProductRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductRow(
      productIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_identifier'],
      )!,
      categoryIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_identifier'],
      )!,
      catalogKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_key'],
      ),
      customName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_name'],
      ),
      canonicalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_unit'],
      )!,
      defaultPackageQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_package_quantity'],
      ),
      recommendedMaximumStorageDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recommended_maximum_storage_days'],
      ),
      shelfLifeAfterOpeningDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_life_after_opening_days'],
      ),
      iconEmoji: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_emoji'],
      ),
      iconImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}icon_image'],
      ),
      defaultCompartmentIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_compartment_identifier'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductRow extends DataClass implements Insertable<ProductRow> {
  final String productIdentifier;
  final String categoryIdentifier;
  final String? catalogKey;
  final String? customName;

  /// `gram`, `milliliter`, `piece` or `portion`; every quantity of this
  /// product is stored in this unit's base unit (decision D10).
  final String canonicalUnit;
  final int? defaultPackageQuantity;

  /// Overrides the category's shelf life when set.
  final int? recommendedMaximumStorageDays;

  /// Overrides the category's shelf life after opening when set.
  final int? shelfLifeAfterOpeningDays;

  /// Falls back to the category icon when null.
  final String? iconEmoji;

  /// A picture the user chose as the icon, shown instead of [iconEmoji]: a
  /// small square PNG made by core_media_storage (a few kilobytes, so it
  /// lives in the encrypted database and travels with backups).
  final Uint8List? iconImage;

  /// The drawer a new batch of this product goes into unless the user picks
  /// another; `null` suggests the drawer it went into last time.
  final String? defaultCompartmentIdentifier;
  final bool isArchived;
  final DateTime createdAt;
  const ProductRow({
    required this.productIdentifier,
    required this.categoryIdentifier,
    this.catalogKey,
    this.customName,
    required this.canonicalUnit,
    this.defaultPackageQuantity,
    this.recommendedMaximumStorageDays,
    this.shelfLifeAfterOpeningDays,
    this.iconEmoji,
    this.iconImage,
    this.defaultCompartmentIdentifier,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_identifier'] = Variable<String>(productIdentifier);
    map['category_identifier'] = Variable<String>(categoryIdentifier);
    if (!nullToAbsent || catalogKey != null) {
      map['catalog_key'] = Variable<String>(catalogKey);
    }
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['canonical_unit'] = Variable<String>(canonicalUnit);
    if (!nullToAbsent || defaultPackageQuantity != null) {
      map['default_package_quantity'] = Variable<int>(defaultPackageQuantity);
    }
    if (!nullToAbsent || recommendedMaximumStorageDays != null) {
      map['recommended_maximum_storage_days'] = Variable<int>(
        recommendedMaximumStorageDays,
      );
    }
    if (!nullToAbsent || shelfLifeAfterOpeningDays != null) {
      map['shelf_life_after_opening_days'] = Variable<int>(
        shelfLifeAfterOpeningDays,
      );
    }
    if (!nullToAbsent || iconEmoji != null) {
      map['icon_emoji'] = Variable<String>(iconEmoji);
    }
    if (!nullToAbsent || iconImage != null) {
      map['icon_image'] = Variable<Uint8List>(iconImage);
    }
    if (!nullToAbsent || defaultCompartmentIdentifier != null) {
      map['default_compartment_identifier'] = Variable<String>(
        defaultCompartmentIdentifier,
      );
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      productIdentifier: Value(productIdentifier),
      categoryIdentifier: Value(categoryIdentifier),
      catalogKey: catalogKey == null && nullToAbsent
          ? const Value.absent()
          : Value(catalogKey),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      canonicalUnit: Value(canonicalUnit),
      defaultPackageQuantity: defaultPackageQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultPackageQuantity),
      recommendedMaximumStorageDays:
          recommendedMaximumStorageDays == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendedMaximumStorageDays),
      shelfLifeAfterOpeningDays:
          shelfLifeAfterOpeningDays == null && nullToAbsent
          ? const Value.absent()
          : Value(shelfLifeAfterOpeningDays),
      iconEmoji: iconEmoji == null && nullToAbsent
          ? const Value.absent()
          : Value(iconEmoji),
      iconImage: iconImage == null && nullToAbsent
          ? const Value.absent()
          : Value(iconImage),
      defaultCompartmentIdentifier:
          defaultCompartmentIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultCompartmentIdentifier),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory ProductRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductRow(
      productIdentifier: serializer.fromJson<String>(json['productIdentifier']),
      categoryIdentifier: serializer.fromJson<String>(
        json['categoryIdentifier'],
      ),
      catalogKey: serializer.fromJson<String?>(json['catalogKey']),
      customName: serializer.fromJson<String?>(json['customName']),
      canonicalUnit: serializer.fromJson<String>(json['canonicalUnit']),
      defaultPackageQuantity: serializer.fromJson<int?>(
        json['defaultPackageQuantity'],
      ),
      recommendedMaximumStorageDays: serializer.fromJson<int?>(
        json['recommendedMaximumStorageDays'],
      ),
      shelfLifeAfterOpeningDays: serializer.fromJson<int?>(
        json['shelfLifeAfterOpeningDays'],
      ),
      iconEmoji: serializer.fromJson<String?>(json['iconEmoji']),
      iconImage: serializer.fromJson<Uint8List?>(json['iconImage']),
      defaultCompartmentIdentifier: serializer.fromJson<String?>(
        json['defaultCompartmentIdentifier'],
      ),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productIdentifier': serializer.toJson<String>(productIdentifier),
      'categoryIdentifier': serializer.toJson<String>(categoryIdentifier),
      'catalogKey': serializer.toJson<String?>(catalogKey),
      'customName': serializer.toJson<String?>(customName),
      'canonicalUnit': serializer.toJson<String>(canonicalUnit),
      'defaultPackageQuantity': serializer.toJson<int?>(defaultPackageQuantity),
      'recommendedMaximumStorageDays': serializer.toJson<int?>(
        recommendedMaximumStorageDays,
      ),
      'shelfLifeAfterOpeningDays': serializer.toJson<int?>(
        shelfLifeAfterOpeningDays,
      ),
      'iconEmoji': serializer.toJson<String?>(iconEmoji),
      'iconImage': serializer.toJson<Uint8List?>(iconImage),
      'defaultCompartmentIdentifier': serializer.toJson<String?>(
        defaultCompartmentIdentifier,
      ),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProductRow copyWith({
    String? productIdentifier,
    String? categoryIdentifier,
    Value<String?> catalogKey = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    String? canonicalUnit,
    Value<int?> defaultPackageQuantity = const Value.absent(),
    Value<int?> recommendedMaximumStorageDays = const Value.absent(),
    Value<int?> shelfLifeAfterOpeningDays = const Value.absent(),
    Value<String?> iconEmoji = const Value.absent(),
    Value<Uint8List?> iconImage = const Value.absent(),
    Value<String?> defaultCompartmentIdentifier = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => ProductRow(
    productIdentifier: productIdentifier ?? this.productIdentifier,
    categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
    catalogKey: catalogKey.present ? catalogKey.value : this.catalogKey,
    customName: customName.present ? customName.value : this.customName,
    canonicalUnit: canonicalUnit ?? this.canonicalUnit,
    defaultPackageQuantity: defaultPackageQuantity.present
        ? defaultPackageQuantity.value
        : this.defaultPackageQuantity,
    recommendedMaximumStorageDays: recommendedMaximumStorageDays.present
        ? recommendedMaximumStorageDays.value
        : this.recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays.present
        ? shelfLifeAfterOpeningDays.value
        : this.shelfLifeAfterOpeningDays,
    iconEmoji: iconEmoji.present ? iconEmoji.value : this.iconEmoji,
    iconImage: iconImage.present ? iconImage.value : this.iconImage,
    defaultCompartmentIdentifier: defaultCompartmentIdentifier.present
        ? defaultCompartmentIdentifier.value
        : this.defaultCompartmentIdentifier,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  ProductRow copyWithCompanion(ProductsCompanion data) {
    return ProductRow(
      productIdentifier: data.productIdentifier.present
          ? data.productIdentifier.value
          : this.productIdentifier,
      categoryIdentifier: data.categoryIdentifier.present
          ? data.categoryIdentifier.value
          : this.categoryIdentifier,
      catalogKey: data.catalogKey.present
          ? data.catalogKey.value
          : this.catalogKey,
      customName: data.customName.present
          ? data.customName.value
          : this.customName,
      canonicalUnit: data.canonicalUnit.present
          ? data.canonicalUnit.value
          : this.canonicalUnit,
      defaultPackageQuantity: data.defaultPackageQuantity.present
          ? data.defaultPackageQuantity.value
          : this.defaultPackageQuantity,
      recommendedMaximumStorageDays: data.recommendedMaximumStorageDays.present
          ? data.recommendedMaximumStorageDays.value
          : this.recommendedMaximumStorageDays,
      shelfLifeAfterOpeningDays: data.shelfLifeAfterOpeningDays.present
          ? data.shelfLifeAfterOpeningDays.value
          : this.shelfLifeAfterOpeningDays,
      iconEmoji: data.iconEmoji.present ? data.iconEmoji.value : this.iconEmoji,
      iconImage: data.iconImage.present ? data.iconImage.value : this.iconImage,
      defaultCompartmentIdentifier: data.defaultCompartmentIdentifier.present
          ? data.defaultCompartmentIdentifier.value
          : this.defaultCompartmentIdentifier,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductRow(')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('categoryIdentifier: $categoryIdentifier, ')
          ..write('catalogKey: $catalogKey, ')
          ..write('customName: $customName, ')
          ..write('canonicalUnit: $canonicalUnit, ')
          ..write('defaultPackageQuantity: $defaultPackageQuantity, ')
          ..write(
            'recommendedMaximumStorageDays: $recommendedMaximumStorageDays, ',
          )
          ..write('shelfLifeAfterOpeningDays: $shelfLifeAfterOpeningDays, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('iconImage: $iconImage, ')
          ..write(
            'defaultCompartmentIdentifier: $defaultCompartmentIdentifier, ',
          )
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productIdentifier,
    categoryIdentifier,
    catalogKey,
    customName,
    canonicalUnit,
    defaultPackageQuantity,
    recommendedMaximumStorageDays,
    shelfLifeAfterOpeningDays,
    iconEmoji,
    $driftBlobEquality.hash(iconImage),
    defaultCompartmentIdentifier,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductRow &&
          other.productIdentifier == this.productIdentifier &&
          other.categoryIdentifier == this.categoryIdentifier &&
          other.catalogKey == this.catalogKey &&
          other.customName == this.customName &&
          other.canonicalUnit == this.canonicalUnit &&
          other.defaultPackageQuantity == this.defaultPackageQuantity &&
          other.recommendedMaximumStorageDays ==
              this.recommendedMaximumStorageDays &&
          other.shelfLifeAfterOpeningDays == this.shelfLifeAfterOpeningDays &&
          other.iconEmoji == this.iconEmoji &&
          $driftBlobEquality.equals(other.iconImage, this.iconImage) &&
          other.defaultCompartmentIdentifier ==
              this.defaultCompartmentIdentifier &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<ProductRow> {
  final Value<String> productIdentifier;
  final Value<String> categoryIdentifier;
  final Value<String?> catalogKey;
  final Value<String?> customName;
  final Value<String> canonicalUnit;
  final Value<int?> defaultPackageQuantity;
  final Value<int?> recommendedMaximumStorageDays;
  final Value<int?> shelfLifeAfterOpeningDays;
  final Value<String?> iconEmoji;
  final Value<Uint8List?> iconImage;
  final Value<String?> defaultCompartmentIdentifier;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProductsCompanion({
    this.productIdentifier = const Value.absent(),
    this.categoryIdentifier = const Value.absent(),
    this.catalogKey = const Value.absent(),
    this.customName = const Value.absent(),
    this.canonicalUnit = const Value.absent(),
    this.defaultPackageQuantity = const Value.absent(),
    this.recommendedMaximumStorageDays = const Value.absent(),
    this.shelfLifeAfterOpeningDays = const Value.absent(),
    this.iconEmoji = const Value.absent(),
    this.iconImage = const Value.absent(),
    this.defaultCompartmentIdentifier = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String productIdentifier,
    required String categoryIdentifier,
    this.catalogKey = const Value.absent(),
    this.customName = const Value.absent(),
    required String canonicalUnit,
    this.defaultPackageQuantity = const Value.absent(),
    this.recommendedMaximumStorageDays = const Value.absent(),
    this.shelfLifeAfterOpeningDays = const Value.absent(),
    this.iconEmoji = const Value.absent(),
    this.iconImage = const Value.absent(),
    this.defaultCompartmentIdentifier = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : productIdentifier = Value(productIdentifier),
       categoryIdentifier = Value(categoryIdentifier),
       canonicalUnit = Value(canonicalUnit),
       createdAt = Value(createdAt);
  static Insertable<ProductRow> custom({
    Expression<String>? productIdentifier,
    Expression<String>? categoryIdentifier,
    Expression<String>? catalogKey,
    Expression<String>? customName,
    Expression<String>? canonicalUnit,
    Expression<int>? defaultPackageQuantity,
    Expression<int>? recommendedMaximumStorageDays,
    Expression<int>? shelfLifeAfterOpeningDays,
    Expression<String>? iconEmoji,
    Expression<Uint8List>? iconImage,
    Expression<String>? defaultCompartmentIdentifier,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productIdentifier != null) 'product_identifier': productIdentifier,
      if (categoryIdentifier != null) 'category_identifier': categoryIdentifier,
      if (catalogKey != null) 'catalog_key': catalogKey,
      if (customName != null) 'custom_name': customName,
      if (canonicalUnit != null) 'canonical_unit': canonicalUnit,
      if (defaultPackageQuantity != null)
        'default_package_quantity': defaultPackageQuantity,
      if (recommendedMaximumStorageDays != null)
        'recommended_maximum_storage_days': recommendedMaximumStorageDays,
      if (shelfLifeAfterOpeningDays != null)
        'shelf_life_after_opening_days': shelfLifeAfterOpeningDays,
      if (iconEmoji != null) 'icon_emoji': iconEmoji,
      if (iconImage != null) 'icon_image': iconImage,
      if (defaultCompartmentIdentifier != null)
        'default_compartment_identifier': defaultCompartmentIdentifier,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith({
    Value<String>? productIdentifier,
    Value<String>? categoryIdentifier,
    Value<String?>? catalogKey,
    Value<String?>? customName,
    Value<String>? canonicalUnit,
    Value<int?>? defaultPackageQuantity,
    Value<int?>? recommendedMaximumStorageDays,
    Value<int?>? shelfLifeAfterOpeningDays,
    Value<String?>? iconEmoji,
    Value<Uint8List?>? iconImage,
    Value<String?>? defaultCompartmentIdentifier,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProductsCompanion(
      productIdentifier: productIdentifier ?? this.productIdentifier,
      categoryIdentifier: categoryIdentifier ?? this.categoryIdentifier,
      catalogKey: catalogKey ?? this.catalogKey,
      customName: customName ?? this.customName,
      canonicalUnit: canonicalUnit ?? this.canonicalUnit,
      defaultPackageQuantity:
          defaultPackageQuantity ?? this.defaultPackageQuantity,
      recommendedMaximumStorageDays:
          recommendedMaximumStorageDays ?? this.recommendedMaximumStorageDays,
      shelfLifeAfterOpeningDays:
          shelfLifeAfterOpeningDays ?? this.shelfLifeAfterOpeningDays,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      iconImage: iconImage ?? this.iconImage,
      defaultCompartmentIdentifier:
          defaultCompartmentIdentifier ?? this.defaultCompartmentIdentifier,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productIdentifier.present) {
      map['product_identifier'] = Variable<String>(productIdentifier.value);
    }
    if (categoryIdentifier.present) {
      map['category_identifier'] = Variable<String>(categoryIdentifier.value);
    }
    if (catalogKey.present) {
      map['catalog_key'] = Variable<String>(catalogKey.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (canonicalUnit.present) {
      map['canonical_unit'] = Variable<String>(canonicalUnit.value);
    }
    if (defaultPackageQuantity.present) {
      map['default_package_quantity'] = Variable<int>(
        defaultPackageQuantity.value,
      );
    }
    if (recommendedMaximumStorageDays.present) {
      map['recommended_maximum_storage_days'] = Variable<int>(
        recommendedMaximumStorageDays.value,
      );
    }
    if (shelfLifeAfterOpeningDays.present) {
      map['shelf_life_after_opening_days'] = Variable<int>(
        shelfLifeAfterOpeningDays.value,
      );
    }
    if (iconEmoji.present) {
      map['icon_emoji'] = Variable<String>(iconEmoji.value);
    }
    if (iconImage.present) {
      map['icon_image'] = Variable<Uint8List>(iconImage.value);
    }
    if (defaultCompartmentIdentifier.present) {
      map['default_compartment_identifier'] = Variable<String>(
        defaultCompartmentIdentifier.value,
      );
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('categoryIdentifier: $categoryIdentifier, ')
          ..write('catalogKey: $catalogKey, ')
          ..write('customName: $customName, ')
          ..write('canonicalUnit: $canonicalUnit, ')
          ..write('defaultPackageQuantity: $defaultPackageQuantity, ')
          ..write(
            'recommendedMaximumStorageDays: $recommendedMaximumStorageDays, ',
          )
          ..write('shelfLifeAfterOpeningDays: $shelfLifeAfterOpeningDays, ')
          ..write('iconEmoji: $iconEmoji, ')
          ..write('iconImage: $iconImage, ')
          ..write(
            'defaultCompartmentIdentifier: $defaultCompartmentIdentifier, ',
          )
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StockBatchesTable extends StockBatches
    with TableInfo<$StockBatchesTable, StockBatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockBatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stockBatchIdentifierMeta =
      const VerificationMeta('stockBatchIdentifier');
  @override
  late final GeneratedColumn<String> stockBatchIdentifier =
      GeneratedColumn<String>(
        'stock_batch_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _productIdentifierMeta = const VerificationMeta(
    'productIdentifier',
  );
  @override
  late final GeneratedColumn<String> productIdentifier =
      GeneratedColumn<String>(
        'product_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES products (product_identifier)',
        ),
      );
  static const VerificationMeta _compartmentIdentifierMeta =
      const VerificationMeta('compartmentIdentifier');
  @override
  late final GeneratedColumn<String> compartmentIdentifier =
      GeneratedColumn<String>(
        'compartment_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES compartments (compartment_identifier)',
        ),
      );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialQuantityMeta = const VerificationMeta(
    'initialQuantity',
  );
  @override
  late final GeneratedColumn<int> initialQuantity = GeneratedColumn<int>(
    'initial_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityRemainingMeta = const VerificationMeta(
    'quantityRemaining',
  );
  @override
  late final GeneratedColumn<int> quantityRemaining = GeneratedColumn<int>(
    'quantity_remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentBatchIdentifierMeta =
      const VerificationMeta('parentBatchIdentifier');
  @override
  late final GeneratedColumn<String> parentBatchIdentifier =
      GeneratedColumn<String>(
        'parent_batch_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate, String> storedOn =
      GeneratedColumn<String>(
        'stored_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CalendarDate>($StockBatchesTable.$converterstoredOn);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String>
  bestBeforeOn = GeneratedColumn<String>(
    'best_before_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<CalendarDate?>($StockBatchesTable.$converterbestBeforeOnn);
  @override
  late final GeneratedColumnWithTypeConverter<CalendarDate?, String> openedOn =
      GeneratedColumn<String>(
        'opened_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CalendarDate?>($StockBatchesTable.$converteropenedOnn);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stockBatchIdentifier,
    productIdentifier,
    compartmentIdentifier,
    quantityUnit,
    initialQuantity,
    quantityRemaining,
    parentBatchIdentifier,
    storedOn,
    bestBeforeOn,
    openedOn,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_batches';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockBatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stock_batch_identifier')) {
      context.handle(
        _stockBatchIdentifierMeta,
        stockBatchIdentifier.isAcceptableOrUnknown(
          data['stock_batch_identifier']!,
          _stockBatchIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockBatchIdentifierMeta);
    }
    if (data.containsKey('product_identifier')) {
      context.handle(
        _productIdentifierMeta,
        productIdentifier.isAcceptableOrUnknown(
          data['product_identifier']!,
          _productIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productIdentifierMeta);
    }
    if (data.containsKey('compartment_identifier')) {
      context.handle(
        _compartmentIdentifierMeta,
        compartmentIdentifier.isAcceptableOrUnknown(
          data['compartment_identifier']!,
          _compartmentIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compartmentIdentifierMeta);
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('initial_quantity')) {
      context.handle(
        _initialQuantityMeta,
        initialQuantity.isAcceptableOrUnknown(
          data['initial_quantity']!,
          _initialQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialQuantityMeta);
    }
    if (data.containsKey('quantity_remaining')) {
      context.handle(
        _quantityRemainingMeta,
        quantityRemaining.isAcceptableOrUnknown(
          data['quantity_remaining']!,
          _quantityRemainingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityRemainingMeta);
    }
    if (data.containsKey('parent_batch_identifier')) {
      context.handle(
        _parentBatchIdentifierMeta,
        parentBatchIdentifier.isAcceptableOrUnknown(
          data['parent_batch_identifier']!,
          _parentBatchIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stockBatchIdentifier};
  @override
  StockBatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockBatchRow(
      stockBatchIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_batch_identifier'],
      )!,
      productIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_identifier'],
      )!,
      compartmentIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compartment_identifier'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      initialQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_quantity'],
      )!,
      quantityRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_remaining'],
      )!,
      parentBatchIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_batch_identifier'],
      ),
      storedOn: $StockBatchesTable.$converterstoredOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}stored_on'],
        )!,
      ),
      bestBeforeOn: $StockBatchesTable.$converterbestBeforeOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}best_before_on'],
        ),
      ),
      openedOn: $StockBatchesTable.$converteropenedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}opened_on'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockBatchesTable createAlias(String alias) {
    return $StockBatchesTable(attachedDatabase, alias);
  }

  static TypeConverter<CalendarDate, String> $converterstoredOn =
      const CalendarDateTextConverter();
  static TypeConverter<CalendarDate, String> $converterbestBeforeOn =
      const CalendarDateTextConverter();
  static TypeConverter<CalendarDate?, String?> $converterbestBeforeOnn =
      NullAwareTypeConverter.wrap($converterbestBeforeOn);
  static TypeConverter<CalendarDate, String> $converteropenedOn =
      const CalendarDateTextConverter();
  static TypeConverter<CalendarDate?, String?> $converteropenedOnn =
      NullAwareTypeConverter.wrap($converteropenedOn);
}

class StockBatchRow extends DataClass implements Insertable<StockBatchRow> {
  final String stockBatchIdentifier;
  final String productIdentifier;
  final String compartmentIdentifier;

  /// The product's canonical unit, copied for self-contained rows; it never
  /// changes once a product has stock (decision D10).
  final String quantityUnit;
  final int initialQuantity;

  /// The fast current state; the movement log is the history.
  final int quantityRemaining;

  /// Set when this batch was split off another one.
  final String? parentBatchIdentifier;

  /// The day the batch was put away: frozen or bought. Called `frozen_on`
  /// before schema version 9.
  final CalendarDate storedOn;
  final CalendarDate? bestBeforeOn;

  /// The day the package was opened; `null` while it is closed.
  final CalendarDate? openedOn;
  final String? note;
  final DateTime createdAt;
  const StockBatchRow({
    required this.stockBatchIdentifier,
    required this.productIdentifier,
    required this.compartmentIdentifier,
    required this.quantityUnit,
    required this.initialQuantity,
    required this.quantityRemaining,
    this.parentBatchIdentifier,
    required this.storedOn,
    this.bestBeforeOn,
    this.openedOn,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stock_batch_identifier'] = Variable<String>(stockBatchIdentifier);
    map['product_identifier'] = Variable<String>(productIdentifier);
    map['compartment_identifier'] = Variable<String>(compartmentIdentifier);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    map['initial_quantity'] = Variable<int>(initialQuantity);
    map['quantity_remaining'] = Variable<int>(quantityRemaining);
    if (!nullToAbsent || parentBatchIdentifier != null) {
      map['parent_batch_identifier'] = Variable<String>(parentBatchIdentifier);
    }
    {
      map['stored_on'] = Variable<String>(
        $StockBatchesTable.$converterstoredOn.toSql(storedOn),
      );
    }
    if (!nullToAbsent || bestBeforeOn != null) {
      map['best_before_on'] = Variable<String>(
        $StockBatchesTable.$converterbestBeforeOnn.toSql(bestBeforeOn),
      );
    }
    if (!nullToAbsent || openedOn != null) {
      map['opened_on'] = Variable<String>(
        $StockBatchesTable.$converteropenedOnn.toSql(openedOn),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockBatchesCompanion toCompanion(bool nullToAbsent) {
    return StockBatchesCompanion(
      stockBatchIdentifier: Value(stockBatchIdentifier),
      productIdentifier: Value(productIdentifier),
      compartmentIdentifier: Value(compartmentIdentifier),
      quantityUnit: Value(quantityUnit),
      initialQuantity: Value(initialQuantity),
      quantityRemaining: Value(quantityRemaining),
      parentBatchIdentifier: parentBatchIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(parentBatchIdentifier),
      storedOn: Value(storedOn),
      bestBeforeOn: bestBeforeOn == null && nullToAbsent
          ? const Value.absent()
          : Value(bestBeforeOn),
      openedOn: openedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(openedOn),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StockBatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockBatchRow(
      stockBatchIdentifier: serializer.fromJson<String>(
        json['stockBatchIdentifier'],
      ),
      productIdentifier: serializer.fromJson<String>(json['productIdentifier']),
      compartmentIdentifier: serializer.fromJson<String>(
        json['compartmentIdentifier'],
      ),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      initialQuantity: serializer.fromJson<int>(json['initialQuantity']),
      quantityRemaining: serializer.fromJson<int>(json['quantityRemaining']),
      parentBatchIdentifier: serializer.fromJson<String?>(
        json['parentBatchIdentifier'],
      ),
      storedOn: serializer.fromJson<CalendarDate>(json['storedOn']),
      bestBeforeOn: serializer.fromJson<CalendarDate?>(json['bestBeforeOn']),
      openedOn: serializer.fromJson<CalendarDate?>(json['openedOn']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stockBatchIdentifier': serializer.toJson<String>(stockBatchIdentifier),
      'productIdentifier': serializer.toJson<String>(productIdentifier),
      'compartmentIdentifier': serializer.toJson<String>(compartmentIdentifier),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'initialQuantity': serializer.toJson<int>(initialQuantity),
      'quantityRemaining': serializer.toJson<int>(quantityRemaining),
      'parentBatchIdentifier': serializer.toJson<String?>(
        parentBatchIdentifier,
      ),
      'storedOn': serializer.toJson<CalendarDate>(storedOn),
      'bestBeforeOn': serializer.toJson<CalendarDate?>(bestBeforeOn),
      'openedOn': serializer.toJson<CalendarDate?>(openedOn),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockBatchRow copyWith({
    String? stockBatchIdentifier,
    String? productIdentifier,
    String? compartmentIdentifier,
    String? quantityUnit,
    int? initialQuantity,
    int? quantityRemaining,
    Value<String?> parentBatchIdentifier = const Value.absent(),
    CalendarDate? storedOn,
    Value<CalendarDate?> bestBeforeOn = const Value.absent(),
    Value<CalendarDate?> openedOn = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => StockBatchRow(
    stockBatchIdentifier: stockBatchIdentifier ?? this.stockBatchIdentifier,
    productIdentifier: productIdentifier ?? this.productIdentifier,
    compartmentIdentifier: compartmentIdentifier ?? this.compartmentIdentifier,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    initialQuantity: initialQuantity ?? this.initialQuantity,
    quantityRemaining: quantityRemaining ?? this.quantityRemaining,
    parentBatchIdentifier: parentBatchIdentifier.present
        ? parentBatchIdentifier.value
        : this.parentBatchIdentifier,
    storedOn: storedOn ?? this.storedOn,
    bestBeforeOn: bestBeforeOn.present ? bestBeforeOn.value : this.bestBeforeOn,
    openedOn: openedOn.present ? openedOn.value : this.openedOn,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  StockBatchRow copyWithCompanion(StockBatchesCompanion data) {
    return StockBatchRow(
      stockBatchIdentifier: data.stockBatchIdentifier.present
          ? data.stockBatchIdentifier.value
          : this.stockBatchIdentifier,
      productIdentifier: data.productIdentifier.present
          ? data.productIdentifier.value
          : this.productIdentifier,
      compartmentIdentifier: data.compartmentIdentifier.present
          ? data.compartmentIdentifier.value
          : this.compartmentIdentifier,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      initialQuantity: data.initialQuantity.present
          ? data.initialQuantity.value
          : this.initialQuantity,
      quantityRemaining: data.quantityRemaining.present
          ? data.quantityRemaining.value
          : this.quantityRemaining,
      parentBatchIdentifier: data.parentBatchIdentifier.present
          ? data.parentBatchIdentifier.value
          : this.parentBatchIdentifier,
      storedOn: data.storedOn.present ? data.storedOn.value : this.storedOn,
      bestBeforeOn: data.bestBeforeOn.present
          ? data.bestBeforeOn.value
          : this.bestBeforeOn,
      openedOn: data.openedOn.present ? data.openedOn.value : this.openedOn,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockBatchRow(')
          ..write('stockBatchIdentifier: $stockBatchIdentifier, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('compartmentIdentifier: $compartmentIdentifier, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('quantityRemaining: $quantityRemaining, ')
          ..write('parentBatchIdentifier: $parentBatchIdentifier, ')
          ..write('storedOn: $storedOn, ')
          ..write('bestBeforeOn: $bestBeforeOn, ')
          ..write('openedOn: $openedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    stockBatchIdentifier,
    productIdentifier,
    compartmentIdentifier,
    quantityUnit,
    initialQuantity,
    quantityRemaining,
    parentBatchIdentifier,
    storedOn,
    bestBeforeOn,
    openedOn,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockBatchRow &&
          other.stockBatchIdentifier == this.stockBatchIdentifier &&
          other.productIdentifier == this.productIdentifier &&
          other.compartmentIdentifier == this.compartmentIdentifier &&
          other.quantityUnit == this.quantityUnit &&
          other.initialQuantity == this.initialQuantity &&
          other.quantityRemaining == this.quantityRemaining &&
          other.parentBatchIdentifier == this.parentBatchIdentifier &&
          other.storedOn == this.storedOn &&
          other.bestBeforeOn == this.bestBeforeOn &&
          other.openedOn == this.openedOn &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StockBatchesCompanion extends UpdateCompanion<StockBatchRow> {
  final Value<String> stockBatchIdentifier;
  final Value<String> productIdentifier;
  final Value<String> compartmentIdentifier;
  final Value<String> quantityUnit;
  final Value<int> initialQuantity;
  final Value<int> quantityRemaining;
  final Value<String?> parentBatchIdentifier;
  final Value<CalendarDate> storedOn;
  final Value<CalendarDate?> bestBeforeOn;
  final Value<CalendarDate?> openedOn;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const StockBatchesCompanion({
    this.stockBatchIdentifier = const Value.absent(),
    this.productIdentifier = const Value.absent(),
    this.compartmentIdentifier = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.initialQuantity = const Value.absent(),
    this.quantityRemaining = const Value.absent(),
    this.parentBatchIdentifier = const Value.absent(),
    this.storedOn = const Value.absent(),
    this.bestBeforeOn = const Value.absent(),
    this.openedOn = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StockBatchesCompanion.insert({
    required String stockBatchIdentifier,
    required String productIdentifier,
    required String compartmentIdentifier,
    required String quantityUnit,
    required int initialQuantity,
    required int quantityRemaining,
    this.parentBatchIdentifier = const Value.absent(),
    required CalendarDate storedOn,
    this.bestBeforeOn = const Value.absent(),
    this.openedOn = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : stockBatchIdentifier = Value(stockBatchIdentifier),
       productIdentifier = Value(productIdentifier),
       compartmentIdentifier = Value(compartmentIdentifier),
       quantityUnit = Value(quantityUnit),
       initialQuantity = Value(initialQuantity),
       quantityRemaining = Value(quantityRemaining),
       storedOn = Value(storedOn),
       createdAt = Value(createdAt);
  static Insertable<StockBatchRow> custom({
    Expression<String>? stockBatchIdentifier,
    Expression<String>? productIdentifier,
    Expression<String>? compartmentIdentifier,
    Expression<String>? quantityUnit,
    Expression<int>? initialQuantity,
    Expression<int>? quantityRemaining,
    Expression<String>? parentBatchIdentifier,
    Expression<String>? storedOn,
    Expression<String>? bestBeforeOn,
    Expression<String>? openedOn,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stockBatchIdentifier != null)
        'stock_batch_identifier': stockBatchIdentifier,
      if (productIdentifier != null) 'product_identifier': productIdentifier,
      if (compartmentIdentifier != null)
        'compartment_identifier': compartmentIdentifier,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (initialQuantity != null) 'initial_quantity': initialQuantity,
      if (quantityRemaining != null) 'quantity_remaining': quantityRemaining,
      if (parentBatchIdentifier != null)
        'parent_batch_identifier': parentBatchIdentifier,
      if (storedOn != null) 'stored_on': storedOn,
      if (bestBeforeOn != null) 'best_before_on': bestBeforeOn,
      if (openedOn != null) 'opened_on': openedOn,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StockBatchesCompanion copyWith({
    Value<String>? stockBatchIdentifier,
    Value<String>? productIdentifier,
    Value<String>? compartmentIdentifier,
    Value<String>? quantityUnit,
    Value<int>? initialQuantity,
    Value<int>? quantityRemaining,
    Value<String?>? parentBatchIdentifier,
    Value<CalendarDate>? storedOn,
    Value<CalendarDate?>? bestBeforeOn,
    Value<CalendarDate?>? openedOn,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return StockBatchesCompanion(
      stockBatchIdentifier: stockBatchIdentifier ?? this.stockBatchIdentifier,
      productIdentifier: productIdentifier ?? this.productIdentifier,
      compartmentIdentifier:
          compartmentIdentifier ?? this.compartmentIdentifier,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      quantityRemaining: quantityRemaining ?? this.quantityRemaining,
      parentBatchIdentifier:
          parentBatchIdentifier ?? this.parentBatchIdentifier,
      storedOn: storedOn ?? this.storedOn,
      bestBeforeOn: bestBeforeOn ?? this.bestBeforeOn,
      openedOn: openedOn ?? this.openedOn,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stockBatchIdentifier.present) {
      map['stock_batch_identifier'] = Variable<String>(
        stockBatchIdentifier.value,
      );
    }
    if (productIdentifier.present) {
      map['product_identifier'] = Variable<String>(productIdentifier.value);
    }
    if (compartmentIdentifier.present) {
      map['compartment_identifier'] = Variable<String>(
        compartmentIdentifier.value,
      );
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (initialQuantity.present) {
      map['initial_quantity'] = Variable<int>(initialQuantity.value);
    }
    if (quantityRemaining.present) {
      map['quantity_remaining'] = Variable<int>(quantityRemaining.value);
    }
    if (parentBatchIdentifier.present) {
      map['parent_batch_identifier'] = Variable<String>(
        parentBatchIdentifier.value,
      );
    }
    if (storedOn.present) {
      map['stored_on'] = Variable<String>(
        $StockBatchesTable.$converterstoredOn.toSql(storedOn.value),
      );
    }
    if (bestBeforeOn.present) {
      map['best_before_on'] = Variable<String>(
        $StockBatchesTable.$converterbestBeforeOnn.toSql(bestBeforeOn.value),
      );
    }
    if (openedOn.present) {
      map['opened_on'] = Variable<String>(
        $StockBatchesTable.$converteropenedOnn.toSql(openedOn.value),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockBatchesCompanion(')
          ..write('stockBatchIdentifier: $stockBatchIdentifier, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('compartmentIdentifier: $compartmentIdentifier, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('initialQuantity: $initialQuantity, ')
          ..write('quantityRemaining: $quantityRemaining, ')
          ..write('parentBatchIdentifier: $parentBatchIdentifier, ')
          ..write('storedOn: $storedOn, ')
          ..write('bestBeforeOn: $bestBeforeOn, ')
          ..write('openedOn: $openedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryMovementsTable extends InventoryMovements
    with TableInfo<$InventoryMovementsTable, InventoryMovementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _movementIdentifierMeta =
      const VerificationMeta('movementIdentifier');
  @override
  late final GeneratedColumn<String> movementIdentifier =
      GeneratedColumn<String>(
        'movement_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stockBatchIdentifierMeta =
      const VerificationMeta('stockBatchIdentifier');
  @override
  late final GeneratedColumn<String> stockBatchIdentifier =
      GeneratedColumn<String>(
        'stock_batch_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES stock_batches (stock_batch_identifier)',
        ),
      );
  static const VerificationMeta _productIdentifierMeta = const VerificationMeta(
    'productIdentifier',
  );
  @override
  late final GeneratedColumn<String> productIdentifier =
      GeneratedColumn<String>(
        'product_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES products (product_identifier)',
        ),
      );
  static const VerificationMeta _compartmentIdentifierMeta =
      const VerificationMeta('compartmentIdentifier');
  @override
  late final GeneratedColumn<String> compartmentIdentifier =
      GeneratedColumn<String>(
        'compartment_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES compartments (compartment_identifier)',
        ),
      );
  static const VerificationMeta _movementKindMeta = const VerificationMeta(
    'movementKind',
  );
  @override
  late final GeneratedColumn<String> movementKind = GeneratedColumn<String>(
    'movement_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityDeltaMeta = const VerificationMeta(
    'quantityDelta',
  );
  @override
  late final GeneratedColumn<int> quantityDelta = GeneratedColumn<int>(
    'quantity_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discardReasonMeta = const VerificationMeta(
    'discardReason',
  );
  @override
  late final GeneratedColumn<String> discardReason = GeneratedColumn<String>(
    'discard_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reversesMovementIdentifierMeta =
      const VerificationMeta('reversesMovementIdentifier');
  @override
  late final GeneratedColumn<String> reversesMovementIdentifier =
      GeneratedColumn<String>(
        'reverses_movement_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    movementIdentifier,
    stockBatchIdentifier,
    productIdentifier,
    compartmentIdentifier,
    movementKind,
    quantityDelta,
    discardReason,
    reversesMovementIdentifier,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryMovementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('movement_identifier')) {
      context.handle(
        _movementIdentifierMeta,
        movementIdentifier.isAcceptableOrUnknown(
          data['movement_identifier']!,
          _movementIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementIdentifierMeta);
    }
    if (data.containsKey('stock_batch_identifier')) {
      context.handle(
        _stockBatchIdentifierMeta,
        stockBatchIdentifier.isAcceptableOrUnknown(
          data['stock_batch_identifier']!,
          _stockBatchIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockBatchIdentifierMeta);
    }
    if (data.containsKey('product_identifier')) {
      context.handle(
        _productIdentifierMeta,
        productIdentifier.isAcceptableOrUnknown(
          data['product_identifier']!,
          _productIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productIdentifierMeta);
    }
    if (data.containsKey('compartment_identifier')) {
      context.handle(
        _compartmentIdentifierMeta,
        compartmentIdentifier.isAcceptableOrUnknown(
          data['compartment_identifier']!,
          _compartmentIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_compartmentIdentifierMeta);
    }
    if (data.containsKey('movement_kind')) {
      context.handle(
        _movementKindMeta,
        movementKind.isAcceptableOrUnknown(
          data['movement_kind']!,
          _movementKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementKindMeta);
    }
    if (data.containsKey('quantity_delta')) {
      context.handle(
        _quantityDeltaMeta,
        quantityDelta.isAcceptableOrUnknown(
          data['quantity_delta']!,
          _quantityDeltaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityDeltaMeta);
    }
    if (data.containsKey('discard_reason')) {
      context.handle(
        _discardReasonMeta,
        discardReason.isAcceptableOrUnknown(
          data['discard_reason']!,
          _discardReasonMeta,
        ),
      );
    }
    if (data.containsKey('reverses_movement_identifier')) {
      context.handle(
        _reversesMovementIdentifierMeta,
        reversesMovementIdentifier.isAcceptableOrUnknown(
          data['reverses_movement_identifier']!,
          _reversesMovementIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {movementIdentifier};
  @override
  InventoryMovementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryMovementRow(
      movementIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_identifier'],
      )!,
      stockBatchIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stock_batch_identifier'],
      )!,
      productIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_identifier'],
      )!,
      compartmentIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}compartment_identifier'],
      )!,
      movementKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_kind'],
      )!,
      quantityDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_delta'],
      )!,
      discardReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discard_reason'],
      ),
      reversesMovementIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reverses_movement_identifier'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $InventoryMovementsTable createAlias(String alias) {
    return $InventoryMovementsTable(attachedDatabase, alias);
  }
}

class InventoryMovementRow extends DataClass
    implements Insertable<InventoryMovementRow> {
  final String movementIdentifier;
  final String stockBatchIdentifier;
  final String productIdentifier;
  final String compartmentIdentifier;

  /// `added`, `consumed`, `discarded`, `moved` or `corrected`.
  final String movementKind;

  /// Change of the batch's quantity in the product's base unit; negative for removals.
  final int quantityDelta;

  /// `tooOld`, `freezerBurn`, `expired`, `spoiled`, `unwanted` or `other`
  /// for discards.
  final String? discardReason;

  /// Set on a compensating movement (undo); it has the same kind and the
  /// opposite delta, so sums per kind stay correct.
  final String? reversesMovementIdentifier;
  final DateTime occurredAt;
  const InventoryMovementRow({
    required this.movementIdentifier,
    required this.stockBatchIdentifier,
    required this.productIdentifier,
    required this.compartmentIdentifier,
    required this.movementKind,
    required this.quantityDelta,
    this.discardReason,
    this.reversesMovementIdentifier,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['movement_identifier'] = Variable<String>(movementIdentifier);
    map['stock_batch_identifier'] = Variable<String>(stockBatchIdentifier);
    map['product_identifier'] = Variable<String>(productIdentifier);
    map['compartment_identifier'] = Variable<String>(compartmentIdentifier);
    map['movement_kind'] = Variable<String>(movementKind);
    map['quantity_delta'] = Variable<int>(quantityDelta);
    if (!nullToAbsent || discardReason != null) {
      map['discard_reason'] = Variable<String>(discardReason);
    }
    if (!nullToAbsent || reversesMovementIdentifier != null) {
      map['reverses_movement_identifier'] = Variable<String>(
        reversesMovementIdentifier,
      );
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  InventoryMovementsCompanion toCompanion(bool nullToAbsent) {
    return InventoryMovementsCompanion(
      movementIdentifier: Value(movementIdentifier),
      stockBatchIdentifier: Value(stockBatchIdentifier),
      productIdentifier: Value(productIdentifier),
      compartmentIdentifier: Value(compartmentIdentifier),
      movementKind: Value(movementKind),
      quantityDelta: Value(quantityDelta),
      discardReason: discardReason == null && nullToAbsent
          ? const Value.absent()
          : Value(discardReason),
      reversesMovementIdentifier:
          reversesMovementIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(reversesMovementIdentifier),
      occurredAt: Value(occurredAt),
    );
  }

  factory InventoryMovementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryMovementRow(
      movementIdentifier: serializer.fromJson<String>(
        json['movementIdentifier'],
      ),
      stockBatchIdentifier: serializer.fromJson<String>(
        json['stockBatchIdentifier'],
      ),
      productIdentifier: serializer.fromJson<String>(json['productIdentifier']),
      compartmentIdentifier: serializer.fromJson<String>(
        json['compartmentIdentifier'],
      ),
      movementKind: serializer.fromJson<String>(json['movementKind']),
      quantityDelta: serializer.fromJson<int>(json['quantityDelta']),
      discardReason: serializer.fromJson<String?>(json['discardReason']),
      reversesMovementIdentifier: serializer.fromJson<String?>(
        json['reversesMovementIdentifier'],
      ),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'movementIdentifier': serializer.toJson<String>(movementIdentifier),
      'stockBatchIdentifier': serializer.toJson<String>(stockBatchIdentifier),
      'productIdentifier': serializer.toJson<String>(productIdentifier),
      'compartmentIdentifier': serializer.toJson<String>(compartmentIdentifier),
      'movementKind': serializer.toJson<String>(movementKind),
      'quantityDelta': serializer.toJson<int>(quantityDelta),
      'discardReason': serializer.toJson<String?>(discardReason),
      'reversesMovementIdentifier': serializer.toJson<String?>(
        reversesMovementIdentifier,
      ),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  InventoryMovementRow copyWith({
    String? movementIdentifier,
    String? stockBatchIdentifier,
    String? productIdentifier,
    String? compartmentIdentifier,
    String? movementKind,
    int? quantityDelta,
    Value<String?> discardReason = const Value.absent(),
    Value<String?> reversesMovementIdentifier = const Value.absent(),
    DateTime? occurredAt,
  }) => InventoryMovementRow(
    movementIdentifier: movementIdentifier ?? this.movementIdentifier,
    stockBatchIdentifier: stockBatchIdentifier ?? this.stockBatchIdentifier,
    productIdentifier: productIdentifier ?? this.productIdentifier,
    compartmentIdentifier: compartmentIdentifier ?? this.compartmentIdentifier,
    movementKind: movementKind ?? this.movementKind,
    quantityDelta: quantityDelta ?? this.quantityDelta,
    discardReason: discardReason.present
        ? discardReason.value
        : this.discardReason,
    reversesMovementIdentifier: reversesMovementIdentifier.present
        ? reversesMovementIdentifier.value
        : this.reversesMovementIdentifier,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  InventoryMovementRow copyWithCompanion(InventoryMovementsCompanion data) {
    return InventoryMovementRow(
      movementIdentifier: data.movementIdentifier.present
          ? data.movementIdentifier.value
          : this.movementIdentifier,
      stockBatchIdentifier: data.stockBatchIdentifier.present
          ? data.stockBatchIdentifier.value
          : this.stockBatchIdentifier,
      productIdentifier: data.productIdentifier.present
          ? data.productIdentifier.value
          : this.productIdentifier,
      compartmentIdentifier: data.compartmentIdentifier.present
          ? data.compartmentIdentifier.value
          : this.compartmentIdentifier,
      movementKind: data.movementKind.present
          ? data.movementKind.value
          : this.movementKind,
      quantityDelta: data.quantityDelta.present
          ? data.quantityDelta.value
          : this.quantityDelta,
      discardReason: data.discardReason.present
          ? data.discardReason.value
          : this.discardReason,
      reversesMovementIdentifier: data.reversesMovementIdentifier.present
          ? data.reversesMovementIdentifier.value
          : this.reversesMovementIdentifier,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementRow(')
          ..write('movementIdentifier: $movementIdentifier, ')
          ..write('stockBatchIdentifier: $stockBatchIdentifier, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('compartmentIdentifier: $compartmentIdentifier, ')
          ..write('movementKind: $movementKind, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('discardReason: $discardReason, ')
          ..write('reversesMovementIdentifier: $reversesMovementIdentifier, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    movementIdentifier,
    stockBatchIdentifier,
    productIdentifier,
    compartmentIdentifier,
    movementKind,
    quantityDelta,
    discardReason,
    reversesMovementIdentifier,
    occurredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryMovementRow &&
          other.movementIdentifier == this.movementIdentifier &&
          other.stockBatchIdentifier == this.stockBatchIdentifier &&
          other.productIdentifier == this.productIdentifier &&
          other.compartmentIdentifier == this.compartmentIdentifier &&
          other.movementKind == this.movementKind &&
          other.quantityDelta == this.quantityDelta &&
          other.discardReason == this.discardReason &&
          other.reversesMovementIdentifier == this.reversesMovementIdentifier &&
          other.occurredAt == this.occurredAt);
}

class InventoryMovementsCompanion
    extends UpdateCompanion<InventoryMovementRow> {
  final Value<String> movementIdentifier;
  final Value<String> stockBatchIdentifier;
  final Value<String> productIdentifier;
  final Value<String> compartmentIdentifier;
  final Value<String> movementKind;
  final Value<int> quantityDelta;
  final Value<String?> discardReason;
  final Value<String?> reversesMovementIdentifier;
  final Value<DateTime> occurredAt;
  final Value<int> rowid;
  const InventoryMovementsCompanion({
    this.movementIdentifier = const Value.absent(),
    this.stockBatchIdentifier = const Value.absent(),
    this.productIdentifier = const Value.absent(),
    this.compartmentIdentifier = const Value.absent(),
    this.movementKind = const Value.absent(),
    this.quantityDelta = const Value.absent(),
    this.discardReason = const Value.absent(),
    this.reversesMovementIdentifier = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryMovementsCompanion.insert({
    required String movementIdentifier,
    required String stockBatchIdentifier,
    required String productIdentifier,
    required String compartmentIdentifier,
    required String movementKind,
    required int quantityDelta,
    this.discardReason = const Value.absent(),
    this.reversesMovementIdentifier = const Value.absent(),
    required DateTime occurredAt,
    this.rowid = const Value.absent(),
  }) : movementIdentifier = Value(movementIdentifier),
       stockBatchIdentifier = Value(stockBatchIdentifier),
       productIdentifier = Value(productIdentifier),
       compartmentIdentifier = Value(compartmentIdentifier),
       movementKind = Value(movementKind),
       quantityDelta = Value(quantityDelta),
       occurredAt = Value(occurredAt);
  static Insertable<InventoryMovementRow> custom({
    Expression<String>? movementIdentifier,
    Expression<String>? stockBatchIdentifier,
    Expression<String>? productIdentifier,
    Expression<String>? compartmentIdentifier,
    Expression<String>? movementKind,
    Expression<int>? quantityDelta,
    Expression<String>? discardReason,
    Expression<String>? reversesMovementIdentifier,
    Expression<DateTime>? occurredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (movementIdentifier != null) 'movement_identifier': movementIdentifier,
      if (stockBatchIdentifier != null)
        'stock_batch_identifier': stockBatchIdentifier,
      if (productIdentifier != null) 'product_identifier': productIdentifier,
      if (compartmentIdentifier != null)
        'compartment_identifier': compartmentIdentifier,
      if (movementKind != null) 'movement_kind': movementKind,
      if (quantityDelta != null) 'quantity_delta': quantityDelta,
      if (discardReason != null) 'discard_reason': discardReason,
      if (reversesMovementIdentifier != null)
        'reverses_movement_identifier': reversesMovementIdentifier,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryMovementsCompanion copyWith({
    Value<String>? movementIdentifier,
    Value<String>? stockBatchIdentifier,
    Value<String>? productIdentifier,
    Value<String>? compartmentIdentifier,
    Value<String>? movementKind,
    Value<int>? quantityDelta,
    Value<String?>? discardReason,
    Value<String?>? reversesMovementIdentifier,
    Value<DateTime>? occurredAt,
    Value<int>? rowid,
  }) {
    return InventoryMovementsCompanion(
      movementIdentifier: movementIdentifier ?? this.movementIdentifier,
      stockBatchIdentifier: stockBatchIdentifier ?? this.stockBatchIdentifier,
      productIdentifier: productIdentifier ?? this.productIdentifier,
      compartmentIdentifier:
          compartmentIdentifier ?? this.compartmentIdentifier,
      movementKind: movementKind ?? this.movementKind,
      quantityDelta: quantityDelta ?? this.quantityDelta,
      discardReason: discardReason ?? this.discardReason,
      reversesMovementIdentifier:
          reversesMovementIdentifier ?? this.reversesMovementIdentifier,
      occurredAt: occurredAt ?? this.occurredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (movementIdentifier.present) {
      map['movement_identifier'] = Variable<String>(movementIdentifier.value);
    }
    if (stockBatchIdentifier.present) {
      map['stock_batch_identifier'] = Variable<String>(
        stockBatchIdentifier.value,
      );
    }
    if (productIdentifier.present) {
      map['product_identifier'] = Variable<String>(productIdentifier.value);
    }
    if (compartmentIdentifier.present) {
      map['compartment_identifier'] = Variable<String>(
        compartmentIdentifier.value,
      );
    }
    if (movementKind.present) {
      map['movement_kind'] = Variable<String>(movementKind.value);
    }
    if (quantityDelta.present) {
      map['quantity_delta'] = Variable<int>(quantityDelta.value);
    }
    if (discardReason.present) {
      map['discard_reason'] = Variable<String>(discardReason.value);
    }
    if (reversesMovementIdentifier.present) {
      map['reverses_movement_identifier'] = Variable<String>(
        reversesMovementIdentifier.value,
      );
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryMovementsCompanion(')
          ..write('movementIdentifier: $movementIdentifier, ')
          ..write('stockBatchIdentifier: $stockBatchIdentifier, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('compartmentIdentifier: $compartmentIdentifier, ')
          ..write('movementKind: $movementKind, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('discardReason: $discardReason, ')
          ..write('reversesMovementIdentifier: $reversesMovementIdentifier, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduledNotificationRecordsTable extends ScheduledNotificationRecords
    with
        TableInfo<
          $ScheduledNotificationRecordsTable,
          ScheduledNotificationRecordRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduledNotificationRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _notificationIdentifierMeta =
      const VerificationMeta('notificationIdentifier');
  @override
  late final GeneratedColumn<int> notificationIdentifier = GeneratedColumn<int>(
    'notification_identifier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purposeMeta = const VerificationMeta(
    'purpose',
  );
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
    'purpose',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    notificationIdentifier,
    purpose,
    scheduledFor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scheduled_notification_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduledNotificationRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('notification_identifier')) {
      context.handle(
        _notificationIdentifierMeta,
        notificationIdentifier.isAcceptableOrUnknown(
          data['notification_identifier']!,
          _notificationIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('purpose')) {
      context.handle(
        _purposeMeta,
        purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta),
      );
    } else if (isInserting) {
      context.missing(_purposeMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {notificationIdentifier};
  @override
  ScheduledNotificationRecordRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduledNotificationRecordRow(
      notificationIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_identifier'],
      )!,
      purpose: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purpose'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
    );
  }

  @override
  $ScheduledNotificationRecordsTable createAlias(String alias) {
    return $ScheduledNotificationRecordsTable(attachedDatabase, alias);
  }
}

class ScheduledNotificationRecordRow extends DataClass
    implements Insertable<ScheduledNotificationRecordRow> {
  final int notificationIdentifier;

  /// Who scheduled it, for example `storage_reminders.digest`.
  final String purpose;

  /// Local wall-clock time the notification was scheduled for, stored as UTC.
  final DateTime scheduledFor;
  const ScheduledNotificationRecordRow({
    required this.notificationIdentifier,
    required this.purpose,
    required this.scheduledFor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['notification_identifier'] = Variable<int>(notificationIdentifier);
    map['purpose'] = Variable<String>(purpose);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    return map;
  }

  ScheduledNotificationRecordsCompanion toCompanion(bool nullToAbsent) {
    return ScheduledNotificationRecordsCompanion(
      notificationIdentifier: Value(notificationIdentifier),
      purpose: Value(purpose),
      scheduledFor: Value(scheduledFor),
    );
  }

  factory ScheduledNotificationRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduledNotificationRecordRow(
      notificationIdentifier: serializer.fromJson<int>(
        json['notificationIdentifier'],
      ),
      purpose: serializer.fromJson<String>(json['purpose']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'notificationIdentifier': serializer.toJson<int>(notificationIdentifier),
      'purpose': serializer.toJson<String>(purpose),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
    };
  }

  ScheduledNotificationRecordRow copyWith({
    int? notificationIdentifier,
    String? purpose,
    DateTime? scheduledFor,
  }) => ScheduledNotificationRecordRow(
    notificationIdentifier:
        notificationIdentifier ?? this.notificationIdentifier,
    purpose: purpose ?? this.purpose,
    scheduledFor: scheduledFor ?? this.scheduledFor,
  );
  ScheduledNotificationRecordRow copyWithCompanion(
    ScheduledNotificationRecordsCompanion data,
  ) {
    return ScheduledNotificationRecordRow(
      notificationIdentifier: data.notificationIdentifier.present
          ? data.notificationIdentifier.value
          : this.notificationIdentifier,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotificationRecordRow(')
          ..write('notificationIdentifier: $notificationIdentifier, ')
          ..write('purpose: $purpose, ')
          ..write('scheduledFor: $scheduledFor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(notificationIdentifier, purpose, scheduledFor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduledNotificationRecordRow &&
          other.notificationIdentifier == this.notificationIdentifier &&
          other.purpose == this.purpose &&
          other.scheduledFor == this.scheduledFor);
}

class ScheduledNotificationRecordsCompanion
    extends UpdateCompanion<ScheduledNotificationRecordRow> {
  final Value<int> notificationIdentifier;
  final Value<String> purpose;
  final Value<DateTime> scheduledFor;
  const ScheduledNotificationRecordsCompanion({
    this.notificationIdentifier = const Value.absent(),
    this.purpose = const Value.absent(),
    this.scheduledFor = const Value.absent(),
  });
  ScheduledNotificationRecordsCompanion.insert({
    this.notificationIdentifier = const Value.absent(),
    required String purpose,
    required DateTime scheduledFor,
  }) : purpose = Value(purpose),
       scheduledFor = Value(scheduledFor);
  static Insertable<ScheduledNotificationRecordRow> custom({
    Expression<int>? notificationIdentifier,
    Expression<String>? purpose,
    Expression<DateTime>? scheduledFor,
  }) {
    return RawValuesInsertable({
      if (notificationIdentifier != null)
        'notification_identifier': notificationIdentifier,
      if (purpose != null) 'purpose': purpose,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
    });
  }

  ScheduledNotificationRecordsCompanion copyWith({
    Value<int>? notificationIdentifier,
    Value<String>? purpose,
    Value<DateTime>? scheduledFor,
  }) {
    return ScheduledNotificationRecordsCompanion(
      notificationIdentifier:
          notificationIdentifier ?? this.notificationIdentifier,
      purpose: purpose ?? this.purpose,
      scheduledFor: scheduledFor ?? this.scheduledFor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (notificationIdentifier.present) {
      map['notification_identifier'] = Variable<int>(
        notificationIdentifier.value,
      );
    }
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduledNotificationRecordsCompanion(')
          ..write('notificationIdentifier: $notificationIdentifier, ')
          ..write('purpose: $purpose, ')
          ..write('scheduledFor: $scheduledFor')
          ..write(')'))
        .toString();
  }
}

class $RestockRulesTable extends RestockRules
    with TableInfo<$RestockRulesTable, RestockRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RestockRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdentifierMeta = const VerificationMeta(
    'productIdentifier',
  );
  @override
  late final GeneratedColumn<String> productIdentifier =
      GeneratedColumn<String>(
        'product_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES products (product_identifier)',
        ),
      );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minimumQuantityMeta = const VerificationMeta(
    'minimumQuantity',
  );
  @override
  late final GeneratedColumn<int> minimumQuantity = GeneratedColumn<int>(
    'minimum_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetQuantityMeta = const VerificationMeta(
    'targetQuantity',
  );
  @override
  late final GeneratedColumn<int> targetQuantity = GeneratedColumn<int>(
    'target_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productIdentifier,
    quantityUnit,
    minimumQuantity,
    targetQuantity,
    isActive,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'restock_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RestockRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_identifier')) {
      context.handle(
        _productIdentifierMeta,
        productIdentifier.isAcceptableOrUnknown(
          data['product_identifier']!,
          _productIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productIdentifierMeta);
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('minimum_quantity')) {
      context.handle(
        _minimumQuantityMeta,
        minimumQuantity.isAcceptableOrUnknown(
          data['minimum_quantity']!,
          _minimumQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minimumQuantityMeta);
    }
    if (data.containsKey('target_quantity')) {
      context.handle(
        _targetQuantityMeta,
        targetQuantity.isAcceptableOrUnknown(
          data['target_quantity']!,
          _targetQuantityMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productIdentifier};
  @override
  RestockRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RestockRuleRow(
      productIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_identifier'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      minimumQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minimum_quantity'],
      )!,
      targetQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_quantity'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RestockRulesTable createAlias(String alias) {
    return $RestockRulesTable(attachedDatabase, alias);
  }
}

class RestockRuleRow extends DataClass implements Insertable<RestockRuleRow> {
  final String productIdentifier;

  /// The product's canonical unit, copied for self-contained rows.
  final String quantityUnit;

  /// Below this, in base units, the product is running low.
  final int minimumQuantity;

  /// What to buy up to; `null` means up to the minimum, at least one package.
  final int? targetQuantity;
  final bool isActive;
  final DateTime updatedAt;
  const RestockRuleRow({
    required this.productIdentifier,
    required this.quantityUnit,
    required this.minimumQuantity,
    this.targetQuantity,
    required this.isActive,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_identifier'] = Variable<String>(productIdentifier);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    map['minimum_quantity'] = Variable<int>(minimumQuantity);
    if (!nullToAbsent || targetQuantity != null) {
      map['target_quantity'] = Variable<int>(targetQuantity);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RestockRulesCompanion toCompanion(bool nullToAbsent) {
    return RestockRulesCompanion(
      productIdentifier: Value(productIdentifier),
      quantityUnit: Value(quantityUnit),
      minimumQuantity: Value(minimumQuantity),
      targetQuantity: targetQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(targetQuantity),
      isActive: Value(isActive),
      updatedAt: Value(updatedAt),
    );
  }

  factory RestockRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RestockRuleRow(
      productIdentifier: serializer.fromJson<String>(json['productIdentifier']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      minimumQuantity: serializer.fromJson<int>(json['minimumQuantity']),
      targetQuantity: serializer.fromJson<int?>(json['targetQuantity']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productIdentifier': serializer.toJson<String>(productIdentifier),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'minimumQuantity': serializer.toJson<int>(minimumQuantity),
      'targetQuantity': serializer.toJson<int?>(targetQuantity),
      'isActive': serializer.toJson<bool>(isActive),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RestockRuleRow copyWith({
    String? productIdentifier,
    String? quantityUnit,
    int? minimumQuantity,
    Value<int?> targetQuantity = const Value.absent(),
    bool? isActive,
    DateTime? updatedAt,
  }) => RestockRuleRow(
    productIdentifier: productIdentifier ?? this.productIdentifier,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    minimumQuantity: minimumQuantity ?? this.minimumQuantity,
    targetQuantity: targetQuantity.present
        ? targetQuantity.value
        : this.targetQuantity,
    isActive: isActive ?? this.isActive,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RestockRuleRow copyWithCompanion(RestockRulesCompanion data) {
    return RestockRuleRow(
      productIdentifier: data.productIdentifier.present
          ? data.productIdentifier.value
          : this.productIdentifier,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      minimumQuantity: data.minimumQuantity.present
          ? data.minimumQuantity.value
          : this.minimumQuantity,
      targetQuantity: data.targetQuantity.present
          ? data.targetQuantity.value
          : this.targetQuantity,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RestockRuleRow(')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('minimumQuantity: $minimumQuantity, ')
          ..write('targetQuantity: $targetQuantity, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    productIdentifier,
    quantityUnit,
    minimumQuantity,
    targetQuantity,
    isActive,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RestockRuleRow &&
          other.productIdentifier == this.productIdentifier &&
          other.quantityUnit == this.quantityUnit &&
          other.minimumQuantity == this.minimumQuantity &&
          other.targetQuantity == this.targetQuantity &&
          other.isActive == this.isActive &&
          other.updatedAt == this.updatedAt);
}

class RestockRulesCompanion extends UpdateCompanion<RestockRuleRow> {
  final Value<String> productIdentifier;
  final Value<String> quantityUnit;
  final Value<int> minimumQuantity;
  final Value<int?> targetQuantity;
  final Value<bool> isActive;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RestockRulesCompanion({
    this.productIdentifier = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.minimumQuantity = const Value.absent(),
    this.targetQuantity = const Value.absent(),
    this.isActive = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RestockRulesCompanion.insert({
    required String productIdentifier,
    required String quantityUnit,
    required int minimumQuantity,
    this.targetQuantity = const Value.absent(),
    required bool isActive,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : productIdentifier = Value(productIdentifier),
       quantityUnit = Value(quantityUnit),
       minimumQuantity = Value(minimumQuantity),
       isActive = Value(isActive),
       updatedAt = Value(updatedAt);
  static Insertable<RestockRuleRow> custom({
    Expression<String>? productIdentifier,
    Expression<String>? quantityUnit,
    Expression<int>? minimumQuantity,
    Expression<int>? targetQuantity,
    Expression<bool>? isActive,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productIdentifier != null) 'product_identifier': productIdentifier,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (minimumQuantity != null) 'minimum_quantity': minimumQuantity,
      if (targetQuantity != null) 'target_quantity': targetQuantity,
      if (isActive != null) 'is_active': isActive,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RestockRulesCompanion copyWith({
    Value<String>? productIdentifier,
    Value<String>? quantityUnit,
    Value<int>? minimumQuantity,
    Value<int?>? targetQuantity,
    Value<bool>? isActive,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RestockRulesCompanion(
      productIdentifier: productIdentifier ?? this.productIdentifier,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productIdentifier.present) {
      map['product_identifier'] = Variable<String>(productIdentifier.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (minimumQuantity.present) {
      map['minimum_quantity'] = Variable<int>(minimumQuantity.value);
    }
    if (targetQuantity.present) {
      map['target_quantity'] = Variable<int>(targetQuantity.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RestockRulesCompanion(')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('minimumQuantity: $minimumQuantity, ')
          ..write('targetQuantity: $targetQuantity, ')
          ..write('isActive: $isActive, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListEntriesTable extends ShoppingListEntries
    with TableInfo<$ShoppingListEntriesTable, ShoppingListEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _shoppingListEntryIdentifierMeta =
      const VerificationMeta('shoppingListEntryIdentifier');
  @override
  late final GeneratedColumn<String> shoppingListEntryIdentifier =
      GeneratedColumn<String>(
        'shopping_list_entry_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _productIdentifierMeta = const VerificationMeta(
    'productIdentifier',
  );
  @override
  late final GeneratedColumn<String> productIdentifier =
      GeneratedColumn<String>(
        'product_identifier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES products (product_identifier)',
        ),
      );
  static const VerificationMeta _freeTextNameMeta = const VerificationMeta(
    'freeTextName',
  );
  @override
  late final GeneratedColumn<String> freeTextName = GeneratedColumn<String>(
    'free_text_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedQuantityMeta = const VerificationMeta(
    'requestedQuantity',
  );
  @override
  late final GeneratedColumn<int> requestedQuantity = GeneratedColumn<int>(
    'requested_quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedAtMeta = const VerificationMeta(
    'checkedAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedAt = GeneratedColumn<DateTime>(
    'checked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    shoppingListEntryIdentifier,
    productIdentifier,
    freeTextName,
    quantityUnit,
    requestedQuantity,
    origin,
    createdAt,
    checkedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShoppingListEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('shopping_list_entry_identifier')) {
      context.handle(
        _shoppingListEntryIdentifierMeta,
        shoppingListEntryIdentifier.isAcceptableOrUnknown(
          data['shopping_list_entry_identifier']!,
          _shoppingListEntryIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_shoppingListEntryIdentifierMeta);
    }
    if (data.containsKey('product_identifier')) {
      context.handle(
        _productIdentifierMeta,
        productIdentifier.isAcceptableOrUnknown(
          data['product_identifier']!,
          _productIdentifierMeta,
        ),
      );
    }
    if (data.containsKey('free_text_name')) {
      context.handle(
        _freeTextNameMeta,
        freeTextName.isAcceptableOrUnknown(
          data['free_text_name']!,
          _freeTextNameMeta,
        ),
      );
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    }
    if (data.containsKey('requested_quantity')) {
      context.handle(
        _requestedQuantityMeta,
        requestedQuantity.isAcceptableOrUnknown(
          data['requested_quantity']!,
          _requestedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    } else if (isInserting) {
      context.missing(_originMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('checked_at')) {
      context.handle(
        _checkedAtMeta,
        checkedAt.isAcceptableOrUnknown(data['checked_at']!, _checkedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {shoppingListEntryIdentifier};
  @override
  ShoppingListEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingListEntryRow(
      shoppingListEntryIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shopping_list_entry_identifier'],
      )!,
      productIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_identifier'],
      ),
      freeTextName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}free_text_name'],
      ),
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      ),
      requestedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_quantity'],
      ),
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      checkedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_at'],
      ),
    );
  }

  @override
  $ShoppingListEntriesTable createAlias(String alias) {
    return $ShoppingListEntriesTable(attachedDatabase, alias);
  }
}

class ShoppingListEntryRow extends DataClass
    implements Insertable<ShoppingListEntryRow> {
  final String shoppingListEntryIdentifier;
  final String? productIdentifier;

  /// For something that is not a product in the catalog.
  final String? freeTextName;

  /// `null` for free text entries.
  final String? quantityUnit;

  /// In base units of [quantityUnit]; `null` for free text entries.
  final int? requestedQuantity;

  /// `manual` or `restock`.
  final String origin;
  final DateTime createdAt;

  /// Set while the entry is ticked as bought.
  final DateTime? checkedAt;
  const ShoppingListEntryRow({
    required this.shoppingListEntryIdentifier,
    this.productIdentifier,
    this.freeTextName,
    this.quantityUnit,
    this.requestedQuantity,
    required this.origin,
    required this.createdAt,
    this.checkedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['shopping_list_entry_identifier'] = Variable<String>(
      shoppingListEntryIdentifier,
    );
    if (!nullToAbsent || productIdentifier != null) {
      map['product_identifier'] = Variable<String>(productIdentifier);
    }
    if (!nullToAbsent || freeTextName != null) {
      map['free_text_name'] = Variable<String>(freeTextName);
    }
    if (!nullToAbsent || quantityUnit != null) {
      map['quantity_unit'] = Variable<String>(quantityUnit);
    }
    if (!nullToAbsent || requestedQuantity != null) {
      map['requested_quantity'] = Variable<int>(requestedQuantity);
    }
    map['origin'] = Variable<String>(origin);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || checkedAt != null) {
      map['checked_at'] = Variable<DateTime>(checkedAt);
    }
    return map;
  }

  ShoppingListEntriesCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListEntriesCompanion(
      shoppingListEntryIdentifier: Value(shoppingListEntryIdentifier),
      productIdentifier: productIdentifier == null && nullToAbsent
          ? const Value.absent()
          : Value(productIdentifier),
      freeTextName: freeTextName == null && nullToAbsent
          ? const Value.absent()
          : Value(freeTextName),
      quantityUnit: quantityUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(quantityUnit),
      requestedQuantity: requestedQuantity == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedQuantity),
      origin: Value(origin),
      createdAt: Value(createdAt),
      checkedAt: checkedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkedAt),
    );
  }

  factory ShoppingListEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingListEntryRow(
      shoppingListEntryIdentifier: serializer.fromJson<String>(
        json['shoppingListEntryIdentifier'],
      ),
      productIdentifier: serializer.fromJson<String?>(
        json['productIdentifier'],
      ),
      freeTextName: serializer.fromJson<String?>(json['freeTextName']),
      quantityUnit: serializer.fromJson<String?>(json['quantityUnit']),
      requestedQuantity: serializer.fromJson<int?>(json['requestedQuantity']),
      origin: serializer.fromJson<String>(json['origin']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      checkedAt: serializer.fromJson<DateTime?>(json['checkedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'shoppingListEntryIdentifier': serializer.toJson<String>(
        shoppingListEntryIdentifier,
      ),
      'productIdentifier': serializer.toJson<String?>(productIdentifier),
      'freeTextName': serializer.toJson<String?>(freeTextName),
      'quantityUnit': serializer.toJson<String?>(quantityUnit),
      'requestedQuantity': serializer.toJson<int?>(requestedQuantity),
      'origin': serializer.toJson<String>(origin),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'checkedAt': serializer.toJson<DateTime?>(checkedAt),
    };
  }

  ShoppingListEntryRow copyWith({
    String? shoppingListEntryIdentifier,
    Value<String?> productIdentifier = const Value.absent(),
    Value<String?> freeTextName = const Value.absent(),
    Value<String?> quantityUnit = const Value.absent(),
    Value<int?> requestedQuantity = const Value.absent(),
    String? origin,
    DateTime? createdAt,
    Value<DateTime?> checkedAt = const Value.absent(),
  }) => ShoppingListEntryRow(
    shoppingListEntryIdentifier:
        shoppingListEntryIdentifier ?? this.shoppingListEntryIdentifier,
    productIdentifier: productIdentifier.present
        ? productIdentifier.value
        : this.productIdentifier,
    freeTextName: freeTextName.present ? freeTextName.value : this.freeTextName,
    quantityUnit: quantityUnit.present ? quantityUnit.value : this.quantityUnit,
    requestedQuantity: requestedQuantity.present
        ? requestedQuantity.value
        : this.requestedQuantity,
    origin: origin ?? this.origin,
    createdAt: createdAt ?? this.createdAt,
    checkedAt: checkedAt.present ? checkedAt.value : this.checkedAt,
  );
  ShoppingListEntryRow copyWithCompanion(ShoppingListEntriesCompanion data) {
    return ShoppingListEntryRow(
      shoppingListEntryIdentifier: data.shoppingListEntryIdentifier.present
          ? data.shoppingListEntryIdentifier.value
          : this.shoppingListEntryIdentifier,
      productIdentifier: data.productIdentifier.present
          ? data.productIdentifier.value
          : this.productIdentifier,
      freeTextName: data.freeTextName.present
          ? data.freeTextName.value
          : this.freeTextName,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      requestedQuantity: data.requestedQuantity.present
          ? data.requestedQuantity.value
          : this.requestedQuantity,
      origin: data.origin.present ? data.origin.value : this.origin,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      checkedAt: data.checkedAt.present ? data.checkedAt.value : this.checkedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListEntryRow(')
          ..write('shoppingListEntryIdentifier: $shoppingListEntryIdentifier, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('freeTextName: $freeTextName, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('requestedQuantity: $requestedQuantity, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('checkedAt: $checkedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    shoppingListEntryIdentifier,
    productIdentifier,
    freeTextName,
    quantityUnit,
    requestedQuantity,
    origin,
    createdAt,
    checkedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingListEntryRow &&
          other.shoppingListEntryIdentifier ==
              this.shoppingListEntryIdentifier &&
          other.productIdentifier == this.productIdentifier &&
          other.freeTextName == this.freeTextName &&
          other.quantityUnit == this.quantityUnit &&
          other.requestedQuantity == this.requestedQuantity &&
          other.origin == this.origin &&
          other.createdAt == this.createdAt &&
          other.checkedAt == this.checkedAt);
}

class ShoppingListEntriesCompanion
    extends UpdateCompanion<ShoppingListEntryRow> {
  final Value<String> shoppingListEntryIdentifier;
  final Value<String?> productIdentifier;
  final Value<String?> freeTextName;
  final Value<String?> quantityUnit;
  final Value<int?> requestedQuantity;
  final Value<String> origin;
  final Value<DateTime> createdAt;
  final Value<DateTime?> checkedAt;
  final Value<int> rowid;
  const ShoppingListEntriesCompanion({
    this.shoppingListEntryIdentifier = const Value.absent(),
    this.productIdentifier = const Value.absent(),
    this.freeTextName = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.requestedQuantity = const Value.absent(),
    this.origin = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.checkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListEntriesCompanion.insert({
    required String shoppingListEntryIdentifier,
    this.productIdentifier = const Value.absent(),
    this.freeTextName = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.requestedQuantity = const Value.absent(),
    required String origin,
    required DateTime createdAt,
    this.checkedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : shoppingListEntryIdentifier = Value(shoppingListEntryIdentifier),
       origin = Value(origin),
       createdAt = Value(createdAt);
  static Insertable<ShoppingListEntryRow> custom({
    Expression<String>? shoppingListEntryIdentifier,
    Expression<String>? productIdentifier,
    Expression<String>? freeTextName,
    Expression<String>? quantityUnit,
    Expression<int>? requestedQuantity,
    Expression<String>? origin,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? checkedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (shoppingListEntryIdentifier != null)
        'shopping_list_entry_identifier': shoppingListEntryIdentifier,
      if (productIdentifier != null) 'product_identifier': productIdentifier,
      if (freeTextName != null) 'free_text_name': freeTextName,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (requestedQuantity != null) 'requested_quantity': requestedQuantity,
      if (origin != null) 'origin': origin,
      if (createdAt != null) 'created_at': createdAt,
      if (checkedAt != null) 'checked_at': checkedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListEntriesCompanion copyWith({
    Value<String>? shoppingListEntryIdentifier,
    Value<String?>? productIdentifier,
    Value<String?>? freeTextName,
    Value<String?>? quantityUnit,
    Value<int?>? requestedQuantity,
    Value<String>? origin,
    Value<DateTime>? createdAt,
    Value<DateTime?>? checkedAt,
    Value<int>? rowid,
  }) {
    return ShoppingListEntriesCompanion(
      shoppingListEntryIdentifier:
          shoppingListEntryIdentifier ?? this.shoppingListEntryIdentifier,
      productIdentifier: productIdentifier ?? this.productIdentifier,
      freeTextName: freeTextName ?? this.freeTextName,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      origin: origin ?? this.origin,
      createdAt: createdAt ?? this.createdAt,
      checkedAt: checkedAt ?? this.checkedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (shoppingListEntryIdentifier.present) {
      map['shopping_list_entry_identifier'] = Variable<String>(
        shoppingListEntryIdentifier.value,
      );
    }
    if (productIdentifier.present) {
      map['product_identifier'] = Variable<String>(productIdentifier.value);
    }
    if (freeTextName.present) {
      map['free_text_name'] = Variable<String>(freeTextName.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (requestedQuantity.present) {
      map['requested_quantity'] = Variable<int>(requestedQuantity.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (checkedAt.present) {
      map['checked_at'] = Variable<DateTime>(checkedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListEntriesCompanion(')
          ..write('shoppingListEntryIdentifier: $shoppingListEntryIdentifier, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('freeTextName: $freeTextName, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('requestedQuantity: $requestedQuantity, ')
          ..write('origin: $origin, ')
          ..write('createdAt: $createdAt, ')
          ..write('checkedAt: $checkedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemPicturesTable extends ItemPictures
    with TableInfo<$ItemPicturesTable, ItemPictureRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemPicturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemPictureIdentifierMeta =
      const VerificationMeta('itemPictureIdentifier');
  @override
  late final GeneratedColumn<String> itemPictureIdentifier =
      GeneratedColumn<String>(
        'item_picture_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ownerKindMeta = const VerificationMeta(
    'ownerKind',
  );
  @override
  late final GeneratedColumn<String> ownerKind = GeneratedColumn<String>(
    'owner_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdentifierMeta = const VerificationMeta(
    'ownerIdentifier',
  );
  @override
  late final GeneratedColumn<String> ownerIdentifier = GeneratedColumn<String>(
    'owner_identifier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedFileNameMeta = const VerificationMeta(
    'encryptedFileName',
  );
  @override
  late final GeneratedColumn<String> encryptedFileName =
      GeneratedColumn<String>(
        'encrypted_file_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _thumbnailFileNameMeta = const VerificationMeta(
    'thumbnailFileName',
  );
  @override
  late final GeneratedColumn<String> thumbnailFileName =
      GeneratedColumn<String>(
        'thumbnail_file_name',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _widthPixelsMeta = const VerificationMeta(
    'widthPixels',
  );
  @override
  late final GeneratedColumn<int> widthPixels = GeneratedColumn<int>(
    'width_pixels',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightPixelsMeta = const VerificationMeta(
    'heightPixels',
  );
  @override
  late final GeneratedColumn<int> heightPixels = GeneratedColumn<int>(
    'height_pixels',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemPictureIdentifier,
    ownerKind,
    ownerIdentifier,
    encryptedFileName,
    thumbnailFileName,
    widthPixels,
    heightPixels,
    byteSize,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_pictures';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemPictureRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_picture_identifier')) {
      context.handle(
        _itemPictureIdentifierMeta,
        itemPictureIdentifier.isAcceptableOrUnknown(
          data['item_picture_identifier']!,
          _itemPictureIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_itemPictureIdentifierMeta);
    }
    if (data.containsKey('owner_kind')) {
      context.handle(
        _ownerKindMeta,
        ownerKind.isAcceptableOrUnknown(data['owner_kind']!, _ownerKindMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerKindMeta);
    }
    if (data.containsKey('owner_identifier')) {
      context.handle(
        _ownerIdentifierMeta,
        ownerIdentifier.isAcceptableOrUnknown(
          data['owner_identifier']!,
          _ownerIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ownerIdentifierMeta);
    }
    if (data.containsKey('encrypted_file_name')) {
      context.handle(
        _encryptedFileNameMeta,
        encryptedFileName.isAcceptableOrUnknown(
          data['encrypted_file_name']!,
          _encryptedFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedFileNameMeta);
    }
    if (data.containsKey('thumbnail_file_name')) {
      context.handle(
        _thumbnailFileNameMeta,
        thumbnailFileName.isAcceptableOrUnknown(
          data['thumbnail_file_name']!,
          _thumbnailFileNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailFileNameMeta);
    }
    if (data.containsKey('width_pixels')) {
      context.handle(
        _widthPixelsMeta,
        widthPixels.isAcceptableOrUnknown(
          data['width_pixels']!,
          _widthPixelsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_widthPixelsMeta);
    }
    if (data.containsKey('height_pixels')) {
      context.handle(
        _heightPixelsMeta,
        heightPixels.isAcceptableOrUnknown(
          data['height_pixels']!,
          _heightPixelsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heightPixelsMeta);
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemPictureIdentifier};
  @override
  ItemPictureRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemPictureRow(
      itemPictureIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_picture_identifier'],
      )!,
      ownerKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_kind'],
      )!,
      ownerIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_identifier'],
      )!,
      encryptedFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_file_name'],
      )!,
      thumbnailFileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_file_name'],
      )!,
      widthPixels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width_pixels'],
      )!,
      heightPixels: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_pixels'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ItemPicturesTable createAlias(String alias) {
    return $ItemPicturesTable(attachedDatabase, alias);
  }
}

class ItemPictureRow extends DataClass implements Insertable<ItemPictureRow> {
  final String itemPictureIdentifier;

  /// `product` or `stock_batch`. No foreign key, because the owner is one of
  /// two tables; the module removes pictures of removed owners itself.
  final String ownerKind;
  final String ownerIdentifier;
  final String encryptedFileName;
  final String thumbnailFileName;
  final int widthPixels;
  final int heightPixels;
  final int byteSize;
  final DateTime createdAt;
  const ItemPictureRow({
    required this.itemPictureIdentifier,
    required this.ownerKind,
    required this.ownerIdentifier,
    required this.encryptedFileName,
    required this.thumbnailFileName,
    required this.widthPixels,
    required this.heightPixels,
    required this.byteSize,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_picture_identifier'] = Variable<String>(itemPictureIdentifier);
    map['owner_kind'] = Variable<String>(ownerKind);
    map['owner_identifier'] = Variable<String>(ownerIdentifier);
    map['encrypted_file_name'] = Variable<String>(encryptedFileName);
    map['thumbnail_file_name'] = Variable<String>(thumbnailFileName);
    map['width_pixels'] = Variable<int>(widthPixels);
    map['height_pixels'] = Variable<int>(heightPixels);
    map['byte_size'] = Variable<int>(byteSize);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ItemPicturesCompanion toCompanion(bool nullToAbsent) {
    return ItemPicturesCompanion(
      itemPictureIdentifier: Value(itemPictureIdentifier),
      ownerKind: Value(ownerKind),
      ownerIdentifier: Value(ownerIdentifier),
      encryptedFileName: Value(encryptedFileName),
      thumbnailFileName: Value(thumbnailFileName),
      widthPixels: Value(widthPixels),
      heightPixels: Value(heightPixels),
      byteSize: Value(byteSize),
      createdAt: Value(createdAt),
    );
  }

  factory ItemPictureRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemPictureRow(
      itemPictureIdentifier: serializer.fromJson<String>(
        json['itemPictureIdentifier'],
      ),
      ownerKind: serializer.fromJson<String>(json['ownerKind']),
      ownerIdentifier: serializer.fromJson<String>(json['ownerIdentifier']),
      encryptedFileName: serializer.fromJson<String>(json['encryptedFileName']),
      thumbnailFileName: serializer.fromJson<String>(json['thumbnailFileName']),
      widthPixels: serializer.fromJson<int>(json['widthPixels']),
      heightPixels: serializer.fromJson<int>(json['heightPixels']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemPictureIdentifier': serializer.toJson<String>(itemPictureIdentifier),
      'ownerKind': serializer.toJson<String>(ownerKind),
      'ownerIdentifier': serializer.toJson<String>(ownerIdentifier),
      'encryptedFileName': serializer.toJson<String>(encryptedFileName),
      'thumbnailFileName': serializer.toJson<String>(thumbnailFileName),
      'widthPixels': serializer.toJson<int>(widthPixels),
      'heightPixels': serializer.toJson<int>(heightPixels),
      'byteSize': serializer.toJson<int>(byteSize),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ItemPictureRow copyWith({
    String? itemPictureIdentifier,
    String? ownerKind,
    String? ownerIdentifier,
    String? encryptedFileName,
    String? thumbnailFileName,
    int? widthPixels,
    int? heightPixels,
    int? byteSize,
    DateTime? createdAt,
  }) => ItemPictureRow(
    itemPictureIdentifier: itemPictureIdentifier ?? this.itemPictureIdentifier,
    ownerKind: ownerKind ?? this.ownerKind,
    ownerIdentifier: ownerIdentifier ?? this.ownerIdentifier,
    encryptedFileName: encryptedFileName ?? this.encryptedFileName,
    thumbnailFileName: thumbnailFileName ?? this.thumbnailFileName,
    widthPixels: widthPixels ?? this.widthPixels,
    heightPixels: heightPixels ?? this.heightPixels,
    byteSize: byteSize ?? this.byteSize,
    createdAt: createdAt ?? this.createdAt,
  );
  ItemPictureRow copyWithCompanion(ItemPicturesCompanion data) {
    return ItemPictureRow(
      itemPictureIdentifier: data.itemPictureIdentifier.present
          ? data.itemPictureIdentifier.value
          : this.itemPictureIdentifier,
      ownerKind: data.ownerKind.present ? data.ownerKind.value : this.ownerKind,
      ownerIdentifier: data.ownerIdentifier.present
          ? data.ownerIdentifier.value
          : this.ownerIdentifier,
      encryptedFileName: data.encryptedFileName.present
          ? data.encryptedFileName.value
          : this.encryptedFileName,
      thumbnailFileName: data.thumbnailFileName.present
          ? data.thumbnailFileName.value
          : this.thumbnailFileName,
      widthPixels: data.widthPixels.present
          ? data.widthPixels.value
          : this.widthPixels,
      heightPixels: data.heightPixels.present
          ? data.heightPixels.value
          : this.heightPixels,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemPictureRow(')
          ..write('itemPictureIdentifier: $itemPictureIdentifier, ')
          ..write('ownerKind: $ownerKind, ')
          ..write('ownerIdentifier: $ownerIdentifier, ')
          ..write('encryptedFileName: $encryptedFileName, ')
          ..write('thumbnailFileName: $thumbnailFileName, ')
          ..write('widthPixels: $widthPixels, ')
          ..write('heightPixels: $heightPixels, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemPictureIdentifier,
    ownerKind,
    ownerIdentifier,
    encryptedFileName,
    thumbnailFileName,
    widthPixels,
    heightPixels,
    byteSize,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemPictureRow &&
          other.itemPictureIdentifier == this.itemPictureIdentifier &&
          other.ownerKind == this.ownerKind &&
          other.ownerIdentifier == this.ownerIdentifier &&
          other.encryptedFileName == this.encryptedFileName &&
          other.thumbnailFileName == this.thumbnailFileName &&
          other.widthPixels == this.widthPixels &&
          other.heightPixels == this.heightPixels &&
          other.byteSize == this.byteSize &&
          other.createdAt == this.createdAt);
}

class ItemPicturesCompanion extends UpdateCompanion<ItemPictureRow> {
  final Value<String> itemPictureIdentifier;
  final Value<String> ownerKind;
  final Value<String> ownerIdentifier;
  final Value<String> encryptedFileName;
  final Value<String> thumbnailFileName;
  final Value<int> widthPixels;
  final Value<int> heightPixels;
  final Value<int> byteSize;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ItemPicturesCompanion({
    this.itemPictureIdentifier = const Value.absent(),
    this.ownerKind = const Value.absent(),
    this.ownerIdentifier = const Value.absent(),
    this.encryptedFileName = const Value.absent(),
    this.thumbnailFileName = const Value.absent(),
    this.widthPixels = const Value.absent(),
    this.heightPixels = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemPicturesCompanion.insert({
    required String itemPictureIdentifier,
    required String ownerKind,
    required String ownerIdentifier,
    required String encryptedFileName,
    required String thumbnailFileName,
    required int widthPixels,
    required int heightPixels,
    required int byteSize,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : itemPictureIdentifier = Value(itemPictureIdentifier),
       ownerKind = Value(ownerKind),
       ownerIdentifier = Value(ownerIdentifier),
       encryptedFileName = Value(encryptedFileName),
       thumbnailFileName = Value(thumbnailFileName),
       widthPixels = Value(widthPixels),
       heightPixels = Value(heightPixels),
       byteSize = Value(byteSize),
       createdAt = Value(createdAt);
  static Insertable<ItemPictureRow> custom({
    Expression<String>? itemPictureIdentifier,
    Expression<String>? ownerKind,
    Expression<String>? ownerIdentifier,
    Expression<String>? encryptedFileName,
    Expression<String>? thumbnailFileName,
    Expression<int>? widthPixels,
    Expression<int>? heightPixels,
    Expression<int>? byteSize,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemPictureIdentifier != null)
        'item_picture_identifier': itemPictureIdentifier,
      if (ownerKind != null) 'owner_kind': ownerKind,
      if (ownerIdentifier != null) 'owner_identifier': ownerIdentifier,
      if (encryptedFileName != null) 'encrypted_file_name': encryptedFileName,
      if (thumbnailFileName != null) 'thumbnail_file_name': thumbnailFileName,
      if (widthPixels != null) 'width_pixels': widthPixels,
      if (heightPixels != null) 'height_pixels': heightPixels,
      if (byteSize != null) 'byte_size': byteSize,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemPicturesCompanion copyWith({
    Value<String>? itemPictureIdentifier,
    Value<String>? ownerKind,
    Value<String>? ownerIdentifier,
    Value<String>? encryptedFileName,
    Value<String>? thumbnailFileName,
    Value<int>? widthPixels,
    Value<int>? heightPixels,
    Value<int>? byteSize,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ItemPicturesCompanion(
      itemPictureIdentifier:
          itemPictureIdentifier ?? this.itemPictureIdentifier,
      ownerKind: ownerKind ?? this.ownerKind,
      ownerIdentifier: ownerIdentifier ?? this.ownerIdentifier,
      encryptedFileName: encryptedFileName ?? this.encryptedFileName,
      thumbnailFileName: thumbnailFileName ?? this.thumbnailFileName,
      widthPixels: widthPixels ?? this.widthPixels,
      heightPixels: heightPixels ?? this.heightPixels,
      byteSize: byteSize ?? this.byteSize,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemPictureIdentifier.present) {
      map['item_picture_identifier'] = Variable<String>(
        itemPictureIdentifier.value,
      );
    }
    if (ownerKind.present) {
      map['owner_kind'] = Variable<String>(ownerKind.value);
    }
    if (ownerIdentifier.present) {
      map['owner_identifier'] = Variable<String>(ownerIdentifier.value);
    }
    if (encryptedFileName.present) {
      map['encrypted_file_name'] = Variable<String>(encryptedFileName.value);
    }
    if (thumbnailFileName.present) {
      map['thumbnail_file_name'] = Variable<String>(thumbnailFileName.value);
    }
    if (widthPixels.present) {
      map['width_pixels'] = Variable<int>(widthPixels.value);
    }
    if (heightPixels.present) {
      map['height_pixels'] = Variable<int>(heightPixels.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemPicturesCompanion(')
          ..write('itemPictureIdentifier: $itemPictureIdentifier, ')
          ..write('ownerKind: $ownerKind, ')
          ..write('ownerIdentifier: $ownerIdentifier, ')
          ..write('encryptedFileName: $encryptedFileName, ')
          ..write('thumbnailFileName: $thumbnailFileName, ')
          ..write('widthPixels: $widthPixels, ')
          ..write('heightPixels: $heightPixels, ')
          ..write('byteSize: $byteSize, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductBarcodesTable extends ProductBarcodes
    with TableInfo<$ProductBarcodesTable, ProductBarcodeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductBarcodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _barcodeValueMeta = const VerificationMeta(
    'barcodeValue',
  );
  @override
  late final GeneratedColumn<String> barcodeValue = GeneratedColumn<String>(
    'barcode_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productIdentifierMeta = const VerificationMeta(
    'productIdentifier',
  );
  @override
  late final GeneratedColumn<String> productIdentifier =
      GeneratedColumn<String>(
        'product_identifier',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES products (product_identifier)',
        ),
      );
  static const VerificationMeta _symbologyMeta = const VerificationMeta(
    'symbology',
  );
  @override
  late final GeneratedColumn<String> symbology = GeneratedColumn<String>(
    'symbology',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isVariableMeasureMeta = const VerificationMeta(
    'isVariableMeasure',
  );
  @override
  late final GeneratedColumn<bool> isVariableMeasure = GeneratedColumn<bool>(
    'is_variable_measure',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_variable_measure" IN (0, 1))',
    ),
  );
  static const VerificationMeta _learnedAtMeta = const VerificationMeta(
    'learnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> learnedAt = GeneratedColumn<DateTime>(
    'learned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    barcodeValue,
    productIdentifier,
    symbology,
    isVariableMeasure,
    learnedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_barcodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductBarcodeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('barcode_value')) {
      context.handle(
        _barcodeValueMeta,
        barcodeValue.isAcceptableOrUnknown(
          data['barcode_value']!,
          _barcodeValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_barcodeValueMeta);
    }
    if (data.containsKey('product_identifier')) {
      context.handle(
        _productIdentifierMeta,
        productIdentifier.isAcceptableOrUnknown(
          data['product_identifier']!,
          _productIdentifierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productIdentifierMeta);
    }
    if (data.containsKey('symbology')) {
      context.handle(
        _symbologyMeta,
        symbology.isAcceptableOrUnknown(data['symbology']!, _symbologyMeta),
      );
    } else if (isInserting) {
      context.missing(_symbologyMeta);
    }
    if (data.containsKey('is_variable_measure')) {
      context.handle(
        _isVariableMeasureMeta,
        isVariableMeasure.isAcceptableOrUnknown(
          data['is_variable_measure']!,
          _isVariableMeasureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isVariableMeasureMeta);
    }
    if (data.containsKey('learned_at')) {
      context.handle(
        _learnedAtMeta,
        learnedAt.isAcceptableOrUnknown(data['learned_at']!, _learnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_learnedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {barcodeValue};
  @override
  ProductBarcodeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductBarcodeRow(
      barcodeValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode_value'],
      )!,
      productIdentifier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_identifier'],
      )!,
      symbology: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbology'],
      )!,
      isVariableMeasure: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_variable_measure'],
      )!,
      learnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}learned_at'],
      )!,
    );
  }

  @override
  $ProductBarcodesTable createAlias(String alias) {
    return $ProductBarcodesTable(attachedDatabase, alias);
  }
}

class ProductBarcodeRow extends DataClass
    implements Insertable<ProductBarcodeRow> {
  /// The code as scanned, or for weighed goods only its item part (for
  /// example `2412345` of `2412345012340`), so every package matches.
  final String barcodeValue;
  final String productIdentifier;

  /// `ean13`, `ean8`, `upc_a`, `upc_e`, `code128`, `qr_code` or `other`.
  final String symbology;

  /// A weighed-goods code (GS1 prefixes 02 and 20 to 29).
  final bool isVariableMeasure;
  final DateTime learnedAt;
  const ProductBarcodeRow({
    required this.barcodeValue,
    required this.productIdentifier,
    required this.symbology,
    required this.isVariableMeasure,
    required this.learnedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['barcode_value'] = Variable<String>(barcodeValue);
    map['product_identifier'] = Variable<String>(productIdentifier);
    map['symbology'] = Variable<String>(symbology);
    map['is_variable_measure'] = Variable<bool>(isVariableMeasure);
    map['learned_at'] = Variable<DateTime>(learnedAt);
    return map;
  }

  ProductBarcodesCompanion toCompanion(bool nullToAbsent) {
    return ProductBarcodesCompanion(
      barcodeValue: Value(barcodeValue),
      productIdentifier: Value(productIdentifier),
      symbology: Value(symbology),
      isVariableMeasure: Value(isVariableMeasure),
      learnedAt: Value(learnedAt),
    );
  }

  factory ProductBarcodeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductBarcodeRow(
      barcodeValue: serializer.fromJson<String>(json['barcodeValue']),
      productIdentifier: serializer.fromJson<String>(json['productIdentifier']),
      symbology: serializer.fromJson<String>(json['symbology']),
      isVariableMeasure: serializer.fromJson<bool>(json['isVariableMeasure']),
      learnedAt: serializer.fromJson<DateTime>(json['learnedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'barcodeValue': serializer.toJson<String>(barcodeValue),
      'productIdentifier': serializer.toJson<String>(productIdentifier),
      'symbology': serializer.toJson<String>(symbology),
      'isVariableMeasure': serializer.toJson<bool>(isVariableMeasure),
      'learnedAt': serializer.toJson<DateTime>(learnedAt),
    };
  }

  ProductBarcodeRow copyWith({
    String? barcodeValue,
    String? productIdentifier,
    String? symbology,
    bool? isVariableMeasure,
    DateTime? learnedAt,
  }) => ProductBarcodeRow(
    barcodeValue: barcodeValue ?? this.barcodeValue,
    productIdentifier: productIdentifier ?? this.productIdentifier,
    symbology: symbology ?? this.symbology,
    isVariableMeasure: isVariableMeasure ?? this.isVariableMeasure,
    learnedAt: learnedAt ?? this.learnedAt,
  );
  ProductBarcodeRow copyWithCompanion(ProductBarcodesCompanion data) {
    return ProductBarcodeRow(
      barcodeValue: data.barcodeValue.present
          ? data.barcodeValue.value
          : this.barcodeValue,
      productIdentifier: data.productIdentifier.present
          ? data.productIdentifier.value
          : this.productIdentifier,
      symbology: data.symbology.present ? data.symbology.value : this.symbology,
      isVariableMeasure: data.isVariableMeasure.present
          ? data.isVariableMeasure.value
          : this.isVariableMeasure,
      learnedAt: data.learnedAt.present ? data.learnedAt.value : this.learnedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductBarcodeRow(')
          ..write('barcodeValue: $barcodeValue, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('symbology: $symbology, ')
          ..write('isVariableMeasure: $isVariableMeasure, ')
          ..write('learnedAt: $learnedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    barcodeValue,
    productIdentifier,
    symbology,
    isVariableMeasure,
    learnedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductBarcodeRow &&
          other.barcodeValue == this.barcodeValue &&
          other.productIdentifier == this.productIdentifier &&
          other.symbology == this.symbology &&
          other.isVariableMeasure == this.isVariableMeasure &&
          other.learnedAt == this.learnedAt);
}

class ProductBarcodesCompanion extends UpdateCompanion<ProductBarcodeRow> {
  final Value<String> barcodeValue;
  final Value<String> productIdentifier;
  final Value<String> symbology;
  final Value<bool> isVariableMeasure;
  final Value<DateTime> learnedAt;
  final Value<int> rowid;
  const ProductBarcodesCompanion({
    this.barcodeValue = const Value.absent(),
    this.productIdentifier = const Value.absent(),
    this.symbology = const Value.absent(),
    this.isVariableMeasure = const Value.absent(),
    this.learnedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductBarcodesCompanion.insert({
    required String barcodeValue,
    required String productIdentifier,
    required String symbology,
    required bool isVariableMeasure,
    required DateTime learnedAt,
    this.rowid = const Value.absent(),
  }) : barcodeValue = Value(barcodeValue),
       productIdentifier = Value(productIdentifier),
       symbology = Value(symbology),
       isVariableMeasure = Value(isVariableMeasure),
       learnedAt = Value(learnedAt);
  static Insertable<ProductBarcodeRow> custom({
    Expression<String>? barcodeValue,
    Expression<String>? productIdentifier,
    Expression<String>? symbology,
    Expression<bool>? isVariableMeasure,
    Expression<DateTime>? learnedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (barcodeValue != null) 'barcode_value': barcodeValue,
      if (productIdentifier != null) 'product_identifier': productIdentifier,
      if (symbology != null) 'symbology': symbology,
      if (isVariableMeasure != null) 'is_variable_measure': isVariableMeasure,
      if (learnedAt != null) 'learned_at': learnedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductBarcodesCompanion copyWith({
    Value<String>? barcodeValue,
    Value<String>? productIdentifier,
    Value<String>? symbology,
    Value<bool>? isVariableMeasure,
    Value<DateTime>? learnedAt,
    Value<int>? rowid,
  }) {
    return ProductBarcodesCompanion(
      barcodeValue: barcodeValue ?? this.barcodeValue,
      productIdentifier: productIdentifier ?? this.productIdentifier,
      symbology: symbology ?? this.symbology,
      isVariableMeasure: isVariableMeasure ?? this.isVariableMeasure,
      learnedAt: learnedAt ?? this.learnedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (barcodeValue.present) {
      map['barcode_value'] = Variable<String>(barcodeValue.value);
    }
    if (productIdentifier.present) {
      map['product_identifier'] = Variable<String>(productIdentifier.value);
    }
    if (symbology.present) {
      map['symbology'] = Variable<String>(symbology.value);
    }
    if (isVariableMeasure.present) {
      map['is_variable_measure'] = Variable<bool>(isVariableMeasure.value);
    }
    if (learnedAt.present) {
      map['learned_at'] = Variable<DateTime>(learnedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductBarcodesCompanion(')
          ..write('barcodeValue: $barcodeValue, ')
          ..write('productIdentifier: $productIdentifier, ')
          ..write('symbology: $symbology, ')
          ..write('isVariableMeasure: $isVariableMeasure, ')
          ..write('learnedAt: $learnedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ApplicationDatabase extends GeneratedDatabase {
  _$ApplicationDatabase(QueryExecutor e) : super(e);
  $ApplicationDatabaseManager get managers => $ApplicationDatabaseManager(this);
  late final $PreferenceEntriesTable preferenceEntries =
      $PreferenceEntriesTable(this);
  late final $SchemaMetadataEntriesTable schemaMetadataEntries =
      $SchemaMetadataEntriesTable(this);
  late final $StoragePlacesTable storagePlaces = $StoragePlacesTable(this);
  late final $CompartmentsTable compartments = $CompartmentsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $StockBatchesTable stockBatches = $StockBatchesTable(this);
  late final $InventoryMovementsTable inventoryMovements =
      $InventoryMovementsTable(this);
  late final $ScheduledNotificationRecordsTable scheduledNotificationRecords =
      $ScheduledNotificationRecordsTable(this);
  late final $RestockRulesTable restockRules = $RestockRulesTable(this);
  late final $ShoppingListEntriesTable shoppingListEntries =
      $ShoppingListEntriesTable(this);
  late final $ItemPicturesTable itemPictures = $ItemPicturesTable(this);
  late final $ProductBarcodesTable productBarcodes = $ProductBarcodesTable(
    this,
  );
  late final Index inventoryMovementsByTime = Index(
    'inventory_movements_by_time',
    'CREATE INDEX inventory_movements_by_time ON inventory_movements (occurred_at)',
  );
  late final Index inventoryMovementsByProductAndTime = Index(
    'inventory_movements_by_product_and_time',
    'CREATE INDEX inventory_movements_by_product_and_time ON inventory_movements (product_identifier, occurred_at)',
  );
  late final Index inventoryMovementsByBatch = Index(
    'inventory_movements_by_batch',
    'CREATE INDEX inventory_movements_by_batch ON inventory_movements (stock_batch_identifier)',
  );
  late final Index itemPicturesByOwner = Index(
    'item_pictures_by_owner',
    'CREATE UNIQUE INDEX item_pictures_by_owner ON item_pictures (owner_kind, owner_identifier)',
  );
  late final Index productBarcodesByProduct = Index(
    'product_barcodes_by_product',
    'CREATE INDEX product_barcodes_by_product ON product_barcodes (product_identifier)',
  );
  late final PreferencesDao preferencesDao = PreferencesDao(
    this as ApplicationDatabase,
  );
  late final SchemaMetadataDao schemaMetadataDao = SchemaMetadataDao(
    this as ApplicationDatabase,
  );
  late final StorageLayoutDao storageLayoutDao = StorageLayoutDao(
    this as ApplicationDatabase,
  );
  late final ProductCatalogDao productCatalogDao = ProductCatalogDao(
    this as ApplicationDatabase,
  );
  late final InventoryDao inventoryDao = InventoryDao(
    this as ApplicationDatabase,
  );
  late final ScheduledNotificationsDao scheduledNotificationsDao =
      ScheduledNotificationsDao(this as ApplicationDatabase);
  late final RestockDao restockDao = RestockDao(this as ApplicationDatabase);
  late final ItemPicturesDao itemPicturesDao = ItemPicturesDao(
    this as ApplicationDatabase,
  );
  late final ProductBarcodesDao productBarcodesDao = ProductBarcodesDao(
    this as ApplicationDatabase,
  );
  late final StatisticsDao statisticsDao = StatisticsDao(
    this as ApplicationDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    preferenceEntries,
    schemaMetadataEntries,
    storagePlaces,
    compartments,
    categories,
    products,
    stockBatches,
    inventoryMovements,
    scheduledNotificationRecords,
    restockRules,
    shoppingListEntries,
    itemPictures,
    productBarcodes,
    inventoryMovementsByTime,
    inventoryMovementsByProductAndTime,
    inventoryMovementsByBatch,
    itemPicturesByOwner,
    productBarcodesByProduct,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$PreferenceEntriesTableCreateCompanionBuilder =
    PreferenceEntriesCompanion Function({
      required String preferenceKey,
      required String encodedValue,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PreferenceEntriesTableUpdateCompanionBuilder =
    PreferenceEntriesCompanion Function({
      Value<String> preferenceKey,
      Value<String> encodedValue,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PreferenceEntriesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $PreferenceEntriesTable> {
  $$PreferenceEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get preferenceKey => $composableBuilder(
    column: $table.preferenceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encodedValue => $composableBuilder(
    column: $table.encodedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreferenceEntriesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $PreferenceEntriesTable> {
  $$PreferenceEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get preferenceKey => $composableBuilder(
    column: $table.preferenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encodedValue => $composableBuilder(
    column: $table.encodedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreferenceEntriesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $PreferenceEntriesTable> {
  $$PreferenceEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get preferenceKey => $composableBuilder(
    column: $table.preferenceKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encodedValue => $composableBuilder(
    column: $table.encodedValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PreferenceEntriesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $PreferenceEntriesTable,
          PreferenceEntryRow,
          $$PreferenceEntriesTableFilterComposer,
          $$PreferenceEntriesTableOrderingComposer,
          $$PreferenceEntriesTableAnnotationComposer,
          $$PreferenceEntriesTableCreateCompanionBuilder,
          $$PreferenceEntriesTableUpdateCompanionBuilder,
          (
            PreferenceEntryRow,
            BaseReferences<
              _$ApplicationDatabase,
              $PreferenceEntriesTable,
              PreferenceEntryRow
            >,
          ),
          PreferenceEntryRow,
          PrefetchHooks Function()
        > {
  $$PreferenceEntriesTableTableManager(
    _$ApplicationDatabase db,
    $PreferenceEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> preferenceKey = const Value.absent(),
                Value<String> encodedValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferenceEntriesCompanion(
                preferenceKey: preferenceKey,
                encodedValue: encodedValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String preferenceKey,
                required String encodedValue,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PreferenceEntriesCompanion.insert(
                preferenceKey: preferenceKey,
                encodedValue: encodedValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferenceEntriesTable, PreferenceEntryRow>(
                    table,
                  ),
                  BaseReferences<
                    _$ApplicationDatabase,
                    $PreferenceEntriesTable,
                    PreferenceEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferenceEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $PreferenceEntriesTable,
      PreferenceEntryRow,
      $$PreferenceEntriesTableFilterComposer,
      $$PreferenceEntriesTableOrderingComposer,
      $$PreferenceEntriesTableAnnotationComposer,
      $$PreferenceEntriesTableCreateCompanionBuilder,
      $$PreferenceEntriesTableUpdateCompanionBuilder,
      (
        PreferenceEntryRow,
        BaseReferences<
          _$ApplicationDatabase,
          $PreferenceEntriesTable,
          PreferenceEntryRow
        >,
      ),
      PreferenceEntryRow,
      PrefetchHooks Function()
    >;
typedef $$SchemaMetadataEntriesTableCreateCompanionBuilder =
    SchemaMetadataEntriesCompanion Function({
      Value<int> singletonIdentifier,
      required int schemaVersion,
      required String lastMigratedByApplicationVersion,
      required DateTime migratedAt,
    });
typedef $$SchemaMetadataEntriesTableUpdateCompanionBuilder =
    SchemaMetadataEntriesCompanion Function({
      Value<int> singletonIdentifier,
      Value<int> schemaVersion,
      Value<String> lastMigratedByApplicationVersion,
      Value<DateTime> migratedAt,
    });

class $$SchemaMetadataEntriesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $SchemaMetadataEntriesTable> {
  $$SchemaMetadataEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get singletonIdentifier => $composableBuilder(
    column: $table.singletonIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMigratedByApplicationVersion =>
      $composableBuilder(
        column: $table.lastMigratedByApplicationVersion,
        builder: (column) => ColumnFilters(column),
      );

  ColumnFilters<DateTime> get migratedAt => $composableBuilder(
    column: $table.migratedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchemaMetadataEntriesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $SchemaMetadataEntriesTable> {
  $$SchemaMetadataEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get singletonIdentifier => $composableBuilder(
    column: $table.singletonIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMigratedByApplicationVersion =>
      $composableBuilder(
        column: $table.lastMigratedByApplicationVersion,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get migratedAt => $composableBuilder(
    column: $table.migratedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchemaMetadataEntriesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $SchemaMetadataEntriesTable> {
  $$SchemaMetadataEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get singletonIdentifier => $composableBuilder(
    column: $table.singletonIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastMigratedByApplicationVersion =>
      $composableBuilder(
        column: $table.lastMigratedByApplicationVersion,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get migratedAt => $composableBuilder(
    column: $table.migratedAt,
    builder: (column) => column,
  );
}

class $$SchemaMetadataEntriesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $SchemaMetadataEntriesTable,
          SchemaMetadataRow,
          $$SchemaMetadataEntriesTableFilterComposer,
          $$SchemaMetadataEntriesTableOrderingComposer,
          $$SchemaMetadataEntriesTableAnnotationComposer,
          $$SchemaMetadataEntriesTableCreateCompanionBuilder,
          $$SchemaMetadataEntriesTableUpdateCompanionBuilder,
          (
            SchemaMetadataRow,
            BaseReferences<
              _$ApplicationDatabase,
              $SchemaMetadataEntriesTable,
              SchemaMetadataRow
            >,
          ),
          SchemaMetadataRow,
          PrefetchHooks Function()
        > {
  $$SchemaMetadataEntriesTableTableManager(
    _$ApplicationDatabase db,
    $SchemaMetadataEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMetadataEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SchemaMetadataEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SchemaMetadataEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> singletonIdentifier = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> lastMigratedByApplicationVersion =
                    const Value.absent(),
                Value<DateTime> migratedAt = const Value.absent(),
              }) => SchemaMetadataEntriesCompanion(
                singletonIdentifier: singletonIdentifier,
                schemaVersion: schemaVersion,
                lastMigratedByApplicationVersion:
                    lastMigratedByApplicationVersion,
                migratedAt: migratedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> singletonIdentifier = const Value.absent(),
                required int schemaVersion,
                required String lastMigratedByApplicationVersion,
                required DateTime migratedAt,
              }) => SchemaMetadataEntriesCompanion.insert(
                singletonIdentifier: singletonIdentifier,
                schemaVersion: schemaVersion,
                lastMigratedByApplicationVersion:
                    lastMigratedByApplicationVersion,
                migratedAt: migratedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SchemaMetadataEntriesTable, SchemaMetadataRow>(
                    table,
                  ),
                  BaseReferences<
                    _$ApplicationDatabase,
                    $SchemaMetadataEntriesTable,
                    SchemaMetadataRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchemaMetadataEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $SchemaMetadataEntriesTable,
      SchemaMetadataRow,
      $$SchemaMetadataEntriesTableFilterComposer,
      $$SchemaMetadataEntriesTableOrderingComposer,
      $$SchemaMetadataEntriesTableAnnotationComposer,
      $$SchemaMetadataEntriesTableCreateCompanionBuilder,
      $$SchemaMetadataEntriesTableUpdateCompanionBuilder,
      (
        SchemaMetadataRow,
        BaseReferences<
          _$ApplicationDatabase,
          $SchemaMetadataEntriesTable,
          SchemaMetadataRow
        >,
      ),
      SchemaMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$StoragePlacesTableCreateCompanionBuilder =
    StoragePlacesCompanion Function({
      required String storagePlaceIdentifier,
      required String defaultNameKey,
      Value<String?> customName,
      required String storageKind,
      required int sortOrder,
      Value<bool> isArchived,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StoragePlacesTableUpdateCompanionBuilder =
    StoragePlacesCompanion Function({
      Value<String> storagePlaceIdentifier,
      Value<String> defaultNameKey,
      Value<String?> customName,
      Value<String> storageKind,
      Value<int> sortOrder,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StoragePlacesTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $StoragePlacesTable,
          StoragePlaceRow
        > {
  $$StoragePlacesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CompartmentsTable, List<CompartmentRow>>
  _compartmentsRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.compartments,
    aliasName:
        'storage_places__storage_place_identifier__compartments__storage_place_identifier',
  );

  $$CompartmentsTableProcessedTableManager get compartmentsRefs {
    final manager = $$CompartmentsTableTableManager($_db, $_db.compartments)
        .filter(
          (f) => f.storagePlaceIdentifier.storagePlaceIdentifier.sqlEquals(
            $_itemColumn<String>('storage_place_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_compartmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoragePlacesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $StoragePlacesTable> {
  $$StoragePlacesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get storagePlaceIdentifier => $composableBuilder(
    column: $table.storagePlaceIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultNameKey => $composableBuilder(
    column: $table.defaultNameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageKind => $composableBuilder(
    column: $table.storageKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> compartmentsRefs(
    Expression<bool> Function($$CompartmentsTableFilterComposer f) f,
  ) {
    final $$CompartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storagePlaceIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.storagePlaceIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableFilterComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoragePlacesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $StoragePlacesTable> {
  $$StoragePlacesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get storagePlaceIdentifier => $composableBuilder(
    column: $table.storagePlaceIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultNameKey => $composableBuilder(
    column: $table.defaultNameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageKind => $composableBuilder(
    column: $table.storageKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoragePlacesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $StoragePlacesTable> {
  $$StoragePlacesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get storagePlaceIdentifier => $composableBuilder(
    column: $table.storagePlaceIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultNameKey => $composableBuilder(
    column: $table.defaultNameKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storageKind => $composableBuilder(
    column: $table.storageKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> compartmentsRefs<T extends Object>(
    Expression<T> Function($$CompartmentsTableAnnotationComposer a) f,
  ) {
    final $$CompartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storagePlaceIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.storagePlaceIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoragePlacesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $StoragePlacesTable,
          StoragePlaceRow,
          $$StoragePlacesTableFilterComposer,
          $$StoragePlacesTableOrderingComposer,
          $$StoragePlacesTableAnnotationComposer,
          $$StoragePlacesTableCreateCompanionBuilder,
          $$StoragePlacesTableUpdateCompanionBuilder,
          (StoragePlaceRow, $$StoragePlacesTableReferences),
          StoragePlaceRow,
          PrefetchHooks Function({bool compartmentsRefs})
        > {
  $$StoragePlacesTableTableManager(
    _$ApplicationDatabase db,
    $StoragePlacesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoragePlacesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoragePlacesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoragePlacesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> storagePlaceIdentifier = const Value.absent(),
                Value<String> defaultNameKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String> storageKind = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoragePlacesCompanion(
                storagePlaceIdentifier: storagePlaceIdentifier,
                defaultNameKey: defaultNameKey,
                customName: customName,
                storageKind: storageKind,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storagePlaceIdentifier,
                required String defaultNameKey,
                Value<String?> customName = const Value.absent(),
                required String storageKind,
                required int sortOrder,
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StoragePlacesCompanion.insert(
                storagePlaceIdentifier: storagePlaceIdentifier,
                defaultNameKey: defaultNameKey,
                customName: customName,
                storageKind: storageKind,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoragePlacesTable, StoragePlaceRow>(table),
                  $$StoragePlacesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({compartmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (compartmentsRefs) db.compartments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (compartmentsRefs)
                    await $_getPrefetchedData<
                      StoragePlaceRow,
                      $StoragePlacesTable,
                      CompartmentRow
                    >(
                      currentTable: table,
                      referencedTable: $$StoragePlacesTableReferences
                          ._compartmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StoragePlacesTableReferences(
                            db,
                            table,
                            p0,
                          ).compartmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) =>
                                e.storagePlaceIdentifier ==
                                item.storagePlaceIdentifier,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StoragePlacesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $StoragePlacesTable,
      StoragePlaceRow,
      $$StoragePlacesTableFilterComposer,
      $$StoragePlacesTableOrderingComposer,
      $$StoragePlacesTableAnnotationComposer,
      $$StoragePlacesTableCreateCompanionBuilder,
      $$StoragePlacesTableUpdateCompanionBuilder,
      (StoragePlaceRow, $$StoragePlacesTableReferences),
      StoragePlaceRow,
      PrefetchHooks Function({bool compartmentsRefs})
    >;
typedef $$CompartmentsTableCreateCompanionBuilder =
    CompartmentsCompanion Function({
      required String compartmentIdentifier,
      required String storagePlaceIdentifier,
      required int defaultNumber,
      Value<String?> customName,
      required int colorTagIndex,
      required int sortOrder,
      Value<bool> isArchived,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CompartmentsTableUpdateCompanionBuilder =
    CompartmentsCompanion Function({
      Value<String> compartmentIdentifier,
      Value<String> storagePlaceIdentifier,
      Value<int> defaultNumber,
      Value<String?> customName,
      Value<int> colorTagIndex,
      Value<int> sortOrder,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CompartmentsTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $CompartmentsTable,
          CompartmentRow
        > {
  $$CompartmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StoragePlacesTable _storagePlaceIdentifierTable(
    _$ApplicationDatabase db,
  ) => db.storagePlaces.createAlias(
    'compartments__storage_place_identifier__storage_places__storage_place_identifier',
  );

  $$StoragePlacesTableProcessedTableManager get storagePlaceIdentifier {
    final $_column = $_itemColumn<String>('storage_place_identifier')!;

    final manager = $$StoragePlacesTableTableManager(
      $_db,
      $_db.storagePlaces,
    ).filter((f) => f.storagePlaceIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _storagePlaceIdentifierTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$ApplicationDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName:
        'compartments__compartment_identifier__products__default_compartment_identifier',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products).filter(
      (f) => f.defaultCompartmentIdentifier.compartmentIdentifier.sqlEquals(
        $_itemColumn<String>('compartment_identifier')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockBatchesTable, List<StockBatchRow>>
  _stockBatchesRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stockBatches,
    aliasName:
        'compartments__compartment_identifier__stock_batches__compartment_identifier',
  );

  $$StockBatchesTableProcessedTableManager get stockBatchesRefs {
    final manager = $$StockBatchesTableTableManager($_db, $_db.stockBatches)
        .filter(
          (f) => f.compartmentIdentifier.compartmentIdentifier.sqlEquals(
            $_itemColumn<String>('compartment_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_stockBatchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InventoryMovementsTable,
    List<InventoryMovementRow>
  >
  _inventoryMovementsRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.inventoryMovements,
    aliasName:
        'compartments__compartment_identifier__inventory_movements__compartment_identifier',
  );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager =
        $$InventoryMovementsTableTableManager(
          $_db,
          $_db.inventoryMovements,
        ).filter(
          (f) => f.compartmentIdentifier.compartmentIdentifier.sqlEquals(
            $_itemColumn<String>('compartment_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CompartmentsTableFilterComposer
    extends Composer<_$ApplicationDatabase, $CompartmentsTable> {
  $$CompartmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get compartmentIdentifier => $composableBuilder(
    column: $table.compartmentIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultNumber => $composableBuilder(
    column: $table.defaultNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorTagIndex => $composableBuilder(
    column: $table.colorTagIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoragePlacesTableFilterComposer get storagePlaceIdentifier {
    final $$StoragePlacesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storagePlaceIdentifier,
      referencedTable: $db.storagePlaces,
      getReferencedColumn: (t) => t.storagePlaceIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoragePlacesTableFilterComposer(
            $db: $db,
            $table: $db.storagePlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.defaultCompartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockBatchesRefs(
    Expression<bool> Function($$StockBatchesTableFilterComposer f) f,
  ) {
    final $$StockBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableFilterComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CompartmentsTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $CompartmentsTable> {
  $$CompartmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get compartmentIdentifier => $composableBuilder(
    column: $table.compartmentIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultNumber => $composableBuilder(
    column: $table.defaultNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorTagIndex => $composableBuilder(
    column: $table.colorTagIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoragePlacesTableOrderingComposer get storagePlaceIdentifier {
    final $$StoragePlacesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storagePlaceIdentifier,
      referencedTable: $db.storagePlaces,
      getReferencedColumn: (t) => t.storagePlaceIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoragePlacesTableOrderingComposer(
            $db: $db,
            $table: $db.storagePlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CompartmentsTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $CompartmentsTable> {
  $$CompartmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get compartmentIdentifier => $composableBuilder(
    column: $table.compartmentIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultNumber => $composableBuilder(
    column: $table.defaultNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorTagIndex => $composableBuilder(
    column: $table.colorTagIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StoragePlacesTableAnnotationComposer get storagePlaceIdentifier {
    final $$StoragePlacesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storagePlaceIdentifier,
      referencedTable: $db.storagePlaces,
      getReferencedColumn: (t) => t.storagePlaceIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoragePlacesTableAnnotationComposer(
            $db: $db,
            $table: $db.storagePlaces,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.defaultCompartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockBatchesRefs<T extends Object>(
    Expression<T> Function($$StockBatchesTableAnnotationComposer a) f,
  ) {
    final $$StockBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.compartmentIdentifier,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.compartmentIdentifier,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CompartmentsTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $CompartmentsTable,
          CompartmentRow,
          $$CompartmentsTableFilterComposer,
          $$CompartmentsTableOrderingComposer,
          $$CompartmentsTableAnnotationComposer,
          $$CompartmentsTableCreateCompanionBuilder,
          $$CompartmentsTableUpdateCompanionBuilder,
          (CompartmentRow, $$CompartmentsTableReferences),
          CompartmentRow,
          PrefetchHooks Function({
            bool storagePlaceIdentifier,
            bool productsRefs,
            bool stockBatchesRefs,
            bool inventoryMovementsRefs,
          })
        > {
  $$CompartmentsTableTableManager(
    _$ApplicationDatabase db,
    $CompartmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompartmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompartmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> compartmentIdentifier = const Value.absent(),
                Value<String> storagePlaceIdentifier = const Value.absent(),
                Value<int> defaultNumber = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<int> colorTagIndex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompartmentsCompanion(
                compartmentIdentifier: compartmentIdentifier,
                storagePlaceIdentifier: storagePlaceIdentifier,
                defaultNumber: defaultNumber,
                customName: customName,
                colorTagIndex: colorTagIndex,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String compartmentIdentifier,
                required String storagePlaceIdentifier,
                required int defaultNumber,
                Value<String?> customName = const Value.absent(),
                required int colorTagIndex,
                required int sortOrder,
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CompartmentsCompanion.insert(
                compartmentIdentifier: compartmentIdentifier,
                storagePlaceIdentifier: storagePlaceIdentifier,
                defaultNumber: defaultNumber,
                customName: customName,
                colorTagIndex: colorTagIndex,
                sortOrder: sortOrder,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompartmentsTable, CompartmentRow>(table),
                  $$CompartmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                storagePlaceIdentifier = false,
                productsRefs = false,
                stockBatchesRefs = false,
                inventoryMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (productsRefs) db.products,
                    if (stockBatchesRefs) db.stockBatches,
                    if (inventoryMovementsRefs) db.inventoryMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (storagePlaceIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.storagePlaceIdentifier,
                                    referencedTable:
                                        $$CompartmentsTableReferences
                                            ._storagePlaceIdentifierTable(db),
                                    referencedColumn:
                                        $$CompartmentsTableReferences
                                            ._storagePlaceIdentifierTable(db)
                                            .storagePlaceIdentifier,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (productsRefs)
                        await $_getPrefetchedData<
                          CompartmentRow,
                          $CompartmentsTable,
                          ProductRow
                        >(
                          currentTable: table,
                          referencedTable: $$CompartmentsTableReferences
                              ._productsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).productsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.defaultCompartmentIdentifier ==
                                    item.compartmentIdentifier,
                              ),
                          typedResults: items,
                        ),
                      if (stockBatchesRefs)
                        await $_getPrefetchedData<
                          CompartmentRow,
                          $CompartmentsTable,
                          StockBatchRow
                        >(
                          currentTable: table,
                          referencedTable: $$CompartmentsTableReferences
                              ._stockBatchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockBatchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.compartmentIdentifier ==
                                    item.compartmentIdentifier,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedData<
                          CompartmentRow,
                          $CompartmentsTable,
                          InventoryMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$CompartmentsTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CompartmentsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.compartmentIdentifier ==
                                    item.compartmentIdentifier,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CompartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $CompartmentsTable,
      CompartmentRow,
      $$CompartmentsTableFilterComposer,
      $$CompartmentsTableOrderingComposer,
      $$CompartmentsTableAnnotationComposer,
      $$CompartmentsTableCreateCompanionBuilder,
      $$CompartmentsTableUpdateCompanionBuilder,
      (CompartmentRow, $$CompartmentsTableReferences),
      CompartmentRow,
      PrefetchHooks Function({
        bool storagePlaceIdentifier,
        bool productsRefs,
        bool stockBatchesRefs,
        bool inventoryMovementsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String categoryIdentifier,
      Value<String?> catalogKey,
      Value<String?> customName,
      Value<int?> recommendedMaximumStorageDays,
      Value<int?> shelfLifeAfterOpeningDays,
      required String iconEmoji,
      required int sortOrder,
      Value<String> storageDomain,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> categoryIdentifier,
      Value<String?> catalogKey,
      Value<String?> customName,
      Value<int?> recommendedMaximumStorageDays,
      Value<int?> shelfLifeAfterOpeningDays,
      Value<String> iconEmoji,
      Value<int> sortOrder,
      Value<String> storageDomain,
      Value<int> rowid,
    });

final class $$CategoriesTableReferences
    extends
        BaseReferences<_$ApplicationDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductRow>>
  _productsRefsTable(_$ApplicationDatabase db) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: 'categories__category_identifier__products__category_identifier',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products).filter(
      (f) => f.categoryIdentifier.categoryIdentifier.sqlEquals(
        $_itemColumn<String>('category_identifier')!,
      ),
    );

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryIdentifier => $composableBuilder(
    column: $table.categoryIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recommendedMaximumStorageDays => $composableBuilder(
    column: $table.recommendedMaximumStorageDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfLifeAfterOpeningDays => $composableBuilder(
    column: $table.shelfLifeAfterOpeningDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconEmoji => $composableBuilder(
    column: $table.iconEmoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storageDomain => $composableBuilder(
    column: $table.storageDomain,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryIdentifier => $composableBuilder(
    column: $table.categoryIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recommendedMaximumStorageDays => $composableBuilder(
    column: $table.recommendedMaximumStorageDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfLifeAfterOpeningDays => $composableBuilder(
    column: $table.shelfLifeAfterOpeningDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconEmoji => $composableBuilder(
    column: $table.iconEmoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storageDomain => $composableBuilder(
    column: $table.storageDomain,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryIdentifier => $composableBuilder(
    column: $table.categoryIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recommendedMaximumStorageDays => $composableBuilder(
    column: $table.recommendedMaximumStorageDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shelfLifeAfterOpeningDays => $composableBuilder(
    column: $table.shelfLifeAfterOpeningDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconEmoji =>
      $composableBuilder(column: $table.iconEmoji, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get storageDomain => $composableBuilder(
    column: $table.storageDomain,
    builder: (column) => column,
  );

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.categoryIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({bool productsRefs})
        > {
  $$CategoriesTableTableManager(
    _$ApplicationDatabase db,
    $CategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> categoryIdentifier = const Value.absent(),
                Value<String?> catalogKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<int?> recommendedMaximumStorageDays =
                    const Value.absent(),
                Value<int?> shelfLifeAfterOpeningDays = const Value.absent(),
                Value<String> iconEmoji = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> storageDomain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                categoryIdentifier: categoryIdentifier,
                catalogKey: catalogKey,
                customName: customName,
                recommendedMaximumStorageDays: recommendedMaximumStorageDays,
                shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays,
                iconEmoji: iconEmoji,
                sortOrder: sortOrder,
                storageDomain: storageDomain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryIdentifier,
                Value<String?> catalogKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<int?> recommendedMaximumStorageDays =
                    const Value.absent(),
                Value<int?> shelfLifeAfterOpeningDays = const Value.absent(),
                required String iconEmoji,
                required int sortOrder,
                Value<String> storageDomain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                categoryIdentifier: categoryIdentifier,
                catalogKey: catalogKey,
                customName: customName,
                recommendedMaximumStorageDays: recommendedMaximumStorageDays,
                shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays,
                iconEmoji: iconEmoji,
                sortOrder: sortOrder,
                storageDomain: storageDomain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData<
                      CategoryRow,
                      $CategoriesTable,
                      ProductRow
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableReferences
                          ._productsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).productsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) =>
                                e.categoryIdentifier == item.categoryIdentifier,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({bool productsRefs})
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      required String productIdentifier,
      required String categoryIdentifier,
      Value<String?> catalogKey,
      Value<String?> customName,
      required String canonicalUnit,
      Value<int?> defaultPackageQuantity,
      Value<int?> recommendedMaximumStorageDays,
      Value<int?> shelfLifeAfterOpeningDays,
      Value<String?> iconEmoji,
      Value<Uint8List?> iconImage,
      Value<String?> defaultCompartmentIdentifier,
      Value<bool> isArchived,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<String> productIdentifier,
      Value<String> categoryIdentifier,
      Value<String?> catalogKey,
      Value<String?> customName,
      Value<String> canonicalUnit,
      Value<int?> defaultPackageQuantity,
      Value<int?> recommendedMaximumStorageDays,
      Value<int?> shelfLifeAfterOpeningDays,
      Value<String?> iconEmoji,
      Value<Uint8List?> iconImage,
      Value<String?> defaultCompartmentIdentifier,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$ApplicationDatabase, $ProductsTable, ProductRow> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdentifierTable(_$ApplicationDatabase db) =>
      db.categories.createAlias(
        'products__category_identifier__categories__category_identifier',
      );

  $$CategoriesTableProcessedTableManager get categoryIdentifier {
    final $_column = $_itemColumn<String>('category_identifier')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.categoryIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompartmentsTable _defaultCompartmentIdentifierTable(
    _$ApplicationDatabase db,
  ) => db.compartments.createAlias(
    'products__default_compartment_identifier__compartments__compartment_identifier',
  );

  $$CompartmentsTableProcessedTableManager? get defaultCompartmentIdentifier {
    final $_column = $_itemColumn<String>('default_compartment_identifier');
    if ($_column == null) return null;
    final manager = $$CompartmentsTableTableManager(
      $_db,
      $_db.compartments,
    ).filter((f) => f.compartmentIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _defaultCompartmentIdentifierTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$StockBatchesTable, List<StockBatchRow>>
  _stockBatchesRefsTable(_$ApplicationDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.stockBatches,
        aliasName:
            'products__product_identifier__stock_batches__product_identifier',
      );

  $$StockBatchesTableProcessedTableManager get stockBatchesRefs {
    final manager = $$StockBatchesTableTableManager($_db, $_db.stockBatches)
        .filter(
          (f) => f.productIdentifier.productIdentifier.sqlEquals(
            $_itemColumn<String>('product_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_stockBatchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $InventoryMovementsTable,
    List<InventoryMovementRow>
  >
  _inventoryMovementsRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.inventoryMovements,
    aliasName:
        'products__product_identifier__inventory_movements__product_identifier',
  );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager =
        $$InventoryMovementsTableTableManager(
          $_db,
          $_db.inventoryMovements,
        ).filter(
          (f) => f.productIdentifier.productIdentifier.sqlEquals(
            $_itemColumn<String>('product_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RestockRulesTable, List<RestockRuleRow>>
  _restockRulesRefsTable(_$ApplicationDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.restockRules,
        aliasName:
            'products__product_identifier__restock_rules__product_identifier',
      );

  $$RestockRulesTableProcessedTableManager get restockRulesRefs {
    final manager = $$RestockRulesTableTableManager($_db, $_db.restockRules)
        .filter(
          (f) => f.productIdentifier.productIdentifier.sqlEquals(
            $_itemColumn<String>('product_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_restockRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ShoppingListEntriesTable,
    List<ShoppingListEntryRow>
  >
  _shoppingListEntriesRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.shoppingListEntries,
    aliasName:
        'products__product_identifier__shopping_list_entries__product_identifier',
  );

  $$ShoppingListEntriesTableProcessedTableManager get shoppingListEntriesRefs {
    final manager =
        $$ShoppingListEntriesTableTableManager(
          $_db,
          $_db.shoppingListEntries,
        ).filter(
          (f) => f.productIdentifier.productIdentifier.sqlEquals(
            $_itemColumn<String>('product_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _shoppingListEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductBarcodesTable, List<ProductBarcodeRow>>
  _productBarcodesRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.productBarcodes,
    aliasName:
        'products__product_identifier__product_barcodes__product_identifier',
  );

  $$ProductBarcodesTableProcessedTableManager get productBarcodesRefs {
    final manager =
        $$ProductBarcodesTableTableManager($_db, $_db.productBarcodes).filter(
          (f) => f.productIdentifier.productIdentifier.sqlEquals(
            $_itemColumn<String>('product_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _productBarcodesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$ApplicationDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productIdentifier => $composableBuilder(
    column: $table.productIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalUnit => $composableBuilder(
    column: $table.canonicalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultPackageQuantity => $composableBuilder(
    column: $table.defaultPackageQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recommendedMaximumStorageDays => $composableBuilder(
    column: $table.recommendedMaximumStorageDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shelfLifeAfterOpeningDays => $composableBuilder(
    column: $table.shelfLifeAfterOpeningDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconEmoji => $composableBuilder(
    column: $table.iconEmoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get iconImage => $composableBuilder(
    column: $table.iconImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryIdentifier {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryIdentifier,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.categoryIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableFilterComposer get defaultCompartmentIdentifier {
    final $$CompartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultCompartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableFilterComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> stockBatchesRefs(
    Expression<bool> Function($$StockBatchesTableFilterComposer f) f,
  ) {
    final $$StockBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableFilterComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> restockRulesRefs(
    Expression<bool> Function($$RestockRulesTableFilterComposer f) f,
  ) {
    final $$RestockRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.restockRules,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestockRulesTableFilterComposer(
            $db: $db,
            $table: $db.restockRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> shoppingListEntriesRefs(
    Expression<bool> Function($$ShoppingListEntriesTableFilterComposer f) f,
  ) {
    final $$ShoppingListEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.shoppingListEntries,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShoppingListEntriesTableFilterComposer(
            $db: $db,
            $table: $db.shoppingListEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productBarcodesRefs(
    Expression<bool> Function($$ProductBarcodesTableFilterComposer f) f,
  ) {
    final $$ProductBarcodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.productBarcodes,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductBarcodesTableFilterComposer(
            $db: $db,
            $table: $db.productBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productIdentifier => $composableBuilder(
    column: $table.productIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalUnit => $composableBuilder(
    column: $table.canonicalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultPackageQuantity => $composableBuilder(
    column: $table.defaultPackageQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recommendedMaximumStorageDays => $composableBuilder(
    column: $table.recommendedMaximumStorageDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shelfLifeAfterOpeningDays => $composableBuilder(
    column: $table.shelfLifeAfterOpeningDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconEmoji => $composableBuilder(
    column: $table.iconEmoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get iconImage => $composableBuilder(
    column: $table.iconImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryIdentifier {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryIdentifier,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.categoryIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableOrderingComposer get defaultCompartmentIdentifier {
    final $$CompartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultCompartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productIdentifier => $composableBuilder(
    column: $table.productIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get catalogKey => $composableBuilder(
    column: $table.catalogKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customName => $composableBuilder(
    column: $table.customName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get canonicalUnit => $composableBuilder(
    column: $table.canonicalUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultPackageQuantity => $composableBuilder(
    column: $table.defaultPackageQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get recommendedMaximumStorageDays => $composableBuilder(
    column: $table.recommendedMaximumStorageDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shelfLifeAfterOpeningDays => $composableBuilder(
    column: $table.shelfLifeAfterOpeningDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconEmoji =>
      $composableBuilder(column: $table.iconEmoji, builder: (column) => column);

  GeneratedColumn<Uint8List> get iconImage =>
      $composableBuilder(column: $table.iconImage, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryIdentifier {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryIdentifier,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.categoryIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableAnnotationComposer get defaultCompartmentIdentifier {
    final $$CompartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultCompartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> stockBatchesRefs<T extends Object>(
    Expression<T> Function($$StockBatchesTableAnnotationComposer a) f,
  ) {
    final $$StockBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.productIdentifier,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.productIdentifier,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> restockRulesRefs<T extends Object>(
    Expression<T> Function($$RestockRulesTableAnnotationComposer a) f,
  ) {
    final $$RestockRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.restockRules,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RestockRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.restockRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> shoppingListEntriesRefs<T extends Object>(
    Expression<T> Function($$ShoppingListEntriesTableAnnotationComposer a) f,
  ) {
    final $$ShoppingListEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.productIdentifier,
          referencedTable: $db.shoppingListEntries,
          getReferencedColumn: (t) => t.productIdentifier,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ShoppingListEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.shoppingListEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> productBarcodesRefs<T extends Object>(
    Expression<T> Function($$ProductBarcodesTableAnnotationComposer a) f,
  ) {
    final $$ProductBarcodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.productBarcodes,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductBarcodesTableAnnotationComposer(
            $db: $db,
            $table: $db.productBarcodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $ProductsTable,
          ProductRow,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (ProductRow, $$ProductsTableReferences),
          ProductRow,
          PrefetchHooks Function({
            bool categoryIdentifier,
            bool defaultCompartmentIdentifier,
            bool stockBatchesRefs,
            bool inventoryMovementsRefs,
            bool restockRulesRefs,
            bool shoppingListEntriesRefs,
            bool productBarcodesRefs,
          })
        > {
  $$ProductsTableTableManager(_$ApplicationDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productIdentifier = const Value.absent(),
                Value<String> categoryIdentifier = const Value.absent(),
                Value<String?> catalogKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                Value<String> canonicalUnit = const Value.absent(),
                Value<int?> defaultPackageQuantity = const Value.absent(),
                Value<int?> recommendedMaximumStorageDays =
                    const Value.absent(),
                Value<int?> shelfLifeAfterOpeningDays = const Value.absent(),
                Value<String?> iconEmoji = const Value.absent(),
                Value<Uint8List?> iconImage = const Value.absent(),
                Value<String?> defaultCompartmentIdentifier =
                    const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion(
                productIdentifier: productIdentifier,
                categoryIdentifier: categoryIdentifier,
                catalogKey: catalogKey,
                customName: customName,
                canonicalUnit: canonicalUnit,
                defaultPackageQuantity: defaultPackageQuantity,
                recommendedMaximumStorageDays: recommendedMaximumStorageDays,
                shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays,
                iconEmoji: iconEmoji,
                iconImage: iconImage,
                defaultCompartmentIdentifier: defaultCompartmentIdentifier,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productIdentifier,
                required String categoryIdentifier,
                Value<String?> catalogKey = const Value.absent(),
                Value<String?> customName = const Value.absent(),
                required String canonicalUnit,
                Value<int?> defaultPackageQuantity = const Value.absent(),
                Value<int?> recommendedMaximumStorageDays =
                    const Value.absent(),
                Value<int?> shelfLifeAfterOpeningDays = const Value.absent(),
                Value<String?> iconEmoji = const Value.absent(),
                Value<Uint8List?> iconImage = const Value.absent(),
                Value<String?> defaultCompartmentIdentifier =
                    const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductsCompanion.insert(
                productIdentifier: productIdentifier,
                categoryIdentifier: categoryIdentifier,
                catalogKey: catalogKey,
                customName: customName,
                canonicalUnit: canonicalUnit,
                defaultPackageQuantity: defaultPackageQuantity,
                recommendedMaximumStorageDays: recommendedMaximumStorageDays,
                shelfLifeAfterOpeningDays: shelfLifeAfterOpeningDays,
                iconEmoji: iconEmoji,
                iconImage: iconImage,
                defaultCompartmentIdentifier: defaultCompartmentIdentifier,
                isArchived: isArchived,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductsTable, ProductRow>(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryIdentifier = false,
                defaultCompartmentIdentifier = false,
                stockBatchesRefs = false,
                inventoryMovementsRefs = false,
                restockRulesRefs = false,
                shoppingListEntriesRefs = false,
                productBarcodesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (stockBatchesRefs) db.stockBatches,
                    if (inventoryMovementsRefs) db.inventoryMovements,
                    if (restockRulesRefs) db.restockRules,
                    if (shoppingListEntriesRefs) db.shoppingListEntries,
                    if (productBarcodesRefs) db.productBarcodes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryIdentifier,
                                    referencedTable: $$ProductsTableReferences
                                        ._categoryIdentifierTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._categoryIdentifierTable(db)
                                        .categoryIdentifier,
                                  )
                                  as T;
                        }
                        if (defaultCompartmentIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn:
                                        table.defaultCompartmentIdentifier,
                                    referencedTable: $$ProductsTableReferences
                                        ._defaultCompartmentIdentifierTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._defaultCompartmentIdentifierTable(db)
                                        .compartmentIdentifier,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (stockBatchesRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          StockBatchRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockBatchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockBatchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.productIdentifier ==
                                    item.productIdentifier,
                              ),
                          typedResults: items,
                        ),
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          InventoryMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.productIdentifier ==
                                    item.productIdentifier,
                              ),
                          typedResults: items,
                        ),
                      if (restockRulesRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          RestockRuleRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._restockRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).restockRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.productIdentifier ==
                                    item.productIdentifier,
                              ),
                          typedResults: items,
                        ),
                      if (shoppingListEntriesRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ShoppingListEntryRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._shoppingListEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).shoppingListEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.productIdentifier ==
                                    item.productIdentifier,
                              ),
                          typedResults: items,
                        ),
                      if (productBarcodesRefs)
                        await $_getPrefetchedData<
                          ProductRow,
                          $ProductsTable,
                          ProductBarcodeRow
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._productBarcodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).productBarcodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.productIdentifier ==
                                    item.productIdentifier,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $ProductsTable,
      ProductRow,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (ProductRow, $$ProductsTableReferences),
      ProductRow,
      PrefetchHooks Function({
        bool categoryIdentifier,
        bool defaultCompartmentIdentifier,
        bool stockBatchesRefs,
        bool inventoryMovementsRefs,
        bool restockRulesRefs,
        bool shoppingListEntriesRefs,
        bool productBarcodesRefs,
      })
    >;
typedef $$StockBatchesTableCreateCompanionBuilder =
    StockBatchesCompanion Function({
      required String stockBatchIdentifier,
      required String productIdentifier,
      required String compartmentIdentifier,
      required String quantityUnit,
      required int initialQuantity,
      required int quantityRemaining,
      Value<String?> parentBatchIdentifier,
      required CalendarDate storedOn,
      Value<CalendarDate?> bestBeforeOn,
      Value<CalendarDate?> openedOn,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$StockBatchesTableUpdateCompanionBuilder =
    StockBatchesCompanion Function({
      Value<String> stockBatchIdentifier,
      Value<String> productIdentifier,
      Value<String> compartmentIdentifier,
      Value<String> quantityUnit,
      Value<int> initialQuantity,
      Value<int> quantityRemaining,
      Value<String?> parentBatchIdentifier,
      Value<CalendarDate> storedOn,
      Value<CalendarDate?> bestBeforeOn,
      Value<CalendarDate?> openedOn,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$StockBatchesTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $StockBatchesTable,
          StockBatchRow
        > {
  $$StockBatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdentifierTable(_$ApplicationDatabase db) =>
      db.products.createAlias(
        'stock_batches__product_identifier__products__product_identifier',
      );

  $$ProductsTableProcessedTableManager get productIdentifier {
    final $_column = $_itemColumn<String>('product_identifier')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.productIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompartmentsTable _compartmentIdentifierTable(
    _$ApplicationDatabase db,
  ) => db.compartments.createAlias(
    'stock_batches__compartment_identifier__compartments__compartment_identifier',
  );

  $$CompartmentsTableProcessedTableManager get compartmentIdentifier {
    final $_column = $_itemColumn<String>('compartment_identifier')!;

    final manager = $$CompartmentsTableTableManager(
      $_db,
      $_db.compartments,
    ).filter((f) => f.compartmentIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _compartmentIdentifierTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InventoryMovementsTable,
    List<InventoryMovementRow>
  >
  _inventoryMovementsRefsTable(
    _$ApplicationDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.inventoryMovements,
    aliasName:
        'stock_batches__stock_batch_identifier__inventory_movements__stock_batch_identifier',
  );

  $$InventoryMovementsTableProcessedTableManager get inventoryMovementsRefs {
    final manager =
        $$InventoryMovementsTableTableManager(
          $_db,
          $_db.inventoryMovements,
        ).filter(
          (f) => f.stockBatchIdentifier.stockBatchIdentifier.sqlEquals(
            $_itemColumn<String>('stock_batch_identifier')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _inventoryMovementsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StockBatchesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $StockBatchesTable> {
  $$StockBatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stockBatchIdentifier => $composableBuilder(
    column: $table.stockBatchIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityRemaining => $composableBuilder(
    column: $table.quantityRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentBatchIdentifier => $composableBuilder(
    column: $table.parentBatchIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate, CalendarDate, String>
  get storedOn => $composableBuilder(
    column: $table.storedOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get bestBeforeOn => $composableBuilder(
    column: $table.bestBeforeOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CalendarDate?, CalendarDate, String>
  get openedOn => $composableBuilder(
    column: $table.openedOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productIdentifier {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableFilterComposer get compartmentIdentifier {
    final $$CompartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableFilterComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> inventoryMovementsRefs(
    Expression<bool> Function($$InventoryMovementsTableFilterComposer f) f,
  ) {
    final $$InventoryMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockBatchIdentifier,
      referencedTable: $db.inventoryMovements,
      getReferencedColumn: (t) => t.stockBatchIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryMovementsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StockBatchesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $StockBatchesTable> {
  $$StockBatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stockBatchIdentifier => $composableBuilder(
    column: $table.stockBatchIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityRemaining => $composableBuilder(
    column: $table.quantityRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentBatchIdentifier => $composableBuilder(
    column: $table.parentBatchIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storedOn => $composableBuilder(
    column: $table.storedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestBeforeOn => $composableBuilder(
    column: $table.bestBeforeOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedOn => $composableBuilder(
    column: $table.openedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productIdentifier {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableOrderingComposer get compartmentIdentifier {
    final $$CompartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockBatchesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $StockBatchesTable> {
  $$StockBatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stockBatchIdentifier => $composableBuilder(
    column: $table.stockBatchIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialQuantity => $composableBuilder(
    column: $table.initialQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityRemaining => $composableBuilder(
    column: $table.quantityRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentBatchIdentifier => $composableBuilder(
    column: $table.parentBatchIdentifier,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CalendarDate, String> get storedOn =>
      $composableBuilder(column: $table.storedOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get bestBeforeOn =>
      $composableBuilder(
        column: $table.bestBeforeOn,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<CalendarDate?, String> get openedOn =>
      $composableBuilder(column: $table.openedOn, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productIdentifier {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableAnnotationComposer get compartmentIdentifier {
    final $$CompartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> inventoryMovementsRefs<T extends Object>(
    Expression<T> Function($$InventoryMovementsTableAnnotationComposer a) f,
  ) {
    final $$InventoryMovementsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.stockBatchIdentifier,
          referencedTable: $db.inventoryMovements,
          getReferencedColumn: (t) => t.stockBatchIdentifier,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InventoryMovementsTableAnnotationComposer(
                $db: $db,
                $table: $db.inventoryMovements,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$StockBatchesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $StockBatchesTable,
          StockBatchRow,
          $$StockBatchesTableFilterComposer,
          $$StockBatchesTableOrderingComposer,
          $$StockBatchesTableAnnotationComposer,
          $$StockBatchesTableCreateCompanionBuilder,
          $$StockBatchesTableUpdateCompanionBuilder,
          (StockBatchRow, $$StockBatchesTableReferences),
          StockBatchRow,
          PrefetchHooks Function({
            bool productIdentifier,
            bool compartmentIdentifier,
            bool inventoryMovementsRefs,
          })
        > {
  $$StockBatchesTableTableManager(
    _$ApplicationDatabase db,
    $StockBatchesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockBatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockBatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockBatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stockBatchIdentifier = const Value.absent(),
                Value<String> productIdentifier = const Value.absent(),
                Value<String> compartmentIdentifier = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<int> initialQuantity = const Value.absent(),
                Value<int> quantityRemaining = const Value.absent(),
                Value<String?> parentBatchIdentifier = const Value.absent(),
                Value<CalendarDate> storedOn = const Value.absent(),
                Value<CalendarDate?> bestBeforeOn = const Value.absent(),
                Value<CalendarDate?> openedOn = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StockBatchesCompanion(
                stockBatchIdentifier: stockBatchIdentifier,
                productIdentifier: productIdentifier,
                compartmentIdentifier: compartmentIdentifier,
                quantityUnit: quantityUnit,
                initialQuantity: initialQuantity,
                quantityRemaining: quantityRemaining,
                parentBatchIdentifier: parentBatchIdentifier,
                storedOn: storedOn,
                bestBeforeOn: bestBeforeOn,
                openedOn: openedOn,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stockBatchIdentifier,
                required String productIdentifier,
                required String compartmentIdentifier,
                required String quantityUnit,
                required int initialQuantity,
                required int quantityRemaining,
                Value<String?> parentBatchIdentifier = const Value.absent(),
                required CalendarDate storedOn,
                Value<CalendarDate?> bestBeforeOn = const Value.absent(),
                Value<CalendarDate?> openedOn = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => StockBatchesCompanion.insert(
                stockBatchIdentifier: stockBatchIdentifier,
                productIdentifier: productIdentifier,
                compartmentIdentifier: compartmentIdentifier,
                quantityUnit: quantityUnit,
                initialQuantity: initialQuantity,
                quantityRemaining: quantityRemaining,
                parentBatchIdentifier: parentBatchIdentifier,
                storedOn: storedOn,
                bestBeforeOn: bestBeforeOn,
                openedOn: openedOn,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StockBatchesTable, StockBatchRow>(table),
                  $$StockBatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                productIdentifier = false,
                compartmentIdentifier = false,
                inventoryMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (inventoryMovementsRefs) db.inventoryMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (productIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productIdentifier,
                                    referencedTable:
                                        $$StockBatchesTableReferences
                                            ._productIdentifierTable(db),
                                    referencedColumn:
                                        $$StockBatchesTableReferences
                                            ._productIdentifierTable(db)
                                            .productIdentifier,
                                  )
                                  as T;
                        }
                        if (compartmentIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.compartmentIdentifier,
                                    referencedTable:
                                        $$StockBatchesTableReferences
                                            ._compartmentIdentifierTable(db),
                                    referencedColumn:
                                        $$StockBatchesTableReferences
                                            ._compartmentIdentifierTable(db)
                                            .compartmentIdentifier,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (inventoryMovementsRefs)
                        await $_getPrefetchedData<
                          StockBatchRow,
                          $StockBatchesTable,
                          InventoryMovementRow
                        >(
                          currentTable: table,
                          referencedTable: $$StockBatchesTableReferences
                              ._inventoryMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StockBatchesTableReferences(
                                db,
                                table,
                                p0,
                              ).inventoryMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) =>
                                    e.stockBatchIdentifier ==
                                    item.stockBatchIdentifier,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$StockBatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $StockBatchesTable,
      StockBatchRow,
      $$StockBatchesTableFilterComposer,
      $$StockBatchesTableOrderingComposer,
      $$StockBatchesTableAnnotationComposer,
      $$StockBatchesTableCreateCompanionBuilder,
      $$StockBatchesTableUpdateCompanionBuilder,
      (StockBatchRow, $$StockBatchesTableReferences),
      StockBatchRow,
      PrefetchHooks Function({
        bool productIdentifier,
        bool compartmentIdentifier,
        bool inventoryMovementsRefs,
      })
    >;
typedef $$InventoryMovementsTableCreateCompanionBuilder =
    InventoryMovementsCompanion Function({
      required String movementIdentifier,
      required String stockBatchIdentifier,
      required String productIdentifier,
      required String compartmentIdentifier,
      required String movementKind,
      required int quantityDelta,
      Value<String?> discardReason,
      Value<String?> reversesMovementIdentifier,
      required DateTime occurredAt,
      Value<int> rowid,
    });
typedef $$InventoryMovementsTableUpdateCompanionBuilder =
    InventoryMovementsCompanion Function({
      Value<String> movementIdentifier,
      Value<String> stockBatchIdentifier,
      Value<String> productIdentifier,
      Value<String> compartmentIdentifier,
      Value<String> movementKind,
      Value<int> quantityDelta,
      Value<String?> discardReason,
      Value<String?> reversesMovementIdentifier,
      Value<DateTime> occurredAt,
      Value<int> rowid,
    });

final class $$InventoryMovementsTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $InventoryMovementsTable,
          InventoryMovementRow
        > {
  $$InventoryMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StockBatchesTable _stockBatchIdentifierTable(
    _$ApplicationDatabase db,
  ) => db.stockBatches.createAlias(
    'inventory_movements__stock_batch_identifier__stock_batches__stock_batch_identifier',
  );

  $$StockBatchesTableProcessedTableManager get stockBatchIdentifier {
    final $_column = $_itemColumn<String>('stock_batch_identifier')!;

    final manager = $$StockBatchesTableTableManager(
      $_db,
      $_db.stockBatches,
    ).filter((f) => f.stockBatchIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _stockBatchIdentifierTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdentifierTable(_$ApplicationDatabase db) =>
      db.products.createAlias(
        'inventory_movements__product_identifier__products__product_identifier',
      );

  $$ProductsTableProcessedTableManager get productIdentifier {
    final $_column = $_itemColumn<String>('product_identifier')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.productIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CompartmentsTable _compartmentIdentifierTable(
    _$ApplicationDatabase db,
  ) => db.compartments.createAlias(
    'inventory_movements__compartment_identifier__compartments__compartment_identifier',
  );

  $$CompartmentsTableProcessedTableManager get compartmentIdentifier {
    final $_column = $_itemColumn<String>('compartment_identifier')!;

    final manager = $$CompartmentsTableTableManager(
      $_db,
      $_db.compartments,
    ).filter((f) => f.compartmentIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _compartmentIdentifierTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InventoryMovementsTableFilterComposer
    extends Composer<_$ApplicationDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get movementIdentifier => $composableBuilder(
    column: $table.movementIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementKind => $composableBuilder(
    column: $table.movementKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discardReason => $composableBuilder(
    column: $table.discardReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversesMovementIdentifier => $composableBuilder(
    column: $table.reversesMovementIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StockBatchesTableFilterComposer get stockBatchIdentifier {
    final $$StockBatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockBatchIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.stockBatchIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableFilterComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productIdentifier {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableFilterComposer get compartmentIdentifier {
    final $$CompartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableFilterComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get movementIdentifier => $composableBuilder(
    column: $table.movementIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementKind => $composableBuilder(
    column: $table.movementKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discardReason => $composableBuilder(
    column: $table.discardReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversesMovementIdentifier => $composableBuilder(
    column: $table.reversesMovementIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StockBatchesTableOrderingComposer get stockBatchIdentifier {
    final $$StockBatchesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockBatchIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.stockBatchIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableOrderingComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productIdentifier {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableOrderingComposer get compartmentIdentifier {
    final $$CompartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $InventoryMovementsTable> {
  $$InventoryMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get movementIdentifier => $composableBuilder(
    column: $table.movementIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movementKind => $composableBuilder(
    column: $table.movementKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discardReason => $composableBuilder(
    column: $table.discardReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversesMovementIdentifier => $composableBuilder(
    column: $table.reversesMovementIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  $$StockBatchesTableAnnotationComposer get stockBatchIdentifier {
    final $$StockBatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stockBatchIdentifier,
      referencedTable: $db.stockBatches,
      getReferencedColumn: (t) => t.stockBatchIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockBatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.stockBatches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productIdentifier {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CompartmentsTableAnnotationComposer get compartmentIdentifier {
    final $$CompartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.compartmentIdentifier,
      referencedTable: $db.compartments,
      getReferencedColumn: (t) => t.compartmentIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CompartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.compartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InventoryMovementsTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $InventoryMovementsTable,
          InventoryMovementRow,
          $$InventoryMovementsTableFilterComposer,
          $$InventoryMovementsTableOrderingComposer,
          $$InventoryMovementsTableAnnotationComposer,
          $$InventoryMovementsTableCreateCompanionBuilder,
          $$InventoryMovementsTableUpdateCompanionBuilder,
          (InventoryMovementRow, $$InventoryMovementsTableReferences),
          InventoryMovementRow,
          PrefetchHooks Function({
            bool stockBatchIdentifier,
            bool productIdentifier,
            bool compartmentIdentifier,
          })
        > {
  $$InventoryMovementsTableTableManager(
    _$ApplicationDatabase db,
    $InventoryMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> movementIdentifier = const Value.absent(),
                Value<String> stockBatchIdentifier = const Value.absent(),
                Value<String> productIdentifier = const Value.absent(),
                Value<String> compartmentIdentifier = const Value.absent(),
                Value<String> movementKind = const Value.absent(),
                Value<int> quantityDelta = const Value.absent(),
                Value<String?> discardReason = const Value.absent(),
                Value<String?> reversesMovementIdentifier =
                    const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryMovementsCompanion(
                movementIdentifier: movementIdentifier,
                stockBatchIdentifier: stockBatchIdentifier,
                productIdentifier: productIdentifier,
                compartmentIdentifier: compartmentIdentifier,
                movementKind: movementKind,
                quantityDelta: quantityDelta,
                discardReason: discardReason,
                reversesMovementIdentifier: reversesMovementIdentifier,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String movementIdentifier,
                required String stockBatchIdentifier,
                required String productIdentifier,
                required String compartmentIdentifier,
                required String movementKind,
                required int quantityDelta,
                Value<String?> discardReason = const Value.absent(),
                Value<String?> reversesMovementIdentifier =
                    const Value.absent(),
                required DateTime occurredAt,
                Value<int> rowid = const Value.absent(),
              }) => InventoryMovementsCompanion.insert(
                movementIdentifier: movementIdentifier,
                stockBatchIdentifier: stockBatchIdentifier,
                productIdentifier: productIdentifier,
                compartmentIdentifier: compartmentIdentifier,
                movementKind: movementKind,
                quantityDelta: quantityDelta,
                discardReason: discardReason,
                reversesMovementIdentifier: reversesMovementIdentifier,
                occurredAt: occurredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryMovementsTable, InventoryMovementRow>(
                    table,
                  ),
                  $$InventoryMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                stockBatchIdentifier = false,
                productIdentifier = false,
                compartmentIdentifier = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (stockBatchIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.stockBatchIdentifier,
                                    referencedTable:
                                        $$InventoryMovementsTableReferences
                                            ._stockBatchIdentifierTable(db),
                                    referencedColumn:
                                        $$InventoryMovementsTableReferences
                                            ._stockBatchIdentifierTable(db)
                                            .stockBatchIdentifier,
                                  )
                                  as T;
                        }
                        if (productIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.productIdentifier,
                                    referencedTable:
                                        $$InventoryMovementsTableReferences
                                            ._productIdentifierTable(db),
                                    referencedColumn:
                                        $$InventoryMovementsTableReferences
                                            ._productIdentifierTable(db)
                                            .productIdentifier,
                                  )
                                  as T;
                        }
                        if (compartmentIdentifier) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.compartmentIdentifier,
                                    referencedTable:
                                        $$InventoryMovementsTableReferences
                                            ._compartmentIdentifierTable(db),
                                    referencedColumn:
                                        $$InventoryMovementsTableReferences
                                            ._compartmentIdentifierTable(db)
                                            .compartmentIdentifier,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$InventoryMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $InventoryMovementsTable,
      InventoryMovementRow,
      $$InventoryMovementsTableFilterComposer,
      $$InventoryMovementsTableOrderingComposer,
      $$InventoryMovementsTableAnnotationComposer,
      $$InventoryMovementsTableCreateCompanionBuilder,
      $$InventoryMovementsTableUpdateCompanionBuilder,
      (InventoryMovementRow, $$InventoryMovementsTableReferences),
      InventoryMovementRow,
      PrefetchHooks Function({
        bool stockBatchIdentifier,
        bool productIdentifier,
        bool compartmentIdentifier,
      })
    >;
typedef $$ScheduledNotificationRecordsTableCreateCompanionBuilder =
    ScheduledNotificationRecordsCompanion Function({
      Value<int> notificationIdentifier,
      required String purpose,
      required DateTime scheduledFor,
    });
typedef $$ScheduledNotificationRecordsTableUpdateCompanionBuilder =
    ScheduledNotificationRecordsCompanion Function({
      Value<int> notificationIdentifier,
      Value<String> purpose,
      Value<DateTime> scheduledFor,
    });

class $$ScheduledNotificationRecordsTableFilterComposer
    extends
        Composer<_$ApplicationDatabase, $ScheduledNotificationRecordsTable> {
  $$ScheduledNotificationRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get notificationIdentifier => $composableBuilder(
    column: $table.notificationIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScheduledNotificationRecordsTableOrderingComposer
    extends
        Composer<_$ApplicationDatabase, $ScheduledNotificationRecordsTable> {
  $$ScheduledNotificationRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get notificationIdentifier => $composableBuilder(
    column: $table.notificationIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purpose => $composableBuilder(
    column: $table.purpose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScheduledNotificationRecordsTableAnnotationComposer
    extends
        Composer<_$ApplicationDatabase, $ScheduledNotificationRecordsTable> {
  $$ScheduledNotificationRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get notificationIdentifier => $composableBuilder(
    column: $table.notificationIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );
}

class $$ScheduledNotificationRecordsTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $ScheduledNotificationRecordsTable,
          ScheduledNotificationRecordRow,
          $$ScheduledNotificationRecordsTableFilterComposer,
          $$ScheduledNotificationRecordsTableOrderingComposer,
          $$ScheduledNotificationRecordsTableAnnotationComposer,
          $$ScheduledNotificationRecordsTableCreateCompanionBuilder,
          $$ScheduledNotificationRecordsTableUpdateCompanionBuilder,
          (
            ScheduledNotificationRecordRow,
            BaseReferences<
              _$ApplicationDatabase,
              $ScheduledNotificationRecordsTable,
              ScheduledNotificationRecordRow
            >,
          ),
          ScheduledNotificationRecordRow,
          PrefetchHooks Function()
        > {
  $$ScheduledNotificationRecordsTableTableManager(
    _$ApplicationDatabase db,
    $ScheduledNotificationRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduledNotificationRecordsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ScheduledNotificationRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ScheduledNotificationRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> notificationIdentifier = const Value.absent(),
                Value<String> purpose = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
              }) => ScheduledNotificationRecordsCompanion(
                notificationIdentifier: notificationIdentifier,
                purpose: purpose,
                scheduledFor: scheduledFor,
              ),
          createCompanionCallback:
              ({
                Value<int> notificationIdentifier = const Value.absent(),
                required String purpose,
                required DateTime scheduledFor,
              }) => ScheduledNotificationRecordsCompanion.insert(
                notificationIdentifier: notificationIdentifier,
                purpose: purpose,
                scheduledFor: scheduledFor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ScheduledNotificationRecordsTable,
                    ScheduledNotificationRecordRow
                  >(table),
                  BaseReferences<
                    _$ApplicationDatabase,
                    $ScheduledNotificationRecordsTable,
                    ScheduledNotificationRecordRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScheduledNotificationRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $ScheduledNotificationRecordsTable,
      ScheduledNotificationRecordRow,
      $$ScheduledNotificationRecordsTableFilterComposer,
      $$ScheduledNotificationRecordsTableOrderingComposer,
      $$ScheduledNotificationRecordsTableAnnotationComposer,
      $$ScheduledNotificationRecordsTableCreateCompanionBuilder,
      $$ScheduledNotificationRecordsTableUpdateCompanionBuilder,
      (
        ScheduledNotificationRecordRow,
        BaseReferences<
          _$ApplicationDatabase,
          $ScheduledNotificationRecordsTable,
          ScheduledNotificationRecordRow
        >,
      ),
      ScheduledNotificationRecordRow,
      PrefetchHooks Function()
    >;
typedef $$RestockRulesTableCreateCompanionBuilder =
    RestockRulesCompanion Function({
      required String productIdentifier,
      required String quantityUnit,
      required int minimumQuantity,
      Value<int?> targetQuantity,
      required bool isActive,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RestockRulesTableUpdateCompanionBuilder =
    RestockRulesCompanion Function({
      Value<String> productIdentifier,
      Value<String> quantityUnit,
      Value<int> minimumQuantity,
      Value<int?> targetQuantity,
      Value<bool> isActive,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$RestockRulesTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $RestockRulesTable,
          RestockRuleRow
        > {
  $$RestockRulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProductsTable _productIdentifierTable(_$ApplicationDatabase db) =>
      db.products.createAlias(
        'restock_rules__product_identifier__products__product_identifier',
      );

  $$ProductsTableProcessedTableManager get productIdentifier {
    final $_column = $_itemColumn<String>('product_identifier')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.productIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RestockRulesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $RestockRulesTable> {
  $$RestockRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetQuantity => $composableBuilder(
    column: $table.targetQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productIdentifier {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestockRulesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $RestockRulesTable> {
  $$RestockRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetQuantity => $composableBuilder(
    column: $table.targetQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productIdentifier {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestockRulesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $RestockRulesTable> {
  $$RestockRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minimumQuantity => $composableBuilder(
    column: $table.minimumQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetQuantity => $composableBuilder(
    column: $table.targetQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productIdentifier {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RestockRulesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $RestockRulesTable,
          RestockRuleRow,
          $$RestockRulesTableFilterComposer,
          $$RestockRulesTableOrderingComposer,
          $$RestockRulesTableAnnotationComposer,
          $$RestockRulesTableCreateCompanionBuilder,
          $$RestockRulesTableUpdateCompanionBuilder,
          (RestockRuleRow, $$RestockRulesTableReferences),
          RestockRuleRow,
          PrefetchHooks Function({bool productIdentifier})
        > {
  $$RestockRulesTableTableManager(
    _$ApplicationDatabase db,
    $RestockRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RestockRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RestockRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RestockRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productIdentifier = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<int> minimumQuantity = const Value.absent(),
                Value<int?> targetQuantity = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RestockRulesCompanion(
                productIdentifier: productIdentifier,
                quantityUnit: quantityUnit,
                minimumQuantity: minimumQuantity,
                targetQuantity: targetQuantity,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productIdentifier,
                required String quantityUnit,
                required int minimumQuantity,
                Value<int?> targetQuantity = const Value.absent(),
                required bool isActive,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RestockRulesCompanion.insert(
                productIdentifier: productIdentifier,
                quantityUnit: quantityUnit,
                minimumQuantity: minimumQuantity,
                targetQuantity: targetQuantity,
                isActive: isActive,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RestockRulesTable, RestockRuleRow>(table),
                  $$RestockRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productIdentifier = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productIdentifier) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productIdentifier,
                                referencedTable: $$RestockRulesTableReferences
                                    ._productIdentifierTable(db),
                                referencedColumn: $$RestockRulesTableReferences
                                    ._productIdentifierTable(db)
                                    .productIdentifier,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RestockRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $RestockRulesTable,
      RestockRuleRow,
      $$RestockRulesTableFilterComposer,
      $$RestockRulesTableOrderingComposer,
      $$RestockRulesTableAnnotationComposer,
      $$RestockRulesTableCreateCompanionBuilder,
      $$RestockRulesTableUpdateCompanionBuilder,
      (RestockRuleRow, $$RestockRulesTableReferences),
      RestockRuleRow,
      PrefetchHooks Function({bool productIdentifier})
    >;
typedef $$ShoppingListEntriesTableCreateCompanionBuilder =
    ShoppingListEntriesCompanion Function({
      required String shoppingListEntryIdentifier,
      Value<String?> productIdentifier,
      Value<String?> freeTextName,
      Value<String?> quantityUnit,
      Value<int?> requestedQuantity,
      required String origin,
      required DateTime createdAt,
      Value<DateTime?> checkedAt,
      Value<int> rowid,
    });
typedef $$ShoppingListEntriesTableUpdateCompanionBuilder =
    ShoppingListEntriesCompanion Function({
      Value<String> shoppingListEntryIdentifier,
      Value<String?> productIdentifier,
      Value<String?> freeTextName,
      Value<String?> quantityUnit,
      Value<int?> requestedQuantity,
      Value<String> origin,
      Value<DateTime> createdAt,
      Value<DateTime?> checkedAt,
      Value<int> rowid,
    });

final class $$ShoppingListEntriesTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $ShoppingListEntriesTable,
          ShoppingListEntryRow
        > {
  $$ShoppingListEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdentifierTable(
    _$ApplicationDatabase db,
  ) => db.products.createAlias(
    'shopping_list_entries__product_identifier__products__product_identifier',
  );

  $$ProductsTableProcessedTableManager? get productIdentifier {
    final $_column = $_itemColumn<String>('product_identifier');
    if ($_column == null) return null;
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.productIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ShoppingListEntriesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $ShoppingListEntriesTable> {
  $$ShoppingListEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get shoppingListEntryIdentifier => $composableBuilder(
    column: $table.shoppingListEntryIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get freeTextName => $composableBuilder(
    column: $table.freeTextName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedQuantity => $composableBuilder(
    column: $table.requestedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productIdentifier {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingListEntriesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $ShoppingListEntriesTable> {
  $$ShoppingListEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get shoppingListEntryIdentifier => $composableBuilder(
    column: $table.shoppingListEntryIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get freeTextName => $composableBuilder(
    column: $table.freeTextName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedQuantity => $composableBuilder(
    column: $table.requestedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedAt => $composableBuilder(
    column: $table.checkedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productIdentifier {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingListEntriesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $ShoppingListEntriesTable> {
  $$ShoppingListEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get shoppingListEntryIdentifier => $composableBuilder(
    column: $table.shoppingListEntryIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get freeTextName => $composableBuilder(
    column: $table.freeTextName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedQuantity => $composableBuilder(
    column: $table.requestedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedAt =>
      $composableBuilder(column: $table.checkedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productIdentifier {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ShoppingListEntriesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $ShoppingListEntriesTable,
          ShoppingListEntryRow,
          $$ShoppingListEntriesTableFilterComposer,
          $$ShoppingListEntriesTableOrderingComposer,
          $$ShoppingListEntriesTableAnnotationComposer,
          $$ShoppingListEntriesTableCreateCompanionBuilder,
          $$ShoppingListEntriesTableUpdateCompanionBuilder,
          (ShoppingListEntryRow, $$ShoppingListEntriesTableReferences),
          ShoppingListEntryRow,
          PrefetchHooks Function({bool productIdentifier})
        > {
  $$ShoppingListEntriesTableTableManager(
    _$ApplicationDatabase db,
    $ShoppingListEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ShoppingListEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> shoppingListEntryIdentifier =
                    const Value.absent(),
                Value<String?> productIdentifier = const Value.absent(),
                Value<String?> freeTextName = const Value.absent(),
                Value<String?> quantityUnit = const Value.absent(),
                Value<int?> requestedQuantity = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingListEntriesCompanion(
                shoppingListEntryIdentifier: shoppingListEntryIdentifier,
                productIdentifier: productIdentifier,
                freeTextName: freeTextName,
                quantityUnit: quantityUnit,
                requestedQuantity: requestedQuantity,
                origin: origin,
                createdAt: createdAt,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String shoppingListEntryIdentifier,
                Value<String?> productIdentifier = const Value.absent(),
                Value<String?> freeTextName = const Value.absent(),
                Value<String?> quantityUnit = const Value.absent(),
                Value<int?> requestedQuantity = const Value.absent(),
                required String origin,
                required DateTime createdAt,
                Value<DateTime?> checkedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShoppingListEntriesCompanion.insert(
                shoppingListEntryIdentifier: shoppingListEntryIdentifier,
                productIdentifier: productIdentifier,
                freeTextName: freeTextName,
                quantityUnit: quantityUnit,
                requestedQuantity: requestedQuantity,
                origin: origin,
                createdAt: createdAt,
                checkedAt: checkedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShoppingListEntriesTable, ShoppingListEntryRow>(
                    table,
                  ),
                  $$ShoppingListEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productIdentifier = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productIdentifier) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productIdentifier,
                                referencedTable:
                                    $$ShoppingListEntriesTableReferences
                                        ._productIdentifierTable(db),
                                referencedColumn:
                                    $$ShoppingListEntriesTableReferences
                                        ._productIdentifierTable(db)
                                        .productIdentifier,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ShoppingListEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $ShoppingListEntriesTable,
      ShoppingListEntryRow,
      $$ShoppingListEntriesTableFilterComposer,
      $$ShoppingListEntriesTableOrderingComposer,
      $$ShoppingListEntriesTableAnnotationComposer,
      $$ShoppingListEntriesTableCreateCompanionBuilder,
      $$ShoppingListEntriesTableUpdateCompanionBuilder,
      (ShoppingListEntryRow, $$ShoppingListEntriesTableReferences),
      ShoppingListEntryRow,
      PrefetchHooks Function({bool productIdentifier})
    >;
typedef $$ItemPicturesTableCreateCompanionBuilder =
    ItemPicturesCompanion Function({
      required String itemPictureIdentifier,
      required String ownerKind,
      required String ownerIdentifier,
      required String encryptedFileName,
      required String thumbnailFileName,
      required int widthPixels,
      required int heightPixels,
      required int byteSize,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ItemPicturesTableUpdateCompanionBuilder =
    ItemPicturesCompanion Function({
      Value<String> itemPictureIdentifier,
      Value<String> ownerKind,
      Value<String> ownerIdentifier,
      Value<String> encryptedFileName,
      Value<String> thumbnailFileName,
      Value<int> widthPixels,
      Value<int> heightPixels,
      Value<int> byteSize,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ItemPicturesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $ItemPicturesTable> {
  $$ItemPicturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemPictureIdentifier => $composableBuilder(
    column: $table.itemPictureIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerKind => $composableBuilder(
    column: $table.ownerKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerIdentifier => $composableBuilder(
    column: $table.ownerIdentifier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get encryptedFileName => $composableBuilder(
    column: $table.encryptedFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailFileName => $composableBuilder(
    column: $table.thumbnailFileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemPicturesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $ItemPicturesTable> {
  $$ItemPicturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemPictureIdentifier => $composableBuilder(
    column: $table.itemPictureIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerKind => $composableBuilder(
    column: $table.ownerKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerIdentifier => $composableBuilder(
    column: $table.ownerIdentifier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get encryptedFileName => $composableBuilder(
    column: $table.encryptedFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailFileName => $composableBuilder(
    column: $table.thumbnailFileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemPicturesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $ItemPicturesTable> {
  $$ItemPicturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemPictureIdentifier => $composableBuilder(
    column: $table.itemPictureIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerKind =>
      $composableBuilder(column: $table.ownerKind, builder: (column) => column);

  GeneratedColumn<String> get ownerIdentifier => $composableBuilder(
    column: $table.ownerIdentifier,
    builder: (column) => column,
  );

  GeneratedColumn<String> get encryptedFileName => $composableBuilder(
    column: $table.encryptedFileName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailFileName => $composableBuilder(
    column: $table.thumbnailFileName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get widthPixels => $composableBuilder(
    column: $table.widthPixels,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heightPixels => $composableBuilder(
    column: $table.heightPixels,
    builder: (column) => column,
  );

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ItemPicturesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $ItemPicturesTable,
          ItemPictureRow,
          $$ItemPicturesTableFilterComposer,
          $$ItemPicturesTableOrderingComposer,
          $$ItemPicturesTableAnnotationComposer,
          $$ItemPicturesTableCreateCompanionBuilder,
          $$ItemPicturesTableUpdateCompanionBuilder,
          (
            ItemPictureRow,
            BaseReferences<
              _$ApplicationDatabase,
              $ItemPicturesTable,
              ItemPictureRow
            >,
          ),
          ItemPictureRow,
          PrefetchHooks Function()
        > {
  $$ItemPicturesTableTableManager(
    _$ApplicationDatabase db,
    $ItemPicturesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemPicturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemPicturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemPicturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemPictureIdentifier = const Value.absent(),
                Value<String> ownerKind = const Value.absent(),
                Value<String> ownerIdentifier = const Value.absent(),
                Value<String> encryptedFileName = const Value.absent(),
                Value<String> thumbnailFileName = const Value.absent(),
                Value<int> widthPixels = const Value.absent(),
                Value<int> heightPixels = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemPicturesCompanion(
                itemPictureIdentifier: itemPictureIdentifier,
                ownerKind: ownerKind,
                ownerIdentifier: ownerIdentifier,
                encryptedFileName: encryptedFileName,
                thumbnailFileName: thumbnailFileName,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                byteSize: byteSize,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemPictureIdentifier,
                required String ownerKind,
                required String ownerIdentifier,
                required String encryptedFileName,
                required String thumbnailFileName,
                required int widthPixels,
                required int heightPixels,
                required int byteSize,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemPicturesCompanion.insert(
                itemPictureIdentifier: itemPictureIdentifier,
                ownerKind: ownerKind,
                ownerIdentifier: ownerIdentifier,
                encryptedFileName: encryptedFileName,
                thumbnailFileName: thumbnailFileName,
                widthPixels: widthPixels,
                heightPixels: heightPixels,
                byteSize: byteSize,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemPicturesTable, ItemPictureRow>(table),
                  BaseReferences<
                    _$ApplicationDatabase,
                    $ItemPicturesTable,
                    ItemPictureRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemPicturesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $ItemPicturesTable,
      ItemPictureRow,
      $$ItemPicturesTableFilterComposer,
      $$ItemPicturesTableOrderingComposer,
      $$ItemPicturesTableAnnotationComposer,
      $$ItemPicturesTableCreateCompanionBuilder,
      $$ItemPicturesTableUpdateCompanionBuilder,
      (
        ItemPictureRow,
        BaseReferences<
          _$ApplicationDatabase,
          $ItemPicturesTable,
          ItemPictureRow
        >,
      ),
      ItemPictureRow,
      PrefetchHooks Function()
    >;
typedef $$ProductBarcodesTableCreateCompanionBuilder =
    ProductBarcodesCompanion Function({
      required String barcodeValue,
      required String productIdentifier,
      required String symbology,
      required bool isVariableMeasure,
      required DateTime learnedAt,
      Value<int> rowid,
    });
typedef $$ProductBarcodesTableUpdateCompanionBuilder =
    ProductBarcodesCompanion Function({
      Value<String> barcodeValue,
      Value<String> productIdentifier,
      Value<String> symbology,
      Value<bool> isVariableMeasure,
      Value<DateTime> learnedAt,
      Value<int> rowid,
    });

final class $$ProductBarcodesTableReferences
    extends
        BaseReferences<
          _$ApplicationDatabase,
          $ProductBarcodesTable,
          ProductBarcodeRow
        > {
  $$ProductBarcodesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdentifierTable(_$ApplicationDatabase db) =>
      db.products.createAlias(
        'product_barcodes__product_identifier__products__product_identifier',
      );

  $$ProductsTableProcessedTableManager get productIdentifier {
    final $_column = $_itemColumn<String>('product_identifier')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.productIdentifier.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdentifierTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProductBarcodesTableFilterComposer
    extends Composer<_$ApplicationDatabase, $ProductBarcodesTable> {
  $$ProductBarcodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get barcodeValue => $composableBuilder(
    column: $table.barcodeValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbology => $composableBuilder(
    column: $table.symbology,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVariableMeasure => $composableBuilder(
    column: $table.isVariableMeasure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get learnedAt => $composableBuilder(
    column: $table.learnedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productIdentifier {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBarcodesTableOrderingComposer
    extends Composer<_$ApplicationDatabase, $ProductBarcodesTable> {
  $$ProductBarcodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get barcodeValue => $composableBuilder(
    column: $table.barcodeValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbology => $composableBuilder(
    column: $table.symbology,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVariableMeasure => $composableBuilder(
    column: $table.isVariableMeasure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get learnedAt => $composableBuilder(
    column: $table.learnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productIdentifier {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBarcodesTableAnnotationComposer
    extends Composer<_$ApplicationDatabase, $ProductBarcodesTable> {
  $$ProductBarcodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get barcodeValue => $composableBuilder(
    column: $table.barcodeValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get symbology =>
      $composableBuilder(column: $table.symbology, builder: (column) => column);

  GeneratedColumn<bool> get isVariableMeasure => $composableBuilder(
    column: $table.isVariableMeasure,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get learnedAt =>
      $composableBuilder(column: $table.learnedAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productIdentifier {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productIdentifier,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.productIdentifier,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductBarcodesTableTableManager
    extends
        RootTableManager<
          _$ApplicationDatabase,
          $ProductBarcodesTable,
          ProductBarcodeRow,
          $$ProductBarcodesTableFilterComposer,
          $$ProductBarcodesTableOrderingComposer,
          $$ProductBarcodesTableAnnotationComposer,
          $$ProductBarcodesTableCreateCompanionBuilder,
          $$ProductBarcodesTableUpdateCompanionBuilder,
          (ProductBarcodeRow, $$ProductBarcodesTableReferences),
          ProductBarcodeRow,
          PrefetchHooks Function({bool productIdentifier})
        > {
  $$ProductBarcodesTableTableManager(
    _$ApplicationDatabase db,
    $ProductBarcodesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductBarcodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductBarcodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductBarcodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> barcodeValue = const Value.absent(),
                Value<String> productIdentifier = const Value.absent(),
                Value<String> symbology = const Value.absent(),
                Value<bool> isVariableMeasure = const Value.absent(),
                Value<DateTime> learnedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductBarcodesCompanion(
                barcodeValue: barcodeValue,
                productIdentifier: productIdentifier,
                symbology: symbology,
                isVariableMeasure: isVariableMeasure,
                learnedAt: learnedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String barcodeValue,
                required String productIdentifier,
                required String symbology,
                required bool isVariableMeasure,
                required DateTime learnedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProductBarcodesCompanion.insert(
                barcodeValue: barcodeValue,
                productIdentifier: productIdentifier,
                symbology: symbology,
                isVariableMeasure: isVariableMeasure,
                learnedAt: learnedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProductBarcodesTable, ProductBarcodeRow>(table),
                  $$ProductBarcodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productIdentifier = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productIdentifier) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productIdentifier,
                                referencedTable:
                                    $$ProductBarcodesTableReferences
                                        ._productIdentifierTable(db),
                                referencedColumn:
                                    $$ProductBarcodesTableReferences
                                        ._productIdentifierTable(db)
                                        .productIdentifier,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProductBarcodesTableProcessedTableManager =
    ProcessedTableManager<
      _$ApplicationDatabase,
      $ProductBarcodesTable,
      ProductBarcodeRow,
      $$ProductBarcodesTableFilterComposer,
      $$ProductBarcodesTableOrderingComposer,
      $$ProductBarcodesTableAnnotationComposer,
      $$ProductBarcodesTableCreateCompanionBuilder,
      $$ProductBarcodesTableUpdateCompanionBuilder,
      (ProductBarcodeRow, $$ProductBarcodesTableReferences),
      ProductBarcodeRow,
      PrefetchHooks Function({bool productIdentifier})
    >;

class $ApplicationDatabaseManager {
  final _$ApplicationDatabase _db;
  $ApplicationDatabaseManager(this._db);
  $$PreferenceEntriesTableTableManager get preferenceEntries =>
      $$PreferenceEntriesTableTableManager(_db, _db.preferenceEntries);
  $$SchemaMetadataEntriesTableTableManager get schemaMetadataEntries =>
      $$SchemaMetadataEntriesTableTableManager(_db, _db.schemaMetadataEntries);
  $$StoragePlacesTableTableManager get storagePlaces =>
      $$StoragePlacesTableTableManager(_db, _db.storagePlaces);
  $$CompartmentsTableTableManager get compartments =>
      $$CompartmentsTableTableManager(_db, _db.compartments);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$StockBatchesTableTableManager get stockBatches =>
      $$StockBatchesTableTableManager(_db, _db.stockBatches);
  $$InventoryMovementsTableTableManager get inventoryMovements =>
      $$InventoryMovementsTableTableManager(_db, _db.inventoryMovements);
  $$ScheduledNotificationRecordsTableTableManager
  get scheduledNotificationRecords =>
      $$ScheduledNotificationRecordsTableTableManager(
        _db,
        _db.scheduledNotificationRecords,
      );
  $$RestockRulesTableTableManager get restockRules =>
      $$RestockRulesTableTableManager(_db, _db.restockRules);
  $$ShoppingListEntriesTableTableManager get shoppingListEntries =>
      $$ShoppingListEntriesTableTableManager(_db, _db.shoppingListEntries);
  $$ItemPicturesTableTableManager get itemPictures =>
      $$ItemPicturesTableTableManager(_db, _db.itemPictures);
  $$ProductBarcodesTableTableManager get productBarcodes =>
      $$ProductBarcodesTableTableManager(_db, _db.productBarcodes);
}
