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
import ./layout

## RenderContext re-export for convenience.
type
  RenderContext* = types.RenderContext

## Computes the intersection of two rectangles.
proc intersect*(a, b: Rect): Rect =
  let x = max(a.x, b.x)
  let y = max(a.y, b.y)
  let w = min(a.x + a.w, b.x + b.w) - x
  let h = min(a.y + a.h, b.y + b.h) - y
  if w > 0 and h > 0:
    Rect(x: x, y: y, w: w, h: h)
  else:
    Rect(x: 0, y: 0, w: 0, h: 0)

proc rectsOverlap(a, b: Rect): bool =
  a.x < b.x + b.w and
    a.x + a.w > b.x and
    a.y < b.y + b.h and
    a.y + a.h > b.y

proc computeClipRect(
  node: Node,
  clipRect: Option[Rect],
  globalBounds: Rect
): Option[Rect] =
  var effectiveClip = clipRect
  if node.clipChildren and node.size.x > 0 and node.size.y > 0:
    let nodeRect = rect(globalBounds.x, globalBounds.y, globalBounds.w, globalBounds.h)
    if effectiveClip.isSome:
      effectiveClip = some(intersect(effectiveClip.get(), nodeRect))
    else:
      effectiveClip = some(nodeRect)
  effectiveClip

proc shouldDrawNode(
  ctx: RenderContext,
  node: Node,
  clipRect: Option[Rect],
  globalBounds: Rect
): tuple[draw: bool, clip: Option[Rect]] =
  let viewportRect = rect(vec2(0.0'f32, 0.0'f32), ctx.viewportSize)
  let effectiveClip = computeClipRect(node, clipRect, globalBounds)

  if effectiveClip.isSome and not rectsOverlap(globalBounds, effectiveClip.get()):
    return (false, effectiveClip)

  if not rectsOverlap(globalBounds, viewportRect):
    return (false, effectiveClip)

  (true, effectiveClip)

## Creates a new RenderContext with the specified viewport size.
proc newRenderContext*(viewportSize: Vec2): RenderContext =
  RenderContext(
    bxy: newBoxy(),
    nodeTextures: initTable[Node, string](),
    imageCache: initTable[string, Image](),
    fontCache: initTable[string, Font](),
    nextNodeId: 0,
    viewportSize: viewportSize
  )

proc newHeadlessRenderContext*(viewportSize: Vec2): RenderContext =
  RenderContext(
    bxy: nil,
    nodeTextures: initTable[Node, string](),
    imageCache: initTable[string, Image](),
    fontCache: initTable[string, Font](),
    nextNodeId: 0,
    viewportSize: viewportSize
  )

## Checks if a texture with the given key exists.
proc contains*(ctx: RenderContext, key: string): bool =
  if ctx.imageCache.hasKey(key):
    return true
  if ctx.bxy.isNil:
    return false
  ctx.bxy.contains(key)

## Returns the size of an image by key.
proc getImageSize*(ctx: RenderContext, key: string): Vec2 =
  if ctx.imageCache.hasKey(key):
    let image = ctx.imageCache[key]
    return vec2(image.width.float32, image.height.float32)
  if ctx.bxy.isNil:
    return vec2(0, 0)
  let size = ctx.bxy.getImageSize(key)
  vec2(size.x.float32, size.y.float32)

## Returns a cached image by key.
##
## Raises KeyError if key not found.
proc getImage*(ctx: RenderContext, key: string): Image =
  ctx.imageCache[key]

## Returns a font, reading from disk if not cached.
##
## Fonts are cached after first load for performance.
proc getFont*(ctx: RenderContext, path: string): Font =
  if ctx.fontCache.hasKey(path):
    return ctx.fontCache[path]
  let font = readFont(path)
  ctx.fontCache[path] = font
  font

## Adds an image to the context cache and Boxy atlas.
proc addImage*(ctx: RenderContext, key: string, image: Image) =
  if not ctx.bxy.isNil:
    ctx.bxy.addImage(key, image)
  ctx.imageCache[key] = image

## Draws a cached image at the specified position.
proc drawImage*(ctx: RenderContext, key: string, pos: Vec2, tint: Color = color(1, 1, 1, 1)) =
  if ctx.bxy.isNil:
    return
  ctx.bxy.drawImage(key, pos, tint)

## Begins a new frame with the specified viewport size.
proc beginFrame*(ctx: RenderContext) =
  if ctx.bxy.isNil:
    return
  ctx.bxy.beginFrame(ctx.viewportSize.ivec2)

## Ends the current frame.
proc endFrame*(ctx: RenderContext) =
  if ctx.bxy.isNil:
    return
  ctx.bxy.endFrame()

## Rasterizes a node to an Image using Pixie.
##
## Creates a transparent image and calls node.draw() on it.
proc rasterizeNode*(ctx: RenderContext, node: Node): Image =
  let image = newImage(node.size.x.int, node.size.y.int)
  image.fill(rgba(0, 0, 0, 0))
  types.draw(node, ctx, image)
  image

