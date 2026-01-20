import pixie
import vmath
import ../core/types
import ../core/context
import ../core/transform
import ../layout/alignment

type
  TextNode* = ref object of Node
    text*: string
    fontPath*: string
    fontSize*: float32
    color*: Color
    maxWidth*: float32
    horizontalAlign*: HorizontalAlign
    verticalAlign*: VerticalAlign

  HorizontalAlign* = enum
    AlignLeft
    AlignCenter
    AlignRight

  VerticalAlign* = enum
    AlignTop
    AlignCenter
    AlignBottom

proc newTextNode*(
  text: string,
  fontPath: string,
  fontSize: float32 = 16.0,
  color: Color = color(0, 0, 0, 1)
): TextNode =
  TextNode(
    globalTransform: identityTransform,
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
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
    text: text,
    fontPath: fontPath,
    fontSize: fontSize,
    color: color,
    maxWidth: 0.0,
    horizontalAlign: AlignLeft,
    verticalAlign: AlignTop
  )

proc contains*(node: TextNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  localPoint.x >= 0 and localPoint.x < node.size.x and
  localPoint.y >= 0 and localPoint.y < node.size.y

method measure*(node: TextNode, ctx: types.RenderContext) =
  try:
    let font = ctx.getFont(node.fontPath)
    font.size = node.fontSize

    let bounds = if node.maxWidth > 0:
      vec2(node.maxWidth, Inf.float32)
    else:
      vec2(Inf.float32, Inf.float32)

    let arrangement = font.typeset(node.text, bounds)
    let layout = arrangement.layoutBounds()
    node.size = vec2(layout.x, layout.y)
  except KeyError:
    node.size = vec2(0, 0)

method draw*(node: TextNode, renderCtx: types.RenderContext, image: Image) =
  if node.size.x == 0 or node.size.y == 0:
    node.measure(renderCtx)

  try:
    let font = renderCtx.getFont(node.fontPath)
    font.size = node.fontSize
    font.paint.color = node.color

    let bounds = if node.maxWidth > 0:
      vec2(node.maxWidth, node.size.y)
    else:
      vec2(Inf.float32, Inf.float32)
    let arrangement = font.typeset(node.text, bounds)

    let layout = arrangement.layoutBounds()
    let textWidth = layout.x
    let textHeight = layout.y
    if node.size.x == 0 or node.size.y == 0:
      node.size = vec2(textWidth, textHeight)

    let xOffset = case node.horizontalAlign
      of AlignLeft: 0.0
      of AlignCenter: max(0.0, (node.size.x - textWidth) / 2)
      of AlignRight: max(0.0, node.size.x - textWidth)

    let yOffset = case node.verticalAlign
      of AlignTop: 0.0
      of AlignCenter: max(0.0, (node.size.y - textHeight) / 2)
      of AlignBottom: max(0.0, node.size.y - textHeight)

    image.fillText(arrangement, translate(vec2(xOffset, yOffset)))
  except KeyError, PixieError:
    discard
