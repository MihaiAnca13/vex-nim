import std/options
import pixie
import vmath
import ../src/vex
import ../src/vex/nodes/button as btnModule
import ../src/vex/core/types as typesModule

const TestFontPath = "tests/data/DejaVuSans.ttf"

proc main() =
  let btn = newButton("Test", TestFontPath, size = vec2(100, 50))
  btn.localPos = vec2(10, 20)
  btn.updateGlobalTransform()
  
  echo "Button size: ", btn.size
  
  let point = vec2(105.0, 65.0)
  let localPoint = btn.globalToLocal(point)
  echo "\nGlobal point: ", point
  echo "Local point: ", localPoint
  
  echo "\nUsing btnModule.contains: ", btnModule.contains(btn, point)
  echo "Using types.contains: ", typesModule.contains(btn.Node, point)
  
  # Manual check
  echo "Manual check: ", localPoint.x >= 0 and localPoint.x < btn.size.x and localPoint.y >= 0 and localPoint.y < btn.size.y

main()
