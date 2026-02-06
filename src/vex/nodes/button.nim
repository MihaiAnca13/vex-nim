import std/options
import pixie
import vmath
import ../core/types
import ../core/colors
import ../core/transform
import ../layout/alignment
import ./primitive
import ./text

type
  ## Visual states supported by `Button`.
  ButtonState* = enum
    ButtonStateNormal
    ButtonStateHover
    ButtonStateActive
    ButtonStateDisabled

  ## Color palette used by `Button` for each state.
  ButtonColors* = object
    normalBg*: Color
    hoverBg*: Color
    activeBg*: Color
    disabledBg*: Color
    normalText*: Color
    hoverText*: Color
    activeText*: Color
    disabledText*: Color

  ## Clickable UI button with built-in hover/active/disabled states.
  Button* = ref object of Node
    label*: TextNode
    bg*: RectNode
    state*: ButtonState
    onClick*: proc()
    colors*: ButtonColors
    cornerRadius*: float32

proc defaultButtonColors(): ButtonColors =
  ButtonColors(
    normalBg: color(0.25, 0.35, 0.55, 1.0),
    hoverBg: color(0.35, 0.45, 0.65, 1.0),
    activeBg: color(0.20, 0.30, 0.50, 1.0),
    disabledBg: color(0.15, 0.15, 0.18, 1.0),
    normalText: color(0.95, 0.95, 0.95, 1.0),
    hoverText: color(1.0, 1.0, 1.0, 1.0),
    activeText: color(0.9, 0.9, 0.9, 1.0),
    disabledText: color(0.5, 0.5, 0.5, 1.0)
  )

## Creates a new button node with centered text label.
proc newButton*(
  text: string,
  fontPath: string,
  fontSize: float32 = 16.0,
  size: Vec2 = vec2(120, 40),
  colors: ButtonColors = defaultButtonColors()
): Button =
  let label = newTextNode(text, fontPath, fontSize, colors.normalText)
  label.horizontalAlign = AlignCenter
  label.verticalAlign = AlignCenter
  label.name = "button_label"

  let bg = newRectNode(size)
  bg.fill = some(solidPaint(colors.normalBg))
  bg.cornerRadius = 4.0
  bg.name = "button_bg"

  Button(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "Button",
    size: size,
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
    bg: bg,
    state: ButtonStateNormal,
    onClick: nil,
    colors: colors,
    cornerRadius: 4.0
  )

## Applies current button state colors to background and label.
proc updateVisualState*(btn: Button) =
  let (bgColor, textColor) = case btn.state
    of ButtonStateNormal: (btn.colors.normalBg, btn.colors.normalText)
    of ButtonStateHover: (btn.colors.hoverBg, btn.colors.hoverText)
    of ButtonStateActive: (btn.colors.activeBg, btn.colors.activeText)
    of ButtonStateDisabled: (btn.colors.disabledBg, btn.colors.disabledText)

  btn.bg.fill = some(solidPaint(bgColor))
  btn.bg.dirty = true
  btn.label.color = textColor
  btn.label.dirty = true

## Sets button state and refreshes visuals when state changed.
proc setState*(btn: Button, newState: ButtonState) =
  if btn.state != newState:
    btn.state = newState
    btn.updateVisualState()

## Enables or disables the button.
proc setEnabled*(btn: Button, enabled: bool) =
  btn.setState(if enabled: ButtonStateNormal else: ButtonStateDisabled)

## Returns `true` when button is not disabled.
proc isEnabled*(btn: Button): bool =
  btn.state != ButtonStateDisabled

## Transitions button to hover state when enabled.
proc handleMouseEnter*(btn: Button) =
  if btn.isEnabled():
    btn.setState(ButtonStateHover)

## Transitions button to normal state when enabled.
proc handleMouseLeave*(btn: Button) =
  if btn.isEnabled():
    btn.setState(ButtonStateNormal)

## Transitions button to active state when enabled.
proc handleMouseDown*(btn: Button) =
  if btn.isEnabled():
    btn.setState(ButtonStateActive)

## Handles mouse release and fires `onClick` when appropriate.
proc handleMouseUp*(btn: Button) =
  if btn.isEnabled():
    if btn.state == ButtonStateActive:
      btn.setState(ButtonStateHover)
      if not btn.onClick.isNil:
        btn.onClick()

## Replaces button label text.
proc setText*(btn: Button, text: string) =
  btn.label.text = text
  btn.label.dirty = true

## Hit tests a screen-space point against button bounds.
proc contains*(btn: Button, point: Vec2): bool =
  let localPoint = btn.globalToLocal(point)
  localPoint.x >= 0 and localPoint.x < btn.size.x and
  localPoint.y >= 0 and localPoint.y < btn.size.y

method measure*(btn: Button, ctx: types.RenderContext) =
  btn.label.measure(ctx)
  btn.bg.size = btn.size
  btn.layoutValid = true

method draw*(btn: Button, renderCtx: types.RenderContext, image: Image) =
  btn.bg.size = btn.size
  btn.bg.draw(renderCtx, image)

  btn.label.measure(renderCtx)
  let labelX = btn.size.x / 2 - btn.label.size.x / 2
  let labelY = btn.size.y / 2 - btn.label.size.y / 2
  btn.label.localPos = vec2(labelX, labelY)
  btn.label.draw(renderCtx, image)
