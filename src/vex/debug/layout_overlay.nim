import std/options
import vmath
import pixie
import ../core/types
import ../layout/alignment
import ../layout/container

type
  DebugOverlay* = ref object of Node
    enabled*: bool
    showBounds*: bool
    showAnchors*: bool
    showLayoutInfo*: bool
    showClipRegions*: bool
    showHierarchy*: bool
    targetNode*: Option[Node]

proc newDebugOverlay*(): DebugOverlay =
  DebugOverlay(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "DebugOverlay",
    size: vec2(0, 0),
    zIndex: 99999,
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
    autoLayout: false,
    enabled: true,
    showBounds: true,
    showAnchors: false,
    showLayoutInfo: false,
    showClipRegions: false,
    showHierarchy: false,
    targetNode: none(Node)
  )

proc getDebugColor*(node: Node): Color =
  if node of HBox or node of VBox:
    color(1, 1, 0, 1)
  elif node.clipChildren:
    color(1, 0, 0, 1)
  else:
    color(0, 1, 0, 1)

proc drawDebugBounds*(overlay: DebugOverlay, ctx: RenderContext, image: Image, node: Node) =
  if not overlay.showBounds:
    return

  let paint = newPaint(SolidPaint)
  paint.color = node.getDebugColor()
  paint.opacity = 0.8

  let strokePaint = newPaint(SolidPaint)
  strokePaint.color = color(1, 1, 1, 0.9)

  let renderCtx = newContext(image)

  renderCtx.fillStyle = paint
  renderCtx.strokeStyle = strokePaint
  renderCtx.lineWidth = 1.0

  let localRect = rect(vec2(0, 0), node.size)
  renderCtx.strokeRect(localRect)

proc drawDebugAnchor*(overlay: DebugOverlay, ctx: RenderContext, image: Image, node: Node) =
  if not overlay.showAnchors:
    return

  let paint = newPaint(SolidPaint)
  paint.color = color(0, 0, 1, 1)

  let renderCtx = newContext(image)

  renderCtx.fillStyle = paint
  let anchorOffset = getAnchorOffset(node.anchor)
  let center = node.size * anchorOffset
  let circle = newPath()
  circle.circle(center.x, center.y, 4.0)
  renderCtx.fill(circle)

proc drawDebugClipRegion*(overlay: DebugOverlay, ctx: RenderContext, image: Image, node: Node) =
  if not overlay.showClipRegions or not node.clipChildren:
    return

  let paint = newPaint(SolidPaint)
  paint.color = color(1, 0, 0, 0.2)

  let strokePaint = newPaint(SolidPaint)
  strokePaint.color = color(1, 0, 0, 1)

  let renderCtx = newContext(image)

  renderCtx.fillStyle = paint
  renderCtx.strokeStyle = strokePaint
  renderCtx.lineWidth = 2.0

  let localRect = rect(vec2(0, 0), node.size)
  renderCtx.fillRect(localRect)
  renderCtx.strokeRect(localRect)

proc drawDebugNode*(overlay: DebugOverlay, ctx: RenderContext, image: Image, node: Node) =
  overlay.drawDebugClipRegion(ctx, image, node)
  overlay.drawDebugBounds(ctx, image, node)
  overlay.drawDebugAnchor(ctx, image, node)

  for child in node.children:
    overlay.drawDebugNode(ctx, image, child)

method draw*(overlay: DebugOverlay, renderCtx: RenderContext, image: Image) =
  if not overlay.enabled:
    return

  let target = if overlay.targetNode.isSome: overlay.targetNode.get() else: overlay

  for node in target.traverse:
    overlay.drawDebugNode(renderCtx, image, node)

proc setEnabled*(overlay: DebugOverlay, enabled: bool) =
  overlay.enabled = enabled
  overlay.markDirty()

proc setShowBounds*(overlay: DebugOverlay, show: bool) =
  overlay.showBounds = show
  overlay.markDirty()

proc setShowAnchors*(overlay: DebugOverlay, show: bool) =
  overlay.showAnchors = show
  overlay.markDirty()

proc setShowLayoutInfo*(overlay: DebugOverlay, show: bool) =
  overlay.showLayoutInfo = show
  overlay.markDirty()

proc setShowClipRegions*(overlay: DebugOverlay, show: bool) =
  overlay.showClipRegions = show
  overlay.markDirty()

proc setShowHierarchy*(overlay: DebugOverlay, show: bool) =
  overlay.showHierarchy = show
  overlay.markDirty()

proc setTargetNode*(overlay: DebugOverlay, node: Node) =
  overlay.targetNode = some(node)
  overlay.markDirty()

proc toggle*(overlay: DebugOverlay) =
  overlay.enabled = not overlay.enabled
  overlay.markDirty()
