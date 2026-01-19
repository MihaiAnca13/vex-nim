import unittest
import vmath
import std/options
import pixie

import ../src/vex/core/types
import ../src/vex/hex/hex

suite "hex.nim - HexOrientation":
  test "HexOrientation has two values":
    check HexOrientation.PointyTopped == HexOrientation.PointyTopped
    check HexOrientation.FlatTopped == HexOrientation.FlatTopped
    check ord(HexOrientation.PointyTopped) == 0
    check ord(HexOrientation.FlatTopped) == 1

  test "pointyOrientation constant equals PointyTopped":
    check pointyOrientation == HexOrientation.PointyTopped

  test "flatOrientation constant equals FlatTopped":
    check flatOrientation == HexOrientation.FlatTopped

  test "HexOrientation can be assigned to variable":
    let orient: HexOrientation = PointyTopped
    check orient == pointyOrientation

suite "hex.nim - HexCoord":
  test "HexCoord is a tuple of two ints":
    let coord: HexCoord = (3, -2)
    check coord.q == 3
    check coord.r == -2

  test "axialToCube converts correctly":
    let axial = (3.int, -2.int)
    let cube = axial.axialToCube()
    check cube.x == 3
    check cube.y == -1
    check cube.z == -2

  test "cubeToAxial converts correctly":
    let cube: CubeCoord = (3, -1, -2)
    let axial = cube.cubeToAxial()
    check axial.q == 3
    check axial.r == -2

  test "axialToCube and cubeToAxial are inverses":
    let original = (3.int, -2.int)
    let converted = original.axialToCube().cubeToAxial()
    check converted == original

