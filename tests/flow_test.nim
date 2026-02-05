import unittest
import std/options
import vmath
import pixie
import vex
import vex/layout/flow

suite "flow.nim - Flow layout":
  test "newFlow creates flow with defaults":
    let flow = newFlow()
    check flow.spacing == 4.0
    check flow.lineSpacing == 8.0
    check flow.maxWidth == 0.0
    check flow.horizontalAlign == AlignLeft

  test "newFlow with maxWidth":
    let flow = newFlow(maxWidth = 200.0)
    check flow.maxWidth == 200.0

  test "Flow.addItem adds child and marks dirty":
    let flow = newFlow()
    let child = newRectNode(vec2(50, 30))
    flow.addItem(child)
    check flow.children.len == 1
    check child.parent.isSome()

  test "Flow.update with no children":
    let flow = newFlow()
    flow.update()
    check flow.size == vec2(0, 0)

  test "Flow.update with single child":
    let flow = newFlow()
    let child = newRectNode(vec2(50, 30))
    flow.addItem(child)
    flow.update()
    check flow.size == vec2(50, 30)

  test "Flow with maxWidth=0 behaves like HBox":
    let flow = newFlow(maxWidth = 0)
    let child1 = newRectNode(vec2(50, 30))
    let child2 = newRectNode(vec2(40, 25))
    flow.addItem(child1)
    flow.addItem(child2)
    flow.update()
    check flow.children[0].localPos == vec2(0, 0)
    check flow.children[1].localPos == vec2(54, 0)

  test "Flow wraps items when exceeding maxWidth":
    let flow = newFlow(maxWidth = 100)
    let child1 = newRectNode(vec2(50, 30))
    let child2 = newRectNode(vec2(50, 25))
    flow.addItem(child1)
    flow.addItem(child2)
    flow.update()
    check flow.children[0].localPos == vec2(0, 0)
    check flow.children[1].localPos.x == 0
    check flow.children[1].localPos.y > 0

  test "Flow wraps multiple items":
    let flow = newFlow(maxWidth = 120)
    for i in 0..<4:
      let child = newRectNode(vec2(40, 20))
      flow.addItem(child)
    flow.update()
    check flow.children[0].localPos == vec2(0, 0)
    check flow.children[1].localPos == vec2(44, 0)
    check flow.children[2].localPos.x == 0
    check flow.children[2].localPos.y > 0
    check flow.children[3].localPos.x == 44
    check flow.children[3].localPos.y == flow.children[2].localPos.y

  test "Flow with AlignCenter aligns lines":
    let flow = newFlow(maxWidth = 100)
    flow.horizontalAlign = AlignCenter
    let child1 = newRectNode(vec2(30, 20))
    let child2 = newRectNode(vec2(40, 20))
    flow.addItem(child1)
    flow.addItem(child2)
    flow.update()
    let lineWidth = child1.size.x + flow.spacing + child2.size.x
    let offset = (flow.size.x - lineWidth) / 2.0
    check child1.localPos.x == offset
    check child2.localPos.x == offset + child1.size.x + flow.spacing

  test "Flow with AlignRight aligns lines":
    let flow = newFlow(maxWidth = 100)
    flow.horizontalAlign = AlignRight
    let child1 = newRectNode(vec2(30, 20))
    let child2 = newRectNode(vec2(40, 20))
    flow.addItem(child1)
    flow.addItem(child2)
    flow.update()
    let lineWidth = child1.size.x + flow.spacing + child2.size.x
    check child1.localPos.x == flow.size.x - lineWidth
    check child2.localPos.x == flow.size.x - child2.size.x

  test "Flow inherits from Node type":
    let flow = newFlow()
    check flow of Node
