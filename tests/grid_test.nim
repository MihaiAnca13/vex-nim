import unittest
import std/options
import vmath
import pixie
import vex
import vex/layout/grid

suite "grid.nim - Grid layout":
  test "newGrid creates grid with defaults":
    let grid = newGrid()
    check grid.columns == 0
    check grid.rows == 0
    check grid.columnSpacing == 4.0
    check grid.rowSpacing == 4.0
    check grid.cellWidth == 0.0
    check grid.cellHeight == 0.0
    check grid.fillWidth == false
    check grid.fillHeight == false

  test "newGrid with columns and rows":
    let grid = newGrid(columns = 3, rows = 2)
    check grid.columns == 3
    check grid.rows == 2

  test "Grid.addItem adds child and marks dirty":
    let grid = newGrid()
    let child = newRectNode(vec2(50, 50))
    grid.addItem(child)
    check grid.children.len == 1
    check child.parent.isSome()

  test "Grid.update with no children":
    let grid = newGrid()
    grid.update()
    check grid.size == vec2(0, 0)

  test "Grid.update with single child":
    let grid = newGrid()
    let child = newRectNode(vec2(50, 30))
    grid.addItem(child)
    grid.update()
    check grid.size == vec2(50, 30)

  test "Grid.update with fixed columns":
    let grid = newGrid(columns = 2)
    for i in 0..<4:
      let child = newRectNode(vec2(40, 30))
      grid.addItem(child)
    grid.update()
    let expectedWidth = 40 * 2 + 4.0
    let expectedHeight = 30 * 2 + 4.0
    check grid.size.x == expectedWidth
    check grid.size.y == expectedHeight

  test "Grid.update positions children in row-major order":
    let grid = newGrid(columns = 2, rows = 2)
    for i in 0..<4:
      let child = newRectNode(vec2(30, 20))
      child.name = "child" & $i
      grid.addItem(child)
    grid.update()
    check grid.children[0].localPos == vec2(0, 0)
    check grid.children[1].localPos == vec2(34, 0)
    check grid.children[2].localPos == vec2(0, 24)
    check grid.children[3].localPos == vec2(34, 24)

  test "Grid.update with custom spacing":
    let grid = newGrid(columns = 2, columnSpacing = 10.0, rowSpacing = 15.0)
    for i in 0..<2:
      let child = newRectNode(vec2(30, 20))
      grid.addItem(child)
    grid.update()
    check grid.children[1].localPos.x == 40

  test "Grid.update with fixed cell size":
    let grid = newGrid(columns = 2, cellWidth = 50, cellHeight = 40, fillWidth = true, fillHeight = true)
    for i in 0..<2:
      let child = newRectNode(vec2(20, 15))
      grid.addItem(child)
    grid.update()
    check grid.children[0].size == vec2(50, 40)
    check grid.children[1].size == vec2(50, 40)

  test "Grid inherits from Node type":
    let grid = newGrid()
    check grid of Node
