import vmath
import ../core/types
import ../layout/alignment
import ../nodes/text

type
  ## Flow layout container that wraps items across lines.
  Flow* = ref object of Node
    spacing*: float32
    lineSpacing*: float32
    maxWidth*: float32
    horizontalAlign*: HorizontalAlign

## Creates a new flow container. Set `maxWidth` to enable wrapping.
proc newFlow*(maxWidth: float32 = 0.0): Flow =
  Flow(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "",
    size: vec2(0, 0),
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
    spacing: 4.0,
    lineSpacing: 8.0,
    maxWidth: maxWidth,
    horizontalAlign: AlignLeft
  )

## Adds a child to the flow and marks layout dirty.
proc addItem*(flow: Flow, child: Node) =
  flow.addChild(child)
  child.autoLayout = false
  flow.markDirty()

## Measures children and computes wrapped flow positions.
proc update*(flow: Flow, ctx: types.RenderContext = nil) =
  for child in flow.children:
    child.measure(ctx)

  if flow.children.len == 0:
    flow.size = vec2(0, 0)
    return

  if flow.maxWidth <= 0:
    var currentX = 0.0
    var maxHeight = 0.0
    for child in flow.children:
      if child.size.y > maxHeight:
        maxHeight = child.size.y
      child.localPos = vec2(currentX, 0)
      child.updateGlobalTransform()
      currentX += child.size.x + flow.spacing
    flow.size = vec2(currentX - flow.spacing, maxHeight)
    flow.markDirty()
    return

  var lines: seq[seq[Node]] = @[]
  var currentLine: seq[Node] = @[]
  var currentLineWidth = 0.0

  for child in flow.children:
    let childWidth = child.size.x
    if currentLine.len == 0:
      currentLine.add(child)
      currentLineWidth = childWidth
    elif currentLineWidth + flow.spacing + childWidth <= flow.maxWidth:
      currentLine.add(child)
      currentLineWidth += flow.spacing + childWidth
    else:
      lines.add(currentLine)
      currentLine = @[child]
      currentLineWidth = childWidth

  if currentLine.len > 0:
    lines.add(currentLine)

  var maxLineWidth = 0.0
  for line in lines:
    var lineWidth = 0.0
    for child in line:
      lineWidth += child.size.x
      if line != lines[^1]:
        lineWidth += flow.spacing
    if lineWidth > maxLineWidth:
      maxLineWidth = lineWidth

  var yOffset = 0.0
  for line in lines:
    var lineWidth = 0.0
    for child in line:
      lineWidth += child.size.x
      if child != line[^1]:
        lineWidth += flow.spacing

    var xOffset = 0.0
    case flow.horizontalAlign:
    of AlignLeft:
      xOffset = 0.0
    of AlignCenter:
      xOffset = (maxLineWidth - lineWidth) / 2.0
    of AlignRight:
      xOffset = maxLineWidth - lineWidth

    var currentX = xOffset
    var lineHeight = 0.0
    for child in line:
      if child.size.y > lineHeight:
        lineHeight = child.size.y
      child.localPos = vec2(currentX, yOffset)
      child.updateGlobalTransform()
      currentX += child.size.x + flow.spacing

    yOffset += lineHeight + flow.lineSpacing

  flow.size = vec2(maxLineWidth, yOffset - flow.lineSpacing)
  flow.markDirty()

method measure*(flow: Flow, ctx: types.RenderContext) =
  flow.update(ctx)
