import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/primitive
import ../src/vex/layout/alignment
import ./golden_test_utils

proc renderAlignmentToPng*(root: Node, filename: string, width = 800, height = 600) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  root.updateGlobalTransform()

  for node in root.traverse():
    if node of RectNode:
      let nodeImage = newImage(node.size.x.int, node.size.y.int)
      nodeImage.fill(rgba(0, 0, 0, 0))

      let ctx = nodeImage.newContext()

      let rectNode = RectNode(node)

      if rectNode.fill.isSome:
        ctx.fillStyle = rectNode.fill.get()
        ctx.fillRect(rect(0, 0, node.size.x, node.size.y))

      if rectNode.stroke.isSome:
        ctx.strokeStyle = rectNode.stroke.get()
        ctx.lineWidth = rectNode.strokeWidth
        ctx.strokeRect(rect(0, 0, node.size.x, node.size.y))

      for anchor in Anchor:
        let offset = anchorPoint(node.size, anchor)
        ctx.fillStyle = color(1.0, 0.3, 0.3, 1.0)
        ctx.fillRect(rect(offset.x - 3, offset.y - 3, 6, 6))

      for pivot in Pivot:
        let offset = pivotPoint(node.size, pivot)
        ctx.fillStyle = color(0.3, 1.0, 0.3, 1.0)
        ctx.fillRect(rect(offset.x - 2, offset.y - 2, 4, 4))

      let ctx2 = image.newContext()
      let globalBounds = node.getGlobalBounds()
      ctx2.translate(globalBounds.x, globalBounds.y)
      ctx2.drawImage(nodeImage, 0, 0, node.size.x, node.size.y)

  image.writeFile(filepath)
  echo "Rendered: ", filepath

proc main*() =
  echo "=== Golden Tests for alignment.nim (Anchor, Pivot visuals) ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.15, 0.15, 0.2, 1.0)
  bg.fill = some(paintBg)

  let testBox = newRectNode(vec2(200, 200))
  testBox.localPos = vec2(300, 200)
  let paintBox = newPaint(SolidPaint)
  paintBox.color = color(0.3, 0.3, 0.4, 1.0)
  testBox.fill = some(paintBox)
  testBox.stroke = some(paintBox)
  testBox.strokeWidth = 2

  bg.addChild(testBox)

  echo "1. Rendering Anchor/Pivot visualization..."
  renderAlignmentToPng(bg, "test_alignment_visuals.png")

  echo ""
  echo "2. Testing anchor offsets calculation..."

  for anchor in Anchor:
    let offset = anchorOffsets[anchor]
    echo "  ", anchor, " = (", offset.x, ", ", offset.y, ")"

  echo ""
  echo "3. Testing pivot offsets calculation..."

  for pivot in Pivot:
    let offset = pivotOffsets[pivot]
    echo "  ", pivot, " = (", offset.x, ", ", offset.y, ")"

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
