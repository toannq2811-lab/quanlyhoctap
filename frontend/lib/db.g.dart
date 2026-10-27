// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbSettingCollection on Isar {
  IsarCollection<String, DbSetting> get dbSettings => this.collection();
}

final DbSettingSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbSetting',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'value', type: IsarType.string),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbSetting>(
    serialize: serializeDbSetting,
    deserialize: deserializeDbSetting,
    deserializeProperty: deserializeDbSettingProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDbSetting(IsarWriter writer, DbSetting object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.value);
  return Isar.fastHash(object.id);
}

@isarProtected
DbSetting deserializeDbSetting(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _value;
  _value = IsarCore.readString(reader, 2) ?? '';
  final object = DbSetting(id: _id, value: _value);
  return object;
}

@isarProtected
dynamic deserializeDbSettingProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbSettingUpdate {
  bool call({required String id, String? value});
}

class _DbSettingUpdateImpl implements _DbSettingUpdate {
  const _DbSettingUpdateImpl(this.collection);

  final IsarCollection<String, DbSetting> collection;

  @override
  bool call({required String id, Object? value = ignore}) {
    return collection.updateProperties(
          [id],
          {if (value != ignore) 2: value as String?},
        ) >
        0;
  }
}

sealed class _DbSettingUpdateAll {
  int call({required List<String> id, String? value});
}

class _DbSettingUpdateAllImpl implements _DbSettingUpdateAll {
  const _DbSettingUpdateAllImpl(this.collection);

  final IsarCollection<String, DbSetting> collection;

  @override
  int call({required List<String> id, Object? value = ignore}) {
    return collection.updateProperties(id, {
      if (value != ignore) 2: value as String?,
    });
  }
}

extension DbSettingUpdate on IsarCollection<String, DbSetting> {
  _DbSettingUpdate get update => _DbSettingUpdateImpl(this);

  _DbSettingUpdateAll get updateAll => _DbSettingUpdateAllImpl(this);
}

sealed class _DbSettingQueryUpdate {
  int call({String? value});
}

class _DbSettingQueryUpdateImpl implements _DbSettingQueryUpdate {
  const _DbSettingQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbSetting> query;
  final int? limit;

  @override
  int call({Object? value = ignore}) {
    return query.updateProperties(limit: limit, {
      if (value != ignore) 2: value as String?,
    });
  }
}

extension DbSettingQueryUpdate on IsarQuery<DbSetting> {
  _DbSettingQueryUpdate get updateFirst =>
      _DbSettingQueryUpdateImpl(this, limit: 1);

  _DbSettingQueryUpdate get updateAll => _DbSettingQueryUpdateImpl(this);
}

class _DbSettingQueryBuilderUpdateImpl implements _DbSettingQueryUpdate {
  const _DbSettingQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbSetting, DbSetting, QOperations> query;
  final int? limit;

  @override
  int call({Object? value = ignore}) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (value != ignore) 2: value as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbSettingQueryBuilderUpdate
    on QueryBuilder<DbSetting, DbSetting, QOperations> {
  _DbSettingQueryUpdate get updateFirst =>
      _DbSettingQueryBuilderUpdateImpl(this, limit: 1);

  _DbSettingQueryUpdate get updateAll => _DbSettingQueryBuilderUpdateImpl(this);
}

extension DbSettingQueryFilter
    on QueryBuilder<DbSetting, DbSetting, QFilterCondition> {
  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition>
  idGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition>
  valueGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition>
  valueLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterFilterCondition> valueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }
}

extension DbSettingQueryObject
    on QueryBuilder<DbSetting, DbSetting, QFilterCondition> {}

extension DbSettingQuerySortBy on QueryBuilder<DbSetting, DbSetting, QSortBy> {
  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> sortById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> sortByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> sortByValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> sortByValueDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension DbSettingQuerySortThenBy
    on QueryBuilder<DbSetting, DbSetting, QSortThenBy> {
  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> thenById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> thenByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> thenByValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbSetting, DbSetting, QAfterSortBy> thenByValueDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension DbSettingQueryWhereDistinct
    on QueryBuilder<DbSetting, DbSetting, QDistinct> {
  QueryBuilder<DbSetting, DbSetting, QAfterDistinct> distinctByValue({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }
}

extension DbSettingQueryProperty1
    on QueryBuilder<DbSetting, DbSetting, QProperty> {
  QueryBuilder<DbSetting, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbSetting, String, QAfterProperty> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension DbSettingQueryProperty2<R>
    on QueryBuilder<DbSetting, R, QAfterProperty> {
  QueryBuilder<DbSetting, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbSetting, (R, String), QAfterProperty> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension DbSettingQueryProperty3<R1, R2>
    on QueryBuilder<DbSetting, (R1, R2), QAfterProperty> {
  QueryBuilder<DbSetting, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbSetting, (R1, R2, String), QOperations> valueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbDeckCollection on Isar {
  IsarCollection<String, DbDeck> get dbDecks => this.collection();
}

final DbDeckSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbDeck',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'position', type: IsarType.long),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, DbDeck>(
    serialize: serializeDbDeck,
    deserialize: deserializeDbDeck,
    deserializeProperty: deserializeDbDeckProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDbDeck(IsarWriter writer, DbDeck object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.name);
  IsarCore.writeLong(writer, 3, object.position);
  return Isar.fastHash(object.id);
}

@isarProtected
DbDeck deserializeDbDeck(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _name;
  _name = IsarCore.readString(reader, 2) ?? '';
  final int _position;
  _position = IsarCore.readLong(reader, 3);
  final object = DbDeck(id: _id, name: _name, position: _position);
  return object;
}

@isarProtected
dynamic deserializeDbDeckProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readLong(reader, 3);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbDeckUpdate {
  bool call({required String id, String? name, int? position});
}

class _DbDeckUpdateImpl implements _DbDeckUpdate {
  const _DbDeckUpdateImpl(this.collection);

  final IsarCollection<String, DbDeck> collection;

  @override
  bool call({
    required String id,
    Object? name = ignore,
    Object? position = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (name != ignore) 2: name as String?,
            if (position != ignore) 3: position as int?,
          },
        ) >
        0;
  }
}

sealed class _DbDeckUpdateAll {
  int call({required List<String> id, String? name, int? position});
}

class _DbDeckUpdateAllImpl implements _DbDeckUpdateAll {
  const _DbDeckUpdateAllImpl(this.collection);

  final IsarCollection<String, DbDeck> collection;

  @override
  int call({
    required List<String> id,
    Object? name = ignore,
    Object? position = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 2: name as String?,
      if (position != ignore) 3: position as int?,
    });
  }
}

extension DbDeckUpdate on IsarCollection<String, DbDeck> {
  _DbDeckUpdate get update => _DbDeckUpdateImpl(this);

  _DbDeckUpdateAll get updateAll => _DbDeckUpdateAllImpl(this);
}

sealed class _DbDeckQueryUpdate {
  int call({String? name, int? position});
}

class _DbDeckQueryUpdateImpl implements _DbDeckQueryUpdate {
  const _DbDeckQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbDeck> query;
  final int? limit;

  @override
  int call({Object? name = ignore, Object? position = ignore}) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 2: name as String?,
      if (position != ignore) 3: position as int?,
    });
  }
}

