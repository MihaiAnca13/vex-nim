import std/options
import pixie
import vmath
import ../src/vex

const TestFontPath = "tests/data/DejaVuSans.ttf"

proc main() =
  let viewportSize = vec2(200, 200)
  let ctx = newHeadlessRenderContext(viewportSize)
  let tooltip = newTooltip("Long tooltip text that needs clamping", TestFontPath)
  let target = newRectNode(vec2(50, 50))
  target.localPos = vec2(10, 10)
  target.updateGlobalTransform()
  
  tooltip.show(target, viewportSize, ctx)
  
  echo "Tooltip position after show: ", tooltip.localPos
  echo "Tooltip size: ", tooltip.size
  echo "Viewport size: ", viewportSize
  echo "tooltip.localPos.x >= 0: ", tooltip.localPos.x >= 0
  echo "tooltip.localPos.y >= 0: ", tooltip.localPos.y >= 0
  echo "Right edge: ", tooltip.localPos.x + tooltip.size.x, " <= ", viewportSize.x
  echo "Bottom edge: ", tooltip.localPos.y + tooltip.size.y, " <= ", viewportSize.y

main()
