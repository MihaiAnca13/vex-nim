import std/options
import std/strutils
import vmath
import pixie
import ../core/types
import ../core/colors
import ../layout/alignment
import ../layout/container
import ../nodes/primitive
import ../nodes/text

type
  NavBarItem* = ref object of Node
    label*: string
    icon*: Option[Node]
    isActive*: bool

proc newNavBarItem*(label: string, icon: Node = nil): NavBarItem =
  NavBarItem(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: label,
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
    label: label,
    icon: if icon.isNil: none(Node) else: some(icon),
    isActive: false
  )

type
  Card* = ref object of VBox
    titleNode*: Option[TextNode]
    bgNode*: RectNode

const DefaultFontPath* = "tests/data/DejaVuSans.ttf"

proc newCard*(title: string = ""): Card =
  let bgNode = newRectNode()
  bgNode.fill = some(solidPaint(color(0.98, 0.98, 0.98, 1.0)))
  bgNode.stroke = some(solidPaint(color(0.85, 0.85, 0.85, 1.0)))
  bgNode.strokeWidth = 1.0
  bgNode.cornerRadius = 8.0

  let content = newVBox(spacing = 8, padding = 12)

  var titleNode: Option[TextNode] = none(TextNode)
  if title.len > 0:
    let tn = newTextNode(title, DefaultFontPath, 14)
    tn.color = color(0.3, 0.3, 0.3, 1.0)
    tn.horizontalAlign = AlignLeft
    tn.maxSize = vec2(Inf.float32, Inf.float32)
    content.addItem(tn)
    titleNode = some(tn)

  Card(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "Card",
    size: vec2(0, 0),
    zIndex: 0,
    clipChildren: true,
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
    spacing: 8,
    padding: 12,
    fillWidth: false,
    fillHeight: false,
    titleNode: titleNode,
    bgNode: bgNode
  )

proc setCardContent*(card: Card, content: Node) =
  card.addChild(content)
  content.autoLayout = false

type
  SectionHeader* = ref object of HBox
    labelNode*: TextNode
    lineLeft*: Option[RectNode]
    lineRight*: Option[RectNode]

proc newSectionHeader*(
  label: string,
  fontPath: string = "tests/data/DejaVuSans.ttf",
  fontSize: float32 = 12.0,
  color: Color = colGray,
  lineColor: Color = colGray
): SectionHeader =
  let labelNode = newTextNode(label.toUpperAscii(), fontPath, fontSize, color)
  labelNode.horizontalAlign = AlignCenter
  labelNode.verticalAlign = AlignCenter

  let lineLeft = newRectNode()
  lineLeft.fill = some(solidPaint(lineColor))
  lineLeft.size = vec2(20, 1)

  let lineRight = newRectNode()
  lineRight.fill = some(solidPaint(lineColor))
  lineRight.size = vec2(20, 1)

  SectionHeader(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "SectionHeader",
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
    spacing: 8,
    padding: 0,
    fillWidth: false,
    fillHeight: false,
    labelNode: labelNode,
    lineLeft: some(lineLeft),
    lineRight: some(lineRight)
  )

type
  Badge* = ref object of HBox
    bgNode*: RectNode
    textNode*: TextNode

proc newBadge*(
  text: string,
  bgColor: Color = colBlue,
  textColor: Color = color(1, 1, 1, 1),
  fontPath: string = "tests/data/DejaVuSans.ttf",
  fontSize: float32 = 11.0
): Badge =
  let bgNode = newRectNode()
  bgNode.fill = some(solidPaint(bgColor))
  bgNode.cornerRadius = 10.0

  let textNode = newTextNode(text, fontPath, fontSize, textColor)
  textNode.horizontalAlign = AlignCenter
  textNode.verticalAlign = AlignCenter

  Badge(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "Badge",
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
    spacing: 4,
    padding: 6,
    fillWidth: false,
    fillHeight: false,
    bgNode: bgNode,
    textNode: textNode
  )

type
  Chip* = ref object of HBox
    bgNode*: RectNode
    textNode*: TextNode
    closeButton*: Option[RectNode]

proc newChip*(
  label: string,
  onClose: proc() = nil,
  bgColor: Color = color(0.9, 0.9, 0.9, 1.0),
  textColor: Color = color(0.3, 0.3, 0.3, 1.0),
  fontPath: string = "tests/data/DejaVuSans.ttf",
  fontSize: float32 = 12.0
): Chip =
  let bgNode = newRectNode()
  bgNode.fill = some(solidPaint(bgColor))
  bgNode.cornerRadius = 14.0
  bgNode.clipChildren = true

  let textNode = newTextNode(label, fontPath, fontSize, textColor)
  textNode.horizontalAlign = AlignCenter
  textNode.verticalAlign = AlignCenter

  var closeButton: Option[RectNode] = none(RectNode)
  if not onClose.isNil:
    let btn = newRectNode(vec2(20, 20))
    btn.fill = some(solidPaint(color(0.6, 0.6, 0.6, 1.0)))
    btn.cornerRadius = 10.0
    closeButton = some(btn)

  Chip(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "Chip",
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
    spacing: 4,
    padding: 6,
    fillWidth: false,
    fillHeight: false,
    bgNode: bgNode,
    textNode: textNode,
    closeButton: closeButton
  )

