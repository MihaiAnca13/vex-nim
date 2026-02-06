## Button Visual Test
## Generates a screenshot showing buttons in different states

import std/options
import pixie
import vmath
import ../src/vex

const TestFontPath = "tests/data/DejaVuSans.ttf"
const OutputPath = "tests/screenshots/button_states.png"

proc main() =
  let viewportSize = vec2(800, 600)
  let ctx = newHeadlessRenderContext(viewportSize)
  let root = newNode()
  root.size = viewportSize
  
  let bg = newRectNode(viewportSize)
  bg.fill = some(solidPaint(color(0.1, 0.1, 0.12, 1.0)))
  root.addChild(bg)
  
  let title = newTextNode("Button States", TestFontPath, 24, color(0.9, 0.9, 0.9, 1.0))
  title.localPos = vec2(50, 30)
  root.addChild(title)
  
  var yOffset = 100.0
  let xOffset = 100.0
  
  let normalBtn = newButton("Normal", TestFontPath, size = vec2(120, 40))
  normalBtn.localPos = vec2(xOffset, yOffset)
  normalBtn.setState(ButtonStateNormal)
  root.addChild(normalBtn)
  
  let hoverBtn = newButton("Hover", TestFontPath, size = vec2(120, 40))
  hoverBtn.localPos = vec2(xOffset + 150, yOffset)
  hoverBtn.setState(ButtonStateHover)
  root.addChild(hoverBtn)
  
  let activeBtn = newButton("Active", TestFontPath, size = vec2(120, 40))
  activeBtn.localPos = vec2(xOffset + 300, yOffset)
  activeBtn.setState(ButtonStateActive)
  root.addChild(activeBtn)
  
  let disabledBtn = newButton("Disabled", TestFontPath, size = vec2(120, 40))
  disabledBtn.localPos = vec2(xOffset + 450, yOffset)
  disabledBtn.setState(ButtonStateDisabled)
  root.addChild(disabledBtn)
  
  yOffset += 100
  
  let smallBtn = newButton("Small", TestFontPath, fontSize = 12, size = vec2(80, 30))
  smallBtn.localPos = vec2(xOffset, yOffset)
  root.addChild(smallBtn)
  
  let largeBtn = newButton("Large Button", TestFontPath, fontSize = 20, size = vec2(180, 50))
  largeBtn.localPos = vec2(xOffset + 150, yOffset)
  root.addChild(largeBtn)
  
  let wideBtn = newButton("Wide Button", TestFontPath, size = vec2(200, 40))
  wideBtn.localPos = vec2(xOffset + 150, yOffset + 70)
  root.addChild(wideBtn)
  
  let tallBtn = newButton("Tall", TestFontPath, size = vec2(80, 80))
  tallBtn.localPos = vec2(xOffset + 400, yOffset)
  root.addChild(tallBtn)
  
  yOffset += 180
  
  let label = newTextNode("Interactive Test:", TestFontPath, 16, color(0.7, 0.7, 0.7, 1.0))
  label.localPos = vec2(xOffset, yOffset)
  root.addChild(label)
  
  let clickBtn = newButton("Click Me!", TestFontPath, size = vec2(140, 45))
  clickBtn.localPos = vec2(xOffset + 150, yOffset - 5)
  var clickCount = 0
  clickBtn.onClick = proc() =
    clickCount += 1
    echo "Button clicked! Count: ", clickCount
  root.addChild(clickBtn)
  
  ctx.resize(viewportSize)
  ctx.draw(root)
  
  let image = ctx.renderToImage(root)
  image.writeFile(OutputPath)
  echo "Screenshot saved to: ", OutputPath

main()
