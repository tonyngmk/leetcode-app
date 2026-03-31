# Architecture: Solution Cache Integration

## Status: Draft v1

## Context

**Problem**: leetcode-bot's `solution_cache.json` (42MB, 4054 problems) needs to be integrated into AlgoFlow. The existing `SolutionsLocalDataSource.loadFromAsset()` loads the entire JSON into memory at once, which is unsustainable for a mobile app.

**Goal**: On-demand, per-slug solution fetching with minimal startup cost.

---

## Key Design Decisions

### 1. Storage Location: Bundled Asset (gzipped)

| Option | Pros | Cons |
|--------|------|------|
| **Bundled asset (.gz)** | Ships with app, works offline, delta updates via app store | Larger download on install, rebuild needed for updates |
| App documents dir | No app store rebuild for updates, could download lazily | Requires network on first launch, more complex |

**Decision**: Bundled asset at `assets/solution_cache.json.gz`

**Rationale**: The cache is relatively static (updates come from leetcode-bot). Shipping it as a compressed asset means zero network dependency and instant availability. The gzipped size (~10MB) is acceptable for a bundled asset. App store delta updates minimize the install overhead for incremental changes.

### 2. Loading Strategy: Lazy + Hive Warm Cache

**Current behavior**: `loadFromAsset()` parses entire 42MB JSON into Hive on first launch.

**New behavior**: On-demand per-slug fetching from gzipped asset, with Hive as a warm cache for accessed solutions.

**Flow**:
```
getSolution(slug)
  ├─► Hive cache hit  → return cached Solution
  └─► Hive cache miss → seek+parse in gzipped asset → store in Hive → return
```

**Implementation**:
- On first access to any slug, decompress the gzipped asset to a temp file (one-time cost).
- Use `RandomAccessFile` to seek to the JSON entry by slug key.
- Alternatively, pre-build a slug→byte-offset index on first launch (see section 3).
- Store each accessed solution in Hive for fast subsequent lookups.

**Key insight**: Users typically only view solutions for a handful of problems. Loading all 4054 into Hive on day one is wasteful.

### 3. The 44MB Problem: Gzip Compression + Slug Index

**Gzip**: Compress `solution_cache.json` → `solution_cache.json.gz`. Dart's `gzip` library can decompress in a streaming or chunked fashion. Expect ~10MB compressed.

**Slug Index**: JSON entries are keyed by slug, so we need efficient random access by key.

Options:
- **Option A**: Pre-split into per-slug files (e.g., `solutions/two-sum.json`, `solutions/three-sum.json`). Decompress on first launch into `applicationDocumentsDirectory/solutions/`. Each file is tiny — fast to load per access. Hive not needed.
- **Option B**: Keep as single gzipped JSON, decompress to temp file, maintain an in-memory slug→offset index built on first load.
- **Option C**: Pre-split into per-slug `.json.gz` files. Each problem's solution is its own tiny compressed file. On-demand decompression is trivial.

**Decision**: **Option C — per-solution `.json.gz` files**

**Rationale**:
- No slug index needed — filesystem IS the index.
- Each file is tiny (<5KB typical), so decompression is near-instant.
- Hive is unnecessary for this — just load from `applicationDocumentsDirectory/solutions/slug.json.gz`.
- First launch: decompress the single `solution_cache.json.gz` (containing the split files) into the documents directory once.
- Or better: have leetcode-bot export as a directory of per-solution files from the start.

**Simplified Flow**:
```
init:
  if (solutions/ dir not initialized):
    extract assets/solution_cache.json.gz → applicationDocumentsDirectory/solutions/
    // one-time, on first launch

getSolution(slug):
  return _loadGzip('${documentsDir}/solutions/$slug.json.gz')
```

### 4. Data Model — No Changes Needed

The existing `Solution` / `SolutionApproach` model in `lib/features/solutions/data/models/solution_model.dart` already matches the `solution_cache.json` schema perfectly. No changes required.

### 5. Repository Interface — Minimal Changes

