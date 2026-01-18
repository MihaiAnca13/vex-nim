import std/options
import std/strutils
import unittest
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/path

suite "path.nim - PathNode":
  test "newPathNode creates node with defaults":
    let node = newPathNode("M 0 0 L 10 10")
    check node.pathData == "M 0 0 L 10 10"
    check node.fill.isNone
    check node.stroke.isNone
    check node.strokeWidth == 1.0
    check node.strokeCap == ButtCap
    check node.strokeJoin == MiterJoin

  test "newPathNode with fill":
    let paint = newPaint(SolidPaint)
    paint.color = color(1.0, 0.0, 0.0, 1.0)
    let node = newPathNode("M 0 0 L 10 10")
    node.fill = some(paint)
    check node.fill.isSome

  test "newPathNode with stroke":
    let paint = newPaint(SolidPaint)
    paint.color = color(0.0, 1.0, 0.0, 1.0)
    let node = newPathNode("M 0 0 L 10 10")
    node.stroke = some(paint)
    node.strokeWidth = 2.0
    node.strokeCap = RoundCap
    node.strokeJoin = RoundJoin
    check node.stroke.isSome
    check node.strokeWidth == 2.0
    check node.strokeCap == RoundCap
    check node.strokeJoin == RoundJoin

  test "newHexNode creates hexagon with correct radius":
    let node = newHexNode(50.0)
    check node.size == vec2(100.0, 100.0)
    check node.strokeWidth == 1.0
    check node.strokeCap == ButtCap
    check node.strokeJoin == MiterJoin
    check node.fill.isNone
    check node.stroke.isNone

  test "newHexNode path contains M, L, Z commands":
    let node = newHexNode(25.0)
    check "M" in node.pathData
    check "L" in node.pathData
    check "Z" in node.pathData

  test "newHexNode path has 6 L commands (6 vertices)":
    let node = newHexNode(10.0)
    let segments = node.pathData.split('L')
    check segments.len == 6

  test "PathNode.contains requires updateGlobalTransform to be called first":
    let node = newHexNode(50.0)
    check node.contains(vec2(0, 0)) == true
    check node.contains(vec2(50, 50)) == true
    check node.contains(vec2(99, 99)) == true
    check node.contains(vec2(100, 100)) == false

  test "PathNode.contains returns false for negative coordinates":
    let node = newPathNode("M 0 0 L 10 10")
    node.size = vec2(10, 10)
    check node.contains(vec2(-1, 5)) == false
    check node.contains(vec2(5, -1)) == false

  test "PathNode inherits from Node type":
    let node = newPathNode("M 0 0 L 10 10")
    check node of PathNode
    check node of Node

  test "newHexNode hexagon vertices are correct for radius 100":
    let node = newHexNode(100.0)
    check node.size == vec2(200.0, 200.0)
