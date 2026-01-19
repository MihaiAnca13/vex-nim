## Hex Grid Demo - VEX Interactive Example
##
## Run with: nim r -p:src examples/hex_grid_demo.nim
##
## This example demonstrates:
## - Creating a HexGrid with pointy-topped hexes
## - Adding and styling HexNodes
## - Handling mouse clicks for selection
## - Using hitTest for interaction

import vmath
import pixie
import windy
import vex
import std/options

proc main() =
  let ctx = newRenderContext(vec2(800, 600))

  # Create a hex grid with pointy-topped orientation
  let layout = newHexLayout(PointyTopped, vec2(30, 30), vec2(400, 300))
  let grid = newHexGrid(layout)

  # Add some hexes to the grid
  for q in -3..3:
    for r in -3..3:
      if abs(q + r) <= 3:
        let hex = grid.addHex((q.int, r.int))
        hex.stroke = some(color(0.3, 0.3, 0.3, 1))
        hex.strokeWidth = 1

        # Color based on distance from center
        let dist = hex.coord.hexDistance((0, 0))
        if dist == 0:
          hex.fill = some(color(0.9, 0.9, 0.2, 1))
        elif dist <= 1:
          hex.fill = some(color(0.2, 0.8, 0.4, 1))
        elif dist == 2:
          hex.fill = some(color(0.2, 0.5, 0.8, 1))
        else:
          hex.fill = some(color(0.7, 0.7, 0.7, 1))

  grid.updateGrid()

  # Track selected hex
  var selectedHex: Option[HexCoord] = none(HexCoord)

  window titled "VEX Hex Grid Demo", vec2(800, 600):
    while true:
      pollEvents()

      # Handle mouse clicks
      for event in events():
        if event.kind == MouseButtonDown:
          let hit = hitTest(grid, event.pos)
          if hit.isSome:
            let coord = hit.get().node.coord
            if selectedHex.isSome:
              # Deselect previous
              if let Some(prev) = grid.getHex(selectedHex.get()):
                prev.fill = if prev.coord.hexDistance((0, 0)) == 0: some(color(0.9, 0.9, 0.2, 1))
                           elif prev.coord.hexDistance((0, 0)) <= 1: some(color(0.2, 0.8, 0.4, 1))
                           elif prev.coord.hexDistance((0, 0)) == 2: some(color(0.2, 0.5, 0.8, 1))
                           else: some(color(0.7, 0.7, 0.7, 1))
                prev.markDirty()

            selectedHex = some(coord)
            if let Some(node) = grid.getHex(coord):
              node.fill = some(color(1.0, 0.4, 0.2, 1))
              node.markDirty()

      ctx.resize(vec2(800, 600))
      ctx.beginFrame()
      ctx.draw(grid)
      ctx.endFrame()
      swapBuffers()

when isMainModule:
  main()
