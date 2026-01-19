import std/tables
import std/options
import std/algorithm
import bumpy
import boxy
import pixie
import vmath
import ./types
import ./transform
import ./events

type
  RenderContext* = types.RenderContext

proc newRenderContext*(viewportSize: Vec2): RenderContext =
  RenderContext(
    bxy: newBoxy(),
    nodeTextures: initTable[Node, string](),
    imageCache: initTable[string, Image](),
    fontCache: initTable[string, Font](),
    nextNodeId: 0,
    viewportSize: viewportSize
  )

proc contains*(ctx: RenderContext, key: string): bool =
  ctx.bxy.contains(key)

proc getImageSize*(ctx: RenderContext, key: string): Vec2 =
  let size = ctx.bxy.getImageSize(key)
  vec2(size.x.float32, size.y.float32)

proc getImage*(ctx: RenderContext, key: string): Image =
  ctx.imageCache[key]

proc getFont*(ctx: RenderContext, path: string): Font =
  if ctx.fontCache.hasKey(path):
    return ctx.fontCache[path]
  let font = readFont(path)
  ctx.fontCache[path] = font
  font

proc addImage*(ctx: RenderContext, key: string, image: Image) =
  ctx.bxy.addImage(key, image)
  ctx.imageCache[key] = image

proc drawImage*(ctx: RenderContext, key: string, pos: Vec2, tint: Color = color(1, 1, 1, 1)) =
  ctx.bxy.drawImage(key, pos, tint)

proc beginFrame*(ctx: RenderContext) =
  ctx.bxy.beginFrame(ctx.viewportSize.ivec2)

proc endFrame*(ctx: RenderContext) =
  ctx.bxy.endFrame()

proc rasterizeNode*(ctx: RenderContext, node: Node): Image =
  let image = newImage(node.size.x.int, node.size.y.int)
  image.fill(rgba(0, 0, 0, 0))
  types.draw(node, ctx, image)
  image

proc cacheTexture*(ctx: RenderContext, node: Node): string =
  if node.dirty:
    let key = "node_" & $ctx.nextNodeId
    inc ctx.nextNodeId

    if node.size.x > 0 and node.size.y > 0:
      let image = ctx.rasterizeNode(node)
      ctx.bxy.addImage(key, image)
    else:
      ctx.bxy.addImage(key, newImage(1, 1))

    ctx.nodeTextures[node] = key
    node.dirty = false
    return key

  if ctx.nodeTextures.hasKey(node):
    return ctx.nodeTextures[node]

  let key = "node_" & $ctx.nextNodeId
  inc ctx.nextNodeId
  ctx.bxy.addImage(key, newImage(1, 1))
  ctx.nodeTextures[node] = key
  key

proc uncacheNode*(ctx: RenderContext, node: Node) =
  if ctx.nodeTextures.hasKey(node):
    let key = ctx.nodeTextures[node]
    ctx.bxy.removeImage(key)
    ctx.nodeTextures.del(node)

proc invalidateNodeCache*(ctx: RenderContext, node: Node) =
  for n, key in ctx.nodeTextures:
    ctx.bxy.removeImage(key)
  ctx.nodeTextures.clear()
  ctx.nextNodeId = 0

proc handleEvent*(ctx: RenderContext, root: Node, event: var types.InputEvent): bool =
  let hitResult = hitTest(root, event.position)
  if hitResult.isSome:
    event.target = hitResult.get().node
    discard dispatchEvent(hitResult.get().node, event)
    return true
  false

proc drawNode*(ctx: RenderContext, node: Node) =
  if not node.visible:
    return

  node.updateGlobalTransform()

  let globalBounds = node.getGlobalBounds()

  let viewportRect = rect(vec2(0.0'f32, 0.0'f32), ctx.viewportSize)

  if not (
    globalBounds.x < viewportRect.x + viewportRect.w and
    globalBounds.x + globalBounds.w > viewportRect.x and
    globalBounds.y < viewportRect.y + viewportRect.h and
    globalBounds.y + globalBounds.h > viewportRect.y
  ):
    return

  let key = ctx.cacheTexture(node)
  let pos = globalBounds.xy

  ctx.bxy.drawImage(key, pos)

  node.children = sorted(node.children, proc(a, b: Node): int = a.zIndex - b.zIndex)

  for child in node.children:
    ctx.drawNode(child)

proc draw*(ctx: RenderContext, root: Node) =
  ctx.beginFrame()
  ctx.drawNode(root)
  ctx.endFrame()

proc resize*(ctx: RenderContext, newSize: Vec2) =
  ctx.viewportSize = newSize

proc readAtlas*(ctx: RenderContext): Image =
  ctx.bxy.readAtlas()