Current interface:
```dart
abstract class SolutionsRepository {
  Solution? getSolution(String slug);
  bool hasSolution(String slug);
  Future<void> loadFromAsset();
}
```

The `hasSolution(slug)` and `loadFromAsset()` are awkward with the new approach. Refactor to:

```dart
abstract class SolutionsRepository {
  Solution? getSolution(String slug);
  Future<void> initialize(); // one-time setup
  bool get isInitialized;
}
```

- `getSolution(slug)` returns `null` if not found (no need for separate `hasSolution`).
- `initialize()` handles the one-time extraction on first launch.

### 6. Dependency Injection — Update `lib/injection.dart`

```dart
// New: SolutionCacheDataSource (file-based, no Hive needed)
sl.registerSingleton<SolutionCacheDataSource>(
  SolutionCacheDataSource(
    assetPath: 'assets/solution_cache.json.gz',
    documentsDir: applicationDocumentsDirectory,
  ),
);

// Update: SolutionsRepositoryImpl
sl.registerSingleton<SolutionsRepository>(
  SolutionsRepositoryImpl(local: sl<SolutionCacheDataSource>()),
);
```

Remove the `solutionsBox` Hive registration — it's no longer needed.

### 7. Problem Detail Flow — No Changes Needed

`ProblemDetailCubit` already calls `_solutionsRepo.getSolution(slug)` and passes `Solution?` to the UI. The UI (`SolutionTabView`) already handles `null` gracefully. No changes to the presentation layer.

---

## File Structure Changes

```
lib/features/solutions/
├── data/
│   ├── datasources/
│   │   └── solution_cache_datasource.dart   # NEW: file-based, gzip decode
│   └── repositories/
│       └── solutions_repository_impl.dart  # UPDATE: use new datasource
├── domain/
│   └── repositories/
│       └── solutions_repository.dart        # UPDATE: interface refactor
```

No new domain entities needed — the existing `Solution` model covers the schema.

---

## Implementation Plan

### Phase 1: Data Source
1. Create `SolutionCacheDataSource` that:
   - On `initialize()`: extracts `assets/solution_cache.json.gz` to `applicationDocumentsDirectory/solutions/`
   - `getSolution(slug)`: reads `${slug}.json.gz`, decodes, returns `Solution`
   - `hasSolution(slug)`: checks if file exists
2. Update `SolutionsRepositoryImpl` to use the new data source
3. Update `SolutionsRepository` interface
4. Update `lib/injection.dart` to register new data source and remove Hive solutions box

### Phase 2: UI Integration
5. Update `ProblemDetailCubit` to call `solutionsRepo.initialize()` on first load (best effort, non-blocking)
6. `SolutionTabView` already handles null gracefully

### Phase 3: Build Pipeline
7. Add build step to gzip the cache and split into per-solution files (or update leetcode-bot to export this way)
8. Add `solution_cache/` directory to `pubspec.yaml` assets

---

## Alternatives Considered

**Hive as primary store**: Instead of file-per-solution, load all into Hive on first launch. Rejected because:
- 4054 entries × ~10KB each = ~40MB Hive storage
- Blocking initialization on first launch
- Memory pressure on low-end devices

**Memory-mapped JSON**: Use `dart:convert` with a single file. Rejected because:
- 42MB file still needs full parse even for one slug
- No efficient per-key seeking without an index

**Network download**: Download cache from a server on first launch. Rejected because:
- Adds network dependency
- More complex update/versioning logic
- Leetcode-bot already generates the file — embedding it is simpler

---

## Open Questions

1. **Split format**: Should leetcode-bot's export be split per-solution, or should AlgoFlow's build pipeline handle the split? Best to have leetcode-bot export as a directory of per-solution `.json.gz` files to keep AlgoFlow's build simple.

2. **Updates**: How to update the cache when leetcode-bot adds new solutions? Options: app store delta, in-app refresh from GitHub raw URL, or manual rebuild.

3. **Error handling**: What if extraction fails? Fall back to empty state (no solutions) with a "Refresh" option.
