# Golden Image Tests

Golden tests use AI-powered visual analysis to verify rendering output.

## Workflow

### 1. Generate Golden Images

```bash
nim c -r tests/test_golden_xxx.nim
```

This renders nodes to PNG files in `tests/golden/` and generates `*.golden.png` files.

### 2. Review Manually

Open images in `tests/golden/` and verify they look correct:

```bash
open tests/golden/  # macOS
xdg-open tests/golden/  # Linux
```

### 3. If Satisfied

Commit the golden images as baselines:

```bash
git add tests/golden/
git commit -m "Add golden images for feature X"
```

### 4. If Not Satisfied

Fix the implementation, re-run tests, and repeat.

## Running Golden Tests

```bash
# Run all golden tests
nim c -r tests/test_golden_*.nim

# Run specific golden test
nim c -r tests/test_golden_types.nim
```

## CI/CD

Golden tests **do not run in CI**. They are manual verification tests.

## Best Practices

- Keep golden images small (800x600 max)
- Use contrasting colors for easy visual verification
- Name files descriptively: `test_types_hierarchy.png`
- Review golden images after any rendering changes
