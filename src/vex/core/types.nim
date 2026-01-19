import std/[options, hashes]
import vmath
import pixie

type
  Node* = ref object of RootObj
    parent*: Option[Node]
    children*: seq[Node]
    localPos*: Vec2
    localScale*: Vec2
    localRotation*: float32
    globalTransform*: Mat3
    dirty*: bool
    visible*: bool
    name*: string
    size*: Vec2

  EventType* = enum
    EventMouseDown
    EventMouseUp
    EventMouseMove
    EventKeyDown
    EventKeyUp

  ModifierKey* = enum
    ModShift
    ModCtrl
    ModAlt
    ModMeta

  InputEvent* = object
    eventType*: EventType
    position*: Vec2
    modifierKeys*: set[ModifierKey]
    target*: Node

  StackItem* = tuple[node: Node, visited: bool]

const
  defaultPadding* = 4.0
  identityTransform*: Mat3 = mat3(
    1.0, 0.0, 0.0,
    0.0, 1.0, 0.0,
    0.0, 0.0, 1.0
  )

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
    size: vec2(0, 0)
  )

proc markDirty*(node: Node)

proc addChild*(parent: Node, child: Node) =
  doAssert child.parent.isNone or child.parent.get() != parent, "Node already has a different parent"
  for c in parent.children:
    doAssert c != child, "Node is already a child"
  parent.children.add(child)
  child.parent = some(parent)
  parent.markDirty()

proc removeChild*(parent: Node, child: Node) =
  let idx = parent.children.find(child)
  doAssert idx != -1, "Node is not a child"
  parent.children.delete(idx)
  child.parent = none(Node)
  parent.markDirty()

proc isAncestorOf*(ancestor, node: Node): bool =
  var current = node.parent
  while current.isSome:
    if current.get() == ancestor:
      return true
    current = current.get().parent
  return false

proc computeLocalTransform*(node: Node): Mat3 =
  let t = translate(node.localPos)
  let r = rotate(node.localRotation)
  let s = scale(node.localScale)
  t * r * s

proc computeGlobalTransform*(node: Node): Mat3 =
  let local = node.computeLocalTransform()
  if node.parent.isSome:
    node.parent.get().computeGlobalTransform() * local
  else:
    local

proc updateGlobalTransform*(node: Node) =
  node.globalTransform = node.computeGlobalTransform()
  node.dirty = false
  for child in node.children:
    child.updateGlobalTransform()

proc markDirty*(node: Node) =
  node.dirty = true
  for child in node.children:
    child.markDirty()

proc contains*(node: Node, point: Vec2): bool =
  let bounds = rect(0, 0, node.size.x, node.size.y)
  point.x >= bounds.x and point.x < bounds.x + bounds.w and
  point.y >= bounds.y and point.y < bounds.y + bounds.h

proc draw*[T](node: Node, ctx: T, image: Image) {.raises: [].} =
  discard

proc findChildByName*(node: Node, name: string): Option[Node] =
  for child in node.children:
    if child.name == name:
      return some(child)
    let found = child.findChildByName(name)
    if found.isSome:
      return found
  return none(Node)

iterator traverse*(node: Node): Node =
  var stack = @[node]
  while stack.len > 0:
    let current = stack.pop()
    yield current
    for child in current.children:
      stack.add(child)

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

proc hash*(node: Node): Hash =
  cast[pointer](node).hash

export EventType, InputEvent, ModifierKey
