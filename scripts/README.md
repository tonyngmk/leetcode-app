# Visualization Generation Pipeline

This directory contains CLI tools to automatically generate algorithm visualization steps using the Claude API.

## Setup

1. Ensure you have Dart 3.11.4+ installed
2. Get dependencies:
   ```bash
   cd scripts && dart pub get
   ```

3. Set your Claude API key:
   ```bash
   export CLAUDE_API_KEY="sk-ant-..."
   ```

## Usage

### Generate for a specific template type

```bash
dart generate_visualizations.dart --type array_basic
dart generate_visualizations.dart --type two_pointer
dart generate_visualizations.dart --type sliding_window
```

### Generate for a specific problem

```bash
dart generate_visualizations.dart --slug two-sum
```

### Generate for all target problems

```bash
dart generate_visualizations.dart --all
```

### Dry run (validate only, don't write)

```bash
dart generate_visualizations.dart --type array_basic --dry-run
```

### Verbose output

```bash
dart generate_visualizations.dart --type array_basic --verbose
```

## Configuration Files

### `data/array_target_slugs.txt`

List of problem slugs to generate visualizations for. One per line. Comments start with `#`.

### `data/classifier_overrides.json`

JSON mapping of `slug → templateType` for problems that don't match the heuristic classifier. Example:

```json
{
  "trapping-rain-water": "two_pointer",
  "subarray-sum-equals-k": "hash_map"
}
```

## Output

Generated steps are merged into `assets/visualization_cache.json`. Each entry has:

```json
{
  "type": "array_basic",
  "supported": true,
  "approaches": [
    {
      "name": "Brute Force",
      "array": [2, 7, 11, 15],
      "steps": [...]
    }
  ]
}
```

## Template Types

- `array_basic` — simple array iteration with pointers/indices
- `hash_map` — arrays with hash map data structure
- `two_pointer` — converging left/right pointers
- `sliding_window` — variable-size window scans
- `prefix_sum` — prefix/suffix sum computations
- `binary_search` — lo/mid/hi pointer searches
- `stack` — stack-based algorithms
- `tree_dfs` — depth-first tree traversal
- `tree_bfs` — breadth-first tree traversal
- `grid` — 2D matrix problems
- `graph` — graph traversal
- `dp_1d` — 1D dynamic programming
- `dp_2d` — 2D dynamic programming

See `VISUALIZATION_AI_GUIDE.md` for detailed specifications.

## How It Works

1. **Classify** — determine problem's template type from topic tags
2. **Load** — fetch solution code and metadata
3. **Build Prompt** — construct Claude API prompt with problem details
4. **Generate** — call Claude to generate step JSON array
5. **Validate** — check steps are well-formed (bounds, state consistency, etc.)
6. **Merge** — add to `visualization_cache.json`

## Troubleshooting

### "API error 401"

Check that `CLAUDE_API_KEY` is set correctly.

### "Validation failed"

The LLM generated steps that don't match the schema. Check:
- Are pointer indices within array bounds?
- Does hash map state grow monotonically?
- Are final steps marked as answer found?

Re-run with `--verbose` to see which constraint failed. May need to adjust the prompt.

### "JSON parse error"

The LLM response wasn't valid JSON. Check that the prompt is correct and the API is returning well-formed output.

## Adding a New Template Type

1. Define `StepType` in `visualization_step.dart` (sealed class)
2. Add prompt template in `prompt_builder.dart`
3. Add validation rules in `step_validator.dart`
4. Create renderer widget in `lib/features/visualizer/presentation/widgets/`
5. Update `RendererFactory` to map the step type
6. Update `problem_classifier.dart` heuristics to classify problems into the new type

See `VISUALIZATION_AI_GUIDE.md` §11 for detailed instructions.