suite "hex.nim - CubeCoord":
  test "CubeCoord is a tuple of three ints":
    let cube: CubeCoord = (3, -1, -2)
    check cube.x == 3
    check cube.y == -1
    check cube.z == -2

  test "cubeRound rounds to nearest integer coordinates":
    let rounded = cubeRound(3.2'f32, -1.7'f32, -1.5'f32)
    check rounded.x == 3
    check rounded.y == -2
    check rounded.z == -1

  test "axialRound rounds axial coordinates":
    let rounded = axialRound(3.7'f32, -2.3'f32)
    check rounded.q == 4
    check rounded.r == -2

suite "hex.nim - HexLayout":
  test "newHexLayout creates layout with orientation":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    check layout.orientation == PointyTopped
    check layout.size == vec2(10, 10)
    check layout.origin == vec2(0, 0)

  test "newHexLayout with flat orientation":
    let layout = newHexLayout(FlatTopped, vec2(15, 15), vec2(100, 50))
    check layout.orientation == FlatTopped
    check layout.size == vec2(15, 15)
    check layout.origin == vec2(100, 50)

  test "hexToPixel converts pointy hex to pixel":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let pixel = layout.hexToPixel((0.int, 0.int))
    check abs(pixel.x) < 0.001
    check abs(pixel.y) < 0.001

  test "hexToPixel converts flat hex to pixel":
    let layout = newHexLayout(FlatTopped, vec2(10, 10), vec2(0, 0))
    let pixel = layout.hexToPixel((0.int, 0.int))
    check abs(pixel.x) < 0.001
    check abs(pixel.y) < 0.001

  test "pixelToHex converts pixel back to hex":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let original: HexCoord = (3, -2)
    let pixel = layout.hexToPixel(original)
    let back = layout.pixelToHex(pixel)
    check back.q == original.q
    check back.r == original.r

  test "hexCornerOffset returns 6 corners":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    for i in 0..5:
      let corner = layout.hexCornerOffset(i)
      check corner.x != 0 or corner.y != 0

  test "hexCornerOffset for flat orientation":
    let layout = newHexLayout(FlatTopped, vec2(10, 10), vec2(0, 0))
    for i in 0..5:
      let corner = layout.hexCornerOffset(i)
      check corner.x != 0 or corner.y != 0

suite "hex.nim - HexNeighbor":
  test "hexDirections has 6 elements":
    check hexDirections.len == 6

  test "hexNeighbor returns correct neighbor in direction 0":
    let coord: HexCoord = (0, 0)
    let neighbor = coord.hexNeighbor(0)
    check neighbor.q == 1
    check neighbor.r == 0

  test "hexNeighbor returns correct neighbor in direction 3":
    let coord: HexCoord = (0, 0)
    let neighbor = coord.hexNeighbor(3)
    check neighbor.q == -1
    check neighbor.r == 0

  test "hexNeighbor wraps around correctly":
    let coord: HexCoord = (3, -2)
    let neighbor = coord.hexNeighbor(1)
    check neighbor.q == 4
    check neighbor.r == -3

  test "hexDistance between same hex is 0":
    let a: HexCoord = (3, -2)
    check a.hexDistance(a) == 0

  test "hexDistance between adjacent hexes is 1":
    let a: HexCoord = (0, 0)
    let b: HexCoord = (1, 0)
    check a.hexDistance(b) == 1

  test "hexDistance between opposite hexes is 3":
    let a: HexCoord = (0, 0)
    let b: HexCoord = (-3, 3)
    check a.hexDistance(b) == 3

  test "hexLine returns correct number of points":
    let a: HexCoord = (0, 0)
    let b: HexCoord = (3, -3)
    let line = a.hexLine(b)
    check line.len == 4

  test "hexLine starts at origin":
    let a: HexCoord = (0, 0)
    let b: HexCoord = (2, -2)
    let line = a.hexLine(b)
    check line[0].q == 0
    check line[0].r == 0

  test "hexLine ends at destination":
    let a: HexCoord = (0, 0)
    let b: HexCoord = (2, -2)
    let line = a.hexLine(b)
    check line[^1].q == 2
    check line[^1].r == -2

suite "hex.nim - HexNode":
  test "newHexNode creates node with coord and layout":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let node = newHexNode((3.int, -2.int), layout)
    check node.coord.q == 3
    check node.coord.r == -2
    check node.layout == layout

  test "newHexNode sets size based on layout":
    let layout = newHexLayout(PointyTopped, vec2(15, 15), vec2(0, 0))
    let node = newHexNode((0.int, 0.int), layout)
    check node.size == vec2(30, 30)

  test "newHexNode has default paint properties":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let node = newHexNode((0.int, 0.int), layout)
    check node.fill == none(Paint)
    check node.stroke == none(Paint)
    check node.strokeWidth == 1.0

  test "HexNode is a Node":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let node = newHexNode((0.int, 0.int), layout)
    check node of HexNode
    check node of Node

  test "newHexNode positions node at hex center":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(100, 50))
    let node = newHexNode((1.int, 0.int), layout)
    check abs(node.localPos.x - (100.0 + 10.0 * sqrt(3.0'f32))) < 0.001
    check abs(node.localPos.y - 50.0) < 0.001

suite "hex.nim - HexGrid":
  test "newHexGrid creates grid with layout":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    check grid.layout == layout
    check grid.getHex((0.int, 0.int)).isNone

  test "addHex adds node to grid":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    let node = grid.addHex((0.int, 0.int))
    check not grid.getHex((0.int, 0.int)).isNone
    check grid.getHex((0.int, 0.int)).get() == node

  test "addHex returns existing node if coord exists":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    let node1 = grid.addHex((0.int, 0.int))
    let node2 = grid.addHex((0.int, 0.int))
    check node1 == node2

  test "removeHex removes node from grid":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    discard grid.addHex((0.int, 0.int))
    grid.removeHex((0.int, 0.int))
    check grid.getHex((0.int, 0.int)).isNone

  test "getHex returns none for missing coord":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    check grid.getHex((0.int, 0.int)).isNone

  test "hexAt finds hex at pixel location":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    discard grid.addHex((0.int, 0.int))
    let pixel = layout.hexToPixel((0.int, 0.int))
    check grid.hexAt(pixel).isSome
    check grid.hexAt(pixel).get() == (0.int, 0.int)

  test "HexGrid is a Node":
    let layout = newHexLayout(PointyTopped, vec2(10, 10), vec2(0, 0))
    let grid = newHexGrid(layout)
    check grid of HexGrid
    check grid of Node