extension DbDeckQueryUpdate on IsarQuery<DbDeck> {
  _DbDeckQueryUpdate get updateFirst => _DbDeckQueryUpdateImpl(this, limit: 1);

  _DbDeckQueryUpdate get updateAll => _DbDeckQueryUpdateImpl(this);
}

class _DbDeckQueryBuilderUpdateImpl implements _DbDeckQueryUpdate {
  const _DbDeckQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbDeck, DbDeck, QOperations> query;
  final int? limit;

  @override
  int call({Object? name = ignore, Object? position = ignore}) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 2: name as String?,
        if (position != ignore) 3: position as int?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbDeckQueryBuilderUpdate
    on QueryBuilder<DbDeck, DbDeck, QOperations> {
  _DbDeckQueryUpdate get updateFirst =>
      _DbDeckQueryBuilderUpdateImpl(this, limit: 1);

  _DbDeckQueryUpdate get updateAll => _DbDeckQueryBuilderUpdateImpl(this);
}

extension DbDeckQueryFilter on QueryBuilder<DbDeck, DbDeck, QFilterCondition> {
  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> positionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> positionGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition>
  positionGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> positionLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> positionLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterFilterCondition> positionBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }
}

extension DbDeckQueryObject on QueryBuilder<DbDeck, DbDeck, QFilterCondition> {}

extension DbDeckQuerySortBy on QueryBuilder<DbDeck, DbDeck, QSortBy> {
  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> sortById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> sortByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> sortByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> sortByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }
}

extension DbDeckQuerySortThenBy on QueryBuilder<DbDeck, DbDeck, QSortThenBy> {
  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> thenById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> thenByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> thenByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> thenByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterSortBy> thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }
}

extension DbDeckQueryWhereDistinct on QueryBuilder<DbDeck, DbDeck, QDistinct> {
  QueryBuilder<DbDeck, DbDeck, QAfterDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbDeck, DbDeck, QAfterDistinct> distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }
}

