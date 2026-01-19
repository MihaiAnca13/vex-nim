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

  let hierarchyRoot = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.12, 0.12, 0.18, 1.0)
  hierarchyRoot.fill = some(paintBg)

  let parent = newRectNode(vec2(300, 200))
  parent.localPos = vec2(100, 100)
  let paintParent = newPaint(SolidPaint)
  paintParent.color = color(0.2, 0.4, 0.7, 1.0)
  parent.fill = some(paintParent)

  let child = newRectNode(vec2(160, 100))
  child.localPos = vec2(70, 60)
  let paintChild = newPaint(SolidPaint)
  paintChild.color = color(0.2, 0.7, 0.4, 1.0)
  child.fill = some(paintChild)

  let grandchild = newRectNode(vec2(80, 50))
  grandchild.localPos = vec2(40, 25)
  let paintGrandchild = newPaint(SolidPaint)
  paintGrandchild.color = color(0.9, 0.8, 0.3, 1.0)
  grandchild.fill = some(paintGrandchild)

  child.addChild(grandchild)
  parent.addChild(child)
  hierarchyRoot.addChild(parent)

  echo "1. Rendering Node hierarchy..."
  renderToPng(hierarchyRoot, "test_types_hierarchy.png")

  let dirtyRoot = newRectNode(vec2(800, 600))
  let paintDirtyBg = newPaint(SolidPaint)
  paintDirtyBg.color = color(0.1, 0.1, 0.15, 1.0)
  dirtyRoot.fill = some(paintDirtyBg)

  let cleanNode = newRectNode(vec2(180, 100))
  cleanNode.localPos = vec2(100, 120)
  let paintClean = newPaint(SolidPaint)
  paintClean.color = color(0.2, 0.6, 0.9, 1.0)
  cleanNode.fill = some(paintClean)

  let dirtyNode = newRectNode(vec2(180, 100))
  dirtyNode.localPos = vec2(320, 120)
  let paintDirty = newPaint(SolidPaint)
  paintDirty.color = color(0.9, 0.3, 0.3, 1.0)
  dirtyNode.fill = some(paintDirty)
  dirtyNode.markDirty()

  dirtyRoot.addChild(cleanNode)
  dirtyRoot.addChild(dirtyNode)

  echo "2. Rendering dirty flag visualization..."
  renderToPng(dirtyRoot, "test_types_dirty.png")

  let visualsRoot = newRectNode(vec2(800, 600))
  let paintVisualsBg = newPaint(SolidPaint)
  paintVisualsBg.color = color(0.12, 0.12, 0.18, 1.0)
  visualsRoot.fill = some(paintVisualsBg)

  let leftNode = newRectNode(vec2(120, 120))
  leftNode.localPos = vec2(80, 380)
  let paintLeft = newPaint(SolidPaint)
  paintLeft.color = color(0.4, 0.7, 0.9, 1.0)
  leftNode.fill = some(paintLeft)

  let middleNode = newRectNode(vec2(160, 80))
  middleNode.localPos = vec2(260, 410)
  let paintMiddle = newPaint(SolidPaint)
  paintMiddle.color = color(0.9, 0.6, 0.3, 1.0)
  middleNode.fill = some(paintMiddle)

  let rightNode = newRectNode(vec2(100, 140))
  rightNode.localPos = vec2(480, 360)
  let paintRight = newPaint(SolidPaint)
  paintRight.color = color(0.6, 0.3, 0.8, 1.0)
  rightNode.fill = some(paintRight)

  visualsRoot.addChild(leftNode)
  visualsRoot.addChild(middleNode)
  visualsRoot.addChild(rightNode)

  echo "3. Rendering basic Node visuals..."
  renderToPng(visualsRoot, "test_types_visuals.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
