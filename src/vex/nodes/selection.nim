import std/options
import pixie
import vmath
import ../core/types
import ../core/colors
import ../core/transform
import ../layout/alignment
import ../nodes/primitive

type
  SelectionStyle* = enum
    SelectionStyleBorder
    SelectionStyleGlow
    SelectionStyleFill
    SelectionStyleDashed

  SelectionOverlay* = ref object of Node
    target*: Option[Node]
    style*: SelectionStyle
    color*: Color
    borderWidth*: float32
    glowRadius*: float32
    cornerRadius*: float32
    dashLength*: float32
    dashGap*: float32
    isVisible*: bool

const
  DefaultSelectionColor = color(0.9, 0.7, 0.2, 1.0)
  DefaultGlowColor = color(0.9, 0.7, 0.2, 0.4)
  DefaultBorderWidth = 3.0
  DefaultGlowRadius = 8.0
  DefaultDashLength = 8.0
  DefaultDashGap = 4.0

proc newSelectionOverlay*(
  style: SelectionStyle = SelectionStyleBorder,
  color: Color = DefaultSelectionColor,
  borderWidth: float32 = DefaultBorderWidth,
  glowRadius: float32 = DefaultGlowRadius
): SelectionOverlay =
  SelectionOverlay(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: false,
    name: "SelectionOverlay",
    size: vec2(0, 0),
    zIndex: 500,
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
    target: none(Node),
    style: style,
    color: color,
    borderWidth: borderWidth,
    glowRadius: glowRadius,
    cornerRadius: 0.0,
    dashLength: DefaultDashLength,
    dashGap: DefaultDashGap,
    isVisible: false
  )

proc updateTransform*(overlay: SelectionOverlay)

proc attachTo*(overlay: SelectionOverlay, target: Node) =
  overlay.target = some(target)
  overlay.updateTransform()

proc updateTransform*(overlay: SelectionOverlay) =
  if overlay.target.isNone:
    return
    
  let targetNode = overlay.target.get()
  overlay.size = targetNode.size
  
  case overlay.style
  of SelectionStyleGlow:
    overlay.localPos = targetNode.localPos - vec2(overlay.glowRadius, overlay.glowRadius)
    overlay.size = targetNode.size + vec2(overlay.glowRadius * 2, overlay.glowRadius * 2)
  of SelectionStyleBorder, SelectionStyleFill, SelectionStyleDashed:
    overlay.localPos = targetNode.localPos
    overlay.size = targetNode.size
  
  overlay.dirty = true

proc show*(overlay: SelectionOverlay) =
  overlay.isVisible = true
  overlay.visible = true
  overlay.dirty = true
  overlay.updateTransform()

proc hide*(overlay: SelectionOverlay) =
  overlay.isVisible = false
  overlay.visible = false

proc setStyle*(overlay: SelectionOverlay, style: SelectionStyle) =
  overlay.style = style
  overlay.dirty = true
  overlay.updateTransform()

proc setColor*(overlay: SelectionOverlay, color: Color) =
  overlay.color = color
  overlay.dirty = true

proc drawBorderStyle(overlay: SelectionOverlay, ctx: Context) =
  ctx.strokeStyle = solidPaint(overlay.color)
  ctx.lineWidth = overlay.borderWidth
  
  if overlay.cornerRadius > 0:
    ctx.strokeRoundedRect(
      rect(0, 0, overlay.size.x, overlay.size.y),
      overlay.cornerRadius
    )
  else:
    ctx.strokeRect(rect(0, 0, overlay.size.x, overlay.size.y))