extension DbDeckQueryProperty1 on QueryBuilder<DbDeck, DbDeck, QProperty> {
  QueryBuilder<DbDeck, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbDeck, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbDeck, int, QAfterProperty> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension DbDeckQueryProperty2<R> on QueryBuilder<DbDeck, R, QAfterProperty> {
  QueryBuilder<DbDeck, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbDeck, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbDeck, (R, int), QAfterProperty> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

extension DbDeckQueryProperty3<R1, R2>
    on QueryBuilder<DbDeck, (R1, R2), QAfterProperty> {
  QueryBuilder<DbDeck, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbDeck, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbDeck, (R1, R2, int), QOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbQuestionCollection on Isar {
  IsarCollection<String, DbQuestion> get dbQuestions => this.collection();
}

final DbQuestionSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbQuestion',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'deckId', type: IsarType.string),
      IsarPropertySchema(name: 'sectionIndex', type: IsarType.long),
      IsarPropertySchema(name: 'sectionTitle', type: IsarType.string),
      IsarPropertySchema(name: 'position', type: IsarType.long),
      IsarPropertySchema(name: 'number', type: IsarType.long),
      IsarPropertySchema(name: 'text', type: IsarType.string),
      IsarPropertySchema(name: 'options', type: IsarType.stringList),
      IsarPropertySchema(name: 'answer', type: IsarType.long),
      IsarPropertySchema(name: 'explanation', type: IsarType.string),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'deckId',
        properties: ["deckId"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, DbQuestion>(
    serialize: serializeDbQuestion,
    deserialize: deserializeDbQuestion,
    deserializeProperty: deserializeDbQuestionProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDbQuestion(IsarWriter writer, DbQuestion object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.deckId);
  IsarCore.writeLong(writer, 3, object.sectionIndex);
  IsarCore.writeString(writer, 4, object.sectionTitle);
  IsarCore.writeLong(writer, 5, object.position);
  IsarCore.writeLong(writer, 6, object.number);
  IsarCore.writeString(writer, 7, object.text);
  {
    final list = object.options;
    final listWriter = IsarCore.beginList(writer, 8, list.length);
    for (var i = 0; i < list.length; i++) {
      IsarCore.writeString(listWriter, i, list[i]);
    }
    IsarCore.endList(writer, listWriter);
  }
  IsarCore.writeLong(writer, 9, object.answer ?? -9223372036854775808);
  {
    final value = object.explanation;
    if (value == null) {
      IsarCore.writeNull(writer, 10);
    } else {
      IsarCore.writeString(writer, 10, value);
    }
  }
  return Isar.fastHash(object.id);
}

@isarProtected
DbQuestion deserializeDbQuestion(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _deckId;
  _deckId = IsarCore.readString(reader, 2) ?? '';
  final int _sectionIndex;
  _sectionIndex = IsarCore.readLong(reader, 3);
  final String _sectionTitle;
  _sectionTitle = IsarCore.readString(reader, 4) ?? '';
  final int _position;
  _position = IsarCore.readLong(reader, 5);
  final int _number;
  _number = IsarCore.readLong(reader, 6);
  final String _text;
  _text = IsarCore.readString(reader, 7) ?? '';
  final List<String> _options;
  {
    final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
    {
      final reader = IsarCore.readerPtr;
      if (reader.isNull) {
        _options = const <String>[];
      } else {
        final list = List<String>.filled(length, '', growable: true);
        for (var i = 0; i < length; i++) {
          list[i] = IsarCore.readString(reader, i) ?? '';
        }
        IsarCore.freeReader(reader);
        _options = list;
      }
    }
  }
  final int? _answer;
  {
    final value = IsarCore.readLong(reader, 9);
    if (value == -9223372036854775808) {
      _answer = null;
    } else {
      _answer = value;
    }
  }
  final String? _explanation;
  _explanation = IsarCore.readString(reader, 10);
  final object = DbQuestion(
    id: _id,
    deckId: _deckId,
    sectionIndex: _sectionIndex,
    sectionTitle: _sectionTitle,
    position: _position,
    number: _number,
    text: _text,
    options: _options,
    answer: _answer,
    explanation: _explanation,
  );
  return object;
}

@isarProtected
dynamic deserializeDbQuestionProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readLong(reader, 3);
    case 4:
      return IsarCore.readString(reader, 4) ?? '';
    case 5:
      return IsarCore.readLong(reader, 5);
    case 6:
      return IsarCore.readLong(reader, 6);
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      {
        final length = IsarCore.readList(reader, 8, IsarCore.readerPtrPtr);
        {
          final reader = IsarCore.readerPtr;
          if (reader.isNull) {
            return const <String>[];
          } else {
            final list = List<String>.filled(length, '', growable: true);
            for (var i = 0; i < length; i++) {
              list[i] = IsarCore.readString(reader, i) ?? '';
            }
            IsarCore.freeReader(reader);
            return list;
          }
        }
      }
    case 9:
      {
        final value = IsarCore.readLong(reader, 9);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 10:
      return IsarCore.readString(reader, 10);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbQuestionUpdate {
  bool call({
    required String id,
    String? deckId,
    int? sectionIndex,
    String? sectionTitle,
    int? position,
    int? number,
    String? text,
    int? answer,
    String? explanation,
  });
}

class _DbQuestionUpdateImpl implements _DbQuestionUpdate {
  const _DbQuestionUpdateImpl(this.collection);

  final IsarCollection<String, DbQuestion> collection;

  @override
  bool call({
    required String id,
    Object? deckId = ignore,
    Object? sectionIndex = ignore,
    Object? sectionTitle = ignore,
    Object? position = ignore,
    Object? number = ignore,
    Object? text = ignore,
    Object? answer = ignore,
    Object? explanation = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (deckId != ignore) 2: deckId as String?,
            if (sectionIndex != ignore) 3: sectionIndex as int?,
            if (sectionTitle != ignore) 4: sectionTitle as String?,
            if (position != ignore) 5: position as int?,
            if (number != ignore) 6: number as int?,
            if (text != ignore) 7: text as String?,
            if (answer != ignore) 9: answer as int?,
            if (explanation != ignore) 10: explanation as String?,
          },
        ) >
        0;
  }
}

sealed class _DbQuestionUpdateAll {
  int call({
    required List<String> id,
    String? deckId,
    int? sectionIndex,
    String? sectionTitle,
    int? position,
    int? number,
    String? text,
    int? answer,
    String? explanation,
  });
}

class _DbQuestionUpdateAllImpl implements _DbQuestionUpdateAll {
  const _DbQuestionUpdateAllImpl(this.collection);

  final IsarCollection<String, DbQuestion> collection;

  @override
  int call({
    required List<String> id,
    Object? deckId = ignore,
    Object? sectionIndex = ignore,
    Object? sectionTitle = ignore,
    Object? position = ignore,
    Object? number = ignore,
    Object? text = ignore,
    Object? answer = ignore,
    Object? explanation = ignore,
  }) {
    return collection.updateProperties(id, {
      if (deckId != ignore) 2: deckId as String?,
      if (sectionIndex != ignore) 3: sectionIndex as int?,
      if (sectionTitle != ignore) 4: sectionTitle as String?,
      if (position != ignore) 5: position as int?,
      if (number != ignore) 6: number as int?,
      if (text != ignore) 7: text as String?,
      if (answer != ignore) 9: answer as int?,
      if (explanation != ignore) 10: explanation as String?,
    });
  }
}

extension DbQuestionUpdate on IsarCollection<String, DbQuestion> {
  _DbQuestionUpdate get update => _DbQuestionUpdateImpl(this);

  _DbQuestionUpdateAll get updateAll => _DbQuestionUpdateAllImpl(this);
}

sealed class _DbQuestionQueryUpdate {
  int call({
    String? deckId,
    int? sectionIndex,
    String? sectionTitle,
    int? position,
    int? number,
    String? text,
    int? answer,
    String? explanation,
  });
}

class _DbQuestionQueryUpdateImpl implements _DbQuestionQueryUpdate {
  const _DbQuestionQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbQuestion> query;
  final int? limit;

  @override
  int call({
    Object? deckId = ignore,
    Object? sectionIndex = ignore,
    Object? sectionTitle = ignore,
    Object? position = ignore,
    Object? number = ignore,
    Object? text = ignore,
    Object? answer = ignore,
    Object? explanation = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (deckId != ignore) 2: deckId as String?,
      if (sectionIndex != ignore) 3: sectionIndex as int?,
      if (sectionTitle != ignore) 4: sectionTitle as String?,
      if (position != ignore) 5: position as int?,
      if (number != ignore) 6: number as int?,
      if (text != ignore) 7: text as String?,
      if (answer != ignore) 9: answer as int?,
      if (explanation != ignore) 10: explanation as String?,
    });
  }
}

extension DbQuestionQueryUpdate on IsarQuery<DbQuestion> {
  _DbQuestionQueryUpdate get updateFirst =>
      _DbQuestionQueryUpdateImpl(this, limit: 1);

  _DbQuestionQueryUpdate get updateAll => _DbQuestionQueryUpdateImpl(this);
}

class _DbQuestionQueryBuilderUpdateImpl implements _DbQuestionQueryUpdate {
  const _DbQuestionQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbQuestion, DbQuestion, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? deckId = ignore,
    Object? sectionIndex = ignore,
    Object? sectionTitle = ignore,
    Object? position = ignore,
    Object? number = ignore,
    Object? text = ignore,
    Object? answer = ignore,
    Object? explanation = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (deckId != ignore) 2: deckId as String?,
        if (sectionIndex != ignore) 3: sectionIndex as int?,
        if (sectionTitle != ignore) 4: sectionTitle as String?,
        if (position != ignore) 5: position as int?,
        if (number != ignore) 6: number as int?,
        if (text != ignore) 7: text as String?,
        if (answer != ignore) 9: answer as int?,
        if (explanation != ignore) 10: explanation as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbQuestionQueryBuilderUpdate
    on QueryBuilder<DbQuestion, DbQuestion, QOperations> {
  _DbQuestionQueryUpdate get updateFirst =>
      _DbQuestionQueryBuilderUpdateImpl(this, limit: 1);

  _DbQuestionQueryUpdate get updateAll =>
      _DbQuestionQueryBuilderUpdateImpl(this);
}

extension DbQuestionQueryFilter
    on QueryBuilder<DbQuestion, DbQuestion, QFilterCondition> {
  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  idGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  idLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  deckIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  deckIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> deckIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  deckIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionIndexGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionIndexGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionIndexLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionIndexLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionIndexBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 4,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 4,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  sectionTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 4, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> positionEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  positionGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  positionGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> positionLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  positionLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> positionBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> numberEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> numberGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  numberGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> numberLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  numberLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> numberBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  textGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  textLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> textIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementGreaterThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 8, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 8,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 8,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 8,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 8, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 8, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> optionsIsEmpty() {
    return not().optionsIsNotEmpty();
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  optionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterOrEqualCondition(property: 8, value: null),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> answerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  answerIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 9));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> answerEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> answerGreaterThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 9, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  answerGreaterThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 9, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> answerLessThan(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 9, value: value));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  answerLessThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 9, value: value),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition> answerBetween(
    int? lower,
    int? upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 9, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 10));
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationGreaterThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationLessThan(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 10, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 10,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 10,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 10,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 10, value: ''),
      );
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterFilterCondition>
  explanationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 10, value: ''),
      );
    });
  }
}

