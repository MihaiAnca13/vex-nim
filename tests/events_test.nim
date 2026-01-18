import std/options
import unittest
import vmath

import ../src/vex/core/types
import ../src/vex/core/transform

proc createTestNode*(
  pos: Vec2 = vec2(0, 0),
  scale: Vec2 = vec2(1, 1),
  rotation: float32 = 0.0,
  size: Vec2 = vec2(100, 100),
  visible: bool = true
): Node =
  let node = newNode()
  node.localPos = pos
  node.localScale = scale
  node.localRotation = rotation
  node.size = size
  node.visible = visible
  node

proc createTestHierarchy*(): (Node, Node) =
  let parent = createTestNode(pos = vec2(100, 100), size = vec2(200, 200))
  let child = createTestNode(pos = vec2(50, 50), size = vec2(100, 100))
  parent.addChild(child)
  parent.updateGlobalTransform()
  (parent, child)

suite "events.nim - Hit testing":
  test "contains returns true for point inside node":
    let node = createTestNode(size = vec2(100, 100))
    check node.contains(vec2(50, 50)) == true
    check node.contains(vec2(0, 0)) == true
    check node.contains(vec2(99, 99)) == true

  test "contains returns false for point outside node":
    let node = createTestNode(size = vec2(100, 100))
    check node.contains(vec2(100, 100)) == false
    check node.contains(vec2(-1, 50)) == false
    check node.contains(vec2(50, -1)) == false

  test "contains does not check visibility (use draw logic)":
    let node = createTestNode(size = vec2(100, 100), visible = false)
    check node.contains(vec2(50, 50)) == true

  test "contains uses local bounds":
    let node = createTestNode(pos = vec2(100, 100), size = vec2(100, 100))
    node.updateGlobalTransform()
    check node.contains(vec2(50, 50)) == true
    check node.contains(vec2(0, 0)) == true
    check node.contains(vec2(100, 100)) == false

  test "hit testing in hierarchy":
    let (parent, child) = createTestHierarchy()
    check child.contains(vec2(50, 50)) == true
    check child.contains(vec2(0, 0)) == true
    check child.contains(vec2(150, 150)) == false

  test "globalToLocal converts point correctly":
    let (parent, child) = createTestHierarchy()
    let globalPoint = child.localToGlobal(vec2(50, 50))
    check globalPoint.x == 200.0
    check globalPoint.y == 200.0

  test "hit testing point in parent but outside child":
    let (parent, child) = createTestHierarchy()
    let pointInParentOnly = vec2(125, 125)
    check parent.contains(pointInParentOnly) == true
    check child.contains(pointInParentOnly) == false

  test "hit testing point outside both":
    let (parent, child) = createTestHierarchy()
    let pointOutside = vec2(250, 250)
    check parent.contains(pointOutside) == false
    check child.contains(pointOutside) == false
