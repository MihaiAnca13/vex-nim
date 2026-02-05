## Responsive UI Demo - VEX Resize Handling
##
## Run with: nim r -p:src examples/responsive_demo.nim
##
## This example demonstrates:
## - Resize callbacks for responsive UI
## - Automatic layout invalidation on window resize
## - Dynamic UI adaptation to viewport changes

import vmath
import pixie
import windy
import vex

proc main() =
  let ctx = newRenderContext(vec2(800, 600))

  var currentSize = vec2(800, 600)

  let root = newVBox(spacing = 16, padding = 20)
  root.clipChildren = true

  let header = newHBox(spacing = 8)
  header.name = "header"
  header.anchor = TopCenter
  header.anchorOffset = vec2(0, 20)

  let headerBg = newRectNode(vec2(400, 50))
  headerBg.fill = some(color(0.2, 0.4, 0.8, 1))
  headerBg.anchor = TopCenter
  headerBg.anchorOffset = vec2(0, 20)
  headerBg.zIndex = -1
  header.addItem(headerBg)

  let title = newTextNode("Responsive Demo", "tests/data/Roboto-Regular.ttf", 24)
  title.color = color(1, 1, 1, 1)
  header.addItem(title)
  root.addItem(header)

  let content = newVBox(spacing = 12, padding = 16)
  content.fill = some(color(0.95, 0.95, 0.95, 1))
  content.clipChildren = true
  root.addItem(content)

  let infoText = newTextNode("Resize the window to see the UI adapt", "tests/data/Roboto-Regular.ttf", 16)
  infoText.color = color(0.3, 0.3, 0.3, 1)
  infoText.maxWidth = 350
  content.addItem(infoText)

  let sizeLabel = newTextNode("Size: 800 x 600", "tests/data/Roboto-Regular.ttf", 14)
  sizeLabel.color = color(0.5, 0.5, 0.5, 1)
  content.addItem(sizeLabel)

  let cardsRow = newHBox(spacing = 12)
  cardsRow.fillWidth = true
  content.addItem(cardsRow)

  for i in 0..2:
    let card = newVBox(spacing = 8, padding = 12)
    card.fill = some(color(1, 1, 1, 1))
    card.stroke = some(solidPaint(color(0.8, 0.8, 0.8, 1)))
    card.strokeWidth = 1.0
    card.cornerRadius = 8.0
    card.sizePercent = vec2(1.0 / 3.0, 0)
    cardsRow.addItem(card)

    let cardTitle = newTextNode("Card " & $(i + 1), "tests/data/Roboto-Regular.ttf", 14)
    cardTitle.color = color(0.2, 0.2, 0.2, 1)
    card.addItem(cardTitle)

    let cardDesc = newTextNode("This card adapts to window width", "tests/data/Roboto-Regular.ttf", 12)
    cardDesc.color = color(0.5, 0.5, 0.5, 1)
    card.addItem(cardDesc)

  ctx.setRoot(root)

  ctx.onResize(proc(newSize: Vec2) =
    currentSize = newSize
    sizeLabel.text = "Size: " & $newSize.x.int & " x " & $newSize.y.int
    headerBg.size.x = newSize.x - 80
    headerBg.markDirty()
  )

  header.update(ctx)
  content.update(ctx)
  cardsRow.update(ctx)

  window titled "VEX Responsive Demo", vec2(800, 600):
    while true:
      pollEvents()
      let windowSize = window.size
      ctx.resize(vec2(windowSize.x.float32, windowSize.y.float32))
      ctx.beginFrame()
      ctx.draw(root)
      ctx.endFrame()
      swapBuffers()

when isMainModule:
  main()