extension DbQuestionQueryObject
    on QueryBuilder<DbQuestion, DbQuestion, QFilterCondition> {}

extension DbQuestionQuerySortBy
    on QueryBuilder<DbQuestion, DbQuestion, QSortBy> {
  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByDeckId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByDeckIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortBySectionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortBySectionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortBySectionTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortBySectionTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByTextDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByExplanation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> sortByExplanationDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension DbQuestionQuerySortThenBy
    on QueryBuilder<DbQuestion, DbQuestion, QSortThenBy> {
  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByDeckId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByDeckIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenBySectionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenBySectionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenBySectionTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenBySectionTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByTextDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByAnswerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByExplanation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterSortBy> thenByExplanationDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension DbQuestionQueryWhereDistinct
    on QueryBuilder<DbQuestion, DbQuestion, QDistinct> {
  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByDeckId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct>
  distinctBySectionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctBySectionTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByOptions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByAnswer() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<DbQuestion, DbQuestion, QAfterDistinct> distinctByExplanation({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10, caseSensitive: caseSensitive);
    });
  }
}

extension DbQuestionQueryProperty1
    on QueryBuilder<DbQuestion, DbQuestion, QProperty> {
  QueryBuilder<DbQuestion, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbQuestion, String, QAfterProperty> deckIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbQuestion, int, QAfterProperty> sectionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbQuestion, String, QAfterProperty> sectionTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbQuestion, int, QAfterProperty> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbQuestion, int, QAfterProperty> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbQuestion, String, QAfterProperty> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbQuestion, List<String>, QAfterProperty> optionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbQuestion, int?, QAfterProperty> answerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbQuestion, String?, QAfterProperty> explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension DbQuestionQueryProperty2<R>
    on QueryBuilder<DbQuestion, R, QAfterProperty> {
  QueryBuilder<DbQuestion, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbQuestion, (R, String), QAfterProperty> deckIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbQuestion, (R, int), QAfterProperty> sectionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbQuestion, (R, String), QAfterProperty> sectionTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbQuestion, (R, int), QAfterProperty> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbQuestion, (R, int), QAfterProperty> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbQuestion, (R, String), QAfterProperty> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbQuestion, (R, List<String>), QAfterProperty>
  optionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbQuestion, (R, int?), QAfterProperty> answerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbQuestion, (R, String?), QAfterProperty> explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

extension DbQuestionQueryProperty3<R1, R2>
    on QueryBuilder<DbQuestion, (R1, R2), QAfterProperty> {
  QueryBuilder<DbQuestion, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, String), QOperations> deckIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, int), QOperations> sectionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, String), QOperations>
  sectionTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, int), QOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, int), QOperations> numberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, String), QOperations> textProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, List<String>), QOperations>
  optionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, int?), QOperations> answerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<DbQuestion, (R1, R2, String?), QOperations>
  explanationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbResultCollection on Isar {
  IsarCollection<String, DbResult> get dbResults => this.collection();
}

final DbResultSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbResult',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'user', type: IsarType.string),
      IsarPropertySchema(name: 'questionId', type: IsarType.string),
      IsarPropertySchema(name: 'correct', type: IsarType.bool),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'synced', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'user',
        properties: ["user"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, DbResult>(
    serialize: serializeDbResult,
    deserialize: deserializeDbResult,
    deserializeProperty: deserializeDbResultProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDbResult(IsarWriter writer, DbResult object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.user);
  IsarCore.writeString(writer, 3, object.questionId);
  IsarCore.writeBool(writer, 4, value: object.correct);
  IsarCore.writeLong(
    writer,
    5,
    object.updatedAt.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeBool(writer, 6, value: object.synced);
  return Isar.fastHash(object.id);
}

@isarProtected
DbResult deserializeDbResult(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _user;
  _user = IsarCore.readString(reader, 2) ?? '';
  final String _questionId;
  _questionId = IsarCore.readString(reader, 3) ?? '';
  final bool _correct;
  _correct = IsarCore.readBool(reader, 4);
  final DateTime _updatedAt;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _updatedAt = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _updatedAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final bool _synced;
  _synced = IsarCore.readBool(reader, 6);
  final object = DbResult(
    id: _id,
    user: _user,
    questionId: _questionId,
    correct: _correct,
    updatedAt: _updatedAt,
    synced: _synced,
  );
  return object;
}

@isarProtected
dynamic deserializeDbResultProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readBool(reader, 4);
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 6:
      return IsarCore.readBool(reader, 6);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbResultUpdate {
  bool call({
    required String id,
    String? user,
    String? questionId,
    bool? correct,
    DateTime? updatedAt,
    bool? synced,
  });
}

class _DbResultUpdateImpl implements _DbResultUpdate {
  const _DbResultUpdateImpl(this.collection);

  final IsarCollection<String, DbResult> collection;

  @override
  bool call({
    required String id,
    Object? user = ignore,
    Object? questionId = ignore,
    Object? correct = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (user != ignore) 2: user as String?,
            if (questionId != ignore) 3: questionId as String?,
            if (correct != ignore) 4: correct as bool?,
            if (updatedAt != ignore) 5: updatedAt as DateTime?,
            if (synced != ignore) 6: synced as bool?,
          },
        ) >
        0;
  }
}

sealed class _DbResultUpdateAll {
  int call({
    required List<String> id,
    String? user,
    String? questionId,
    bool? correct,
    DateTime? updatedAt,
    bool? synced,
  });
}

class _DbResultUpdateAllImpl implements _DbResultUpdateAll {
  const _DbResultUpdateAllImpl(this.collection);

  final IsarCollection<String, DbResult> collection;

  @override
  int call({
    required List<String> id,
    Object? user = ignore,
    Object? questionId = ignore,
    Object? correct = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    return collection.updateProperties(id, {
      if (user != ignore) 2: user as String?,
      if (questionId != ignore) 3: questionId as String?,
      if (correct != ignore) 4: correct as bool?,
      if (updatedAt != ignore) 5: updatedAt as DateTime?,
      if (synced != ignore) 6: synced as bool?,
    });
  }
}

extension DbResultUpdate on IsarCollection<String, DbResult> {
  _DbResultUpdate get update => _DbResultUpdateImpl(this);

  _DbResultUpdateAll get updateAll => _DbResultUpdateAllImpl(this);
}

sealed class _DbResultQueryUpdate {
  int call({
    String? user,
    String? questionId,
    bool? correct,
    DateTime? updatedAt,
    bool? synced,
  });
}

class _DbResultQueryUpdateImpl implements _DbResultQueryUpdate {
  const _DbResultQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbResult> query;
  final int? limit;

  @override
  int call({
    Object? user = ignore,
    Object? questionId = ignore,
    Object? correct = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (user != ignore) 2: user as String?,
      if (questionId != ignore) 3: questionId as String?,
      if (correct != ignore) 4: correct as bool?,
      if (updatedAt != ignore) 5: updatedAt as DateTime?,
      if (synced != ignore) 6: synced as bool?,
    });
  }
}

extension DbResultQueryUpdate on IsarQuery<DbResult> {
  _DbResultQueryUpdate get updateFirst =>
      _DbResultQueryUpdateImpl(this, limit: 1);

  _DbResultQueryUpdate get updateAll => _DbResultQueryUpdateImpl(this);
}

class _DbResultQueryBuilderUpdateImpl implements _DbResultQueryUpdate {
  const _DbResultQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbResult, DbResult, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? user = ignore,
    Object? questionId = ignore,
    Object? correct = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (user != ignore) 2: user as String?,
        if (questionId != ignore) 3: questionId as String?,
        if (correct != ignore) 4: correct as bool?,
        if (updatedAt != ignore) 5: updatedAt as DateTime?,
        if (synced != ignore) 6: synced as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbResultQueryBuilderUpdate
    on QueryBuilder<DbResult, DbResult, QOperations> {
  _DbResultQueryUpdate get updateFirst =>
      _DbResultQueryBuilderUpdateImpl(this, limit: 1);

  _DbResultQueryUpdate get updateAll => _DbResultQueryBuilderUpdateImpl(this);
}

extension DbResultQueryFilter
    on QueryBuilder<DbResult, DbResult, QFilterCondition> {
  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  idGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  userGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userLessThanOrEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> userIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  questionIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  questionIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> questionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  questionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> correctEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> updatedAtEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  updatedAtGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> updatedAtLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition>
  updatedAtLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }
}

extension DbResultQueryObject
    on QueryBuilder<DbResult, DbResult, QFilterCondition> {}

extension DbResultQuerySortBy on QueryBuilder<DbResult, DbResult, QSortBy> {
  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByUserDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByQuestionId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByQuestionIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension DbResultQuerySortThenBy
    on QueryBuilder<DbResult, DbResult, QSortThenBy> {
  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByUserDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByQuestionId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByQuestionIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }
}

extension DbResultQueryWhereDistinct
    on QueryBuilder<DbResult, DbResult, QDistinct> {
  QueryBuilder<DbResult, DbResult, QAfterDistinct> distinctByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterDistinct> distinctByQuestionId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterDistinct> distinctByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DbResult, DbResult, QAfterDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }
}

