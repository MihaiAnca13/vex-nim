import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ../src/vex/nodes/path
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for context.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.12, 0.12, 0.17, 1.0)
  bg.fill = some(paintBg)

  let rect = newRectNode(vec2(200, 150))
  rect.localPos = vec2(100, 100)
  let paint1 = newPaint(SolidPaint)
  paint1.color = color(0.2, 0.5, 0.8, 1.0)
  rect.fill = some(paint1)

  let hex = newHexNode(60.0)
  hex.localPos = vec2(400, 120)
  let paint2 = newPaint(SolidPaint)
  paint2.color = color(0.8, 0.3, 0.5, 1.0)
  hex.fill = some(paint2)

  let circle = newCircleNode(vec2(100, 100))
  circle.localPos = vec2(600, 100)
  let paint3 = newPaint(SolidPaint)
  paint3.color = color(0.3, 0.8, 0.5, 1.0)
  circle.fill = some(paint3)

  bg.addChild(rect)
  bg.addChild(hex)
  bg.addChild(circle)

  echo "1. Rendering multiple node types (context rasterization test)..."
  renderToPng(bg, "test_context_rasterization.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
