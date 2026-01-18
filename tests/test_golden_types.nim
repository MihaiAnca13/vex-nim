import std/os
import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for types.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paint1 = newPaint(SolidPaint)
  paint1.color = color(0.1, 0.1, 0.15, 1.0)
  bg.fill = some(paint1)

  let childNodes1 = newRectNode(vec2(80, 80))
  let paint3 = newPaint(SolidPaint)
  paint3.color = color(0.9, 0.3, 0.2, 1.0)
  childNodes1.fill = some(paint3)

  let childNodes2 = newRectNode(vec2(80, 80))
  let paint4 = newPaint(SolidPaint)
  paint4.color = color(0.2, 0.8, 0.4, 1.0)
  childNodes2.fill = some(paint4)

  let parent = newRectNode(vec2(300, 200))
  parent.localPos = vec2(100, 100)
  let paint2 = newPaint(SolidPaint)
  paint2.color = color(0.2, 0.5, 0.8, 1.0)
  parent.fill = some(paint2)
  parent.addChild(childNodes1)
  parent.addChild(childNodes2)
  parent.updateGlobalTransform()

  childNodes1.localPos = vec2(20, 20)
  childNodes2.localPos = vec2(120, 60)

  bg.addChild(parent)

  echo "1. Rendering scene hierarchy..."
  renderToPng(bg, "test_types_hierarchy.png")

  echo ""
  echo "2. Rendering with dirty flag (dirty node highlighted)..."
  let subChild = newRectNode(vec2(80, 80))
  subChild.localPos = vec2(20, 20)
  let paint6 = newPaint(SolidPaint)
  paint6.color = color(0.9, 0.3, 0.2, 1.0)
  subChild.fill = some(paint6)
  subChild.dirty = true

  let parent2 = newRectNode(vec2(300, 200))
  parent2.localPos = vec2(100, 100)
  let paint5 = newPaint(SolidPaint)
  paint5.color = color(0.2, 0.5, 0.8, 1.0)
  parent2.fill = some(paint5)
  parent2.addChild(subChild)
  parent2.updateGlobalTransform()

  let bg2 = newRectNode(vec2(800, 600))
  let paint7 = newPaint(SolidPaint)
  paint7.color = color(0.1, 0.1, 0.15, 1.0)
  bg2.fill = some(paint7)
  bg2.addChild(parent2)

  renderToPng(bg2, "test_types_dirty.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
