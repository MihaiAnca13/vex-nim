import std/os
import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/primitive
import ../src/vex/nodes/path
import ./golden_test_utils

proc renderPathSceneToPng*(root: Node, filename: string, width = 800, height = 600) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  root.updateGlobalTransform()

  for node in root.traverse():
    if node of PathNode:
      let pathNode = PathNode(node)
      let nodeImage = newImage(node.size.x.int, node.size.y.int)
      nodeImage.fill(rgba(0, 0, 0, 0))

      try:
        let path = parsePath(pathNode.pathData)

        let paint = if pathNode.fill.isSome: pathNode.fill.get() else: color(1, 1, 1, 1)
        nodeImage.fillPath(path, paint)

        if pathNode.stroke.isSome:
          nodeImage.strokePath(
            path,
            pathNode.stroke.get(),
            strokeWidth = pathNode.strokeWidth,
            lineCap = pathNode.strokeCap,
            lineJoin = pathNode.strokeJoin
          )
      except PixieError:
        discard

      let ctx = image.newContext()
      let globalBounds = node.getGlobalBounds()
      ctx.translate(globalBounds.x, globalBounds.y)
      ctx.drawImage(nodeImage, 0, 0, node.size.x, node.size.y)

  image.writeFile(filepath)
  echo "Rendered: ", filepath

proc main*() =
  echo "=== Golden Tests for path.nim ==="
  echo ""

  ensureGoldenDir()

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.15, 0.15, 0.2, 1.0)
  bg.fill = some(paintBg)

  let path1 = newHexNode(50.0)
  path1.localPos = vec2(100, 100)
  path1.size = vec2(100, 100)
  let paint1 = newPaint(SolidPaint)
  paint1.color = color(0.9, 0.3, 0.3, 1.0)
  path1.fill = some(paint1)

  let path2 = newPathNode("M 50 50 L 150 50 L 150 150 L 50 150 Z")
  path2.localPos = vec2(250, 100)
  path2.size = vec2(100, 100)
  let paint2 = newPaint(SolidPaint)
  paint2.color = color(0.3, 0.8, 0.3, 1.0)
  path2.fill = some(paint2)
  path2.stroke = some(paint2)
  path2.strokeWidth = 3

  let path3 = newPathNode("M 50 50 Q 100 0 150 50 T 150 150")
  path3.localPos = vec2(450, 100)
  path3.size = vec2(100, 100)
  let paint3 = newPaint(SolidPaint)
  paint3.color = color(0.0, 0.0, 0.0, 0.0)
  path3.fill = some(paint3)
  let paintStroke = newPaint(SolidPaint)
  paintStroke.color = color(0.3, 0.6, 0.9, 1.0)
  path3.stroke = some(paintStroke)
  path3.strokeWidth = 2

  let path4 = newHexNode(60.0)
  path4.localPos = vec2(100, 250)
  path4.size = vec2(120, 120)
  let paint4 = newPaint(SolidPaint)
  paint4.color = color(0.9, 0.6, 0.2, 1.0)
  path4.fill = some(paint4)
  path4.strokeCap = RoundCap

  let path5 = newPathNode("M 10 60 A 50 50 0 1 1 90 60 A 50 50 0 1 1 10 60")
  path5.localPos = vec2(300, 250)
  path5.size = vec2(100, 120)
  let paint5 = newPaint(SolidPaint)
  paint5.color = color(0.6, 0.3, 0.9, 0.8)
  path5.fill = some(paint5)

  bg.addChild(path1)
  bg.addChild(path2)
  bg.addChild(path3)
  bg.addChild(path4)
  bg.addChild(path5)

  echo "1. Rendering PathNode examples..."
  renderPathSceneToPng(bg, "test_path_visuals.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
