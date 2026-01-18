import std/os
import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for primitive.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.15, 0.15, 0.2, 1.0)
  bg.fill = some(paintBg)

  let rect1 = newRectNode(vec2(150, 100))
  rect1.localPos = vec2(50, 50)
  let paint1 = newPaint(SolidPaint)
  paint1.color = color(0.2, 0.6, 0.9, 1.0)
  rect1.fill = some(paint1)

  let rect2 = newRectNode(vec2(150, 100))
  rect2.localPos = vec2(250, 50)
  rect2.cornerRadius = 20
  let paint2 = newPaint(SolidPaint)
  paint2.color = color(0.9, 0.4, 0.2, 1.0)
  rect2.fill = some(paint2)
  rect2.stroke = some(paint2)
  rect2.strokeWidth = 4

  let circle1 = newCircleNode(vec2(100, 100))
  circle1.localPos = vec2(500, 50)
  let paint3 = newPaint(SolidPaint)
  paint3.color = color(0.3, 0.8, 0.3, 1.0)
  circle1.fill = some(paint3)

  let circle2 = newCircleNode(vec2(100, 100))
  circle2.localPos = vec2(650, 50)
  let paint4 = newPaint(SolidPaint)
  paint4.color = color(0.0, 0.0, 0.0, 0.0)
  circle2.fill = some(paint4)
  circle2.stroke = some(paint3)
  circle2.strokeWidth = 5

  bg.addChild(rect1)
  bg.addChild(rect2)
  bg.addChild(circle1)
  bg.addChild(circle2)

  echo "1. Rendering RectNode and CircleNode examples..."
  renderToPng(bg, "test_primitive_visuals.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
