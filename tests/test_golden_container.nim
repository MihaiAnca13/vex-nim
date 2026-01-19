import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ../src/vex/layout/container
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for container.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.12, 0.12, 0.18, 1.0)
  bg.fill = some(paintBg)

  let hbox = newHBox(spacing = 8.0, padding = 12.0)
  hbox.localPos = vec2(50, 50)

  for i in 0..4:
    let child = newRectNode(vec2(60, 60))
    let paint = newPaint(SolidPaint)
    paint.color = color(0.3 + float32(i) * 0.1, 0.5, 0.8, 1.0)
    child.fill = some(paint)
    hbox.addItem(child)

  hbox.update()

  let vbox = newVBox(spacing = 8.0, padding = 12.0)
  vbox.localPos = vec2(400, 50)

  for i in 0..4:
    let child = newRectNode(vec2(120, 40))
    let paint = newPaint(SolidPaint)
    paint.color = color(0.8, 0.3 + float32(i) * 0.1, 0.4, 1.0)
    child.fill = some(paint)
    vbox.addItem(child)

  vbox.update()

  bg.addChild(hbox)
  bg.addChild(vbox)

  echo "1. Rendering HBox and VBox layouts..."
  renderToPng(bg, "test_container_layout.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
