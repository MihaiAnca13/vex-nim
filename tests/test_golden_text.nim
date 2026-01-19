import std/os
import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/primitive
import ../src/vex/nodes/text
import ./golden_test_utils

proc renderTextSceneToPng*(fontPath: string, root: Node, filename: string, width = 800, height = 600) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  root.updateGlobalTransform()

  var font = readFont(fontPath)

  for node in root.traverse():
    if node of TextNode:
      let textNode = TextNode(node)
      let nodeImage = newImage(node.size.x.int, node.size.y.int)
      nodeImage.fill(rgba(0, 0, 0, 0))

      font.size = textNode.fontSize
      font.paint.color = textNode.color

      let bounds = if textNode.maxWidth > 0: vec2(textNode.maxWidth, node.size.y) else: vec2(node.size.x, node.size.y)
      let arrangement = font.typeset(textNode.text, bounds)

      let layout = arrangement.layoutBounds()
      let textWidth = layout.x
      let textHeight = layout.y

      let xOffset = case textNode.horizontalAlign
        of AlignLeft: 0.0
        of AlignCenter: max(0.0, (node.size.x - textWidth) / 2)
        of AlignRight: max(0.0, node.size.x - textWidth)

      let yOffset = case textNode.verticalAlign
        of AlignTop: 0.0
        of AlignCenter: max(0.0, (node.size.y - textHeight) / 2)
        of AlignBottom: max(0.0, node.size.y - textHeight)

      nodeImage.fillText(arrangement, translate(vec2(xOffset, yOffset)))

      let ctx2 = image.newContext()
      let globalBounds = node.getGlobalBounds()
      ctx2.translate(globalBounds.x, globalBounds.y)
      ctx2.drawImage(nodeImage, 0, 0, node.size.x, node.size.y)

  image.writeFile(filepath)
  echo "Rendered: ", filepath

proc main*() =
  echo "=== Golden Tests for text.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.15, 0.15, 0.2, 1.0)
  bg.fill = some(paintBg)

  let fontPath = currentSourcePath.parentDir() / "data" / "DejaVuSans.ttf"

  if not fontPath.fileExists():
    echo "Warning: Font file not found at: ", fontPath
    echo "Skipping text golden tests"
    return

  let text1 = newTextNode("Hello, VEX!", fontPath, 24.0, color(1.0, 1.0, 1.0, 1.0))
  text1.localPos = vec2(50, 50)
  text1.size = vec2(200, 50)

  let text2 = newTextNode("Centered Text", fontPath, 32.0, color(0.3, 0.8, 0.3, 1.0))
  text2.localPos = vec2(300, 50)
  text2.size = vec2(300, 50)
  text2.horizontalAlign = AlignCenter

  let text3 = newTextNode("Right Aligned", fontPath, 28.0, color(0.9, 0.4, 0.2, 1.0))
  text3.localPos = vec2(50, 150)
  text3.size = vec2(400, 50)
  text3.horizontalAlign = AlignRight

  let text4 = newTextNode("Multi-line text that should wrap properly when it exceeds the max width setting.", fontPath, 16.0, color(0.6, 0.6, 0.9, 1.0))
  text4.localPos = vec2(50, 250)
  text4.size = vec2(300, 100)
  text4.maxWidth = 280.0
  text4.verticalAlign = AlignCenter

  bg.addChild(text1)
  bg.addChild(text2)
  bg.addChild(text3)
  bg.addChild(text4)

  echo "1. Rendering TextNode examples..."
  renderTextSceneToPng(fontPath, bg, "test_text_visuals.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
