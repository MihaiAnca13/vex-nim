import std/options
import pixie
import vmath
import ../src/vex

const TestFontPath = "tests/data/DejaVuSans.ttf"
const OutputPath = "tests/screenshots/selection_overlay.png"

proc main() =
  let viewportSize = vec2(800, 600)
  let ctx = newHeadlessRenderContext(viewportSize)
  let root = newNode()
  root.size = viewportSize
  
  let bg = newRectNode(viewportSize)
  bg.fill = some(solidPaint(color(0.1, 0.1, 0.12, 1.0)))
  root.addChild(bg)
  
  let title = newTextNode("Selection Overlay Styles", TestFontPath, 24, color(0.9, 0.9, 0.9, 1.0))
  title.localPos = vec2(50, 30)
  root.addChild(title)
  
  var yOffset = 100.0
  let xOffset = 80.0
  
  let target1 = newRectNode(vec2(120, 60))
  target1.localPos = vec2(xOffset, yOffset)
  target1.fill = some(solidPaint(color(0.2, 0.3, 0.5, 1.0)))
  root.addChild(target1)
  
  let label1 = newTextNode("Border Style", TestFontPath, 12, color(0.7, 0.7, 0.7, 1.0))
  label1.localPos = vec2(xOffset, yOffset + 70)
  root.addChild(label1)
  
  let overlay1 = newSelectionOverlay(SelectionStyleBorder, color(0.9, 0.7, 0.2, 1.0), borderWidth = 3.0)
  overlay1.attachTo(target1)
  overlay1.show()
  root.addChild(overlay1)
  
  let target2 = newRectNode(vec2(120, 60))
  target2.localPos = vec2(xOffset + 200, yOffset)
  target2.fill = some(solidPaint(color(0.2, 0.3, 0.5, 1.0)))
  root.addChild(target2)
  
  let label2 = newTextNode("Glow Style", TestFontPath, 12, color(0.7, 0.7, 0.7, 1.0))
  label2.localPos = vec2(xOffset + 200, yOffset + 80)
  root.addChild(label2)
  
  let overlay2 = newSelectionOverlay(SelectionStyleGlow, color(0.9, 0.7, 0.2, 1.0), glowRadius = 10.0)
  overlay2.attachTo(target2)
  overlay2.show()
  root.addChild(overlay2)
  
  yOffset += 140
  
  let target3 = newRectNode(vec2(120, 60))
  target3.localPos = vec2(xOffset, yOffset)
  target3.fill = some(solidPaint(color(0.2, 0.3, 0.5, 1.0)))
  root.addChild(target3)
  
  let label3 = newTextNode("Fill Style", TestFontPath, 12, color(0.7, 0.7, 0.7, 1.0))
  label3.localPos = vec2(xOffset, yOffset + 70)
  root.addChild(label3)
  
  let overlay3 = newSelectionOverlay(SelectionStyleFill, color(0.9, 0.7, 0.2, 1.0))
  overlay3.attachTo(target3)
  overlay3.show()
  root.addChild(overlay3)
  
  let target4 = newRectNode(vec2(120, 60))
  target4.localPos = vec2(xOffset + 200, yOffset)
  target4.fill = some(solidPaint(color(0.2, 0.3, 0.5, 1.0)))
  root.addChild(target4)
  
  let label4 = newTextNode("Dashed Style", TestFontPath, 12, color(0.7, 0.7, 0.7, 1.0))
  label4.localPos = vec2(xOffset + 200, yOffset + 70)
  root.addChild(label4)
  
  let overlay4 = newSelectionOverlay(SelectionStyleDashed, color(0.9, 0.7, 0.2, 1.0), borderWidth = 2.0)
  overlay4.attachTo(target4)
  overlay4.show()
  root.addChild(overlay4)
  
  yOffset += 140
  
  let target5 = newRectNode(vec2(150, 80))
  target5.localPos = vec2(xOffset + 50, yOffset)
  target5.fill = some(solidPaint(color(0.2, 0.3, 0.5, 1.0)))
  target5.cornerRadius = 8.0
  root.addChild(target5)
  
  let label5 = newTextNode("Rounded Corners (Border)", TestFontPath, 12, color(0.7, 0.7, 0.7, 1.0))
  label5.localPos = vec2(xOffset + 50, yOffset + 90)
  root.addChild(label5)
  
  let overlay5 = newSelectionOverlay(SelectionStyleBorder, color(0.3, 0.8, 0.4, 1.0), borderWidth = 3.0)
  overlay5.cornerRadius = 8.0
  overlay5.attachTo(target5)
  overlay5.show()
  root.addChild(overlay5)
  
  let target6 = newRectNode(vec2(150, 80))
  target6.localPos = vec2(xOffset + 250, yOffset)
  target6.fill = some(solidPaint(color(0.2, 0.3, 0.5, 1.0)))
  target6.cornerRadius = 12.0
  root.addChild(target6)
  
  let label6 = newTextNode("Rounded Corners (Glow)", TestFontPath, 12, color(0.7, 0.7, 0.7, 1.0))
  label6.localPos = vec2(xOffset + 250, yOffset + 100)
  root.addChild(label6)
  
  let overlay6 = newSelectionOverlay(SelectionStyleGlow, color(0.8, 0.3, 0.3, 1.0), glowRadius = 12.0)
  overlay6.cornerRadius = 12.0
  overlay6.attachTo(target6)
  overlay6.show()
  root.addChild(overlay6)
  
  ctx.resize(viewportSize)
  ctx.draw(root)
  
  let image = ctx.renderToImage(root)
  image.writeFile(OutputPath)
  echo "Screenshot saved to: ", OutputPath

main()
