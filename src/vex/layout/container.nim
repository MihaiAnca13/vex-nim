import vmath
import ../core/types
import ../nodes/text

## Layout containers for automatic child positioning.
##
## HBox arranges children horizontally, VBox arranges them vertically.
## Both support spacing and padding, and automatically calculate their size.
## IMPORTANT: Call `update(ctx)` after adding items to calculate layout.

type
  HBox* = ref object of Node
    spacing*: float32
    padding*: float32

  VBox* = ref object of Node
    spacing*: float32
    padding*: float32

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
    spacing: spacing,
    padding: padding
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
    spacing: spacing,
    padding: padding
  )

## Adds a child to the HBox and marks it as dirty.
proc addItem*(hbox: HBox, child: Node) =
  hbox.addChild(child)
  hbox.markDirty()

## Adds a child to the VBox and marks it as dirty.
proc addItem*(vbox: VBox, child: Node) =
  vbox.addChild(child)
  vbox.markDirty()

## Recalculates the HBox layout.
##
## This must be called after adding items to measure TextNodes and
## calculate the container's size. TextNodes need the RenderContext
## to measure their font dimensions.
proc update*(hbox: HBox, ctx: types.RenderContext) =
  for child in hbox.children:
    when child is TextNode:
      child.measure(ctx)

  if hbox.children.len == 0:
    hbox.size = vec2(hbox.padding * 2, hbox.padding * 2)
    return

  var x = hbox.padding
  var maxHeight = 0.0

  for child in hbox.children:
    if not child.visible:
      continue
    child.localPos = vec2(x, hbox.padding)
    child.updateGlobalTransform()
    x += child.size.x + hbox.spacing
    if child.size.y > maxHeight:
      maxHeight = child.size.y

  hbox.size = vec2(x + hbox.padding, maxHeight + hbox.padding * 2)
  hbox.markDirty()

## Recalculates the VBox layout.
##
## This must be called after adding items to measure TextNodes and
## calculate the container's size. TextNodes need the RenderContext
## to measure their font dimensions.
proc update*(vbox: VBox, ctx: types.RenderContext) =
  for child in vbox.children:
    when child is TextNode:
      child.measure(ctx)

  if vbox.children.len == 0:
    vbox.size = vec2(vbox.padding * 2, vbox.padding * 2)
    return

  var y = vbox.padding
  var maxWidth = 0.0

  for child in vbox.children:
    if not child.visible:
      continue
    child.localPos = vec2(vbox.padding, y)
    child.updateGlobalTransform()
    y += child.size.y + vbox.spacing
    if child.size.x > maxWidth:
      maxWidth = child.size.x

  vbox.size = vec2(maxWidth + vbox.padding * 2, y + vbox.padding)
  vbox.markDirty()
