import std/[options, math]
import pixie
import vmath
import ../core/types
import ../core/context
import ../core/transform

type
  SpriteNode* = ref object of Node
    imageKey*: string
    sourceRect*: Rect
    sliceInsets*: Vec4

proc newSpriteNode*(imageKey: string, size: Vec2 = vec2(100, 100)): SpriteNode =
  SpriteNode(
    globalTransform: identityTransform,
    size: size,
    imageKey: imageKey,
    sourceRect: rect(0, 0, 0, 0),
    sliceInsets: vec4(0, 0, 0, 0)
  )

proc newSpriteNodeWithSlice*(
  imageKey: string,
  size: Vec2,
  sliceInsets: Vec4
): SpriteNode =
  SpriteNode(
    globalTransform: identityTransform,
    size: size,
    imageKey: imageKey,
    sourceRect: rect(0, 0, 0, 0),
    sliceInsets: sliceInsets
  )

proc contains*(node: SpriteNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  localPoint.x >= 0 and localPoint.x < node.size.x and
  localPoint.y >= 0 and localPoint.y < node.size.y

proc draw9Slice(
  src: Image,
  dst: Image,
  insets: Vec4,
  srcSize: Vec2
) =
  let ctx = newContext(dst)
  ctx.fillStyle = color(1, 1, 1, 1)

  let left = insets.x
  let top = insets.y
  let right = insets.z
  let bottom = insets.w

  let centerWidth = srcSize.x - left - right
  let centerHeight = srcSize.y - top - bottom

  let dstCenterWidth = dst.width.float32 - left - right
  let dstCenterHeight = dst.height.float32 - top - bottom

  proc drawRegion(
    sx, sy, sw, sh: float32,
    dx, dy, dw, dh: float32
  ) =
    if sw > 0 and sh > 0 and dw > 0 and dh > 0:
      let sub = src.subImage(sx.int, sy.int, sw.int, sh.int)
      ctx.drawImage(sub, dx, dy, dw, dh)

  drawRegion(0, 0, left, top, 0, 0, left, top)
  drawRegion(left, 0, centerWidth, top, left, 0, dstCenterWidth, top)
  drawRegion(srcSize.x - right, 0, right, top, dst.width.float32 - right, 0, right, top)

  drawRegion(0, top, left, centerHeight, 0, top, left, dstCenterHeight)
  drawRegion(left, top, centerWidth, centerHeight, left, top, dstCenterWidth, dstCenterHeight)
  drawRegion(srcSize.x - right, top, right, centerHeight, dst.width.float32 - right, top, right, dstCenterHeight)

  drawRegion(0, srcSize.y - bottom, left, bottom, 0, dst.height.float32 - bottom, left, bottom)
  drawRegion(left, srcSize.y - bottom, centerWidth, bottom, left, dst.height.float32 - bottom, dstCenterWidth, bottom)
  drawRegion(srcSize.x - right, srcSize.y - bottom, right, bottom, dst.width.float32 - right, dst.height.float32 - bottom, right, bottom)

proc draw*(node: SpriteNode, renderCtx: context.RenderContext) =
  if not renderCtx.contains(node.imageKey):
    return

  let srcImage = renderCtx.getImage(node.imageKey)
  let srcSize = vec2(srcImage.width.float32, srcImage.height.float32)

  if node.sliceInsets == vec4(0, 0, 0, 0):
    let scaled = srcImage.resize(node.size.x.int, node.size.y.int)
    let key = "sprite_" & $cast[int](node)
    renderCtx.addImage(key, scaled)
    let globalPos = node.getWorldPosition()
    renderCtx.drawImage(key, globalPos)
  else:
    let dstImage = newImage(node.size.x.int, node.size.y.int)
    dstImage.fill(rgba(0, 0, 0, 0))
    draw9Slice(srcImage, dstImage, node.sliceInsets, srcSize)
    let key = "sprite_" & $cast[int](node)
    renderCtx.addImage(key, dstImage)
    let globalPos = node.getWorldPosition()
    renderCtx.drawImage(key, globalPos)
