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
    var font = ctx.getFont(node.fontPath).copy()
    font.size = node.fontSize

    let bounds = if node.maxWidth > 0:
      vec2(node.maxWidth, Inf.float32)
    else:
      vec2(Inf.float32, Inf.float32)

    if node.size.x <= 0 or node.size.y <= 0:
      let arrangement = font.typeset(node.text, bounds)
      let layout = arrangement.layoutBounds()
      node.size = vec2(layout.x, layout.y)
  except KeyError:
    if node.size.x <= 0 or node.size.y <= 0:
      node.size = vec2(0, 0)

method draw*(node: TextNode, renderCtx: types.RenderContext, image: Image) =
  if node.size.x <= 0 or node.size.y <= 0:
    node.measure(renderCtx)

  try:
    var font = renderCtx.getFont(node.fontPath).copy()
    font.size = node.fontSize
    font.paint.color = node.color

    let hasBounds = node.size.x > 0 and node.size.y > 0
    let bounds = if node.maxWidth > 0:
      vec2(node.maxWidth, (if hasBounds: node.size.y else: Inf.float32))
    elif hasBounds:
      node.size
    else:
      vec2(Inf.float32, Inf.float32)

    let hAlign = case node.horizontalAlign
      of AlignLeft: LeftAlign
      of AlignCenter: CenterAlign
      of AlignRight: RightAlign

    let vAlign = case node.verticalAlign
      of AlignTop: TopAlign
      of AlignCenter: MiddleAlign
      of AlignBottom: BottomAlign

    let arrangement = font.typeset(node.text, bounds, hAlign, vAlign, wrap = node.maxWidth > 0)

    image.fillText(arrangement, mat3())
  except KeyError, PixieError:
    discard
