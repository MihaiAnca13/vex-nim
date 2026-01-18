import std/options
import unittest
import vmath

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/primitive

suite "primitive.nim - RectNode":
  test "newRectNode creates node with defaults":
    let node = newRectNode()
    check node.size == vec2(100, 100)
    check node.fill.isNone
    check node.stroke.isNone
    check node.strokeWidth == 1.0
    check node.cornerRadius == 0.0

  test "newRectNode with custom size":
    let node = newRectNode(vec2(200, 150))
    check node.size == vec2(200, 150)

  test "RectNode.contains at origin (identity transform)":
    let node = newRectNode(vec2(100, 100))
    check node.contains(vec2(0, 0)) == true
    check node.contains(vec2(50, 50)) == true
    check node.contains(vec2(99, 99)) == true
    check node.contains(vec2(100, 100)) == false

  test "RectNode with corner radius":
    let node = newRectNode(vec2(100, 100))
    node.cornerRadius = 10.0
    check node.cornerRadius == 10.0

suite "primitive.nim - CircleNode":
  test "newCircleNode creates node with defaults":
    let node = newCircleNode()
    check node.size == vec2(100, 100)
    check node.fill.isNone
    check node.stroke.isNone
    check node.strokeWidth == 1.0

  test "newCircleNode with custom size":
    let node = newCircleNode(vec2(80, 80))
    check node.size == vec2(80, 80)

  test "CircleNode.contains at origin (identity transform)":
    let node = newCircleNode(vec2(100, 100))
    check node.contains(vec2(0, 0)) == false
    check node.contains(vec2(50, 50)) == true
    check node.contains(vec2(49, 50)) == true
    check node.contains(vec2(50, 49)) == true
    check node.contains(vec2(51, 50)) == true
