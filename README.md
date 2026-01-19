 # VEX: Vector & Hex Scene Graph Library

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nim Version](https://img.shields.io/badge/Nim-2.2+-orange.svg)](https://nim-lang.org/)

**Version:** 0.1.0

**Language:** Nim

**Dependencies:** `boxy`, `pixie`, `vmath`

**Philosophy:** Library, not Framework. Retained-mode scene graph.


---

## 1. Installation

### From Nimble (Coming Soon)

```bash
nimble install vex
```

### From Git (Development)

```bash
nimble install https://github.com/MihaiAnca13/vex-nim.git
```

### Local Development

```bash
git clone https://github.com/MihaiAnca13/vex-nim.git
cd vex-nim
nimble install
```


---

## 2. Quick Start

```nim
import vmath
import pixie
import windy
import vex

# Create a render context
let ctx = newRenderContext(vec2(800, 600))

# Create a simple scene
let root = newNode()
let rect = newRectNode(vec2(100, 100))
rect.fill = some(color(1, 0, 0, 1))
rect.localPos = vec2(50, 50)
root.addChild(rect)

# Render loop
window titled "Vex Demo", vec2(800, 600):
  while true:
    pollEvents()
    ctx.resize(vec2(800, 600))
    ctx.beginFrame()
    ctx.draw(root)
    ctx.endFrame()
    swapBuffers()
```


---

## 3. Core Concepts

### The Node Tree

Vex uses a retained-mode scene graph. All visual elements are `Node` instances organized in a tree:

```
root
├── HBox
│   ├── TextNode ("Hello")
│   ├── RectNode
│   └── CircleNode
└── HexGrid
    ├── HexNode (0, 0)
    ├── HexNode (1, 0)
    └── HexNode (0, 1)
```

### Dirty Flag System

Nodes track a `dirty: bool` flag. When dirty:
1. Vex rasterizes the node using Pixie (vector drawing)
2. The result is cached as a texture in Boxy
3. `dirty` is set to `false`

When clean:
1. Vex draws the cached texture (very fast - 60+ FPS)

Call `node.markDirty()` to trigger re-rasterization.

### Rendering Pipeline

```
Your Code
    ↓
ctx.draw(root)
    ↓
For each node (top-down):
  1. If dirty: rasterize with Pixie → cache texture
  2. Draw cached texture with Boxy
  ↓
Boxy → GPU → Screen
```

### Layout Containers

HBox and VBox automatically position children:

```nim
let hbox = newHBox(spacing = 8, padding = 16)
hbox.addItem(newRectNode(vec2(50, 50)))
hbox.addItem(newRectNode(vec2(50, 50)))
hbox.update(ctx)  # Pass RenderContext for TextNode测量
```


---

## 4. Project Overview

Vex is a high-performance 2D scene graph library designed for the "Treeform" stack (Windy/Boxy/Pixie). It bridges the gap between **Pixie** (high-quality CPU vector drawing) and **Boxy** (fast GPU texture rendering).


### The Problem it Solves

* **Boxy** is fast but only draws textures/rects. It has no concept of "UI hierarchy" or "Layout."

* **Pixie** draws beautiful vectors (rounded rects, fonts) but is too slow to run every frame on the CPU.

* **Vex** provides a Node-based tree. It uses Pixie to rasterize vectors into textures *only when they change* ("dirty" flag), and uses Boxy to render the cached textures at 60+ FPS.


### Design Constraints

1. **Window Agnostic:** Vex does NOT import `windy`. It accepts a generic input state and a `Boxy` reference.

2. **No Game Logic:** Vex does not run a loop. It has a `draw(ctx)` method called by the host.

3. **Pure Nim:** No C-wrappers or heavy external dependencies.


---

## 5. Directory Structure

```text
src/vex/
├── vex.nim              # Main entry point (exports everything)
├── core/
│   ├── types.nim        # Base Node object and Enum definitions
│   ├── context.nim      # The RenderContext (wraps Boxy + Texture Cache)
│   ├── transform.nim    # Matrix math (Global position/scale calculation)
│   └── events.nim       # Hit testing and Input data structures
├── nodes/
│   ├── primitive.nim    # RectNode, CircleNode (Basic shapes)
│   ├── sprite.nim       # SpriteNode (Images, 9-Slice)
│   ├── text.nim         # TextNode (Font rendering, Wrapping)
│   └── path.nim         # PathNode (Complex vector paths/Hexes)
└── layout/
    ├── alignment.nim    # Anchor and Pivot logic
    └── container.nim    # HBox, VBox (Layout containers)
```


---

## 6. API Reference

### Node Types

| Type | Description |
|------|-------------|
| `Node` | Base type for all scene graph objects |
| `RectNode` | Rectangle with optional fill, stroke, corner radius |
| `CircleNode` | Circle with optional fill and stroke |
| `TextNode` | Text rendering with fonts, alignment, wrapping |
| `SpriteNode` | Image rendering with 9-slice scaling |
| `HexNode` | Hexagonal tile for strategy games |
| `PathNode` | Custom SVG-style vector paths |
| `HBox` | Horizontal layout container |
| `VBox` | Vertical layout container |
| `HexGrid` | Grid of HexNodes with spatial queries |

### RenderContext Procedures

| Procedure | Description |
|-----------|-------------|
| `newRenderContext(size)` | Create a new context |
| `draw(root)` | Render the scene graph |
| `handleEvent(root, event)` | Process input events |
| `resize(size)` | Update viewport size |
| `cacheTexture(node)` | Force texture regeneration |

### Node Procedures

| Procedure | Description |
|-----------|-------------|
| `addChild(parent, child)` | Add child to node |
| `removeChild(parent, child)` | Remove child from node |
| `markDirty()` | Mark node for re-rasterization |
| `contains(point)` | Hit test at local coordinates |
| `globalToLocal(point)` | Convert screen to local space |


---

## 7. Examples

See the `examples/` folder for runnable demos:

- `hello_world.nim` - Basic scene with shapes and text
- `hex_grid_demo.nim` - Interactive hex grid with click handling
- `ui_layout_demo.nim` - HBox/VBox layout demonstration


---

## 8. Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.


---

## 9. License

MIT License - see [LICENSE](LICENSE) for details. 