import std/os
import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for events.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.1, 0.1, 0.15, 1.0)
  bg.fill = some(paintBg)

  let parent = newRectNode(vec2(400, 300))
  parent.localPos = vec2(200, 150)
  let paintParent = newPaint(SolidPaint)
  paintParent.color = color(0.2, 0.4, 0.6, 1.0)
  parent.fill = some(paintParent)

  let child1 = newRectNode(vec2(150, 100))
  child1.localPos = vec2(50, 50)
  let paintChild1 = newPaint(SolidPaint)
  paintChild1.color = color(0.2, 0.7, 0.4, 1.0)
  child1.fill = some(paintChild1)

  let child2 = newRectNode(vec2(150, 100))
  child2.localPos = vec2(200, 150)
  let paintChild2 = newPaint(SolidPaint)
  paintChild2.color = color(0.8, 0.3, 0.2, 1.0)
  child2.fill = some(paintChild2)

  parent.addChild(child1)
  parent.addChild(child2)

  let marker = newRectNode(vec2(20, 20))
  marker.localPos = vec2(250, 200)
  let paintMarker = newPaint(SolidPaint)
  paintMarker.color = color(1.0, 1.0, 0.0, 1.0)
  marker.fill = some(paintMarker)

  bg.addChild(parent)
  bg.addChild(marker)

  echo "1. Rendering hit test visualization..."
  echo "   Yellow marker at (260, 220) - inside child2"
  renderToPng(bg, "test_events_hit_test.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
