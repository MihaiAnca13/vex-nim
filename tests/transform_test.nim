import std/options
import unittest
import vmath
import bumpy

import ../src/vex/core/types
import ../src/vex/core/transform

proc createTestHierarchy*(): (Node, Node, Node) =
  let parent = newNode()
  parent.localPos = vec2(50, 50)
  parent.localScale = vec2(2, 2)
  parent.size = vec2(100, 100)

  let child = newNode()
  child.localPos = vec2(25, 25)
  child.localScale = vec2(1, 1)
  child.size = vec2(50, 50)

  let grandchild = newNode()
  grandchild.localPos = vec2(10, 10)
  grandchild.size = vec2(20, 20)

  parent.addChild(child)
  child.addChild(grandchild)
  parent.updateGlobalTransform()

  (parent, child, grandchild)

suite "transform.nim - Point transforms":
  test "localToGlobal transforms point through hierarchy":
    let (parent, child, _) = createTestHierarchy()
    let localPoint = vec2(10, 10)
    let globalPoint = child.localToGlobal(localPoint)
    check globalPoint.x == 120.0
    check globalPoint.y == 120.0

  test "globalToLocal inverse of localToGlobal":
    let (parent, child, _) = createTestHierarchy()
    let original = vec2(10, 10)
    let global = child.localToGlobal(original)
    let recovered = child.globalToLocal(global)
    check recovered.x == 10.0
    check recovered.y == 10.0

  test "transformRect transforms rectangle corners":
    let node = newNode()
    node.localPos = vec2(10, 10)
    node.localScale = vec2(2, 2)
    node.updateGlobalTransform()
    let rect = rect(0, 0, 10, 10)
    let transformed = node.globalTransform.transformRect(rect)
    check transformed.w == 20.0
    check transformed.h == 20.0

suite "transform.nim - World transforms":
  test "getWorldPosition extracts translation":
    let node = newNode()
    node.localPos = vec2(100, 200)
    node.updateGlobalTransform()
    let pos = node.getWorldPosition()
    check pos.x == 100.0
    check pos.y == 200.0

  test "getWorldScale extracts uniform scale":
    let node = newNode()
    node.localScale = vec2(3, 3)
    node.updateGlobalTransform()
    let scale = node.getWorldScale()
    check scale.x == 3.0
    check scale.y == 3.0

  test "getWorldScale extracts non-uniform scale":
    let node = newNode()
    node.localScale = vec2(2, 4)
    node.updateGlobalTransform()
    let scale = node.getWorldScale()
    check scale.x == 2.0
    check scale.y == 4.0

  test "getWorldRotation extracts rotation for 90 degrees":
    let node = newNode()
    node.localRotation = 1.5707963267948966'f32
    node.updateGlobalTransform()
    let rotation = node.getWorldRotation()
    check abs(rotation - 1.5707963267948966) < 0.001

suite "transform.nim - Transform composition":
  test "child transform includes parent transform":
    let (parent, child, _) = createTestHierarchy()
    let childGlobal = child.globalTransform
    check childGlobal[2, 0] == 100.0
    check childGlobal[2, 1] == 100.0

  test "grandchild transform accumulates all ancestors":
    let (_, _, grandchild) = createTestHierarchy()
    let grandGlobal = grandchild.globalTransform
    check grandGlobal[2, 0] == 120.0
    check grandGlobal[2, 1] == 120.0

  test "invertTransform produces inverse matrix":
    let node = newNode()
    node.localPos = vec2(50, 50)
    node.localScale = vec2(2, 2)
    node.updateGlobalTransform()
    let original = node.globalTransform
    let inverted = node.globalTransform.invertTransform()
    let identity = original * inverted
    for i in 0..<3:
      for j in 0..<3:
        if i == j:
          check abs(identity[i, j] - 1.0) < 0.001
        else:
          check abs(identity[i, j]) < 0.001

  test "invertTransform produces inverse matrix":
    let node = newNode()
    node.localPos = vec2(50, 50)
    node.localScale = vec2(2, 2)
    node.updateGlobalTransform()
    let original = node.globalTransform
    let inverted = node.globalTransform.invertTransform()
    let identity = original * inverted
    for i in 0..<3:
      for j in 0..<3:
        if i == j:
          check abs(identity[i, j] - 1.0) < 0.001
        else:
          check abs(identity[i, j]) < 0.001
