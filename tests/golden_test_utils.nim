import std/[os]
import vmath
import pixie

import ../src/vex/core/types

const goldenDir* = currentSourcePath.parentDir() / "golden"

proc ensureGoldenDir*() =
  if not goldenDir.dirExists():
    goldenDir.createDir()

proc renderToPng*(
  node: Node,
  filename: string,
  renderCtx: RenderContext = nil,
  width = 800,
  height = 600
) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  node.updateGlobalTransform()

  let canvas = image.newContext()
  for child in node.traverse():
    if not child.visible:
      continue
    if child.size.x <= 0 or child.size.y <= 0:
      continue
    let nodeImage = newImage(child.size.x.int, child.size.y.int)
    nodeImage.fill(rgba(0, 0, 0, 0))
    child.draw(renderCtx, nodeImage)

    canvas.save()
    canvas.setTransform(child.globalTransform)
    canvas.drawImage(nodeImage, 0, 0, child.size.x, child.size.y)
    canvas.restore()

  image.writeFile(filepath)
  echo "Rendered: ", filepath

proc renderSpriteSceneToPng*(srcImage: Image, root: Node, filename: string, width = 800, height = 600) =
  ensureGoldenDir()
  let filepath = goldenDir / filename

  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  root.updateGlobalTransform()
  let ctx = image.newContext()

  for node in root.traverse():
    let nodeImage = newImage(node.size.x.int, node.size.y.int)
    nodeImage.fill(rgba(0, 0, 0, 0))

    let nodeCtx = nodeImage.newContext()
    nodeCtx.drawImage(srcImage, 0, 0, min(srcImage.width.float32, node.size.x), min(srcImage.height.float32, node.size.y))

    ctx.save()
    ctx.setTransform(node.globalTransform)
    ctx.drawImage(nodeImage, 0, 0, node.size.x, node.size.y)
    ctx.restore()

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
