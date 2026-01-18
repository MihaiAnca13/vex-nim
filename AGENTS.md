# AGENTS.md

**Project:** VEX - Vector & Hex Scene Graph Library
**Language:** Nim
**Dependencies:** `boxy`, `pixie`, `vmath`

---

## 1. CODE STYLE GUIDELINES

### Imports
- Use relative imports within VEX: `import ../core/types`
- Group stdlib imports before external library imports (boxy, pixie, vmath)
- VEX does NOT import `windy` - it is window-agnostic

### Naming Conventions
- **Types:** `PascalCase` (e.g., `Node`, `RectNode`, `RenderContext`)
- **Enums:** `PascalCase` with `Event` prefix for input events (e.g., `EventMouseDown`)
- **Constants:** `camelCase` with `Default`/`Max`/`Min` prefix (e.g., `defaultPadding`)
- **Procedures:** `camelCase` (e.g., `markDirty`, `hitTest`, `updateGlobalTransform`)
- **Export with `*`:** Public API symbols (e.g., `Node*`, `draw*`)
- **Internal fields:** No star (e.g., `parent*: Node`)

### Types
- Use `Option[T]` for nullable values
- Use `seq[T]` for dynamic arrays, `array[N, T]` for fixed
- Use `vmath.Vec2` for 2D positions and sizes
- Use `pixie.Paint` for vector drawing styles

### Node Design
- All nodes inherit from `Node` base type
- Each node type in its own file under `nodes/`
- Node implements `draw(ctx: RenderContext)` method
- `computeGlobalTransform()` updates local → global matrix
- `contains(point: Vec2): bool` for hit testing

### Error Handling
- Use assertions for invariant violations
- Use `Option[T]` for optional values, not exceptions
- Fail fast on invalid scene graph states (cycles, missing parents)

### Formatting
- Max function length: 45 lines (hard cap: 60)
- Max file length: 500 lines (hard cap: 600)
- Use 2-space indentation
- One responsibility per file (e.g., `rect_node.nim` only defines RectNode)
- Prefer early returns over nested conditionals
- No comments unless explaining non-obvious logic

---

## 2. PROJECT STRUCTURE

```
src/vex/
├── vex.nim              # Main entry point (exports everything)
├── core/
│   ├── types.nim        # Base Node object, enums, exports
│   ├── context.nim      # RenderContext (wraps Boxy + Texture Cache)
│   ├── transform.nim    # Matrix math, global position calculation
│   └── events.nim       # Hit testing, Input data structures
├── nodes/
│   ├── primitive.nim    # RectNode, CircleNode
│   ├── sprite.nim       # SpriteNode (images, 9-slice)
│   ├── text.nim         # TextNode (fonts, wrapping)
│   └── path.nim         # PathNode (vector paths)
└── layout/
    ├── alignment.nim    # Anchor, Pivot
    └── container.nim    # HBox, VBox (optional helpers)
```

---

## 3. RENDERING PATTERNS

### Dirty Flag System
- Nodes track `dirty: bool` flag
- When dirty: rasterize with Pixie → cached texture in Boxy
- When clean: draw cached texture (60+ FPS)
- Parent `markDirty()` propagates to children

### RenderContext Responsibilities
- Owns the `Boxy` instance
- Manages texture cache (Pixie rasterization → Boxy textures)
- Provides `draw(node)` entry point
- Handles viewport/culling

### Boxy + Pixie Bridge
- Use Pixie for one-time rasterization of vector content
- Use Boxy for fast texture rendering each frame
- Never re-rasterize vectors every frame

---

## 4. AGENT OPERATIONAL PROTOCOLS

### YAGNI (You Aren't Gonna Need It)
- Implement **exactly** what is requested
- No future-proofing or utility abstractions unless requested

### Stop Conditions
STOP and ask for validation if:
- Boilerplate exceeds 50 lines without clear progress
- About to import outside the approved stack (boxy, pixie, vmath, stdlib)
- Architecture feels forced or unclear
- Keep `plan.md` up to date

### Refactor Triggers
Refactor **before** adding new behavior if:
- File exceeds 500 lines
- Function exceeds 45 lines
- Same pattern appears twice → extract helper
- Third TODO in the same area
- Change touches more than 3 unrelated concepts

---

## 5. NIM DOCUMENTATION (MCP)

Use the `nim-docs` MCP server for Nim library documentation.

### Available Tools

| Tool | Description |
|------|-------------|
| `list_nim_libraries()` | List all available libraries |
| `get_nim_library_toc(library_name)` | Get table of contents for a library |
| `search_nim_docs(query, library_name, search_type, max_results)` | Search docs with `substring`, `regex`, or `topic` modes |
| `get_nim_doc_section(library_name, section_title)` | Retrieve full section content |
| `extract_nim_code_examples(library_name)` | Extract all Nim code examples |

### Library References
```bash
list_nim_libraries()                                    # List all libraries
get_nim_library_toc("boxy")                             # Get Boxy TOC
search_nim_docs("drawRect", "boxy", "substring")        # Search Boxy docs
search_nim_docs("Texture.*", "pixie", "regex")          # Regex search Pixie
get_nim_doc_section("vmath", "Vec2")                    # Get Vec2 section
extract_nim_code_examples("pixie")                      # Get Pixie examples
```

**Do NOT** manually read files from `/refs/` - use the MCP tools above.

---

## 6. TESTING GUIDELINES

- Use `unittest` for headless tests
- Tests must not open a window or depend on a windowing system
- Test scene graph operations (add/remove, hierarchy)
- Test transform propagation (local → global)
- Test hit testing at various positions/scales
- Test dirty flag propagation and rasterization
- Test each node type's `draw()` output

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
