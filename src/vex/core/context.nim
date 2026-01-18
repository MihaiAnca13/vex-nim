import std/tables
import bumpy
import boxy
import pixie
import vmath
import ./types
import ./transform

type
  RenderContext* = ref object
    bxy*: Boxy
    nodeTextures: Table[Node, string]
    nextNodeId: int
    viewportSize*: Vec2

proc newRenderContext*(viewportSize: Vec2): RenderContext =
  RenderContext(
    bxy: newBoxy(),
    nodeTextures: initTable[Node, string](),
    nextNodeId: 0,
    viewportSize: viewportSize
  )

proc contains*(ctx: RenderContext, key: string): bool =
  ctx.bxy.contains(key)

proc getImageSize*(ctx: RenderContext, key: string): Vec2 =
  let size = ctx.bxy.getImageSize(key)
  vec2(size.x.float32, size.y.float32)

proc addImage*(ctx: RenderContext, key: string, image: Image) =
  ctx.bxy.addImage(key, image)

proc drawImage*(ctx: RenderContext, key: string, pos: Vec2, tint: Color = color(1, 1, 1, 1)) =
  ctx.bxy.drawImage(key, pos, tint)

proc beginFrame*(ctx: RenderContext) =
  ctx.bxy.beginFrame(ctx.viewportSize.ivec2)

proc endFrame*(ctx: RenderContext) =
  ctx.bxy.endFrame()

proc rasterizeNode*(node: Node): Image =
  result = newImage(node.size.x.int, node.size.y.int)
  result.fill(rgba(0, 0, 0, 0))

proc cacheTexture*(ctx: RenderContext, node: Node): string =
  let key = "node_" & $ctx.nextNodeId
  inc ctx.nextNodeId

  if node.size.x > 0 and node.size.y > 0:
    let image = rasterizeNode(node)
    ctx.bxy.addImage(key, image)
  else:
    ctx.bxy.addImage(key, newImage(1, 1))

  ctx.nodeTextures[node] = key
  key

proc invalidateNodeCache*(ctx: RenderContext, node: Node) =
  for n, key in ctx.nodeTextures:
    ctx.bxy.removeImage(key)
  ctx.nodeTextures.clear()
  ctx.nextNodeId = 0

proc drawNode*(ctx: RenderContext, node: Node) =
  if not node.visible:
    return

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
