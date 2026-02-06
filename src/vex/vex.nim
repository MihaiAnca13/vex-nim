## VEX - Vector & Hex Scene Graph Library
## High-performance 2D scene graph for Nim

import ./core/types
import ./core/transform
import ./core/events
import ./core/context
import ./core/colors
import ./core/layout

import ./nodes/primitive
import ./nodes/sprite
import ./nodes/text
import ./nodes/path
import ./nodes/button
import ./nodes/selection

import ./layout/alignment
import ./layout/container
import ./layout/grid
import ./layout/flow
import ./hex/hex
import ./debug/layout_overlay

import ./ui/primitives as uip
import ./ui/tooltip
import ./ui/dialog

export types
export transform
export events
export context
export colors
export layout
export primitive.RectNode, primitive.CircleNode
export primitive.newRectNode, primitive.newCircleNode
export sprite.SpriteNode
export sprite.newSpriteNode, sprite.newSpriteNodeWithSlice
export text.TextNode, text.HorizontalAlign, text.VerticalAlign
export text.newTextNode
export path.PathNode
export path.newPathNode
export button.Button, button.ButtonState, button.ButtonColors
export button.newButton, button.setState, button.setEnabled, button.isEnabled
export button.handleMouseEnter, button.handleMouseLeave, button.handleMouseDown, button.handleMouseUp
export button.setText, button.updateVisualState, button.contains
export selection.SelectionOverlay, selection.SelectionStyle
export selection.newSelectionOverlay, selection.attachTo, selection.show, selection.hide
export selection.setStyle, selection.setColor, selection.updateTransform
export alignment.Anchor, alignment.Pivot
export container.HBox, container.VBox
export container.newHBox, container.newVBox
export container.addItem, container.update, container.withSize
export grid.Grid, grid.newGrid, grid.addItem
export flow.Flow, flow.newFlow, flow.addItem
export hex.HexOrientation, hex.pointyOrientation, hex.flatOrientation
export uip.NavBarItem, uip.newNavBarItem
export uip.Card, uip.newCard, uip.setCardContent
export uip.SectionHeader, uip.newSectionHeader
export uip.Badge, uip.newBadge
export uip.Chip, uip.newChip
export uip.LabelValueRow, uip.newLabelValueRow, uip.setValue
export uip.NavBar, uip.newNavBar, uip.addNavItem, uip.setActiveItem
export tooltip.Tooltip, tooltip.TooltipPosition
export tooltip.newTooltip, tooltip.show, tooltip.hide, tooltip.setText
export tooltip.updatePosition, tooltip.clampToViewport
export dialog.Dialog
export dialog.newDialog, dialog.open, dialog.closeDialog, dialog.addContent, dialog.addButton
export dialog.centerInViewport, dialog.handleOverlayClick
export layout_overlay.DebugOverlay, layout_overlay.newDebugOverlay
export layout_overlay.setEnabled, layout_overlay.setShowBounds, layout_overlay.setShowAnchors
export layout_overlay.setShowLayoutInfo, layout_overlay.setShowClipRegions, layout_overlay.setShowHierarchy
export layout_overlay.setTargetNode, layout_overlay.toggle
