import std/options
import pixie
import vmath
import ../core/types
import ../core/context
import ../core/transform

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
    cornerRadius: 0.0
  )

proc newCircleNode*(size: Vec2 = vec2(100, 100)): CircleNode =
  CircleNode(
    globalTransform: identityTransform,
    size: size,
    fill: none(Paint),
    stroke: none(Paint),
    strokeWidth: 1.0
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

proc draw*(node: RectNode, renderCtx: context.RenderContext) =
  let image = newImage(node.size.x.int, node.size.y.int)
  let ctx = newContext(image)

  if node.fill.isSome:
    ctx.fillStyle = node.fill.get()
    if node.cornerRadius > 0:
      ctx.fillRoundedRect(
        rect(vec2(0, 0), node.size),
        node.cornerRadius
      )
    else:
      ctx.fillRect(rect(vec2(0, 0), node.size))

  if node.stroke.isSome:
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

  let key = "rectnode_" & $cast[int](node)
  renderCtx.addImage(key, image)

  let globalPos = node.getWorldPosition()
  renderCtx.drawImage(key, globalPos)

proc draw*(node: CircleNode, renderCtx: context.RenderContext) =
  let image = newImage(node.size.x.int, node.size.y.int)
  let ctx = newContext(image)
  let radius = node.size.x / 2
  let center = node.size / 2

  if node.fill.isSome:
    ctx.fillStyle = node.fill.get()
    let path = newPath()
    path.circle(center.x, center.y, radius)
    ctx.fill(path)

  if node.stroke.isSome:
    ctx.strokeStyle = node.stroke.get()
    ctx.lineWidth = node.strokeWidth
    let path = newPath()
    path.circle(center.x, center.y, radius)
    ctx.stroke(path)

  let key = "circlenode_" & $cast[int](node)
  renderCtx.addImage(key, image)

  let globalPos = node.getWorldPosition()
  renderCtx.drawImage(key, globalPos)
