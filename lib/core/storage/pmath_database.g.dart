// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pmath_database.dart';

// ignore_for_file: type=lint
class $MetaRowsTable extends MetaRows with TableInfo<$MetaRowsTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaRowsTable createAlias(String alias) {
    return $MetaRowsTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String value;
  const MetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaRowsCompanion toCompanion(bool nullToAbsent) {
    return MetaRowsCompanion(key: Value(key), value: Value(value));
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaRow copyWith({String? key, String? value}) =>
      MetaRow(key: key ?? this.key, value: value ?? this.value);
  MetaRow copyWithCompanion(MetaRowsCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaRowsCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JsonDocsTable extends JsonDocs with TableInfo<$JsonDocsTable, JsonDoc> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JsonDocsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'docs';
  @override
  VerificationContext validateIntegrity(
    Insertable<JsonDoc> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  JsonDoc map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JsonDoc(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $JsonDocsTable createAlias(String alias) {
    return $JsonDocsTable(attachedDatabase, alias);
  }
}

class JsonDoc extends DataClass implements Insertable<JsonDoc> {
  final String key;
  final String payload;
  const JsonDoc({required this.key, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  JsonDocsCompanion toCompanion(bool nullToAbsent) {
    return JsonDocsCompanion(key: Value(key), payload: Value(payload));
  }

  factory JsonDoc.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JsonDoc(
      key: serializer.fromJson<String>(json['key']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payload': serializer.toJson<String>(payload),
    };
  }

  JsonDoc copyWith({String? key, String? payload}) =>
      JsonDoc(key: key ?? this.key, payload: payload ?? this.payload);
  JsonDoc copyWithCompanion(JsonDocsCompanion data) {
    return JsonDoc(
      key: data.key.present ? data.key.value : this.key,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JsonDoc(')
          ..write('key: $key, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JsonDoc &&
          other.key == this.key &&
          other.payload == this.payload);
}

class JsonDocsCompanion extends UpdateCompanion<JsonDoc> {
  final Value<String> key;
  final Value<String> payload;
  final Value<int> rowid;
  const JsonDocsCompanion({
    this.key = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JsonDocsCompanion.insert({
    required String key,
    required String payload,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payload = Value(payload);
  static Insertable<JsonDoc> custom({
    Expression<String>? key,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JsonDocsCompanion copyWith({
    Value<String>? key,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return JsonDocsCompanion(
      key: key ?? this.key,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JsonDocsCompanion(')
          ..write('key: $key, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HomeworkRowsTable extends HomeworkRows
    with TableInfo<$HomeworkRowsTable, HomeworkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomeworkRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assignedAtMicrosMeta = const VerificationMeta(
    'assignedAtMicros',
  );
  @override
  late final GeneratedColumn<int> assignedAtMicros = GeneratedColumn<int>(
    'assigned_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    assignedAtMicros,
    seq,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'homework';
  @override
  VerificationContext validateIntegrity(
    Insertable<HomeworkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('assigned_at_micros')) {
      context.handle(
        _assignedAtMicrosMeta,
        assignedAtMicros.isAcceptableOrUnknown(
          data['assigned_at_micros']!,
          _assignedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assignedAtMicrosMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HomeworkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HomeworkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      assignedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}assigned_at_micros'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $HomeworkRowsTable createAlias(String alias) {
    return $HomeworkRowsTable(attachedDatabase, alias);
  }
}

class HomeworkRow extends DataClass implements Insertable<HomeworkRow> {
  final String id;
  final String lessonId;
  final int assignedAtMicros;
  final int seq;
  final String payload;
  const HomeworkRow({
    required this.id,
    required this.lessonId,
    required this.assignedAtMicros,
    required this.seq,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['assigned_at_micros'] = Variable<int>(assignedAtMicros);
    map['seq'] = Variable<int>(seq);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  HomeworkRowsCompanion toCompanion(bool nullToAbsent) {
    return HomeworkRowsCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      assignedAtMicros: Value(assignedAtMicros),
      seq: Value(seq),
      payload: Value(payload),
    );
  }

  factory HomeworkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomeworkRow(
      id: serializer.fromJson<String>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      assignedAtMicros: serializer.fromJson<int>(json['assignedAtMicros']),
      seq: serializer.fromJson<int>(json['seq']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'assignedAtMicros': serializer.toJson<int>(assignedAtMicros),
      'seq': serializer.toJson<int>(seq),
      'payload': serializer.toJson<String>(payload),
    };
  }

  HomeworkRow copyWith({
    String? id,
    String? lessonId,
    int? assignedAtMicros,
    int? seq,
    String? payload,
  }) => HomeworkRow(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    assignedAtMicros: assignedAtMicros ?? this.assignedAtMicros,
    seq: seq ?? this.seq,
    payload: payload ?? this.payload,
  );
  HomeworkRow copyWithCompanion(HomeworkRowsCompanion data) {
    return HomeworkRow(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      assignedAtMicros: data.assignedAtMicros.present
          ? data.assignedAtMicros.value
          : this.assignedAtMicros,
      seq: data.seq.present ? data.seq.value : this.seq,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HomeworkRow(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('assignedAtMicros: $assignedAtMicros, ')
          ..write('seq: $seq, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lessonId, assignedAtMicros, seq, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeworkRow &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.assignedAtMicros == this.assignedAtMicros &&
          other.seq == this.seq &&
          other.payload == this.payload);
}

class HomeworkRowsCompanion extends UpdateCompanion<HomeworkRow> {
  final Value<String> id;
  final Value<String> lessonId;
  final Value<int> assignedAtMicros;
  final Value<int> seq;
  final Value<String> payload;
  final Value<int> rowid;
  const HomeworkRowsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.assignedAtMicros = const Value.absent(),
    this.seq = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HomeworkRowsCompanion.insert({
    required String id,
    required String lessonId,
    required int assignedAtMicros,
    required int seq,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lessonId = Value(lessonId),
       assignedAtMicros = Value(assignedAtMicros),
       seq = Value(seq),
       payload = Value(payload);
  static Insertable<HomeworkRow> custom({
    Expression<String>? id,
    Expression<String>? lessonId,
    Expression<int>? assignedAtMicros,
    Expression<int>? seq,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (assignedAtMicros != null) 'assigned_at_micros': assignedAtMicros,
      if (seq != null) 'seq': seq,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HomeworkRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? lessonId,
    Value<int>? assignedAtMicros,
    Value<int>? seq,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return HomeworkRowsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      assignedAtMicros: assignedAtMicros ?? this.assignedAtMicros,
      seq: seq ?? this.seq,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (assignedAtMicros.present) {
      map['assigned_at_micros'] = Variable<int>(assignedAtMicros.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomeworkRowsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('assignedAtMicros: $assignedAtMicros, ')
          ..write('seq: $seq, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamRowsTable extends ExamRows with TableInfo<$ExamRowsTable, ExamRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMicrosMeta = const VerificationMeta(
    'completedAtMicros',
  );
  @override
  late final GeneratedColumn<int> completedAtMicros = GeneratedColumn<int>(
    'completed_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonId,
    completedAtMicros,
    seq,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('completed_at_micros')) {
      context.handle(
        _completedAtMicrosMeta,
        completedAtMicros.isAcceptableOrUnknown(
          data['completed_at_micros']!,
          _completedAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMicrosMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      completedAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at_micros'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $ExamRowsTable createAlias(String alias) {
    return $ExamRowsTable(attachedDatabase, alias);
  }
}

class ExamRow extends DataClass implements Insertable<ExamRow> {
  final String id;
  final String lessonId;
  final int completedAtMicros;
  final int seq;
  final String payload;
  const ExamRow({
    required this.id,
    required this.lessonId,
    required this.completedAtMicros,
    required this.seq,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lesson_id'] = Variable<String>(lessonId);
    map['completed_at_micros'] = Variable<int>(completedAtMicros);
    map['seq'] = Variable<int>(seq);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  ExamRowsCompanion toCompanion(bool nullToAbsent) {
    return ExamRowsCompanion(
      id: Value(id),
      lessonId: Value(lessonId),
      completedAtMicros: Value(completedAtMicros),
      seq: Value(seq),
      payload: Value(payload),
    );
  }

  factory ExamRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamRow(
      id: serializer.fromJson<String>(json['id']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      completedAtMicros: serializer.fromJson<int>(json['completedAtMicros']),
      seq: serializer.fromJson<int>(json['seq']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lessonId': serializer.toJson<String>(lessonId),
      'completedAtMicros': serializer.toJson<int>(completedAtMicros),
      'seq': serializer.toJson<int>(seq),
      'payload': serializer.toJson<String>(payload),
    };
  }

  ExamRow copyWith({
    String? id,
    String? lessonId,
    int? completedAtMicros,
    int? seq,
    String? payload,
  }) => ExamRow(
    id: id ?? this.id,
    lessonId: lessonId ?? this.lessonId,
    completedAtMicros: completedAtMicros ?? this.completedAtMicros,
    seq: seq ?? this.seq,
    payload: payload ?? this.payload,
  );
  ExamRow copyWithCompanion(ExamRowsCompanion data) {
    return ExamRow(
      id: data.id.present ? data.id.value : this.id,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      completedAtMicros: data.completedAtMicros.present
          ? data.completedAtMicros.value
          : this.completedAtMicros,
      seq: data.seq.present ? data.seq.value : this.seq,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamRow(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('completedAtMicros: $completedAtMicros, ')
          ..write('seq: $seq, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lessonId, completedAtMicros, seq, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamRow &&
          other.id == this.id &&
          other.lessonId == this.lessonId &&
          other.completedAtMicros == this.completedAtMicros &&
          other.seq == this.seq &&
          other.payload == this.payload);
}

class ExamRowsCompanion extends UpdateCompanion<ExamRow> {
  final Value<String> id;
  final Value<String> lessonId;
  final Value<int> completedAtMicros;
  final Value<int> seq;
  final Value<String> payload;
  final Value<int> rowid;
  const ExamRowsCompanion({
    this.id = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.completedAtMicros = const Value.absent(),
    this.seq = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamRowsCompanion.insert({
    required String id,
    required String lessonId,
    required int completedAtMicros,
    required int seq,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lessonId = Value(lessonId),
       completedAtMicros = Value(completedAtMicros),
       seq = Value(seq),
       payload = Value(payload);
  static Insertable<ExamRow> custom({
    Expression<String>? id,
    Expression<String>? lessonId,
    Expression<int>? completedAtMicros,
    Expression<int>? seq,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonId != null) 'lesson_id': lessonId,
      if (completedAtMicros != null) 'completed_at_micros': completedAtMicros,
      if (seq != null) 'seq': seq,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? lessonId,
    Value<int>? completedAtMicros,
    Value<int>? seq,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return ExamRowsCompanion(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      completedAtMicros: completedAtMicros ?? this.completedAtMicros,
      seq: seq ?? this.seq,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (completedAtMicros.present) {
      map['completed_at_micros'] = Variable<int>(completedAtMicros.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamRowsCompanion(')
          ..write('id: $id, ')
          ..write('lessonId: $lessonId, ')
          ..write('completedAtMicros: $completedAtMicros, ')
          ..write('seq: $seq, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertRowsTable extends AlertRows
    with TableInfo<$AlertRowsTable, AlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMicrosMeta = const VerificationMeta(
    'createdAtMicros',
  );
  @override
  late final GeneratedColumn<int> createdAtMicros = GeneratedColumn<int>(
    'created_at_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, createdAtMicros, seq, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at_micros')) {
      context.handle(
        _createdAtMicrosMeta,
        createdAtMicros.isAcceptableOrUnknown(
          data['created_at_micros']!,
          _createdAtMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMicrosMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAtMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_micros'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $AlertRowsTable createAlias(String alias) {
    return $AlertRowsTable(attachedDatabase, alias);
  }
}

class AlertRow extends DataClass implements Insertable<AlertRow> {
  final String id;
  final int createdAtMicros;
  final int seq;
  final String payload;
  const AlertRow({
    required this.id,
    required this.createdAtMicros,
    required this.seq,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at_micros'] = Variable<int>(createdAtMicros);
    map['seq'] = Variable<int>(seq);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  AlertRowsCompanion toCompanion(bool nullToAbsent) {
    return AlertRowsCompanion(
      id: Value(id),
      createdAtMicros: Value(createdAtMicros),
      seq: Value(seq),
      payload: Value(payload),
    );
  }

  factory AlertRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertRow(
      id: serializer.fromJson<String>(json['id']),
      createdAtMicros: serializer.fromJson<int>(json['createdAtMicros']),
      seq: serializer.fromJson<int>(json['seq']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAtMicros': serializer.toJson<int>(createdAtMicros),
      'seq': serializer.toJson<int>(seq),
      'payload': serializer.toJson<String>(payload),
    };
  }

  AlertRow copyWith({
    String? id,
    int? createdAtMicros,
    int? seq,
    String? payload,
  }) => AlertRow(
    id: id ?? this.id,
    createdAtMicros: createdAtMicros ?? this.createdAtMicros,
    seq: seq ?? this.seq,
    payload: payload ?? this.payload,
  );
  AlertRow copyWithCompanion(AlertRowsCompanion data) {
    return AlertRow(
      id: data.id.present ? data.id.value : this.id,
      createdAtMicros: data.createdAtMicros.present
          ? data.createdAtMicros.value
          : this.createdAtMicros,
      seq: data.seq.present ? data.seq.value : this.seq,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertRow(')
          ..write('id: $id, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('seq: $seq, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAtMicros, seq, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertRow &&
          other.id == this.id &&
          other.createdAtMicros == this.createdAtMicros &&
          other.seq == this.seq &&
          other.payload == this.payload);
}

class AlertRowsCompanion extends UpdateCompanion<AlertRow> {
  final Value<String> id;
  final Value<int> createdAtMicros;
  final Value<int> seq;
  final Value<String> payload;
  final Value<int> rowid;
  const AlertRowsCompanion({
    this.id = const Value.absent(),
    this.createdAtMicros = const Value.absent(),
    this.seq = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertRowsCompanion.insert({
    required String id,
    required int createdAtMicros,
    required int seq,
    required String payload,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAtMicros = Value(createdAtMicros),
       seq = Value(seq),
       payload = Value(payload);
  static Insertable<AlertRow> custom({
    Expression<String>? id,
    Expression<int>? createdAtMicros,
    Expression<int>? seq,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAtMicros != null) 'created_at_micros': createdAtMicros,
      if (seq != null) 'seq': seq,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertRowsCompanion copyWith({
    Value<String>? id,
    Value<int>? createdAtMicros,
    Value<int>? seq,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return AlertRowsCompanion(
      id: id ?? this.id,
      createdAtMicros: createdAtMicros ?? this.createdAtMicros,
      seq: seq ?? this.seq,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAtMicros.present) {
      map['created_at_micros'] = Variable<int>(createdAtMicros.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertRowsCompanion(')
          ..write('id: $id, ')
          ..write('createdAtMicros: $createdAtMicros, ')
          ..write('seq: $seq, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BucketValuesTable extends BucketValues
    with TableInfo<$BucketValuesTable, BucketValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BucketValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
    'bucket',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bucket, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buckets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BucketValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bucket')) {
      context.handle(
        _bucketMeta,
        bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta),
      );
    } else if (isInserting) {
      context.missing(_bucketMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bucket, value};
  @override
  BucketValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BucketValue(
      bucket: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bucket'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $BucketValuesTable createAlias(String alias) {
    return $BucketValuesTable(attachedDatabase, alias);
  }
}

class BucketValue extends DataClass implements Insertable<BucketValue> {
  final String bucket;
  final String value;
  const BucketValue({required this.bucket, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bucket'] = Variable<String>(bucket);
    map['value'] = Variable<String>(value);
    return map;
  }

  BucketValuesCompanion toCompanion(bool nullToAbsent) {
    return BucketValuesCompanion(bucket: Value(bucket), value: Value(value));
  }

  factory BucketValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BucketValue(
      bucket: serializer.fromJson<String>(json['bucket']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bucket': serializer.toJson<String>(bucket),
      'value': serializer.toJson<String>(value),
    };
  }

  BucketValue copyWith({String? bucket, String? value}) =>
      BucketValue(bucket: bucket ?? this.bucket, value: value ?? this.value);
  BucketValue copyWithCompanion(BucketValuesCompanion data) {
    return BucketValue(
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BucketValue(')
          ..write('bucket: $bucket, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bucket, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BucketValue &&
          other.bucket == this.bucket &&
          other.value == this.value);
}

class BucketValuesCompanion extends UpdateCompanion<BucketValue> {
  final Value<String> bucket;
  final Value<String> value;
  final Value<int> rowid;
  const BucketValuesCompanion({
    this.bucket = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BucketValuesCompanion.insert({
    required String bucket,
    required String value,
    this.rowid = const Value.absent(),
  }) : bucket = Value(bucket),
       value = Value(value);
  static Insertable<BucketValue> custom({
    Expression<String>? bucket,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bucket != null) 'bucket': bucket,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BucketValuesCompanion copyWith({
    Value<String>? bucket,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return BucketValuesCompanion(
      bucket: bucket ?? this.bucket,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BucketValuesCompanion(')
          ..write('bucket: $bucket, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PmathDatabase extends GeneratedDatabase {
  _$PmathDatabase(QueryExecutor e) : super(e);
  $PmathDatabaseManager get managers => $PmathDatabaseManager(this);
  late final $MetaRowsTable metaRows = $MetaRowsTable(this);
  late final $JsonDocsTable jsonDocs = $JsonDocsTable(this);
  late final $HomeworkRowsTable homeworkRows = $HomeworkRowsTable(this);
  late final $ExamRowsTable examRows = $ExamRowsTable(this);
  late final $AlertRowsTable alertRows = $AlertRowsTable(this);
  late final $BucketValuesTable bucketValues = $BucketValuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    metaRows,
    jsonDocs,
    homeworkRows,
    examRows,
    alertRows,
    bucketValues,
  ];
}

typedef $$MetaRowsTableCreateCompanionBuilder =
    MetaRowsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaRowsTableUpdateCompanionBuilder =
    MetaRowsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaRowsTableFilterComposer
    extends Composer<_$PmathDatabase, $MetaRowsTable> {
  $$MetaRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaRowsTableOrderingComposer
    extends Composer<_$PmathDatabase, $MetaRowsTable> {
  $$MetaRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaRowsTableAnnotationComposer
    extends Composer<_$PmathDatabase, $MetaRowsTable> {
  $$MetaRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaRowsTableTableManager
    extends
        RootTableManager<
          _$PmathDatabase,
          $MetaRowsTable,
          MetaRow,
          $$MetaRowsTableFilterComposer,
          $$MetaRowsTableOrderingComposer,
          $$MetaRowsTableAnnotationComposer,
          $$MetaRowsTableCreateCompanionBuilder,
          $$MetaRowsTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$PmathDatabase, $MetaRowsTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaRowsTableTableManager(_$PmathDatabase db, $MetaRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaRowsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PmathDatabase,
      $MetaRowsTable,
      MetaRow,
      $$MetaRowsTableFilterComposer,
      $$MetaRowsTableOrderingComposer,
      $$MetaRowsTableAnnotationComposer,
      $$MetaRowsTableCreateCompanionBuilder,
      $$MetaRowsTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$PmathDatabase, $MetaRowsTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;
typedef $$JsonDocsTableCreateCompanionBuilder =
    JsonDocsCompanion Function({
      required String key,
      required String payload,
      Value<int> rowid,
    });
typedef $$JsonDocsTableUpdateCompanionBuilder =
    JsonDocsCompanion Function({
      Value<String> key,
      Value<String> payload,
      Value<int> rowid,
    });

class $$JsonDocsTableFilterComposer
    extends Composer<_$PmathDatabase, $JsonDocsTable> {
  $$JsonDocsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JsonDocsTableOrderingComposer
    extends Composer<_$PmathDatabase, $JsonDocsTable> {
  $$JsonDocsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JsonDocsTableAnnotationComposer
    extends Composer<_$PmathDatabase, $JsonDocsTable> {
  $$JsonDocsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$JsonDocsTableTableManager
    extends
        RootTableManager<
          _$PmathDatabase,
          $JsonDocsTable,
          JsonDoc,
          $$JsonDocsTableFilterComposer,
          $$JsonDocsTableOrderingComposer,
          $$JsonDocsTableAnnotationComposer,
          $$JsonDocsTableCreateCompanionBuilder,
          $$JsonDocsTableUpdateCompanionBuilder,
          (JsonDoc, BaseReferences<_$PmathDatabase, $JsonDocsTable, JsonDoc>),
          JsonDoc,
          PrefetchHooks Function()
        > {
  $$JsonDocsTableTableManager(_$PmathDatabase db, $JsonDocsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JsonDocsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JsonDocsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JsonDocsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JsonDocsCompanion(key: key, payload: payload, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => JsonDocsCompanion.insert(
                key: key,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JsonDocsTableProcessedTableManager =
    ProcessedTableManager<
      _$PmathDatabase,
      $JsonDocsTable,
      JsonDoc,
      $$JsonDocsTableFilterComposer,
      $$JsonDocsTableOrderingComposer,
      $$JsonDocsTableAnnotationComposer,
      $$JsonDocsTableCreateCompanionBuilder,
      $$JsonDocsTableUpdateCompanionBuilder,
      (JsonDoc, BaseReferences<_$PmathDatabase, $JsonDocsTable, JsonDoc>),
      JsonDoc,
      PrefetchHooks Function()
    >;
typedef $$HomeworkRowsTableCreateCompanionBuilder =
    HomeworkRowsCompanion Function({
      required String id,
      required String lessonId,
      required int assignedAtMicros,
      required int seq,
      required String payload,
      Value<int> rowid,
    });
typedef $$HomeworkRowsTableUpdateCompanionBuilder =
    HomeworkRowsCompanion Function({
      Value<String> id,
      Value<String> lessonId,
      Value<int> assignedAtMicros,
      Value<int> seq,
      Value<String> payload,
      Value<int> rowid,
    });

class $$HomeworkRowsTableFilterComposer
    extends Composer<_$PmathDatabase, $HomeworkRowsTable> {
  $$HomeworkRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get assignedAtMicros => $composableBuilder(
    column: $table.assignedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HomeworkRowsTableOrderingComposer
    extends Composer<_$PmathDatabase, $HomeworkRowsTable> {
  $$HomeworkRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get assignedAtMicros => $composableBuilder(
    column: $table.assignedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HomeworkRowsTableAnnotationComposer
    extends Composer<_$PmathDatabase, $HomeworkRowsTable> {
  $$HomeworkRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get assignedAtMicros => $composableBuilder(
    column: $table.assignedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$HomeworkRowsTableTableManager
    extends
        RootTableManager<
          _$PmathDatabase,
          $HomeworkRowsTable,
          HomeworkRow,
          $$HomeworkRowsTableFilterComposer,
          $$HomeworkRowsTableOrderingComposer,
          $$HomeworkRowsTableAnnotationComposer,
          $$HomeworkRowsTableCreateCompanionBuilder,
          $$HomeworkRowsTableUpdateCompanionBuilder,
          (
            HomeworkRow,
            BaseReferences<_$PmathDatabase, $HomeworkRowsTable, HomeworkRow>,
          ),
          HomeworkRow,
          PrefetchHooks Function()
        > {
  $$HomeworkRowsTableTableManager(_$PmathDatabase db, $HomeworkRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomeworkRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomeworkRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomeworkRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<int> assignedAtMicros = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomeworkRowsCompanion(
                id: id,
                lessonId: lessonId,
                assignedAtMicros: assignedAtMicros,
                seq: seq,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lessonId,
                required int assignedAtMicros,
                required int seq,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => HomeworkRowsCompanion.insert(
                id: id,
                lessonId: lessonId,
                assignedAtMicros: assignedAtMicros,
                seq: seq,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HomeworkRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PmathDatabase,
      $HomeworkRowsTable,
      HomeworkRow,
      $$HomeworkRowsTableFilterComposer,
      $$HomeworkRowsTableOrderingComposer,
      $$HomeworkRowsTableAnnotationComposer,
      $$HomeworkRowsTableCreateCompanionBuilder,
      $$HomeworkRowsTableUpdateCompanionBuilder,
      (
        HomeworkRow,
        BaseReferences<_$PmathDatabase, $HomeworkRowsTable, HomeworkRow>,
      ),
      HomeworkRow,
      PrefetchHooks Function()
    >;
typedef $$ExamRowsTableCreateCompanionBuilder =
    ExamRowsCompanion Function({
      required String id,
      required String lessonId,
      required int completedAtMicros,
      required int seq,
      required String payload,
      Value<int> rowid,
    });
typedef $$ExamRowsTableUpdateCompanionBuilder =
    ExamRowsCompanion Function({
      Value<String> id,
      Value<String> lessonId,
      Value<int> completedAtMicros,
      Value<int> seq,
      Value<String> payload,
      Value<int> rowid,
    });

class $$ExamRowsTableFilterComposer
    extends Composer<_$PmathDatabase, $ExamRowsTable> {
  $$ExamRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamRowsTableOrderingComposer
    extends Composer<_$PmathDatabase, $ExamRowsTable> {
  $$ExamRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamRowsTableAnnotationComposer
    extends Composer<_$PmathDatabase, $ExamRowsTable> {
  $$ExamRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get completedAtMicros => $composableBuilder(
    column: $table.completedAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$ExamRowsTableTableManager
    extends
        RootTableManager<
          _$PmathDatabase,
          $ExamRowsTable,
          ExamRow,
          $$ExamRowsTableFilterComposer,
          $$ExamRowsTableOrderingComposer,
          $$ExamRowsTableAnnotationComposer,
          $$ExamRowsTableCreateCompanionBuilder,
          $$ExamRowsTableUpdateCompanionBuilder,
          (ExamRow, BaseReferences<_$PmathDatabase, $ExamRowsTable, ExamRow>),
          ExamRow,
          PrefetchHooks Function()
        > {
  $$ExamRowsTableTableManager(_$PmathDatabase db, $ExamRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<int> completedAtMicros = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamRowsCompanion(
                id: id,
                lessonId: lessonId,
                completedAtMicros: completedAtMicros,
                seq: seq,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lessonId,
                required int completedAtMicros,
                required int seq,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => ExamRowsCompanion.insert(
                id: id,
                lessonId: lessonId,
                completedAtMicros: completedAtMicros,
                seq: seq,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PmathDatabase,
      $ExamRowsTable,
      ExamRow,
      $$ExamRowsTableFilterComposer,
      $$ExamRowsTableOrderingComposer,
      $$ExamRowsTableAnnotationComposer,
      $$ExamRowsTableCreateCompanionBuilder,
      $$ExamRowsTableUpdateCompanionBuilder,
      (ExamRow, BaseReferences<_$PmathDatabase, $ExamRowsTable, ExamRow>),
      ExamRow,
      PrefetchHooks Function()
    >;
typedef $$AlertRowsTableCreateCompanionBuilder =
    AlertRowsCompanion Function({
      required String id,
      required int createdAtMicros,
      required int seq,
      required String payload,
      Value<int> rowid,
    });
typedef $$AlertRowsTableUpdateCompanionBuilder =
    AlertRowsCompanion Function({
      Value<String> id,
      Value<int> createdAtMicros,
      Value<int> seq,
      Value<String> payload,
      Value<int> rowid,
    });

class $$AlertRowsTableFilterComposer
    extends Composer<_$PmathDatabase, $AlertRowsTable> {
  $$AlertRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertRowsTableOrderingComposer
    extends Composer<_$PmathDatabase, $AlertRowsTable> {
  $$AlertRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertRowsTableAnnotationComposer
    extends Composer<_$PmathDatabase, $AlertRowsTable> {
  $$AlertRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get createdAtMicros => $composableBuilder(
    column: $table.createdAtMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$AlertRowsTableTableManager
    extends
        RootTableManager<
          _$PmathDatabase,
          $AlertRowsTable,
          AlertRow,
          $$AlertRowsTableFilterComposer,
          $$AlertRowsTableOrderingComposer,
          $$AlertRowsTableAnnotationComposer,
          $$AlertRowsTableCreateCompanionBuilder,
          $$AlertRowsTableUpdateCompanionBuilder,
          (
            AlertRow,
            BaseReferences<_$PmathDatabase, $AlertRowsTable, AlertRow>,
          ),
          AlertRow,
          PrefetchHooks Function()
        > {
  $$AlertRowsTableTableManager(_$PmathDatabase db, $AlertRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> createdAtMicros = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertRowsCompanion(
                id: id,
                createdAtMicros: createdAtMicros,
                seq: seq,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int createdAtMicros,
                required int seq,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => AlertRowsCompanion.insert(
                id: id,
                createdAtMicros: createdAtMicros,
                seq: seq,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$PmathDatabase,
      $AlertRowsTable,
      AlertRow,
      $$AlertRowsTableFilterComposer,
      $$AlertRowsTableOrderingComposer,
      $$AlertRowsTableAnnotationComposer,
      $$AlertRowsTableCreateCompanionBuilder,
      $$AlertRowsTableUpdateCompanionBuilder,
      (AlertRow, BaseReferences<_$PmathDatabase, $AlertRowsTable, AlertRow>),
      AlertRow,
      PrefetchHooks Function()
    >;
typedef $$BucketValuesTableCreateCompanionBuilder =
    BucketValuesCompanion Function({
      required String bucket,
      required String value,
      Value<int> rowid,
    });
typedef $$BucketValuesTableUpdateCompanionBuilder =
    BucketValuesCompanion Function({
      Value<String> bucket,
      Value<String> value,
      Value<int> rowid,
    });

class $$BucketValuesTableFilterComposer
    extends Composer<_$PmathDatabase, $BucketValuesTable> {
  $$BucketValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BucketValuesTableOrderingComposer
    extends Composer<_$PmathDatabase, $BucketValuesTable> {
  $$BucketValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bucket => $composableBuilder(
    column: $table.bucket,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BucketValuesTableAnnotationComposer
    extends Composer<_$PmathDatabase, $BucketValuesTable> {
  $$BucketValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$BucketValuesTableTableManager
    extends
        RootTableManager<
          _$PmathDatabase,
          $BucketValuesTable,
          BucketValue,
          $$BucketValuesTableFilterComposer,
          $$BucketValuesTableOrderingComposer,
          $$BucketValuesTableAnnotationComposer,
          $$BucketValuesTableCreateCompanionBuilder,
          $$BucketValuesTableUpdateCompanionBuilder,
          (
            BucketValue,
            BaseReferences<_$PmathDatabase, $BucketValuesTable, BucketValue>,
          ),
          BucketValue,
          PrefetchHooks Function()
        > {
  $$BucketValuesTableTableManager(_$PmathDatabase db, $BucketValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BucketValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BucketValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BucketValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bucket = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BucketValuesCompanion(
                bucket: bucket,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bucket,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => BucketValuesCompanion.insert(
                bucket: bucket,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BucketValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$PmathDatabase,
      $BucketValuesTable,
      BucketValue,
      $$BucketValuesTableFilterComposer,
      $$BucketValuesTableOrderingComposer,
      $$BucketValuesTableAnnotationComposer,
      $$BucketValuesTableCreateCompanionBuilder,
      $$BucketValuesTableUpdateCompanionBuilder,
      (
        BucketValue,
        BaseReferences<_$PmathDatabase, $BucketValuesTable, BucketValue>,
      ),
      BucketValue,
      PrefetchHooks Function()
    >;

class $PmathDatabaseManager {
  final _$PmathDatabase _db;
  $PmathDatabaseManager(this._db);
  $$MetaRowsTableTableManager get metaRows =>
      $$MetaRowsTableTableManager(_db, _db.metaRows);
  $$JsonDocsTableTableManager get jsonDocs =>
      $$JsonDocsTableTableManager(_db, _db.jsonDocs);
  $$HomeworkRowsTableTableManager get homeworkRows =>
      $$HomeworkRowsTableTableManager(_db, _db.homeworkRows);
  $$ExamRowsTableTableManager get examRows =>
      $$ExamRowsTableTableManager(_db, _db.examRows);
  $$AlertRowsTableTableManager get alertRows =>
      $$AlertRowsTableTableManager(_db, _db.alertRows);
  $$BucketValuesTableTableManager get bucketValues =>
      $$BucketValuesTableTableManager(_db, _db.bucketValues);
}
