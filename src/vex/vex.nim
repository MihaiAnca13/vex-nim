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

import ./layout/alignment
import ./layout/container
import ./hex/hex

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
export alignment.Anchor, alignment.Pivot
export container.HBox, container.VBox
export container.newHBox, container.newVBox
export container.addItem, container.update, container.withSize
export hex.HexOrientation, hex.pointyOrientation, hex.flatOrientation
export hex.newHexLayout, hex.newHexGrid
export hex.addHex, hex.removeHex, hex.getHex, hex.hexAt, hex.updateGrid
