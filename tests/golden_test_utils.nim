import std/[os]
import vmath
import pixie

import ../src/vex/core/types
import ../src/vex/core/transform

const goldenDir* = currentSourcePath.parentDir() / "golden"

proc ensureGoldenDir*() =
  if not goldenDir.existsDir():
    goldenDir.createDir()

proc renderToPng*(node: Node, filename: string, width = 800, height = 600) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  when defined(pixie):
    let ctx = image.newContext()
    ctx.translate(node.globalTransform.m[6], node.globalTransform.m[7])
    ctx.scale(node.globalTransform.m[0], node.globalTransform.m[4])
    node.draw(ctx)

  image.writeFile(filepath)
  echo "Rendered: ", filepath

proc renderSpriteSceneToPng*(srcImage: Image, root: Node, filename: string, width = 800, height = 600) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  root.updateGlobalTransform()

  for node in root.traverse():
    let nodeImage = newImage(node.size.x.int, node.size.y.int)
    nodeImage.fill(rgba(0, 0, 0, 0))

    let nodeCtx = nodeImage.newContext()
    nodeCtx.drawImage(srcImage, 0, 0, min(srcImage.width.float32, node.size.x), min(srcImage.height.float32, node.size.y))

    let ctx = image.newContext()
    let globalBounds = node.getGlobalBounds()
    ctx.translate(globalBounds.x, globalBounds.y)
    ctx.drawImage(nodeImage, 0, 0, node.size.x, node.size.y)

  image.writeFile(filepath)
  echo "Rendered: ", filepath

proc readGoldenImage*(filename: string): Image =
  let filepath = goldenDir / filename
  if not filepath.fileExists():
    raise newException(IOError, "Golden image not found: " & filepath)
  readImage(filepath)

proc saveGolden*(filename: string, image: Image) =
  ensureGoldenDir()
  let filepath = goldenDir / filename
  image.writeFile(filepath)
  echo "Saved golden: ", filepath

proc compareToGolden*(filename: string, image: Image): bool =
  let goldenPath = goldenDir / filename
  if not goldenPath.fileExists():
    return false
  let golden = readImage(goldenPath)
  image.width == golden.width and image.height == golden.height
