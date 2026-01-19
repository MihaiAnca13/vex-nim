import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for transform.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.1, 0.1, 0.15, 1.0)
  bg.fill = some(paintBg)

  let root = newRectNode(vec2(200, 200))
  root.localPos = vec2(100, 100)
  let paint1 = newPaint(SolidPaint)
  paint1.color = color(0.2, 0.5, 0.8, 1.0)
  root.fill = some(paint1)
  root.updateGlobalTransform()

  let rotated = newRectNode(vec2(150, 150))
  rotated.localPos = vec2(400, 100)
  rotated.localRotation = 0.785
  let paint2 = newPaint(SolidPaint)
  paint2.color = color(0.9, 0.3, 0.2, 1.0)
  rotated.fill = some(paint2)
  rotated.updateGlobalTransform()

  let scaled = newRectNode(vec2(200, 200))
  scaled.localPos = vec2(100, 350)
  scaled.localScale = vec2(0.5, 0.5)
  let paint3 = newPaint(SolidPaint)
  paint3.color = color(0.2, 0.8, 0.4, 1.0)
  scaled.fill = some(paint3)
  scaled.updateGlobalTransform()

  bg.addChild(root)
  bg.addChild(rotated)
  bg.addChild(scaled)

  echo "1. Rendering transform examples (normal, rotated, scaled)..."
  renderToPng(bg, "test_transform_visualization.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
