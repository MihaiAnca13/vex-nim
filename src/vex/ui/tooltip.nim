import std/options
import pixie
import vmath
import ../core/types
import ../core/colors
import ../core/transform
import ../layout/alignment
import ../nodes/primitive
import ../nodes/text

type
  ## Preferred placement for a tooltip relative to its target.
  TooltipPosition* = enum
    TooltipAuto
    TooltipTop
    TooltipBottom
    TooltipLeft
    TooltipRight

  ## Floating tooltip node anchored to a target node.
  Tooltip* = ref object of Node
    contentNode*: TextNode
    bgNode*: RectNode
    targetNode*: Option[Node]
    position*: TooltipPosition
    offset*: float32
    maxWidth*: float32
    padding*: float32

const
  DefaultTooltipBg = color(0.15, 0.15, 0.18, 0.95)
  DefaultTooltipBorder = color(0.4, 0.4, 0.5, 1.0)
  DefaultTooltipText = color(0.9, 0.9, 0.9, 1.0)
  DefaultTooltipOffset = 8.0
  DefaultTooltipPadding = 8.0
  DefaultTooltipMaxWidth = 250.0

## Creates a tooltip with text content and placement policy.
proc newTooltip*(
  text: string,
  fontPath: string,
  fontSize: float32 = 13.0,
  position: TooltipPosition = TooltipAuto,
  maxWidth: float32 = DefaultTooltipMaxWidth
): Tooltip =
  let contentNode = newTextNode(text, fontPath, fontSize, DefaultTooltipText)
  contentNode.maxWidth = maxWidth - (DefaultTooltipPadding * 2)
  contentNode.horizontalAlign = AlignLeft
  
  let bgNode = newRectNode()
  bgNode.fill = some(solidPaint(DefaultTooltipBg))
  bgNode.stroke = some(solidPaint(DefaultTooltipBorder))
  bgNode.strokeWidth = 1.0
  bgNode.cornerRadius = 4.0
  
  Tooltip(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: false,
    name: "Tooltip",
    size: vec2(0, 0),
    zIndex: 1000,
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
    contentNode: contentNode,
    bgNode: bgNode,
    targetNode: none(Node),
    position: position,
    offset: DefaultTooltipOffset,
    maxWidth: maxWidth,
    padding: DefaultTooltipPadding
  )

## Measures text content and updates tooltip bounds.
proc measureTooltip*(tooltip: Tooltip, ctx: RenderContext) =
  tooltip.contentNode.measure(ctx)
  
  let contentWidth = min(tooltip.contentNode.size.x + tooltip.padding * 2, tooltip.maxWidth)
  let contentHeight = tooltip.contentNode.size.y + tooltip.padding * 2
  
  tooltip.size = vec2(contentWidth, contentHeight)
  tooltip.bgNode.size = tooltip.size
  tooltip.layoutValid = true

## Positions tooltip relative to the current target node.
proc updatePosition*(tooltip: Tooltip, viewportSize: Vec2) =
  if tooltip.targetNode.isNone:
    return
    
  let target = tooltip.targetNode.get()
  let targetGlobalPos = target.globalTransform * vec3(0, 0, 1)
  let targetPos = vec2(targetGlobalPos.x, targetGlobalPos.y)
  let targetSize = target.size
  
  var finalPos: Vec2
  
  case tooltip.position
  of TooltipTop:
    finalPos = vec2(
      targetPos.x + targetSize.x / 2 - tooltip.size.x / 2,
      targetPos.y - tooltip.size.y - tooltip.offset
    )
  of TooltipBottom:
    finalPos = vec2(
      targetPos.x + targetSize.x / 2 - tooltip.size.x / 2,
      targetPos.y + targetSize.y + tooltip.offset
    )
  of TooltipLeft:
    finalPos = vec2(
      targetPos.x - tooltip.size.x - tooltip.offset,
      targetPos.y + targetSize.y / 2 - tooltip.size.y / 2
    )
  of TooltipRight:
    finalPos = vec2(
      targetPos.x + targetSize.x + tooltip.offset,
      targetPos.y + targetSize.y / 2 - tooltip.size.y / 2
    )
  of TooltipAuto:
    let spaceTop = targetPos.y
    let spaceBottom = viewportSize.y - (targetPos.y + targetSize.y)
    let spaceLeft = targetPos.x
    let spaceRight = viewportSize.x - (targetPos.x + targetSize.x)
    
    var bestSpace = spaceTop
    var bestPos = TooltipTop
    
    if spaceBottom > bestSpace:
      bestSpace = spaceBottom
      bestPos = TooltipBottom
    if spaceLeft > bestSpace:
      bestSpace = spaceLeft
      bestPos = TooltipLeft
    if spaceRight > bestSpace:
      bestPos = TooltipRight
    
    tooltip.position = bestPos
    tooltip.updatePosition(viewportSize)
    return
  
  tooltip.localPos = finalPos
  tooltip.contentNode.localPos = vec2(tooltip.padding, tooltip.padding)
  tooltip.dirty = true

## Clamps tooltip position inside viewport bounds.
proc clampToViewport*(tooltip: Tooltip, viewportSize: Vec2) =
  var pos = tooltip.localPos
  
  if pos.x < 0:
    pos.x = 4
  elif pos.x + tooltip.size.x > viewportSize.x:
    pos.x = viewportSize.x - tooltip.size.x - 4
    
  if pos.y < 0:
    pos.y = 4
  elif pos.y + tooltip.size.y > viewportSize.y:
    pos.y = viewportSize.y - tooltip.size.y - 4
  
  tooltip.localPos = pos

## Shows tooltip for `target` and updates size and position.
proc show*(tooltip: Tooltip, target: Node, viewportSize: Vec2, ctx: RenderContext) =
  tooltip.targetNode = some(target)
  tooltip.visible = true
  tooltip.measureTooltip(ctx)
  tooltip.updatePosition(viewportSize)
  tooltip.clampToViewport(viewportSize)
  tooltip.dirty = true

## Hides tooltip and clears target binding.
proc hide*(tooltip: Tooltip) =
  tooltip.visible = false
  tooltip.targetNode = none(Node)

## Updates tooltip text and invalidates measured layout.
proc setText*(tooltip: Tooltip, text: string) =
  tooltip.contentNode.text = text
  tooltip.contentNode.dirty = true
  tooltip.layoutValid = false

method measure*(tooltip: Tooltip, ctx: RenderContext) =
  tooltip.measureTooltip(ctx)

method draw*(tooltip: Tooltip, renderCtx: RenderContext, image: Image) =
  tooltip.bgNode.draw(renderCtx, image)
  tooltip.contentNode.draw(renderCtx, image)