extension DbResultQueryProperty1
    on QueryBuilder<DbResult, DbResult, QProperty> {
  QueryBuilder<DbResult, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbResult, String, QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbResult, String, QAfterProperty> questionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbResult, bool, QAfterProperty> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbResult, DateTime, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbResult, bool, QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension DbResultQueryProperty2<R>
    on QueryBuilder<DbResult, R, QAfterProperty> {
  QueryBuilder<DbResult, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbResult, (R, String), QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbResult, (R, String), QAfterProperty> questionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbResult, (R, bool), QAfterProperty> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbResult, (R, DateTime), QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbResult, (R, bool), QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

extension DbResultQueryProperty3<R1, R2>
    on QueryBuilder<DbResult, (R1, R2), QAfterProperty> {
  QueryBuilder<DbResult, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbResult, (R1, R2, String), QOperations> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbResult, (R1, R2, String), QOperations> questionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbResult, (R1, R2, bool), QOperations> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbResult, (R1, R2, DateTime), QOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbResult, (R1, R2, bool), QOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbAttemptCollection on Isar {
  IsarCollection<int, DbAttempt> get dbAttempts => this.collection();
}

final DbAttemptSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbAttempt',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'user', type: IsarType.string),
      IsarPropertySchema(name: 'deckId', type: IsarType.string),
      IsarPropertySchema(name: 'at', type: IsarType.dateTime),
      IsarPropertySchema(name: 'totalCount', type: IsarType.long),
      IsarPropertySchema(name: 'rightCount', type: IsarType.long),
      IsarPropertySchema(name: 'wrongCount', type: IsarType.long),
      IsarPropertySchema(name: 'seconds', type: IsarType.long),
      IsarPropertySchema(name: 'synced', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'user',
        properties: ["user"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, DbAttempt>(
    serialize: serializeDbAttempt,
    deserialize: deserializeDbAttempt,
    deserializeProperty: deserializeDbAttemptProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDbAttempt(IsarWriter writer, DbAttempt object) {
  IsarCore.writeString(writer, 1, object.user);
  IsarCore.writeString(writer, 2, object.deckId);
  IsarCore.writeLong(writer, 3, object.at.toUtc().microsecondsSinceEpoch);
  IsarCore.writeLong(writer, 4, object.totalCount);
  IsarCore.writeLong(writer, 5, object.rightCount);
  IsarCore.writeLong(writer, 6, object.wrongCount);
  IsarCore.writeLong(writer, 7, object.seconds);
  IsarCore.writeBool(writer, 8, value: object.synced);
  return object.id;
}

@isarProtected
DbAttempt deserializeDbAttempt(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _user;
  _user = IsarCore.readString(reader, 1) ?? '';
  final String _deckId;
  _deckId = IsarCore.readString(reader, 2) ?? '';
  final DateTime _at;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _at = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _at = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final int _totalCount;
  _totalCount = IsarCore.readLong(reader, 4);
  final int _rightCount;
  _rightCount = IsarCore.readLong(reader, 5);
  final int _wrongCount;
  _wrongCount = IsarCore.readLong(reader, 6);
  final int _seconds;
  _seconds = IsarCore.readLong(reader, 7);
  final bool _synced;
  _synced = IsarCore.readBool(reader, 8);
  final object = DbAttempt(
    id: _id,
    user: _user,
    deckId: _deckId,
    at: _at,
    totalCount: _totalCount,
    rightCount: _rightCount,
    wrongCount: _wrongCount,
    seconds: _seconds,
    synced: _synced,
  );
  return object;
}

@isarProtected
dynamic deserializeDbAttemptProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 4:
      return IsarCore.readLong(reader, 4);
    case 5:
      return IsarCore.readLong(reader, 5);
    case 6:
      return IsarCore.readLong(reader, 6);
    case 7:
      return IsarCore.readLong(reader, 7);
    case 8:
      return IsarCore.readBool(reader, 8);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbAttemptUpdate {
  bool call({
    required int id,
    String? user,
    String? deckId,
    DateTime? at,
    int? totalCount,
    int? rightCount,
    int? wrongCount,
    int? seconds,
    bool? synced,
  });
}

class _DbAttemptUpdateImpl implements _DbAttemptUpdate {
  const _DbAttemptUpdateImpl(this.collection);

  final IsarCollection<int, DbAttempt> collection;

  @override
  bool call({
    required int id,
    Object? user = ignore,
    Object? deckId = ignore,
    Object? at = ignore,
    Object? totalCount = ignore,
    Object? rightCount = ignore,
    Object? wrongCount = ignore,
    Object? seconds = ignore,
    Object? synced = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (user != ignore) 1: user as String?,
            if (deckId != ignore) 2: deckId as String?,
            if (at != ignore) 3: at as DateTime?,
            if (totalCount != ignore) 4: totalCount as int?,
            if (rightCount != ignore) 5: rightCount as int?,
            if (wrongCount != ignore) 6: wrongCount as int?,
            if (seconds != ignore) 7: seconds as int?,
            if (synced != ignore) 8: synced as bool?,
          },
        ) >
        0;
  }
}

sealed class _DbAttemptUpdateAll {
  int call({
    required List<int> id,
    String? user,
    String? deckId,
    DateTime? at,
    int? totalCount,
    int? rightCount,
    int? wrongCount,
    int? seconds,
    bool? synced,
  });
}

class _DbAttemptUpdateAllImpl implements _DbAttemptUpdateAll {
  const _DbAttemptUpdateAllImpl(this.collection);

  final IsarCollection<int, DbAttempt> collection;

  @override
  int call({
    required List<int> id,
    Object? user = ignore,
    Object? deckId = ignore,
    Object? at = ignore,
    Object? totalCount = ignore,
    Object? rightCount = ignore,
    Object? wrongCount = ignore,
    Object? seconds = ignore,
    Object? synced = ignore,
  }) {
    return collection.updateProperties(id, {
      if (user != ignore) 1: user as String?,
      if (deckId != ignore) 2: deckId as String?,
      if (at != ignore) 3: at as DateTime?,
      if (totalCount != ignore) 4: totalCount as int?,
      if (rightCount != ignore) 5: rightCount as int?,
      if (wrongCount != ignore) 6: wrongCount as int?,
      if (seconds != ignore) 7: seconds as int?,
      if (synced != ignore) 8: synced as bool?,
    });
  }
}

extension DbAttemptUpdate on IsarCollection<int, DbAttempt> {
  _DbAttemptUpdate get update => _DbAttemptUpdateImpl(this);

  _DbAttemptUpdateAll get updateAll => _DbAttemptUpdateAllImpl(this);
}

sealed class _DbAttemptQueryUpdate {
  int call({
    String? user,
    String? deckId,
    DateTime? at,
    int? totalCount,
    int? rightCount,
    int? wrongCount,
    int? seconds,
    bool? synced,
  });
}

class _DbAttemptQueryUpdateImpl implements _DbAttemptQueryUpdate {
  const _DbAttemptQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbAttempt> query;
  final int? limit;

  @override
  int call({
    Object? user = ignore,
    Object? deckId = ignore,
    Object? at = ignore,
    Object? totalCount = ignore,
    Object? rightCount = ignore,
    Object? wrongCount = ignore,
    Object? seconds = ignore,
    Object? synced = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (user != ignore) 1: user as String?,
      if (deckId != ignore) 2: deckId as String?,
      if (at != ignore) 3: at as DateTime?,
      if (totalCount != ignore) 4: totalCount as int?,
      if (rightCount != ignore) 5: rightCount as int?,
      if (wrongCount != ignore) 6: wrongCount as int?,
      if (seconds != ignore) 7: seconds as int?,
      if (synced != ignore) 8: synced as bool?,
    });
  }
}

extension DbAttemptQueryUpdate on IsarQuery<DbAttempt> {
  _DbAttemptQueryUpdate get updateFirst =>
      _DbAttemptQueryUpdateImpl(this, limit: 1);

  _DbAttemptQueryUpdate get updateAll => _DbAttemptQueryUpdateImpl(this);
}

class _DbAttemptQueryBuilderUpdateImpl implements _DbAttemptQueryUpdate {
  const _DbAttemptQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbAttempt, DbAttempt, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? user = ignore,
    Object? deckId = ignore,
    Object? at = ignore,
    Object? totalCount = ignore,
    Object? rightCount = ignore,
    Object? wrongCount = ignore,
    Object? seconds = ignore,
    Object? synced = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (user != ignore) 1: user as String?,
        if (deckId != ignore) 2: deckId as String?,
        if (at != ignore) 3: at as DateTime?,
        if (totalCount != ignore) 4: totalCount as int?,
        if (rightCount != ignore) 5: rightCount as int?,
        if (wrongCount != ignore) 6: wrongCount as int?,
        if (seconds != ignore) 7: seconds as int?,
        if (synced != ignore) 8: synced as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbAttemptQueryBuilderUpdate
    on QueryBuilder<DbAttempt, DbAttempt, QOperations> {
  _DbAttemptQueryUpdate get updateFirst =>
      _DbAttemptQueryBuilderUpdateImpl(this, limit: 1);

  _DbAttemptQueryUpdate get updateAll => _DbAttemptQueryBuilderUpdateImpl(this);
}

extension DbAttemptQueryFilter
    on QueryBuilder<DbAttempt, DbAttempt, QFilterCondition> {
  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> idLessThanOrEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  userGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  userLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> userIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  deckIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  deckIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> deckIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> atEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> atGreaterThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  atGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> atLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> atLessThanOrEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> atBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> totalCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  totalCountGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  totalCountGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> totalCountLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 4, value: value));
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  totalCountLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> totalCountBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> rightCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  rightCountGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  rightCountGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> rightCountLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  rightCountLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> rightCountBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> wrongCountEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  wrongCountGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  wrongCountGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> wrongCountLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  wrongCountLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> wrongCountBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> secondsEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> secondsGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  secondsGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> secondsLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 7, value: value));
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition>
  secondsLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> secondsBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 7, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterFilterCondition> syncedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }
}

