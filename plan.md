# VEX: Vector & Hex Scene Graph Library
**Version:** 0.1.0 (Draft)
**Language:** Nim
**Dependencies:** `boxy`, `pixie`, `vmath`
**Philosophy:** Library, not Framework. Retained-mode scene graph.

---

## 1. Project Overview
Vex is a high-performance 2D scene graph library designed for the "Treeform" stack (Windy/Boxy/Pixie). It bridges the gap between **Pixie** (high-quality CPU vector drawing) and **Boxy** (fast GPU texture rendering).

### The Problem it Solves
* **Boxy** is fast but only draws textures/rects. It has no concept of "UI hierarchy" or "Layout."
* **Pixie** draws beautiful vectors (rounded rects, fonts) but is too slow to run every frame on the CPU.
* **Vex** provides a Node-based tree. It uses Pixie to rasterize vectors into textures *only when they change* ("dirty" flag), and uses Boxy to render the cached textures at 60+ FPS.

### Design Constraints
1.  **Window Agnostic:** Vex does NOT import `windy`. It accepts a generic input state and a `Boxy` reference.
2.  **No Game Logic:** Vex does not run a loop. It has a `draw(ctx)` method called by the host.
3.  **Pure Nim:** No C-wrappers or heavy external dependencies.

---

## 2. Directory Structure

```text
src/vex/
├── vex.nim            # Main entry point (exports everything)
├── core/
│   ├── types.nim      # Base Node object and Enum definitions
│   ├── context.nim    # The RenderContext (wraps Boxy + Texture Cache)
│   ├── transform.nim  # Matrix math (Global position/scale calculation)
│   └── events.nim     # Hit testing and Input data structures
├── nodes/
│   ├── primitive.nim  # RectNode, CircleNode (Basic shapes)
│   ├── sprite.nim     # SpriteNode (Images, 9-Slice)
│   ├── text.nim       # TextNode (Font rendering, Wrapping)
│   └── path.nim       # PathNode (Complex vector paths/Hexes)
└── layout/
    ├── alignment.nim  # Anchor and Pivot logic
    └── container.nim  # HBox, VBox, Grid (Optional helpers)
```
