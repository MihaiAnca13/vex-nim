import std/options
import pixie
import vmath
import ../core/types
import ../core/transform
import ../layout/alignment

type
  RectNode* = ref object of Node
    fill*: Option[Paint]
    stroke*: Option[Paint]
    strokeWidth*: float32
    cornerRadius*: float32

  CircleNode* = ref object of Node
    fill*: Option[Paint]
    stroke*: Option[Paint]
    strokeWidth*: float32

proc newRectNode*(size: Vec2 = vec2(100, 100)): RectNode =
  RectNode(
    globalTransform: identityTransform,
    size: size,
    fill: none(Paint),
    stroke: none(Paint),
    strokeWidth: 1.0,
    cornerRadius: 0.0,
    visible: true,
    dirty: true,
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
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
    autoLayout: true
  )

proc newCircleNode*(size: Vec2 = vec2(100, 100)): CircleNode =
  CircleNode(
    globalTransform: identityTransform,
    size: size,
    fill: none(Paint),
    stroke: none(Paint),
    strokeWidth: 1.0,
    visible: true,
    dirty: true,
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
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
    autoLayout: true
  )

proc contains*(node: RectNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  localPoint.x >= 0 and localPoint.x < node.size.x and
  localPoint.y >= 0 and localPoint.y < node.size.y

proc contains*(node: CircleNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  let center = node.size / 2
  let radius = node.size.x / 2
  let dx = localPoint.x - center.x
  let dy = localPoint.y - center.y
  let dist2 = dx * dx + dy * dy
  let rad2 = radius * radius
  result = dist2 <= rad2

method draw*(node: RectNode, renderCtx: RenderContext, image: Image) =
  let ctx = newContext(image)

  if node.fill.isSome:
    try:
      ctx.fillStyle = node.fill.get()
      if node.cornerRadius > 0:
        ctx.fillRoundedRect(
          rect(vec2(0, 0), node.size),
          node.cornerRadius
        )
      else:
        ctx.fillRect(rect(vec2(0, 0), node.size))
    except PixieError:
      discard

  if node.stroke.isSome:
    try:
      ctx.strokeStyle = node.stroke.get()
      ctx.lineWidth = node.strokeWidth
      if node.cornerRadius > 0:
        ctx.strokeRoundedRect(
          rect(vec2(0, 0), node.size),
          node.cornerRadius
        )
      else:
        ctx.strokeRect(
          rect(vec2(0, 0), node.size)
        )
    except PixieError:
      discard

method draw*(node: CircleNode, renderCtx: RenderContext, image: Image) =
  let ctx = newContext(image)
  let radius = node.size.x / 2
  let center = node.size / 2

  if node.fill.isSome:
    try:
      ctx.fillStyle = node.fill.get()
      let path = newPath()
      path.circle(center.x, center.y, radius)
      ctx.fill(path)
    except PixieError:
      discard

  if node.stroke.isSome:
    try:
      ctx.strokeStyle = node.stroke.get()
      ctx.lineWidth = node.strokeWidth
      let path = newPath()
      path.circle(center.x, center.y, radius)
      ctx.stroke(path)
    except PixieError:
      discard
