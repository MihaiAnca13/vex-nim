import std/options
import unittest
import vmath

import ../src/vex/core/types

suite "types.nim - Node hierarchy":
  test "newNode creates node with defaults":
    let node = newNode()
    check node.children.len == 0
    check node.parent.isNone
    check node.localPos == vec2(0, 0)
    check node.localScale == vec2(1, 1)
    check node.localRotation == 0.0
    check node.dirty == true
    check node.visible == true
    check node.name == ""
    check node.size == vec2(0, 0)

  test "addChild establishes parent-child relationship":
    let parent = newNode()
    let child = newNode()
    parent.addChild(child)
    check parent.children.len == 1
    check parent.children[0] == child
    check child.parent.isSome
    check child.parent.get() == parent

  test "addChild marks parent dirty":
    let parent = newNode()
    let child = newNode()
    parent.dirty = false
    parent.addChild(child)
    check parent.dirty == true

  test "removeChild breaks relationship":
    let parent = newNode()
    let child = newNode()
    parent.addChild(child)
    parent.removeChild(child)
    check parent.children.len == 0
    check child.parent.isNone

  test "removeChild marks parent dirty":
    let parent = newNode()
    let child = newNode()
    parent.addChild(child)
    parent.dirty = false
    parent.removeChild(child)
    check parent.dirty == true

  test "isAncestorOf returns true for direct ancestor":
    let parent = newNode()
    let child = newNode()
    parent.addChild(child)
    check parent.isAncestorOf(child) == true

  test "isAncestorOf returns true for indirect ancestor":
    let parent = newNode()
    let child = newNode()
    let grandchild = newNode()
    parent.addChild(child)
    child.addChild(grandchild)
    check parent.isAncestorOf(grandchild) == true

  test "isAncestorOf returns false for non-ancestor":
    let nodeA = newNode()
    let nodeB = newNode()
    check nodeA.isAncestorOf(nodeB) == false

  test "findChildByName finds direct child":
    let parent = newNode()
    let child = newNode()
    child.name = "testchild"
    parent.addChild(child)
    let found = parent.findChildByName("testchild")
    check found.isSome
    check found.get() == child

  test "findChildByName finds nested child":
    let parent = newNode()
    let child = newNode()
    let grandchild = newNode()
    grandchild.name = "deepchild"
    parent.addChild(child)
    child.addChild(grandchild)
    let found = parent.findChildByName("deepchild")
    check found.isSome
    check found.get() == grandchild

  test "findChildByName returns none for missing name":
    let parent = newNode()
    let child = newNode()
    parent.addChild(child)
    let found = parent.findChildByName("nonexistent")
    check found.isNone

suite "types.nim - Dirty flag propagation":
  test "markDirty sets node dirty":
    let node = newNode()
    node.dirty = false
    node.markDirty()
    check node.dirty == true

  test "markDirty only marks the node itself":
    let parent = newNode()
    let child = newNode()
    parent.addChild(child)
    parent.dirty = false
    child.dirty = false
    parent.markDirty()
    check parent.dirty == true
    check child.dirty == false

  test "markDirtyDown propagates to children":
    let parent = newNode()
    let child1 = newNode()
    let child2 = newNode()
    parent.addChild(child1)
    parent.addChild(child2)
    parent.dirty = false
    child1.dirty = false
    child2.dirty = false
    parent.markDirtyDown()
    check parent.dirty == true
    check child1.dirty == true
    check child2.dirty == true

  test "markDirtyDown propagates to grandchildren":
    let parent = newNode()
    let child = newNode()
    let grandchild = newNode()
    parent.addChild(child)
    child.addChild(grandchild)
    parent.dirty = false
    child.dirty = false
    grandchild.dirty = false
    parent.markDirtyDown()
    check grandchild.dirty == true

suite "types.nim - Iterator traverse":
  test "traverse yields node and all descendants":
    let root = newNode()
    let child1 = newNode()
    let child2 = newNode()
    let grandchild = newNode()
    root.addChild(child1)
    root.addChild(child2)
    child1.addChild(grandchild)
    var visited: seq[Node]
    for node in root.traverse():
      visited.add(node)
    check visited.len == 4
    check visited[0] == root
    check visited.contains(child1)
    check visited.contains(child2)
    check visited.contains(grandchild)

  test "traversePostOrder processes children before parent":
    let root = newNode()
    let child = newNode()
    root.addChild(child)
    var order: seq[string]
    for node in root.traversePostOrder():
      order.add(node.name)
    check order[0] == child.name
    check order[1] == root.name
