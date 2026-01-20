import vmath
import ../core/types
import ../layout/alignment

## Layout containers for automatic child positioning.
##
## HBox arranges children horizontally, VBox arranges them vertically.
## Both support spacing and padding, and automatically calculate their size.
## IMPORTANT: Call `update(ctx)` after adding items to calculate layout.

type
  HBox* = ref object of Node
    spacing*: float32
    padding*: float32
    fillWidth*: bool
    fillHeight*: bool

  VBox* = ref object of Node
    spacing*: float32
    padding*: float32
    fillWidth*: bool
    fillHeight*: bool

## Creates a new horizontal box layout container.
proc newHBox*(spacing: float32 = 4.0, padding: float32 = 4.0): HBox =
  HBox(
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
    childrenSorted: true,
    clipChildren: false,
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
    spacing: spacing,
    padding: padding,
    fillWidth: false,
    fillHeight: false
  )

## Creates a new vertical box layout container.
proc newVBox*(spacing: float32 = 4.0, padding: float32 = 4.0): VBox =
  VBox(
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
    childrenSorted: true,
    clipChildren: false,
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
    spacing: spacing,
    padding: padding,
    fillWidth: false,
    fillHeight: false
  )

## Adds a child to the HBox and marks it as dirty.
proc addItem*(hbox: HBox, child: Node) =
  hbox.addChild(child)
  child.autoLayout = false
  hbox.markDirty()

## Adds a child to the VBox and marks it as dirty.
proc addItem*(vbox: VBox, child: Node) =
  vbox.addChild(child)
  child.autoLayout = false
  vbox.markDirty()

## Recalculates the HBox layout.
##
## This must be called after adding items to measure TextNodes and
## calculate the container's size. TextNodes need the RenderContext
## to measure their font dimensions.
proc update*(hbox: HBox, ctx: types.RenderContext = nil) =
  for child in hbox.children:
    child.measure(ctx)

  if hbox.children.len == 0:
    hbox.size = vec2(hbox.padding * 2, hbox.padding * 2)
    return
  var maxHeight = 0.0
  var visibleCount = 0
  for child in hbox.children:
    if not child.visible:
      continue
    inc visibleCount
    if child.size.y > maxHeight:
      maxHeight = child.size.y
  var childWidth = -1.0
  if hbox.fillWidth and hbox.size.x > 0 and visibleCount > 0:
    let available = hbox.size.x - hbox.padding * 2 - hbox.spacing * visibleCount.float32
    if available > 0:
      childWidth = available / visibleCount.float32
  var x = hbox.padding
  for child in hbox.children:
    if not child.visible:
      continue
    var sizeChanged = false
    if childWidth >= 0 and child.size.x != childWidth:
      child.size.x = childWidth
      sizeChanged = true
    if hbox.fillHeight and child.size.y != maxHeight:
      child.size.y = maxHeight
      sizeChanged = true
    if sizeChanged:
      child.markDirty()
    child.localPos = vec2(x, hbox.padding)
    child.updateGlobalTransform()
    x += child.size.x + hbox.spacing
  let height = maxHeight + hbox.padding * 2
  if hbox.fillWidth and hbox.size.x > 0:
    hbox.size = vec2(hbox.size.x, height)
  else:
    hbox.size = vec2(x + hbox.padding, height)
  hbox.markDirty()

method measure*(hbox: HBox, ctx: types.RenderContext) =
  hbox.update(ctx)

## Recalculates the VBox layout.
##
## This must be called after adding items to measure TextNodes and
## calculate the container's size. TextNodes need the RenderContext
## to measure their font dimensions.
proc update*(vbox: VBox, ctx: types.RenderContext = nil) =
  for child in vbox.children:
    child.measure(ctx)

  if vbox.children.len == 0:
    vbox.size = vec2(vbox.padding * 2, vbox.padding * 2)
    return
  var maxWidth = 0.0
  var visibleCount = 0
  for child in vbox.children:
    if not child.visible:
      continue
    inc visibleCount
    if child.size.x > maxWidth:
      maxWidth = child.size.x
  var childHeight = -1.0
  if vbox.fillHeight and vbox.size.y > 0 and visibleCount > 0:
    let available = vbox.size.y - vbox.padding * 2 - vbox.spacing * visibleCount.float32
    if available > 0:
      childHeight = available / visibleCount.float32
  var y = vbox.padding
  for child in vbox.children:
    if not child.visible:
      continue
    var sizeChanged = false
    if vbox.fillWidth and child.size.x != maxWidth:
      child.size.x = maxWidth
      sizeChanged = true
    if childHeight >= 0 and child.size.y != childHeight:
      child.size.y = childHeight
      sizeChanged = true
    if sizeChanged:
      child.markDirty()
    child.localPos = vec2(vbox.padding, y)
    child.updateGlobalTransform()
    y += child.size.y + vbox.spacing
  let width = if vbox.fillWidth and vbox.size.x > 0: vbox.size.x else: maxWidth + vbox.padding * 2
  if vbox.fillHeight and vbox.size.y > 0:
    vbox.size = vec2(width, vbox.size.y)
  else:
    vbox.size = vec2(width, y + vbox.padding)
  vbox.markDirty()

method measure*(vbox: VBox, ctx: types.RenderContext) =
  vbox.update(ctx)

proc withSize*(hbox: HBox, width, height: float32, ctx: types.RenderContext = nil): HBox =
  hbox.update(ctx)
  hbox.size = vec2(width, height)
  hbox

proc withSize*(vbox: VBox, width, height: float32, ctx: types.RenderContext = nil): VBox =
  vbox.update(ctx)
  vbox.size = vec2(width, height)
  vbox
