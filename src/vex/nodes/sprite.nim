import pixie
import vmath
import ../core/types
import ../core/context
import ../core/transform
import ../layout/alignment

type
  SpriteNode* = ref object of Node
    imageKey*: string
    sourceRect*: Rect
    sliceInsets*: Vec4

proc newSpriteNode*(imageKey: string, size: Vec2 = vec2(100, 100)): SpriteNode =
  SpriteNode(
    globalTransform: identityTransform,
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    dirty: true,
    visible: true,
    name: "",
    zIndex: 0,
    clipChildren: false,
    childrenSorted: true,
    anchor: TopLeft,
    anchorOffset: vec2(0, 0),
    pivot: TopLeft,
    sizeMode: Absolute,
    sizePercent: vec2(1, 1),
    scaleMode: Stretch,
    minSize: vec2(0, 0),
    maxSize: vec2(0, 0),
    layoutValid: false,
    autoLayout: true,
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
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    dirty: true,
    visible: true,
    name: "",
    zIndex: 0,
    clipChildren: false,
    childrenSorted: true,
    anchor: TopLeft,
    anchorOffset: vec2(0, 0),
    pivot: TopLeft,
    sizeMode: Absolute,
    sizePercent: vec2(1, 1),
    scaleMode: Stretch,
    minSize: vec2(0, 0),
    maxSize: vec2(0, 0),
    layoutValid: false,
    autoLayout: true,
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

method draw*(node: SpriteNode, renderCtx: types.RenderContext, image: Image) =
  try:
    if not renderCtx.contains(node.imageKey):
      return

    let srcImage = renderCtx.getImage(node.imageKey)
    let srcSize = vec2(srcImage.width.float32, srcImage.height.float32)

    let useSourceRect = node.sourceRect.w > 0 and node.sourceRect.h > 0
    let use9Slice = node.sliceInsets != vec4(0, 0, 0, 0)

    if use9Slice:
      draw9Slice(srcImage, image, node.sliceInsets, srcSize)
    elif useSourceRect:
      let sub = srcImage.subImage(
        node.sourceRect.x.int,
        node.sourceRect.y.int,
        node.sourceRect.w.int,
        node.sourceRect.h.int
      )
      let scaled = sub.resize(image.width, image.height)
      let ctx = newContext(image)
      ctx.drawImage(scaled, 0, 0)
    else:
      let scaled = srcImage.resize(image.width, image.height)
      let ctx = newContext(image)
      ctx.drawImage(scaled, 0, 0)
  except KeyError, PixieError:
    discard
