import vmath
import ../core/types
import ../layout/alignment

proc layoutNode*(node: Node, parentSize: Vec2, isRoot: bool = false) =
  node.layoutValid = true

  let previousSize = node.size
  var targetSize = node.size

  case node.sizeMode:
  of Absolute:
    targetSize = node.size
  of FillParent:
    targetSize = parentSize
  of Percent:
    targetSize = vec2(parentSize.x * node.sizePercent.x, parentSize.y * node.sizePercent.y)

  if node.minSize.x > 0: targetSize.x = max(targetSize.x, node.minSize.x)
  if node.minSize.y > 0: targetSize.y = max(targetSize.y, node.minSize.y)
  if node.maxSize.x > 0: targetSize.x = min(targetSize.x, node.maxSize.x)
  if node.maxSize.y > 0: targetSize.y = min(targetSize.y, node.maxSize.y)

  node.size = targetSize
  if node.size != previousSize:
    node.markDirty()

  if node.autoLayout:
    let boundsForAnchor = if isRoot: parentSize else: parentSize

    case node.anchor:
    of TopLeft:
      node.localPos = node.anchorOffset
    of TopCenter:
      node.localPos = vec2(boundsForAnchor.x / 2 - node.size.x / 2, 0) + node.anchorOffset
    of TopRight:
      node.localPos = vec2(boundsForAnchor.x - node.size.x, 0) + node.anchorOffset
    of CenterLeft:
      node.localPos = vec2(0, boundsForAnchor.y / 2 - node.size.y / 2) + node.anchorOffset
    of Center:
      node.localPos = vec2(boundsForAnchor.x / 2 - node.size.x / 2, boundsForAnchor.y / 2 - node.size.y / 2) + node.anchorOffset
    of CenterRight:
      node.localPos = vec2(boundsForAnchor.x - node.size.x, boundsForAnchor.y / 2 - node.size.y / 2) + node.anchorOffset
    of BottomLeft:
      node.localPos = vec2(0, boundsForAnchor.y - node.size.y) + node.anchorOffset
    of BottomCenter:
      node.localPos = vec2(boundsForAnchor.x / 2 - node.size.x / 2, boundsForAnchor.y - node.size.y) + node.anchorOffset
    of BottomRight:
      node.localPos = vec2(boundsForAnchor.x - node.size.x, boundsForAnchor.y - node.size.y) + node.anchorOffset

  for child in node.children:
    if not child.layoutValid:
      child.layoutNode(node.size, false)

proc requestLayout*(node: Node) =
  node.layoutValid = false
  for child in node.children:
    child.requestLayout()
