import std/[options, tables]
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ../src/vex/nodes/sprite
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for sprite.nim ==="
  echo ""

  ensureGoldenDir()

  let testImage = newImage(200, 200)
  let imgCtx = testImage.newContext()
  imgCtx.fillStyle = color(0.15, 0.15, 0.15, 1.0)
  imgCtx.fillRect(rect(0, 0, 200, 200))
  imgCtx.fillStyle = color(0.9, 0.3, 0.3, 1.0)
  imgCtx.fillRect(rect(20, 20, 160, 160))
  imgCtx.fillStyle = color(0.9, 0.9, 0.2, 1.0)
  imgCtx.fillRect(rect(0, 0, 20, 20))
  imgCtx.fillRect(rect(180, 0, 20, 20))
  imgCtx.fillRect(rect(0, 180, 20, 20))
  imgCtx.fillRect(rect(180, 180, 20, 20))

  let renderCtx = RenderContext(
    bxy: nil,
    nodeTextures: initTable[Node, string](),
    imageCache: initTable[string, Image](),
    fontCache: initTable[string, Font](),
    nextNodeId: 0,
    viewportSize: vec2(0, 0)
  )
  renderCtx.imageCache["test_image"] = testImage

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.12, 0.12, 0.18, 1.0)
  bg.fill = some(paintBg)

  let sprite1 = newSpriteNode("test_image", vec2(100, 100))
  sprite1.localPos = vec2(50, 50)

  let sprite2 = newSpriteNode("test_image", vec2(150, 100))
  sprite2.localPos = vec2(200, 50)

  let sprite3 = newSpriteNodeWithSlice("test_image", vec2(240, 140), vec4(20, 20, 20, 20))
  sprite3.localPos = vec2(400, 50)

  bg.addChild(sprite1)
  bg.addChild(sprite2)
  bg.addChild(sprite3)

  echo "1. Rendering SpriteNode examples..."
  renderToPng(bg, "test_sprite_visuals.png", renderCtx)

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
