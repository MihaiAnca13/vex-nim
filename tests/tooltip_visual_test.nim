import std/options
import pixie
import vmath
import ../src/vex

const TestFontPath = "tests/data/DejaVuSans.ttf"
const OutputPath = "tests/screenshots/tooltip_states.png"

proc main() =
  let viewportSize = vec2(800, 600)
  let ctx = newHeadlessRenderContext(viewportSize)
  let root = newNode()
  root.size = viewportSize
  
  let bg = newRectNode(viewportSize)
  bg.fill = some(solidPaint(color(0.1, 0.1, 0.12, 1.0)))
  root.addChild(bg)
  
  let title = newTextNode("Tooltip Positioning Demo", TestFontPath, 24, color(0.9, 0.9, 0.9, 1.0))
  title.localPos = vec2(50, 30)
  root.addChild(title)
  
  var yOffset = 100.0
  let xOffset = 100.0
  
  let target1 = newRectNode(vec2(120, 40))
  target1.localPos = vec2(xOffset, yOffset)
  target1.fill = some(solidPaint(color(0.3, 0.5, 0.7, 1.0)))
  root.addChild(target1)
  
  let tooltip1 = newTooltip("Tooltip above target", TestFontPath, position = TooltipTop)
  root.addChild(tooltip1)
  
  let target2 = newRectNode(vec2(120, 40))
  target2.localPos = vec2(xOffset + 200, yOffset)
  target2.fill = some(solidPaint(color(0.3, 0.5, 0.7, 1.0)))
  root.addChild(target2)
  
  let tooltip2 = newTooltip("Tooltip below target", TestFontPath, position = TooltipBottom)
  root.addChild(tooltip2)
  
  yOffset += 120
  
  let target3 = newRectNode(vec2(120, 40))
  target3.localPos = vec2(xOffset, yOffset)
  target3.fill = some(solidPaint(color(0.3, 0.5, 0.7, 1.0)))
  root.addChild(target3)
  
  let tooltip3 = newTooltip("Left side tooltip", TestFontPath, position = TooltipLeft)
  root.addChild(tooltip3)
  
  let target4 = newRectNode(vec2(120, 40))
  target4.localPos = vec2(xOffset + 200, yOffset)
  target4.fill = some(solidPaint(color(0.3, 0.5, 0.7, 1.0)))
  root.addChild(target4)
  
  let tooltip4 = newTooltip("Right side tooltip", TestFontPath, position = TooltipRight)
  root.addChild(tooltip4)
  
  yOffset += 120
  
  let target5 = newRectNode(vec2(150, 50))
  target5.localPos = vec2(xOffset + 100, yOffset)
  target5.fill = some(solidPaint(color(0.3, 0.5, 0.7, 1.0)))
  root.addChild(target5)
  
  let longText = "This is a longer tooltip text that should wrap to multiple lines and demonstrate the maxWidth feature."
  let tooltip5 = newTooltip(longText, TestFontPath, position = TooltipTop, maxWidth = 220)
  root.addChild(tooltip5)
  
  yOffset += 120
  
  let label6 = newTextNode("Auto-positioning (picks best side):", TestFontPath, 14, color(0.7, 0.7, 0.7, 1.0))
  label6.localPos = vec2(xOffset, yOffset)
  root.addChild(label6)
  
  let target6 = newRectNode(vec2(120, 40))
  target6.localPos = vec2(xOffset + 280, yOffset)
  target6.fill = some(solidPaint(color(0.3, 0.5, 0.7, 1.0)))
  root.addChild(target6)
  
  let tooltip6 = newTooltip("Auto-positioned", TestFontPath, position = TooltipAuto)
  root.addChild(tooltip6)
  
  root.updateGlobalTransform()
  
  tooltip1.show(target1, viewportSize, ctx)
  tooltip2.show(target2, viewportSize, ctx)
  tooltip3.show(target3, viewportSize, ctx)
  tooltip4.show(target4, viewportSize, ctx)
  tooltip5.show(target5, viewportSize, ctx)
  tooltip6.show(target6, viewportSize, ctx)
  
  ctx.resize(viewportSize)
  ctx.draw(root)
  
  let image = ctx.renderToImage(root)
  image.writeFile(OutputPath)
  echo "Screenshot saved to: ", OutputPath

main()