## Ensures a node has a cached texture, rasterizing if dirty.
##
## Returns the texture key for the node.
proc cacheTexture*(ctx: RenderContext, node: Node): string =
  if ctx.bxy.isNil:
    return ""
  if node.dirty:
    if node.size.x <= 0 or node.size.y <= 0:
      node.measure(ctx)

    let key = if ctx.nodeTextures.hasKey(node):
      ctx.nodeTextures[node]
    else:
      let k = "node_" & $ctx.nextNodeId
      inc ctx.nextNodeId
      k

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

## Removes a node's cached texture from Boxy and the cache.
proc uncacheNode*(ctx: RenderContext, node: Node) =
  if ctx.bxy.isNil:
    return
  if ctx.nodeTextures.hasKey(node):
    let key = ctx.nodeTextures[node]
    ctx.bxy.removeImage(key)
    ctx.nodeTextures.del(node)

## Clears all cached textures.
proc invalidateNodeCache*(ctx: RenderContext, node: Node) =
  if ctx.bxy.isNil:
    ctx.nodeTextures.clear()
    ctx.nextNodeId = 0
    return
  for n, key in ctx.nodeTextures:
    ctx.bxy.removeImage(key)
  ctx.nodeTextures.clear()
  ctx.nextNodeId = 0

## Handles an input event by performing hit testing and dispatch.
##
## Returns true if an event handler consumed the event.
proc handleEvent*(ctx: RenderContext, root: Node, event: var types.InputEvent): bool =
  let hitResult = hitTest(root, event.position)
  if hitResult.isSome:
    event.target = hitResult.get().node
    discard dispatchEvent(hitResult.get().node, event)
    return true
  false

## Draws a single node and its children.
##
## Handles culling, texture caching, z-index sorting, and recursive rendering.
## When node.clipChildren is true, children are clipped to the node's bounds.
proc drawNode*(ctx: RenderContext, node: Node, clipRect: Option[Rect] = none(Rect)) =
  if not node.visible:
    return

  let globalBounds = node.getGlobalBounds()
  let (shouldDraw, effectiveClip) = ctx.shouldDrawNode(node, clipRect, globalBounds)
  if not shouldDraw:
    return

  let key = ctx.cacheTexture(node)
  ctx.bxy.saveTransform()
  ctx.bxy.setTransform(node.globalTransform)
  ctx.bxy.drawImage(key, vec2(0, 0))
  ctx.bxy.restoreTransform()

  if not node.childrenSorted:
    node.children.sort(proc(a, b: Node): int = a.zIndex - b.zIndex)
    node.childrenSorted = true

  for child in node.children:
    ctx.drawNode(child, effectiveClip)

## Renders the entire scene graph.
proc draw*(ctx: RenderContext, root: Node) =
  if ctx.bxy.isNil:
    return
  ctx.beginFrame()
  if not root.layoutValid:
    root.layoutNode(ctx.viewportSize, true)
  root.updateGlobalTransform()
  ctx.drawNode(root, none(Rect))
  ctx.endFrame()

## Updates the viewport size and invalidates layout.
proc resize*(ctx: RenderContext, newSize: Vec2) =
  ctx.viewportSize = newSize

## Lays out the scene graph for the current viewport size.
proc layout*(ctx: RenderContext, root: Node) =
  if not root.layoutValid:
    root.layoutNode(ctx.viewportSize, true)

proc drawNodeToImage(
  ctx: RenderContext,
  node: Node,
  target: Image,
  clipRect: Option[Rect]
) =
  if not node.visible:
    return

  let globalBounds = node.getGlobalBounds()
  let (shouldDraw, effectiveClip) = ctx.shouldDrawNode(node, clipRect, globalBounds)
  if not shouldDraw:
    return

  if node.size.x <= 0 or node.size.y <= 0:
    node.measure(ctx)

  if node.size.x > 0 and node.size.y > 0:
    let image = ctx.rasterizeNode(node)
    try:
      target.draw(image, node.globalTransform, NormalBlend)
    except PixieError:
      discard

  if not node.childrenSorted:
    node.children.sort(proc(a, b: Node): int = a.zIndex - b.zIndex)
    node.childrenSorted = true

  for child in node.children:
    ctx.drawNodeToImage(child, target, effectiveClip)

proc renderToImage*(ctx: RenderContext, root: Node): Image =
  let width = max(ctx.viewportSize.x.int, 1)
  let height = max(ctx.viewportSize.y.int, 1)
  let image = newImage(width, height)
  image.fill(rgba(0, 0, 0, 0))

  if not root.layoutValid:
    root.layoutNode(ctx.viewportSize, true)
  root.updateGlobalTransform()
  ctx.drawNodeToImage(root, image, none(Rect))
  image

## Reads the current atlas as an image.
proc readAtlas*(ctx: RenderContext): Image =
  if ctx.bxy.isNil:
    return newImage(1, 1)
  ctx.bxy.readAtlas()