extension DbAttemptQueryObject
    on QueryBuilder<DbAttempt, DbAttempt, QFilterCondition> {}

extension DbAttemptQuerySortBy on QueryBuilder<DbAttempt, DbAttempt, QSortBy> {
  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByUserDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByDeckId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByDeckIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByRightCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByRightCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortBySeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortBySecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension DbAttemptQuerySortThenBy
    on QueryBuilder<DbAttempt, DbAttempt, QSortThenBy> {
  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByUserDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByDeckId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByDeckIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByTotalCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByRightCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByRightCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenByWrongCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenBySeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenBySecondsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension DbAttemptQueryWhereDistinct
    on QueryBuilder<DbAttempt, DbAttempt, QDistinct> {
  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctByDeckId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctByAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctByTotalCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctByRightCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctByWrongCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctBySeconds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<DbAttempt, DbAttempt, QAfterDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension DbAttemptQueryProperty1
    on QueryBuilder<DbAttempt, DbAttempt, QProperty> {
  QueryBuilder<DbAttempt, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DbAttempt, String, QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbAttempt, String, QAfterProperty> deckIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbAttempt, DateTime, QAfterProperty> atProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbAttempt, int, QAfterProperty> totalCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbAttempt, int, QAfterProperty> rightCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbAttempt, int, QAfterProperty> wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbAttempt, int, QAfterProperty> secondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbAttempt, bool, QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension DbAttemptQueryProperty2<R>
    on QueryBuilder<DbAttempt, R, QAfterProperty> {
  QueryBuilder<DbAttempt, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DbAttempt, (R, String), QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbAttempt, (R, String), QAfterProperty> deckIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbAttempt, (R, DateTime), QAfterProperty> atProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbAttempt, (R, int), QAfterProperty> totalCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbAttempt, (R, int), QAfterProperty> rightCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbAttempt, (R, int), QAfterProperty> wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbAttempt, (R, int), QAfterProperty> secondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbAttempt, (R, bool), QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension DbAttemptQueryProperty3<R1, R2>
    on QueryBuilder<DbAttempt, (R1, R2), QAfterProperty> {
  QueryBuilder<DbAttempt, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, String), QOperations> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, String), QOperations> deckIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, DateTime), QOperations> atProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, int), QOperations> totalCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, int), QOperations> rightCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, int), QOperations> wrongCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, int), QOperations> secondsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbAttempt, (R1, R2, bool), QOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetDbVocabProgressCollection on Isar {
  IsarCollection<String, DbVocabProgress> get dbVocabProgress =>
      this.collection();
}

final DbVocabProgressSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'DbVocabProgress',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'user', type: IsarType.string),
      IsarPropertySchema(name: 'wordId', type: IsarType.string),
      IsarPropertySchema(name: 'known', type: IsarType.bool),
      IsarPropertySchema(name: 'correct', type: IsarType.long),
      IsarPropertySchema(name: 'wrong', type: IsarType.long),
      IsarPropertySchema(name: 'updatedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'synced', type: IsarType.bool),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'user',
        properties: ["user"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<String, DbVocabProgress>(
    serialize: serializeDbVocabProgress,
    deserialize: deserializeDbVocabProgress,
    deserializeProperty: deserializeDbVocabProgressProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeDbVocabProgress(IsarWriter writer, DbVocabProgress object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.user);
  IsarCore.writeString(writer, 3, object.wordId);
  IsarCore.writeBool(writer, 4, value: object.known);
  IsarCore.writeLong(writer, 5, object.correct);
  IsarCore.writeLong(writer, 6, object.wrong);
  IsarCore.writeLong(
    writer,
    7,
    object.updatedAt.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeBool(writer, 8, value: object.synced);
  return Isar.fastHash(object.id);
}

@isarProtected
DbVocabProgress deserializeDbVocabProgress(IsarReader reader) {
  final String _id;
  _id = IsarCore.readString(reader, 1) ?? '';
  final String _user;
  _user = IsarCore.readString(reader, 2) ?? '';
  final String _wordId;
  _wordId = IsarCore.readString(reader, 3) ?? '';
  final bool _known;
  _known = IsarCore.readBool(reader, 4);
  final int _correct;
  _correct = IsarCore.readLong(reader, 5);
  final int _wrong;
  _wrong = IsarCore.readLong(reader, 6);
  final DateTime _updatedAt;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _updatedAt = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _updatedAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final bool _synced;
  _synced = IsarCore.readBool(reader, 8);
  final object = DbVocabProgress(
    id: _id,
    user: _user,
    wordId: _wordId,
    known: _known,
    correct: _correct,
    wrong: _wrong,
    updatedAt: _updatedAt,
    synced: _synced,
  );
  return object;
}

@isarProtected
dynamic deserializeDbVocabProgressProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readString(reader, 3) ?? '';
    case 4:
      return IsarCore.readBool(reader, 4);
    case 5:
      return IsarCore.readLong(reader, 5);
    case 6:
      return IsarCore.readLong(reader, 6);
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 8:
      return IsarCore.readBool(reader, 8);
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _DbVocabProgressUpdate {
  bool call({
    required String id,
    String? user,
    String? wordId,
    bool? known,
    int? correct,
    int? wrong,
    DateTime? updatedAt,
    bool? synced,
  });
}

class _DbVocabProgressUpdateImpl implements _DbVocabProgressUpdate {
  const _DbVocabProgressUpdateImpl(this.collection);

  final IsarCollection<String, DbVocabProgress> collection;

  @override
  bool call({
    required String id,
    Object? user = ignore,
    Object? wordId = ignore,
    Object? known = ignore,
    Object? correct = ignore,
    Object? wrong = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (user != ignore) 2: user as String?,
            if (wordId != ignore) 3: wordId as String?,
            if (known != ignore) 4: known as bool?,
            if (correct != ignore) 5: correct as int?,
            if (wrong != ignore) 6: wrong as int?,
            if (updatedAt != ignore) 7: updatedAt as DateTime?,
            if (synced != ignore) 8: synced as bool?,
          },
        ) >
        0;
  }
}

sealed class _DbVocabProgressUpdateAll {
  int call({
    required List<String> id,
    String? user,
    String? wordId,
    bool? known,
    int? correct,
    int? wrong,
    DateTime? updatedAt,
    bool? synced,
  });
}

class _DbVocabProgressUpdateAllImpl implements _DbVocabProgressUpdateAll {
  const _DbVocabProgressUpdateAllImpl(this.collection);

  final IsarCollection<String, DbVocabProgress> collection;

  @override
  int call({
    required List<String> id,
    Object? user = ignore,
    Object? wordId = ignore,
    Object? known = ignore,
    Object? correct = ignore,
    Object? wrong = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    return collection.updateProperties(id, {
      if (user != ignore) 2: user as String?,
      if (wordId != ignore) 3: wordId as String?,
      if (known != ignore) 4: known as bool?,
      if (correct != ignore) 5: correct as int?,
      if (wrong != ignore) 6: wrong as int?,
      if (updatedAt != ignore) 7: updatedAt as DateTime?,
      if (synced != ignore) 8: synced as bool?,
    });
  }
}

extension DbVocabProgressUpdate on IsarCollection<String, DbVocabProgress> {
  _DbVocabProgressUpdate get update => _DbVocabProgressUpdateImpl(this);

  _DbVocabProgressUpdateAll get updateAll =>
      _DbVocabProgressUpdateAllImpl(this);
}

sealed class _DbVocabProgressQueryUpdate {
  int call({
    String? user,
    String? wordId,
    bool? known,
    int? correct,
    int? wrong,
    DateTime? updatedAt,
    bool? synced,
  });
}

class _DbVocabProgressQueryUpdateImpl implements _DbVocabProgressQueryUpdate {
  const _DbVocabProgressQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<DbVocabProgress> query;
  final int? limit;

  @override
  int call({
    Object? user = ignore,
    Object? wordId = ignore,
    Object? known = ignore,
    Object? correct = ignore,
    Object? wrong = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (user != ignore) 2: user as String?,
      if (wordId != ignore) 3: wordId as String?,
      if (known != ignore) 4: known as bool?,
      if (correct != ignore) 5: correct as int?,
      if (wrong != ignore) 6: wrong as int?,
      if (updatedAt != ignore) 7: updatedAt as DateTime?,
      if (synced != ignore) 8: synced as bool?,
    });
  }
}

extension DbVocabProgressQueryUpdate on IsarQuery<DbVocabProgress> {
  _DbVocabProgressQueryUpdate get updateFirst =>
      _DbVocabProgressQueryUpdateImpl(this, limit: 1);

  _DbVocabProgressQueryUpdate get updateAll =>
      _DbVocabProgressQueryUpdateImpl(this);
}

class _DbVocabProgressQueryBuilderUpdateImpl
    implements _DbVocabProgressQueryUpdate {
  const _DbVocabProgressQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<DbVocabProgress, DbVocabProgress, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? user = ignore,
    Object? wordId = ignore,
    Object? known = ignore,
    Object? correct = ignore,
    Object? wrong = ignore,
    Object? updatedAt = ignore,
    Object? synced = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (user != ignore) 2: user as String?,
        if (wordId != ignore) 3: wordId as String?,
        if (known != ignore) 4: known as bool?,
        if (correct != ignore) 5: correct as int?,
        if (wrong != ignore) 6: wrong as int?,
        if (updatedAt != ignore) 7: updatedAt as DateTime?,
        if (synced != ignore) 8: synced as bool?,
      });
    } finally {
      q.close();
    }
  }
}

