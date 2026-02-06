import std/options
import unittest
import pixie
import vmath
import ../src/vex

const TestFontPath = "tests/data/DejaVuSans.ttf"

suite "Tooltip":
  test "tooltip creation":
    let tooltip = newTooltip("Test tooltip", TestFontPath)
    check tooltip.contentNode.text == "Test tooltip"
    check tooltip.visible == false
    check tooltip.zIndex == 1000

  test "tooltip text change":
    let tooltip = newTooltip("Original", TestFontPath)
    tooltip.setText("Updated")
    check tooltip.contentNode.text == "Updated"

  test "tooltip show/hide":
    let viewportSize = vec2(800, 600)
    let ctx = newHeadlessRenderContext(viewportSize)
    let tooltip = newTooltip("Test", TestFontPath)
    let target = newRectNode(vec2(100, 50))
    target.localPos = vec2(100, 100)
    target.updateGlobalTransform()
    
    tooltip.show(target, viewportSize, ctx)
    check tooltip.visible == true
    check tooltip.targetNode.isSome == true
    
    tooltip.hide()
    check tooltip.visible == false
    check tooltip.targetNode.isNone == true

  test "tooltip positioning":
    let viewportSize = vec2(800, 600)
    let ctx = newHeadlessRenderContext(viewportSize)
    let tooltip = newTooltip("Test tooltip content", TestFontPath, position = TooltipBottom)
    let target = newRectNode(vec2(100, 50))
    target.localPos = vec2(100, 100)
    target.updateGlobalTransform()
    
    tooltip.show(target, viewportSize, ctx)
    
    check tooltip.localPos.y > target.localPos.y + target.size.y

  test "tooltip viewport clamping":
    let viewportSize = vec2(400, 400)
    let ctx = newHeadlessRenderContext(viewportSize)
    let tooltip = newTooltip("Tooltip", TestFontPath, maxWidth = 150)
    let target = newRectNode(vec2(50, 50))
    target.localPos = vec2(10, 10)
    target.updateGlobalTransform()
    
    tooltip.show(target, viewportSize, ctx)
    tooltip.clampToViewport(viewportSize)
    
    check tooltip.localPos.x >= 0
    check tooltip.localPos.y >= 0
    check tooltip.localPos.x + tooltip.size.x <= viewportSize.x
    check tooltip.localPos.y + tooltip.size.y <= viewportSize.y
