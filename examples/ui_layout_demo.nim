## UI Layout Demo - VEX Layout Containers
##
## Run with: nim r -p:src examples/ui_layout_demo.nim
##
## This example demonstrates:
## - HBox and VBox layout containers
## - TextNode auto-sizing with measure()
## - Nesting layouts
## - zIndex ordering

import vmath
import pixie
import windy
import vex

proc main() =
  let ctx = newRenderContext(vec2(800, 600))

  # Main container - vertical layout
  let vbox = newVBox(spacing = 16, padding = 20)
  vbox.localPos = vec2(100, 50)

  # Header - horizontal row of colored boxes
  let header = newHBox(spacing = 8)
  for i in 0..3:
    let box = newRectNode(vec2(40, 40))
    box.fill = some(color(0.2 + float32(i) * 0.15, 0.5, 0.8, 1))
    box.zIndex = i  # Different zIndex for demonstration
    header.addItem(box)
  vbox.addItem(header)

  # Content area - nested HBox with text
  let content = newHBox(spacing = 12, padding = 12)
  content.size = vec2(0, 120)  # Fixed height

  # Card 1
  let card1 = newVBox(spacing = 8, padding = 12)
  card1.fill = some(color(0.95, 0.95, 0.95, 1))
  let title1 = newTextNode("Card One", "tests/data/Roboto-Regular.ttf", 18)
  title1.color = color(0.1, 0.1, 0.1, 1)
  card1.addItem(title1)
  let desc1 = newTextNode("This is a description.", "tests/data/Roboto-Regular.ttf", 14)
  desc1.color = color(0.4, 0.4, 0.4, 1)
  card1.addItem(desc1)
  content.addItem(card1)

  # Card 2
  let card2 = newVBox(spacing = 8, padding = 12)
  card2.fill = some(color(0.95, 0.95, 0.95, 1))
  let title2 = newTextNode("Card Two", "tests/data/Roboto-Regular.ttf", 18)
  title2.color = color(0.1, 0.1, 0.1, 1)
  card2.addItem(title2)
  let desc2 = newTextNode("Another card here.", "tests/data/Roboto-Regular.ttf", 14)
  desc2.color = color(0.4, 0.4, 0.4, 1)
  card2.addItem(desc2)
  content.addItem(card2)

  vbox.addItem(content)

  # Footer - buttons in a row
  let footer = newHBox(spacing = 8)
  footer.localPos = vec2(0, 200)
  for i, label in ["Cancel", "OK", "Apply"]:
    let btn = newRectNode(vec2(80, 36))
    if i == 2:  # OK button
      btn.fill = some(color(0.2, 0.6, 0.3, 1))
    else:
      btn.fill = some(color(0.6, 0.6, 0.6, 1))
    footer.addItem(btn)
  vbox.addItem(footer)

  # Update layouts with context for text measurement
  header.update(ctx)
  vbox.update(ctx)

  window titled "VEX UI Layout Demo", vec2(800, 400):
    while true:
      pollEvents()
      ctx.resize(vec2(800, 400))
      ctx.beginFrame()
      ctx.draw(vbox)
      ctx.endFrame()
      swapBuffers()

when isMainModule:
  main()
