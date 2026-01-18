import std/[sequtils, strutils, os]
import vmath

import ../src/vex/core/types

type
  MockBoxyDrawCall = object
    kind: string
    position: Vec2
    color: string
    size: Vec2

  MockBoxy* = ref object
    drawCalls: seq[MockBoxyDrawCall]

proc newMockBoxy*(): MockBoxy =
  MockBoxy(drawCalls: @[])

proc recordDraw*(boxy: MockBoxy, kind: string, position: Vec2, color: string, size: Vec2) =
  boxy.drawCalls.add(MockBoxyDrawCall(kind: kind, position: position, color: color, size: size))

proc getDrawCalls*(boxy: MockBoxy): seq[MockBoxyDrawCall] = boxy.drawCalls

proc clearDrawCalls*(boxy: MockBoxy) =
  boxy.drawCalls = @[]

template checkTransform*(node: Node, expected: Mat3, tolerance = 0.0001) =
  let actual = node.globalTransform
  for i in 0..<9:
    check abs(actual.m[i] - expected.m[i]) < tolerance

template checkHitTest*(node: Node, point: Vec2, expectedInside: bool) =
  check node.contains(point) == expectedInside

template checkPosition*(node: Node, expected: Vec2, tolerance = 0.0001) =
  check abs(node.localPos.x - expected.x) < tolerance
  check abs(node.localPos.y - expected.y) < tolerance

template checkScale*(node: Node, expected: Vec2, tolerance = 0.0001) =
  check abs(node.localScale.x - expected.x) < tolerance
  check abs(node.localScale.y - expected.y) < tolerance

template checkRotation*(node: Node, expected: float32, tolerance = 0.0001) =
  check abs(node.localRotation - expected) < tolerance

proc createTestNode*(
  name: string = "",
  pos: Vec2 = vec2(0, 0),
  scale: Vec2 = vec2(1, 1),
  rotation: float32 = 0.0,
  size: Vec2 = vec2(100, 100),
  visible: bool = true
): Node =
  let node = newNode()
  node.name = name
  node.localPos = pos
  node.localScale = scale
  node.localRotation = rotation
  node.size = size
  node.visible = visible
  node

proc createTestHierarchy*(): (Node, Node, Node) =
  let parent = createTestNode("parent", pos = vec2(50, 50), size = vec2(200, 200))
  let child = createTestNode("child", pos = vec2(25, 25), size = vec2(50, 50))
  let grandchild = createTestNode("grandchild", pos = vec2(10, 10), size = vec2(20, 20))
  parent.addChild(child)
  child.addChild(grandchild)
  parent.updateGlobalTransform()
  (parent, child, grandchild)

proc assertAlmostEqual*(a, b: float, tolerance = 0.0001) =
  if abs(a - b) >= tolerance:
    raise newException(AssertionDefect, "Values differ: " & $a & " vs " & $b & " (tolerance: " & $tolerance & ")")

proc assertAlmostEqual*(a, b: Vec2, tolerance = 0.0001) =
  assertAlmostEqual(a.x, b.x, tolerance)
  assertAlmostEqual(a.y, b.y, tolerance)

proc assertAlmostEqual*(a, b: Mat3, tolerance = 0.0001) =
  for i in 0..<3:
    for j in 0..<3:
      assertAlmostEqual(a[i, j], b[i, j], tolerance)
