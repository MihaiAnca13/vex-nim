import std/[options, hashes, tables]
import vmath
import pixie
import boxy

## Node is the base type for all scene graph objects.
##
## Nodes form a tree structure where each node can have children.
## The rendering pipeline rasterizes dirty nodes to textures,
## then Boxy renders the cached textures at 60+ FPS.
type
  Node* = ref object of RootObj
    parent*: Option[Node]              ## Parent node, none if root
    children*: seq[Node]               ## Child nodes
    localPos*: Vec2                    ## Position relative to parent
    localScale*: Vec2                  ## Scale factor (default: 1,1)
    localRotation*: float32            ## Rotation in radians
    globalTransform*: Mat3             ## Computed world-space transform
    dirty*: bool                       ## True if node needs re-rasterization
    visible*: bool                     ## False to skip rendering
    name*: string                      ## Optional name for debugging
    size*: Vec2                        ## Node dimensions (used for hit testing)
    zIndex*: int                       ## Rendering order (higher = on top)
    clipChildren*: bool                ## TODO: Not yet implemented (requires Boxy scissor)
    childrenSorted*: bool              ## True if children are sorted by zIndex

## RenderContext wraps Boxy with texture caching and scene graph rendering.
##
## The RenderContext manages:
## - Boxy instance for GPU rendering
## - Texture cache for rasterized nodes
## - Font and image caches
## - Viewport dimensions
type
  RenderContext* = ref object
    bxy*: Boxy                        ## Boxy instance for GPU rendering
    nodeTextures*: Table[Node, string] ## Maps nodes to cached texture keys
    imageCache*: Table[string, Image]  ## Cached images by key
    fontCache*: Table[string, Font]    ## Cached fonts by path
    nextNodeId*: int                   ## Texture key counter
    viewportSize*: Vec2                ## Current viewport dimensions

## EventType identifies the type of input event.
type
  EventType* = enum
    EventMouseDown                     ## Mouse button pressed
    EventMouseUp                       ## Mouse button released
    EventMouseMove                     ## Mouse cursor moved
    EventKeyDown                       ## Key pressed
    EventKeyUp                         ## Key released

## ModifierKey represents keyboard modifier states.
type
  ModifierKey* = enum
    ModShift                           ## Shift key
    ModCtrl                            ## Control key
    ModAlt                             ## Alt/Option key
    ModMeta                            ## Command/Windows key

## InputEvent represents a single input event.
type
  InputEvent* = object
    eventType*: EventType              ## Type of event
    position*: Vec2                    ## Mouse position in screen coordinates
    modifierKeys*: set[ModifierKey]    ## Active modifier keys
    target*: Node                      ## Node that received the event

## StackItem is used internally for traversal algorithms.
type
  StackItem* = tuple[node: Node, visited: bool]

const
  defaultPadding* = 4.0                ## Default padding for layout containers
  identityTransform*: Mat3 = mat3(     ## Identity matrix (no transform)
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0
  )

## Creates a new Node with default values.
proc newNode*(): Node =
  Node(
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
    childrenSorted: true
  )

proc markDirty*(node: Node)

## Adds a child node to the parent.
##
## Raises assertion if child already has a different parent
## or if child is already a child of parent.
proc addChild*(parent: Node, child: Node) =
  doAssert child.parent.isNone or child.parent.get() != parent, "Node already has a different parent"
  for c in parent.children:
    doAssert c != child, "Node is already a child"
  parent.children.add(child)
  child.parent = some(parent)
  parent.childrenSorted = false
  parent.markDirty()

## Removes a child node from the parent.
##
## Raises assertion if child is not a child of parent.
proc removeChild*(parent: Node, child: Node) =
  let idx = parent.children.find(child)
  doAssert idx != -1, "Node is not a child"
  parent.children.delete(idx)
  child.parent = none(Node)
  parent.markDirty()

## Returns true if `ancestor` is in the parent chain of `node`.
proc isAncestorOf*(ancestor, node: Node): bool =
  var current = node.parent
  while current.isSome:
    if current.get() == ancestor:
      return true
    current = current.get().parent
  return false

## Computes the local transformation matrix (position, rotation, scale).
proc computeLocalTransform*(node: Node): Mat3 =
  let t = translate(node.localPos)
  let r = rotate(node.localRotation)
  let s = scale(node.localScale)
  t * r * s

## Computes the global (world-space) transformation matrix.
proc computeGlobalTransform*(node: Node): Mat3 =
  let local = node.computeLocalTransform()
  if node.parent.isSome:
    node.parent.get().computeGlobalTransform() * local
  else:
    local

## Updates globalTransform for the node only (parent-to-child propagation
## ensures children are updated correctly when called from root once).
proc updateGlobalTransform*(node: Node) =
  node.globalTransform = node.computeGlobalTransform()

## Marks the node as dirty, requiring re-rasterization.
proc markDirty*(node: Node) =
  node.dirty = true

## Marks this node and all ancestors as dirty (for layout changes).
proc markDirtyUp*(node: Node) =
  node.markDirty()
  if node.parent.isSome:
    node.parent.get().markDirtyUp()

## Marks this node and all descendants as dirty.
proc markDirtyDown*(node: Node) =
  node.markDirty()
  for child in node.children:
    child.markDirtyDown()

## Tests if `point` (in local coordinates) is within the node's bounds.
proc contains*(node: Node, point: Vec2): bool =
  let bounds = rect(0, 0, node.size.x, node.size.y)
  point.x >= bounds.x and point.x < bounds.x + bounds.w and
  point.y >= bounds.y and point.y < bounds.y + bounds.h

## Base draw method. Override in derived types.
method draw*(node: Node, ctx: RenderContext, image: Image) {.base.} =
  discard

## Base measure method. Override in derived types for auto-sizing.
method measure*(node: Node, ctx: RenderContext) {.base.} =
  discard

## Finds a child node by name (recursive search).
proc findChildByName*(node: Node, name: string): Option[Node] =
  for child in node.children:
    if child.name == name:
      return some(child)
    let found = child.findChildByName(name)
    if found.isSome:
      return found
  return none(Node)

## Iterates over the node and all descendants (pre-order).
iterator traverse*(node: Node): Node =
  var stack = @[node]
  while stack.len > 0:
    let current = stack.pop()
    yield current
    for child in current.children:
      stack.add(child)

## Iterates over the node and all descendants (post-order, children before parents).
iterator traversePostOrder*(node: Node): Node =
  var stack: seq[StackItem] = @[(node, false)]
  var output: seq[Node] = @[]
  while stack.len > 0:
    let (current, visited) = stack.pop()
    if visited:
      output.add(current)
    else:
      stack.add((current, true))
      for i in countdown(current.children.high, 0):
        stack.add((current.children[i], false))
  for n in output:
    yield n

## Hash function for Node (enables use as Table key).
proc hash*(node: Node): Hash =
  cast[pointer](node).hash

export EventType, InputEvent, ModifierKey
