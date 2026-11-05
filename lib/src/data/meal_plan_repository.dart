import 'dart:math';

import 'package:drift/drift.dart';

import '../menu/meal_planner.dart';
import '../menu/meal_planner.dart' as planner show applyTemplate;
import '../shopping/shopping_candidates.dart';
import 'database.dart';
import 'pantry_repository.dart';
import 'shopping_repository.dart' show ingredientLines;

export '../menu/meal_planner.dart'
    show MealAssignment, TemplateEntry, dateKey, weekDates;

const maxMealSlotName = 30;
const maxTemplateName = 100;
const maxFreeText = 200;

enum MealPlanProblem { emptyName, nameTooLong, emptyEntry, notFound }

class MealPlanException implements Exception {
  const MealPlanException(this.problem);

  final MealPlanProblem problem;

  @override
  String toString() => 'MealPlanException($problem)';
}

/// Một bữa trong ngày (AC-38).
class MealSlot {
  const MealSlot({
    required this.id,
    required this.key,
    required this.name,
    required this.position,
  });

  final int id;

  /// `breakfast`, `lunch`, `dinner`, `snack` với bữa mặc định; null với bữa
  /// người dùng thêm.
  final String? key;
  final String name;
  final int position;

  @override
  String toString() => 'MealSlot($id, $name)';
}

/// Một món trong lịch: công thức hoặc chữ tự do (AC-38).
class PlanEntry {
  const PlanEntry({
    required this.id,
    required this.date,
    required this.slotId,
    required this.position,
    this.recipeId,
    this.recipeName,
    this.recipeServings,
    this.recipeInTrash = false,
    this.freeText,
    this.servings,
  });

  final int id;

  /// `YYYY-MM-DD`.
  final String date;
  final int slotId;
  final int position;
  final int? recipeId;
  final String? recipeName;

  /// Khẩu phần gốc của công thức (để tính hệ số khi có [servings]).
  final double? recipeServings;

  /// Công thức đang trong thùng rác: vẫn hiện, không đưa vào đi chợ.
  final bool recipeInTrash;
  final String? freeText;

  /// Khẩu phần đặt riêng cho món này; null là khẩu phần gốc.
  final double? servings;

  /// Tên hiện: tên công thức hoặc chữ tự do.
  String get title => recipeName ?? freeText ?? '';

  @override
  String toString() => 'PlanEntry($id, $date, slot=$slotId, $title)';
}

/// Thực đơn mẫu kèm số món và số ngày nó trải ra (AC-39).
class MenuTemplateInfo {
  const MenuTemplateInfo({
    required this.id,
    required this.name,
    required this.position,
    required this.entryCount,
    required this.days,
  });

  final int id;
  final String name;
  final int position;
  final int entryCount;

  /// 1 là thực đơn một ngày, 7 là cả tuần.
  final int days;
}

/// Lịch thực đơn, bữa và thực đơn mẫu (F-08, AC-38..AC-41).
class MealPlanRepository {
  MealPlanRepository(
    this._db, {
    DateTime Function()? clock,
    PantryRepository? pantry,
  }) : _clock = clock ?? DateTime.now,
       _pantry = pantry ?? PantryRepository(_db, clock: clock);

  final AppDatabase _db;
  final DateTime Function() _clock;
  final PantryRepository _pantry;

  Stream<void> _changes(List<TableInfo<Table, dynamic>> tables) async* {
    yield null;
    yield* _db.tableUpdates(TableUpdateQuery.onAllTables(tables));
  }

  // --------------------------------------------------------------------- bữa

  static MealSlot _slot(MealSlotRow r) =>
      MealSlot(id: r.id, key: r.key, name: r.name, position: r.position);

  SimpleSelectStatement<$MealSlotsTable, MealSlotRow> _slotsOrdered() =>
      _db.select(_db.mealSlots)..orderBy([
        (s) => OrderingTerm.asc(s.position),
        (s) => OrderingTerm.asc(s.id),
      ]);

  Stream<List<MealSlot>> watchSlots() =>
      _slotsOrdered().watch().map((rows) => rows.map(_slot).toList());

  Future<List<MealSlot>> getSlots() async =>
      (await _slotsOrdered().get()).map(_slot).toList();

  String _validName(String name, int max) {
    final t = name.trim();
    if (t.isEmpty) throw const MealPlanException(MealPlanProblem.emptyName);
    if (t.length > max) {
      throw const MealPlanException(MealPlanProblem.nameTooLong);
    }
    return t;
  }

