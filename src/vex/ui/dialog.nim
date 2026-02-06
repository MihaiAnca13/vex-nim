import std/options
import pixie
import vmath
import ../core/types
import ../core/colors
import ../core/transform
import ../layout/alignment
import ../layout/container
import ../nodes/primitive
import ../nodes/text
import ../nodes/button

type
  Dialog* = ref object of Node
    content*: VBox
    overlay*: RectNode
    titleBar*: HBox
    titleText*: TextNode
    closeButton*: Button
    buttonsRow*: HBox
    isOpen*: bool
    onClose*: proc()
    dismissOnOverlay*: bool

const
  DefaultDialogBg = color(0.15, 0.15, 0.18, 1.0)
  DefaultDialogBorder = color(0.35, 0.35, 0.45, 1.0)
  DefaultOverlayColor = color(0.0, 0.0, 0.0, 0.6)
  DefaultDialogWidth = 400.0
  DefaultDialogMinHeight = 200.0

proc closeDialog*(dialog: Dialog)

proc newDialog*(
  title: string,
  fontPath: string,
  width: float32 = DefaultDialogWidth,
  dismissOnOverlay: bool = true
): Dialog =
  let content = newVBox(spacing = 12, padding = 20)
  content.fillWidth = false
  content.fillHeight = false
  
  let overlay = newRectNode()
  overlay.fill = some(solidPaint(DefaultOverlayColor))
  overlay.name = "dialog_overlay"
  
  let titleText = newTextNode(title, fontPath, 18, color(0.95, 0.95, 0.95, 1.0))
  titleText.horizontalAlign = AlignLeft
  
  let closeBtn = newButton("X", fontPath, fontSize = 12, size = vec2(30, 30))
  closeBtn.colors.normalBg = color(0.3, 0.3, 0.35, 1.0)
  closeBtn.colors.hoverBg = color(0.4, 0.4, 0.45, 1.0)
  
  let titleBar = newHBox(spacing = 10, padding = 15)
  titleBar.fillWidth = true
  
  let buttonsRow = newHBox(spacing = 10, padding = 0)
  buttonsRow.fillWidth = true
  
  let dialog = Dialog(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: false,
    name: "Dialog",
    size: vec2(width, DefaultDialogMinHeight),
    zIndex: 2000,
    clipChildren: true,
    childrenSorted: true,
    anchor: TopLeft,
    anchorOffset: vec2(0, 0),
    pivot: Center,
    sizeMode: Absolute,
    sizePercent: vec2(1, 1),
    scaleMode: Stretch,
    minSize: vec2(width, DefaultDialogMinHeight),
    maxSize: vec2(0, 0),
    layoutValid: false,
    autoLayout: true,
    content: content,
    overlay: overlay,
    titleBar: titleBar,
    titleText: titleText,
    closeButton: closeBtn,
    buttonsRow: buttonsRow,
    isOpen: false,
    onClose: nil,
    dismissOnOverlay: dismissOnOverlay
  )
  
  closeBtn.onClick = proc() =
    dialog.closeDialog()
  
  dialog

proc centerInViewport*(dialog: Dialog, viewportSize: Vec2) =
  dialog.localPos = vec2(
    viewportSize.x / 2 - dialog.size.x / 2,
    viewportSize.y / 2 - dialog.size.y / 2
  )
  dialog.overlay.size = viewportSize
  dialog.overlay.localPos = vec2(0, 0)

proc addContent*(dialog: Dialog, node: Node) =
  dialog.content.addChild(node)
  dialog.dirty = true

proc addButton*(dialog: Dialog, button: Button) =
  dialog.buttonsRow.addChild(button)
  dialog.dirty = true

proc open*(dialog: Dialog, viewportSize: Vec2) =
  dialog.isOpen = true
  dialog.visible = true
  dialog.centerInViewport(viewportSize)
  dialog.dirty = true

proc closeDialog*(dialog: Dialog) =
  dialog.isOpen = false
  dialog.visible = false
  if not dialog.onClose.isNil:
    dialog.onClose()

proc handleOverlayClick*(dialog: Dialog): bool =
  if dialog.dismissOnOverlay and dialog.isOpen:
    dialog.closeDialog()
    return true
  return false

proc buildDialogVisuals(dialog: Dialog) =
  if dialog.children.len > 0:
    return
  
  dialog.addChild(dialog.overlay)
  
  let bg = newRectNode(dialog.size)
  bg.fill = some(solidPaint(DefaultDialogBg))
  bg.stroke = some(solidPaint(DefaultDialogBorder))
  bg.strokeWidth = 1.0
  bg.cornerRadius = 6.0
  bg.localPos = vec2(0, 0)
  bg.name = "dialog_bg"
  dialog.addChild(bg)
  
  let headerBg = newRectNode(vec2(dialog.size.x, 50))
  headerBg.fill = some(solidPaint(color(0.12, 0.12, 0.15, 1.0)))
  headerBg.cornerRadius = 6.0
  headerBg.localPos = vec2(0, 0)
  dialog.addChild(headerBg)
  
  dialog.titleText.localPos = vec2(20, 15)
  dialog.addChild(dialog.titleText)
  
  dialog.closeButton.localPos = vec2(dialog.size.x - 40, 10)
  dialog.addChild(dialog.closeButton)
  
  dialog.content.localPos = vec2(20, 60)
  dialog.addChild(dialog.content)
  
  dialog.buttonsRow.localPos = vec2(20, dialog.size.y - 50)
  dialog.addChild(dialog.buttonsRow)

method measure*(dialog: Dialog, ctx: RenderContext) =
  dialog.buildDialogVisuals()
  dialog.content.measure(ctx)
  dialog.titleText.measure(ctx)
  dialog.closeButton.measure(ctx)
  dialog.buttonsRow.measure(ctx)
  
  let contentHeight = 60.0 + dialog.content.size.y + 20.0 + 50.0
  dialog.size.y = max(contentHeight, DefaultDialogMinHeight)
  dialog.minSize.y = dialog.size.y
  
  dialog.layoutValid = true

method draw*(dialog: Dialog, renderCtx: RenderContext, image: Image) =
  if not dialog.isOpen:
    return
  
  dialog.overlay.draw(renderCtx, image)
  
  for child in dialog.children:
    if child != dialog.overlay:
      child.draw(renderCtx, image)
