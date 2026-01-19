# Changelog

All notable changes to VEX will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Complete README with quick start guide, installation instructions, and API overview
- Examples folder with runnable demos:
  - `hello_world.nim` - Basic scene with shapes and text
  - `hex_grid_demo.nim` - Interactive hex grid with click handling
  - `ui_layout_demo.nim` - HBox/VBox layout demonstration
- API documentation generated to `docs/` folder
- CONTRIBUTING.md with contribution guidelines
- `clipChildren` field on Node (API ready, requires Boxy scissor support)
- `childrenSorted` optimization flag for z-index sorting
- `handleEvent` procedure for easy event injection

### Changed

- `markDirty` now only marks the node itself (performance improvement)
- Added `markDirtyUp` and `markDirtyDown` for explicit propagation
- Removed nil default from `HBox.update(ctx)` and `VBox.update(ctx)` (breaking)
- `zIndex` field on Node for explicit rendering order
- In-place sorting for z-index (performance improvement)

### Fixed

- HexNode.contains now uses proper hex point-in-polygon math
- TextNode.measure properly calculates text dimensions for layout
- Layout containers now properly measure TextNode children

### Removed

- Automatic dirty flag propagation to children (use `markDirtyDown` explicitly)

## [0.1.0] - 2025-01-18

### Added

- Initial release of VEX Vector & Hex Scene Graph Library
- Core types: Node, RenderContext, InputEvent
- Node types: RectNode, CircleNode, TextNode, SpriteNode, PathNode, HexNode
- Layout containers: HBox, VBox, HexGrid
- Events: hitTest, dispatchEvent
- Transform calculations: global/local transforms
- Texture caching with Boxy
- Golden image tests

### Known Issues

- `clipChildren` requires Boxy to add scissor support
- Examples require running with `-p:src` flag for import paths