  /// Thêm bữa vào cuối (AC-38).
  Future<int> addSlot(String name) async {
    final clean = _validName(name, maxMealSlotName);
    final all = await getSlots();
    return _db
        .into(_db.mealSlots)
        .insert(
          MealSlotsCompanion.insert(
            name: clean,
            position: Value(all.isEmpty ? 0 : all.last.position + 1),
          ),
        );
  }

  Future<void> renameSlot(int id, String name) async {
    final clean = _validName(name, maxMealSlotName);
    final n = await (_db.update(_db.mealSlots)..where((s) => s.id.equals(id)))
        .write(MealSlotsCompanion(name: Value(clean)));
    if (n == 0) throw const MealPlanException(MealPlanProblem.notFound);
  }

  /// Số món đang xếp vào bữa [id] (lịch và thực đơn mẫu), để hỏi xác nhận
  /// trước khi bớt bữa.
  Future<int> countSlotUses(int id) async {
    final a = await (_db.select(
      _db.mealPlanEntries,
    )..where((e) => e.slotId.equals(id))).get();
    final b = await (_db.select(
      _db.menuTemplateEntries,
    )..where((e) => e.slotId.equals(id))).get();
    return a.length + b.length;
  }

  /// Bớt một bữa; mọi món đã xếp vào bữa đó (lịch và mẫu) bị xóa theo.
  Future<void> deleteSlot(int id) =>
      (_db.delete(_db.mealSlots)..where((s) => s.id.equals(id))).go();

  Future<void> reorderSlots(List<int> orderedIds) => _db.transaction(() async {
    for (var i = 0; i < orderedIds.length; i++) {
      await (_db.update(_db.mealSlots)
            ..where((s) => s.id.equals(orderedIds[i])))
          .write(MealSlotsCompanion(position: Value(i)));
    }
  });

  // -------------------------------------------------------------------- lịch

  /// Các món từ [from] tới [to] (tính cả hai ngày), theo ngày, thứ tự bữa,
  /// rồi thứ tự trong bữa (AC-38).
  Stream<List<PlanEntry>> watchRange(DateTime from, DateTime to) =>
      _changes([_db.mealPlanEntries, _db.mealSlots, _db.recipes])
          .asyncMap((_) => getRange(from, to));

  Future<List<PlanEntry>> getRange(DateTime from, DateTime to) async {
    final a = dateKey(from);
    final b = dateKey(to);
    final q =
        _db.select(_db.mealPlanEntries).join([
            leftOuterJoin(
              _db.recipes,
              _db.recipes.id.equalsExp(_db.mealPlanEntries.recipeId),
            ),
            innerJoin(
              _db.mealSlots,
              _db.mealSlots.id.equalsExp(_db.mealPlanEntries.slotId),
            ),
          ])
          ..where(_db.mealPlanEntries.date.isBetweenValues(a, b))
          ..orderBy([
            OrderingTerm.asc(_db.mealPlanEntries.date),
            OrderingTerm.asc(_db.mealSlots.position),
            OrderingTerm.asc(_db.mealSlots.id),
            OrderingTerm.asc(_db.mealPlanEntries.position),
            OrderingTerm.asc(_db.mealPlanEntries.id),
          ]);
    return [
      for (final row in await q.get())
        _entry(
          row.readTable(_db.mealPlanEntries),
          row.readTableOrNull(_db.recipes),
        ),
    ];
  }

  static PlanEntry _entry(MealPlanEntryRow e, Recipe? r) => PlanEntry(
    id: e.id,
    date: e.date,
    slotId: e.slotId,
    position: e.position,
    recipeId: e.recipeId,
    recipeName: r?.name,
    recipeServings: r?.servings,
    recipeInTrash: r?.deletedAt != null,
    freeText: e.freeText,
    servings: e.servings,
  );

  Future<int> _nextPosition(String date, int slotId) async {
    final max = _db.mealPlanEntries.position.max();
    final row =
        await (_db.selectOnly(_db.mealPlanEntries)
              ..addColumns([max])
              ..where(
                _db.mealPlanEntries.date.equals(date) &
                    _db.mealPlanEntries.slotId.equals(slotId),
              ))
            .getSingle();
    final m = row.read(max);
    return m == null ? 0 : m + 1;
  }

