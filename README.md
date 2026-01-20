 # VEX: Vector & Hex Scene Graph Library

**VEX** is a high-performance 2D retained-mode scene graph library for Nim. It is designed for applications that need sophisticated vector graphics, complex UI layouts, or hex-based game grids - anywhere you need to compose many visual elements into a scene that updates efficiently.

**When to use VEX:**
- Building desktop or game UIs with complex layouts
- Creating vector-heavy applications (diagrams, editors, dashboards)
- Developing hex-grid strategy games
- Any project combining Pixie (vector drawing) with Boxy (GPU rendering)

**When NOT to use VEX:**
- Simple single-shape applications (use Pixie directly)
- Games with many identical sprites (use Boxy directly)
- Projects that need a full game engine (consider Necsus or Nimo)

**Key Features:**
- Retained-mode scene graph with parent-child hierarchies
- Anchor-based responsive layout (UI adapts to window size)
- HBox/VBox containers for automatic child positioning
- Vector shapes (rectangles, circles, paths) with Pixie rendering
- Text rendering with font loading and text wrapping
- Sprite images with 9-slice scaling support
- Hex grids for strategy games
- Efficient dirty-flag system (rasterize once, render many times)
- Window-agnostic design (works with any windowing library)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nim Version](https://img.shields.io/badge/Nim-2.2+-orange.svg)](https://nim-lang.org/)

**Version:** 0.1.0

**Language:** Nim

**Dependencies:** `boxy`, `pixie`, `vmath`

**Philosophy:** Library, not Framework. Retained-mode scene graph.


---

## 1. Installation

### From Nimble

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

## 3. Tutorial: Building Your First Scene

### Step 1: Create a Render Context

The `RenderContext` manages the rendering pipeline and texture cache:

```nim
let ctx = newRenderContext(vec2(800, 600))
```

### Step 2: Build a Scene Graph

Vex uses a tree of `Node` objects. Every visual element is a node:

```nim
let root = newNode()

# Create shapes
let redRect = newRectNode(vec2(200, 100))
redRect.fill = some(color(0.9, 0.2, 0.2, 1))
redRect.localPos = vec2(50, 50)
root.addChild(redRect)

let blueCircle = newCircleNode(vec2(80, 80))
blueCircle.fill = some(color(0.2, 0.6, 0.9, 1))
blueCircle.localPos = vec2(300, 60)
root.addChild(blueCircle)
```

### Step 3: Use Layout Containers

HBox and VBox automatically position children:

```nim
let hbox = newHBox(spacing = 8, padding = 16)
hbox.addItem(newRectNode(vec2(50, 50)))
hbox.addItem(newRectNode(vec2(50, 50)))
hbox.update(ctx)  # IMPORTANT: Call update() after adding items
root.addChild(hbox)
```

The `update(ctx)` call is required after adding items to layout containers.
It measures text nodes and calculates the container's size.

### Step 4: Render the Scene

Call `ctx.draw(root)` each frame:

```nim
window titled "My App", vec2(800, 600):
  while true:
    pollEvents()
    ctx.resize(vec2(800, 600))
    ctx.beginFrame()
    ctx.draw(root)
    ctx.endFrame()
    swapBuffers()
```

### Step 5: Handle Input

Use `hitTest` to find which node was clicked:

```nim
for event in events():
  if event.kind == MouseButtonDown:
    let hit = hitTest(root, event.pos)
    if hit.isSome:
      echo "Clicked: ", hit.get().node.name
      hit.get().node.markDirty()  # Re-render on state change
```

---

## 4. Core Concepts

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

Layout containers (HBox, VBox) automatically position their children.
See the **Tutorial** section above for usage instructions.

### Responsive Layout with Anchors

VEX supports a complete responsive layout system for building UIs that adapt to window resizing:

```nim
# Fill the entire parent container
node.sizeMode = FillParent
node.anchor = TopLeft

# Center content in its parent
node.anchor = Center

# Position in top-right with offset
node.anchor = TopRight
node.anchorOffset = vec2(-20, 20)

# Size as percentage of parent
node.sizeMode = Percent
node.sizePercent = vec2(0.5, 0.8)  # 50% width, 80% height
```

**Anchor Points:** TopLeft, TopCenter, TopRight, CenterLeft, Center, CenterRight, BottomLeft, BottomCenter, BottomRight

**Size Modes:** Absolute (default), FillParent, Percent

When the window resizes, call `ctx.resize(newSize)` and `root.requestLayout()` to recalculate all positions:


---

## 5. Project Overview

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

## 6. Directory Structure

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