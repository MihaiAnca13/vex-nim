## Hello World - VEX Basic Demo
##
## Run with: nim r -p:src examples/hello_world.nim
##
## This example demonstrates:
## - Creating a simple scene with shapes and text
## - Basic rendering pipeline
## - Using VEX with windy for windowing

import vmath
import pixie
import windy
import vex

proc main() =
  # Create a render context for 800x600 viewport
  let ctx = newRenderContext(vec2(800, 600))

  # Create the scene graph
  let root = newNode()

  # Create a red rectangle
  let rect = newRectNode(vec2(200, 100))
  rect.fill = some(color(0.9, 0.2, 0.2, 1))
  rect.stroke = some(color(0.1, 0.1, 0.1, 1))
  rect.strokeWidth = 2
  rect.localPos = vec2(50, 50)
  root.addChild(rect)

  # Create a circle
  let circle = newCircleNode(vec2(80, 80))
  circle.fill = some(color(0.2, 0.6, 0.9, 1))
  circle.localPos = vec2(300, 60)
  root.addChild(circle)

  # Create a text node
  let text = newTextNode("Hello VEX!", "tests/data/Roboto-Regular.ttf", 24)
  text.color = color(0.1, 0.1, 0.1, 1)
  text.localPos = vec2(50, 170)
  root.addChild(text)

  # Window and render loop
  window titled "VEX Hello World", vec2(800, 600):
    while true:
      pollEvents()
      ctx.resize(vec2(800, 600))
      ctx.beginFrame()
      ctx.draw(root)
      ctx.endFrame()
      swapBuffers()

when isMainModule:
  main()