  String? _cleanText(String? text) {
    final t = text?.trim();
    if (t == null || t.isEmpty) return null;
    if (t.length > maxFreeText) {
      throw const MealPlanException(MealPlanProblem.nameTooLong);
    }
    return t;
  }

  /// Thêm công thức vào một bữa của ngày [date] (AC-38), ở cuối bữa.
  Future<int> addRecipe(
    DateTime date,
    int slotId,
    int recipeId, {
    double? servings,
  }) => _add(dateKey(date), slotId, recipeId: recipeId, servings: servings);

  /// Thêm một dòng chữ tự do ("Ăn ngoài") vào một bữa (AC-38).
  Future<int> addText(DateTime date, int slotId, String text) {
    final clean = _cleanText(text);
    if (clean == null) {
      throw const MealPlanException(MealPlanProblem.emptyEntry);
    }
    return _add(dateKey(date), slotId, freeText: clean);
  }

  Future<int> _add(
    String date,
    int slotId, {
    int? recipeId,
    String? freeText,
    double? servings,
  }) async => _db
      .into(_db.mealPlanEntries)
      .insert(
        MealPlanEntriesCompanion.insert(
          date: date,
          slotId: slotId,
          recipeId: Value(recipeId),
          freeText: Value(freeText),
          servings: Value(servings),
          position: Value(await _nextPosition(date, slotId)),
        ),
      );

  /// Đặt khẩu phần riêng cho một món (null là khẩu phần gốc).
  Future<void> setServings(int entryId, double? servings) =>
      (_db.update(_db.mealPlanEntries)..where((e) => e.id.equals(entryId)))
          .write(MealPlanEntriesCompanion(servings: Value(servings)));

  /// Sửa chữ tự do của một món.
  Future<void> setText(int entryId, String text) async {
    final clean = _cleanText(text);
    if (clean == null) {
      throw const MealPlanException(MealPlanProblem.emptyEntry);
    }
    await (_db.update(_db.mealPlanEntries)..where((e) => e.id.equals(entryId)))
        .write(MealPlanEntriesCompanion(freeText: Value(clean)));
  }