extension DbVocabProgressQueryBuilderUpdate
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QOperations> {
  _DbVocabProgressQueryUpdate get updateFirst =>
      _DbVocabProgressQueryBuilderUpdateImpl(this, limit: 1);

  _DbVocabProgressQueryUpdate get updateAll =>
      _DbVocabProgressQueryBuilderUpdateImpl(this);
}

extension DbVocabProgressQueryFilter
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QFilterCondition> {
  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  userIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 3,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 3,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wordIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 3, value: ''),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  knownEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  correctEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  correctGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  correctGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  correctLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  correctLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  correctBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wrongEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wrongGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wrongGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wrongLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wrongLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  wrongBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  updatedAtGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  updatedAtGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  updatedAtLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 7, value: value));
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  updatedAtLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  updatedAtBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 7, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }
}

extension DbVocabProgressQueryObject
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QFilterCondition> {}

extension DbVocabProgressQuerySortBy
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QSortBy> {
  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByUserDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByWordId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortByWordIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByKnown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortByKnownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortByWrongDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension DbVocabProgressQuerySortThenBy
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QSortThenBy> {
  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByIdDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByUser({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByUserDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByWordId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenByWordIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByKnown() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenByKnownDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenByCorrectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenByWrongDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterSortBy>
  thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension DbVocabProgressQueryWhereDistinct
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QDistinct> {
  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctByUser({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctByWordId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctByKnown() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctByCorrect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctByWrong() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<DbVocabProgress, DbVocabProgress, QAfterDistinct>
  distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension DbVocabProgressQueryProperty1
    on QueryBuilder<DbVocabProgress, DbVocabProgress, QProperty> {
  QueryBuilder<DbVocabProgress, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbVocabProgress, String, QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbVocabProgress, String, QAfterProperty> wordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbVocabProgress, bool, QAfterProperty> knownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbVocabProgress, int, QAfterProperty> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbVocabProgress, int, QAfterProperty> wrongProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbVocabProgress, DateTime, QAfterProperty> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbVocabProgress, bool, QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension DbVocabProgressQueryProperty2<R>
    on QueryBuilder<DbVocabProgress, R, QAfterProperty> {
  QueryBuilder<DbVocabProgress, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbVocabProgress, (R, String), QAfterProperty> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbVocabProgress, (R, String), QAfterProperty> wordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbVocabProgress, (R, bool), QAfterProperty> knownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbVocabProgress, (R, int), QAfterProperty> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbVocabProgress, (R, int), QAfterProperty> wrongProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbVocabProgress, (R, DateTime), QAfterProperty>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbVocabProgress, (R, bool), QAfterProperty> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension DbVocabProgressQueryProperty3<R1, R2>
    on QueryBuilder<DbVocabProgress, (R1, R2), QAfterProperty> {
  QueryBuilder<DbVocabProgress, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, String), QOperations> userProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, String), QOperations>
  wordIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, bool), QOperations> knownProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, int), QOperations> correctProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, int), QOperations> wrongProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, DateTime), QOperations>
  updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<DbVocabProgress, (R1, R2, bool), QOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
