import std/options
import unittest
import vmath
import bumpy

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/sprite

suite "sprite.nim - SpriteNode":
  test "newSpriteNode creates node with defaults":
    let node = newSpriteNode("test_image")
    check node.imageKey == "test_image"
    check node.size == vec2(100, 100)
    check node.sourceRect == rect(0, 0, 0, 0)
    check node.sliceInsets == vec4(0, 0, 0, 0)

  test "newSpriteNode with custom size":
    let node = newSpriteNode("test", vec2(200, 150))
    check node.imageKey == "test"
    check node.size == vec2(200, 150)

  test "newSpriteNodeWithSlice creates node with insets":
    let insets = vec4(10, 20, 10, 20)
    let node = newSpriteNodeWithSlice("sliced", vec2(100, 100), insets)
    check node.imageKey == "sliced"
    check node.sliceInsets == insets

  test "SpriteNode.contains at origin (identity transform)":
    let node = newSpriteNode("test", vec2(100, 100))
    check node.contains(vec2(0, 0)) == true
    check node.contains(vec2(50, 50)) == true
    check node.contains(vec2(99, 99)) == true
    check node.contains(vec2(100, 100)) == false

  test "SpriteNode.size defaults to vec2(100, 100)":
    let node = newSpriteNode("test")
    check node.size == vec2(100, 100)