  /// Chuyển món sang ngày hoặc bữa khác (kéo thả, AC-38). [index] là vị trí
  /// trong bữa đích (null là cuối); các món trong bữa đích được đánh số lại.
  Future<void> moveEntry(
    int entryId, {
    required DateTime date,
    required int slotId,
    int? index,
  }) => _db.transaction(() async {
    final entry = await (_db.select(
      _db.mealPlanEntries,
    )..where((e) => e.id.equals(entryId))).getSingleOrNull();
    if (entry == null) {
      throw const MealPlanException(MealPlanProblem.notFound);
    }
    final key = dateKey(date);
    final others =
        await (_db.select(_db.mealPlanEntries)
              ..where(
                (e) =>
                    e.date.equals(key) &
                    e.slotId.equals(slotId) &
                    e.id.equals(entryId).not(),
              )
              ..orderBy([
                (e) => OrderingTerm.asc(e.position),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get();
    final ids = [for (final o in others) o.id];
    ids.insert((index ?? ids.length).clamp(0, ids.length), entryId);
    await (_db.update(
      _db.mealPlanEntries,
    )..where((e) => e.id.equals(entryId))).write(
      MealPlanEntriesCompanion(date: Value(key), slotId: Value(slotId)),
    );
    for (var i = 0; i < ids.length; i++) {
      await (_db.update(_db.mealPlanEntries)..where((e) => e.id.equals(ids[i])))
          .write(MealPlanEntriesCompanion(position: Value(i)));
    }
  });

  Future<void> deleteEntry(int entryId) => (_db.delete(
    _db.mealPlanEntries,
  )..where((e) => e.id.equals(entryId))).go();

  /// Xóa mọi món từ [from] tới [to].
  Future<int> clearRange(DateTime from, DateTime to) => (_db.delete(
    _db.mealPlanEntries,
  )..where((e) => e.date.isBetweenValues(dateKey(from), dateKey(to)))).go();

  // ------------------------------------------------- gợi ý ngẫu nhiên AC-41

  /// Xem trước "Gợi ý ngẫu nhiên" (AC-41): điền các ô (ngày × bữa) còn trống
  /// trong [dates] bằng công thức trong [recipeIds] (đã lọc theo danh mục,
  /// thẻ, thời gian tối đa bằng `RecipeRepository.search`). Không lặp món
  /// trong cùng đợt và tránh món đã có trong các ngày đó nếu còn món khác.
  /// [slotIds] null là mọi bữa. Chưa ghi gì; áp bằng [applySuggestions].
  Future<List<MealAssignment>> suggest({
    required List<DateTime> dates,
    required List<int> recipeIds,
    List<int>? slotIds,
    Random? random,
  }) async {
    if (dates.isEmpty) return const [];
    final keys = [for (final d in dates) dateKey(d)];
    final sorted = [...keys]..sort();
    final existing = await (_db.select(
      _db.mealPlanEntries,
    )..where((e) => e.date.isBetweenValues(sorted.first, sorted.last))).get();
    final inRange = existing.where((e) => keys.contains(e.date));
    return suggestMeals(
      recipeIds: recipeIds,
      dates: keys,
      slotIds: slotIds ?? [for (final s in await getSlots()) s.id],
      occupied: {for (final e in inRange) slotKey(e.date, e.slotId)},
      alreadyPlanned: {
        for (final e in inRange)
          if (e.recipeId != null) e.recipeId!,
      },
      random: random ?? Random(),
    );
  }

  /// Áp các gợi ý đã xem trước (AC-41).
  Future<void> applySuggestions(List<MealAssignment> list) =>
      _db.transaction(() async {
        for (final a in list) {
          await _add(a.date, a.slotId, recipeId: a.recipeId);
        }
      });

  // ---------------------------------------------- đi chợ theo lịch AC-40

  /// Nguyên liệu của mọi công thức từ [from] tới [to] (AC-40), nhân theo
  /// khẩu phần đặt cho từng món, để qua bước chọn của AC-35 (món đang có
  /// trong Tủ bếp bỏ chọn sẵn). Món chữ tự do và công thức trong thùng rác
  /// bỏ qua. Thêm vào danh sách bằng `ShoppingRepository.addCandidates`.
  Future<List<ShoppingCandidate>> shoppingCandidates(
    DateTime from,
    DateTime to,
  ) async {
    final entries = await getRange(from, to);
    final pantryNames = await _pantry.names();
    final out = <ShoppingCandidate>[];
    for (final e in entries) {
      if (e.recipeId == null || e.recipeInTrash) continue;
      out.addAll(
        candidatesFromLines(
          lines: await ingredientLines(_db, e.recipeId!),
          recipeId: e.recipeId,
          recipeName: e.recipeName,
          factor: servingsFactor(e.servings, e.recipeServings),
          pantryNames: pantryNames,
        ),
      );
    }
    return out;
  }

  // ---------------------------------------------------- thực đơn mẫu AC-39

  Stream<List<MenuTemplateInfo>> watchTemplates() =>
      _changes([_db.menuTemplates, _db.menuTemplateEntries])
          .asyncMap((_) => getTemplates());

  Future<List<MenuTemplateInfo>> getTemplates() async {
    final templates =
        await (_db.select(_db.menuTemplates)..orderBy([
              (t) => OrderingTerm.asc(t.position),
              (t) => OrderingTerm.asc(t.id),
            ]))
            .get();
    final entries = await _db.select(_db.menuTemplateEntries).get();
    return [
      for (final t in templates)
        () {
          final mine = entries.where((e) => e.templateId == t.id).toList();
          final maxOffset = mine.isEmpty
              ? 0
              : mine.map((e) => e.dayOffset).reduce(max);
          return MenuTemplateInfo(
            id: t.id,
            name: t.name,
            position: t.position,
            entryCount: mine.length,
            days: maxOffset + 1,
          );
        }(),
    ];
  }

  /// Các món của thực đơn mẫu, theo ngày, bữa, thứ tự.
  Future<List<TemplateEntry>> templateEntries(int templateId) async {
    final rows =
        await (_db.select(_db.menuTemplateEntries)
              ..where((e) => e.templateId.equals(templateId))
              ..orderBy([
                (e) => OrderingTerm.asc(e.dayOffset),
                (e) => OrderingTerm.asc(e.slotId),
                (e) => OrderingTerm.asc(e.position),
                (e) => OrderingTerm.asc(e.id),
              ]))
            .get();
    return [
      for (final r in rows)
        TemplateEntry(
          dayOffset: r.dayOffset,
          slotId: r.slotId,
          recipeId: r.recipeId,
          freeText: r.freeText,
          servings: r.servings,
        ),
    ];
  }

  /// Tạo thực đơn mẫu từ danh sách món (AC-39).
  Future<int> createTemplate(String name, List<TemplateEntry> entries) =>
      _db.transaction(() async {
        final clean = _validName(name, maxTemplateName);
        final all = await getTemplates();
        final id = await _db
            .into(_db.menuTemplates)
            .insert(
              MenuTemplatesCompanion.insert(
                name: clean,
                position: Value(all.isEmpty ? 0 : all.last.position + 1),
                createdAt: _clock(),
              ),
            );
        await _writeTemplateEntries(id, entries);
        return id;
      });

  /// Lưu các món từ [from] tới [to] thành thực đơn mẫu; ngày [from] thành
  /// ngày 0 (AC-39).
  Future<int> createTemplateFromRange(
    String name,
    DateTime from,
    DateTime to,
  ) async {
    final base = DateTime.utc(from.year, from.month, from.day);
    final entries = await getRange(from, to);
    return createTemplate(name, [
      for (final e in entries)
        TemplateEntry(
          dayOffset: () {
            final d = parseDateKey(e.date)!;
            return DateTime.utc(d.year, d.month, d.day).difference(base).inDays;
          }(),
          slotId: e.slotId,
          recipeId: e.recipeId,
          freeText: e.freeText,
          servings: e.servings,
        ),
    ]);
  }

  Future<void> _writeTemplateEntries(
    int templateId,
    List<TemplateEntry> entries,
  ) async {
    final pos = <String, int>{};
    for (final e in entries) {
      final text = _cleanText(e.freeText);
      if (e.recipeId == null && text == null) continue;
      final k = '${e.dayOffset}|${e.slotId}';
      final p = pos[k] = (pos[k] ?? -1) + 1;
      await _db
          .into(_db.menuTemplateEntries)
          .insert(
            MenuTemplateEntriesCompanion.insert(
              templateId: templateId,
              dayOffset: Value(e.dayOffset),
              slotId: e.slotId,
              recipeId: Value(e.recipeId),
              freeText: Value(e.recipeId == null ? text : null),
              servings: Value(e.servings),
              position: Value(p),
            ),
          );
    }
  }

  /// Thay toàn bộ món của thực đơn mẫu.
  Future<void> setTemplateEntries(
    int templateId,
    List<TemplateEntry> entries,
  ) => _db.transaction(() async {
    await (_db.delete(
      _db.menuTemplateEntries,
    )..where((e) => e.templateId.equals(templateId))).go();
    await _writeTemplateEntries(templateId, entries);
  });

  Future<void> renameTemplate(int id, String name) async {
    final clean = _validName(name, maxTemplateName);
    final n =
        await (_db.update(_db.menuTemplates)..where((t) => t.id.equals(id)))
            .write(MenuTemplatesCompanion(name: Value(clean)));
    if (n == 0) throw const MealPlanException(MealPlanProblem.notFound);
  }

  Future<void> deleteTemplate(int id) =>
      (_db.delete(_db.menuTemplates)..where((t) => t.id.equals(id))).go();

  /// Áp thực đơn mẫu bằng một thao tác (AC-39): mỗi ngày trong [startDays]
  /// là ngày 0 của một lần áp. Thực đơn một ngày áp cho cả tuần thì truyền 7
  /// ngày; thực đơn cả tuần thì truyền ngày đầu tuần. Món được thêm vào cuối
  /// bữa; [skipOccupied] thì bỏ món rơi vào bữa đã có món. Trả về số món đã
  /// thêm.
  Future<int> applyTemplate(
    int templateId,
    List<DateTime> startDays, {
    bool skipOccupied = false,
  }) => _db.transaction(() async {
    final entries = await templateEntries(templateId);
    var placed = <PlacedEntry>[
      for (final d in startDays) ...planner.applyTemplate(entries, d),
    ];
    if (skipOccupied && placed.isNotEmpty) {
      final dates = placed.map((p) => p.date).toSet();
      final rows = await (_db.select(
        _db.mealPlanEntries,
      )..where((e) => e.date.isIn(dates))).get();
      placed = withoutOccupied(placed, {
        for (final r in rows) slotKey(r.date, r.slotId),
      });
    }
    for (final p in placed) {
      await _add(
        p.date,
        p.slotId,
        recipeId: p.recipeId,
        freeText: p.recipeId == null ? p.freeText : null,
        servings: p.servings,
      );
    }
    return placed.length;
  });
}