proc drawGlowStyle(overlay: SelectionOverlay, ctx: Context) =
  let innerRect = rect(
    overlay.glowRadius,
    overlay.glowRadius,
    overlay.size.x - overlay.glowRadius * 2,
    overlay.size.y - overlay.glowRadius * 2
  )
  
  for i in 0..<int(overlay.glowRadius):
    let alpha = 1.0 - (i.float32 / overlay.glowRadius)
    let glowColor = color(
      overlay.color.r,
      overlay.color.g,
      overlay.color.b,
      overlay.color.a * alpha * 0.5
    )
    ctx.strokeStyle = solidPaint(glowColor)
    ctx.lineWidth = 1.0
    
    let offset = overlay.glowRadius - i.float32
    let glowRect = rect(
      offset,
      offset,
      overlay.size.x - offset * 2,
      overlay.size.y - offset * 2
    )
    
    if overlay.cornerRadius > 0:
      ctx.strokeRoundedRect(glowRect, overlay.cornerRadius)
    else:
      ctx.strokeRect(glowRect)
  
  ctx.strokeStyle = solidPaint(overlay.color)
  ctx.lineWidth = overlay.borderWidth
  if overlay.cornerRadius > 0:
    ctx.strokeRoundedRect(innerRect, overlay.cornerRadius)
  else:
    ctx.strokeRect(innerRect)

proc drawFillStyle(overlay: SelectionOverlay, ctx: Context) =
  let fillColor = color(
    overlay.color.r,
    overlay.color.g,
    overlay.color.b,
    overlay.color.a * 0.3
  )
  ctx.fillStyle = solidPaint(fillColor)
  
  if overlay.cornerRadius > 0:
    ctx.fillRoundedRect(
      rect(0, 0, overlay.size.x, overlay.size.y),
      overlay.cornerRadius
    )
  else:
    ctx.fillRect(rect(0, 0, overlay.size.x, overlay.size.y))
  
  ctx.strokeStyle = solidPaint(overlay.color)
  ctx.lineWidth = overlay.borderWidth
  if overlay.cornerRadius > 0:
    ctx.strokeRoundedRect(
      rect(0, 0, overlay.size.x, overlay.size.y),
      overlay.cornerRadius
    )
  else:
    ctx.strokeRect(rect(0, 0, overlay.size.x, overlay.size.y))

proc drawDashedStyle(overlay: SelectionOverlay, ctx: Context) =
  ctx.strokeStyle = solidPaint(overlay.color)
  ctx.lineWidth = overlay.borderWidth
  
  let w = overlay.size.x
  let h = overlay.size.y
  let dashLen = overlay.dashLength
  let gapLen = overlay.dashGap
  let r = overlay.cornerRadius
  
  proc drawDashedLine(startX, startY, endX, endY: float32) =
    let dx = endX - startX
    let dy = endY - startY
    let dist = sqrt(dx * dx + dy * dy)
    if dist <= 0:
      return
    
    let nx = dx / dist
    let ny = dy / dist
    var currentDist = 0.0
    var drawing = true
    
    while currentDist < dist:
      let segmentLen = if drawing: dashLen else: gapLen
      let remaining = dist - currentDist
      let len = min(segmentLen, remaining)
      
      if drawing:
        let line = newPath()
        line.moveTo(startX + nx * currentDist, startY + ny * currentDist)
        line.lineTo(startX + nx * (currentDist + len), startY + ny * (currentDist + len))
        ctx.stroke(line)
      
      currentDist += len
      drawing = not drawing
  
  if r > 0:
    drawDashedLine(r, 0, w - r, 0)
    drawDashedLine(w, r, w, h - r)
    drawDashedLine(w - r, h, r, h)
    drawDashedLine(0, h - r, 0, r)
  else:
    drawDashedLine(0, 0, w, 0)
    drawDashedLine(w, 0, w, h)
    drawDashedLine(w, h, 0, h)
    drawDashedLine(0, h, 0, 0)

method draw*(overlay: SelectionOverlay, renderCtx: RenderContext, image: Image) =
  if not overlay.isVisible:
    return
    
  let ctx = newContext(image)
  
  case overlay.style
  of SelectionStyleBorder:
    overlay.drawBorderStyle(ctx)
  of SelectionStyleGlow:
    overlay.drawGlowStyle(ctx)
  of SelectionStyleFill:
    overlay.drawFillStyle(ctx)
  of SelectionStyleDashed:
    overlay.drawDashedStyle(ctx)