type
  LabelValueRow* = ref object of HBox
    labelNode*: TextNode
    valueNode*: TextNode

proc newLabelValueRow*(
  label: string,
  value: string,
  labelColor: Color = colGray,
  valueColor: Color = color(0.2, 0.2, 0.2, 1.0),
  fontPath: string = "tests/data/DejaVuSans.ttf",
  labelSize: float32 = 12.0,
  valueSize: float32 = 14.0
): LabelValueRow =
  let labelNode = newTextNode(label, fontPath, labelSize, labelColor)
  labelNode.horizontalAlign = AlignLeft
  labelNode.verticalAlign = AlignCenter

  let valueNode = newTextNode(value, fontPath, valueSize, valueColor)
  valueNode.horizontalAlign = AlignRight
  valueNode.verticalAlign = AlignCenter

  LabelValueRow(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "LabelValueRow",
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
    spacing: 12,
    padding: 0,
    fillWidth: false,
    fillHeight: false,
    labelNode: labelNode,
    valueNode: valueNode
  )

proc setValue*(row: LabelValueRow, value: string) =
  row.valueNode.text = value
  row.valueNode.markDirty()

type
  NavBar* = ref object of HBox
    items*: seq[NavBarItem]
    activeItem*: Option[NavBarItem]
    bgNode*: RectNode

proc newNavBar*(
  bgColor: Color = color(0.95, 0.95, 0.95, 1.0),
  height: float32 = 48.0
): NavBar =
  let bgNode = newRectNode()
  bgNode.fill = some(solidPaint(bgColor))
  bgNode.size = vec2(0, height)

  NavBar(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "NavBar",
    size: vec2(0, height),
    zIndex: 100,
    clipChildren: false,
    childrenSorted: true,
    anchor: TopLeft,
    anchorOffset: vec2(0, 0),
    pivot: TopLeft,
    sizeMode: Absolute,
    sizePercent: vec2(1, 0),
    scaleMode: Stretch,
    minSize: vec2(0, height),
    maxSize: vec2(0, height),
    layoutValid: false,
    autoLayout: true,
    spacing: 0,
    padding: 16,
    fillWidth: false,
    fillHeight: false,
    items: @[],
    activeItem: none(NavBarItem),
    bgNode: bgNode
  )

proc addNavItem*(nav: NavBar, item: NavBarItem) =
  nav.addChild(item)
  item.autoLayout = false
  nav.items.add(item)
  nav.markDirty()

proc setActiveItem*(nav: NavBar, item: NavBarItem) =
  for i in nav.items:
    i.isActive = false
  item.isActive = true
  nav.activeItem = some(item)
  nav.markDirty()

method measure*(card: Card, ctx: types.RenderContext) =
  card.bgNode.measure(ctx)
  card.update(ctx)

method measure*(header: SectionHeader, ctx: types.RenderContext) =
  header.labelNode.measure(ctx)
  header.update(ctx)

method measure*(badge: Badge, ctx: types.RenderContext) =
  badge.bgNode.measure(ctx)
  badge.textNode.measure(ctx)
  badge.update(ctx)

method measure*(chip: Chip, ctx: types.RenderContext) =
  chip.bgNode.measure(ctx)
  chip.textNode.measure(ctx)
  chip.update(ctx)

method measure*(row: LabelValueRow, ctx: types.RenderContext) =
  row.labelNode.measure(ctx)
  row.valueNode.measure(ctx)
  row.update(ctx)

method measure*(nav: NavBar, ctx: types.RenderContext) =
  nav.bgNode.measure(ctx)
  for item in nav.items:
    item.measure(ctx)
  nav.update(ctx)

method draw*(card: Card, renderCtx: types.RenderContext, image: Image) =
  card.bgNode.draw(renderCtx, image)
  procCall draw(VBox(card), renderCtx, image)

method draw*(header: SectionHeader, renderCtx: types.RenderContext, image: Image) =
  procCall draw(HBox(header), renderCtx, image)

method draw*(badge: Badge, renderCtx: types.RenderContext, image: Image) =
  badge.bgNode.draw(renderCtx, image)
  procCall draw(HBox(badge), renderCtx, image)

method draw*(chip: Chip, renderCtx: types.RenderContext, image: Image) =
  chip.bgNode.draw(renderCtx, image)
  procCall draw(HBox(chip), renderCtx, image)

method draw*(row: LabelValueRow, renderCtx: types.RenderContext, image: Image) =
  procCall draw(HBox(row), renderCtx, image)

method draw*(nav: NavBar, renderCtx: types.RenderContext, image: Image) =
  nav.bgNode.draw(renderCtx, image)
  procCall draw(HBox(nav), renderCtx, image)
