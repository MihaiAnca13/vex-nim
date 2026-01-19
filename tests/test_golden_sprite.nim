import std/os
import std/options
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/core/context
import ../src/vex/core/transform
import ../src/vex/nodes/primitive
import ../src/vex/nodes/sprite
import ./golden_test_utils

proc main*() =
  echo "=== Golden Tests for sprite.nim ==="
  echo ""

  ensureGoldenDir()

  let testImage = newImage(200, 200)
  let paint = newPaint(SolidPaint)
  paint.color = color(0.9, 0.3, 0.3, 1.0)
  testImage.fill(paint)

  let bg = newRectNode(vec2(800, 600))
  let paintBg = newPaint(SolidPaint)
  paintBg.color = color(0.15, 0.15, 0.2, 1.0)
  bg.fill = some(paintBg)

  let sprite1 = newSpriteNode("test_image", vec2(100, 100))
  sprite1.localPos = vec2(50, 50)

  let sprite2 = newSpriteNode("test_image", vec2(150, 100))
  sprite2.localPos = vec2(200, 50)

  let sprite3 = newSpriteNodeWithSlice("test_image", vec2(150, 150), vec4(20, 20, 20, 20))
  sprite3.localPos = vec2(400, 50)

  bg.addChild(sprite1)
  bg.addChild(sprite2)
  bg.addChild(sprite3)

  echo "1. Rendering SpriteNode examples..."
  renderSpriteSceneToPng(testImage, bg, "test_sprite_visuals.png")

  echo ""
  echo "Golden images saved to: ", goldenDir
  echo "Review these images manually and commit if satisfied."

when isMainModule:
  main()
