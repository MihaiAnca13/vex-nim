import std/options
import vmath
import ./types
import ./transform

type
  HitTestResult* = object
    node*: Node
    localPosition*: Vec2

  EventPhase* = enum
    PhaseCapturing
    PhaseAtTarget
    PhaseBubbling

  EventListener* = object
    node*: Node
    eventType*: EventType
    callback*: proc(event: InputEvent)

proc hitTest*(root: Node, position: Vec2): Option[HitTestResult] =
  for node in root.traversePostOrder:
    if not node.visible:
      continue
    let localPos = node.globalToLocal(position)
    if node.contains(localPos):
      return some(HitTestResult(node: node, localPosition: localPos))
  return none(HitTestResult)

proc hitTestAll*(root: Node, position: Vec2): seq[HitTestResult] =
  var results: seq[HitTestResult] = @[]
  for node in root.traversePostOrder:
    if not node.visible:
      continue
    let localPos = node.globalToLocal(position)
    if node.contains(localPos):
      results.add(HitTestResult(node: node, localPosition: localPos))
  return results

proc dispatchEvent*(target: Node, event: var InputEvent): bool =
  event.target = target
  result = true

proc dispatchEventToAncestors*(startNode: Node, event: var InputEvent, includeStart = true): bool =
  var nodesToNotify: seq[Node] = @[]
  var current = startNode.parent
  while current.isSome:
    let node = current.get()
    nodesToNotify.add(node)
    current = node.parent

  for node in nodesToNotify.items:
    event.target = node

  result = true

proc createMouseEvent*(eventType: EventType, position: Vec2, modifiers: set[ModifierKey] = {}): InputEvent =
  InputEvent(eventType: eventType, position: position, modifierKeys: modifiers)

proc createKeyEvent*(eventType: EventType, key: int, modifiers: set[ModifierKey] = {}): InputEvent =
  InputEvent(eventType: eventType, position: vec2(0, 0), modifierKeys: modifiers)

proc isMouseButton*(event: InputEvent): bool =
  event.eventType in {EventMouseDown, EventMouseUp, EventMouseMove}

proc isKeyEvent*(event: InputEvent): bool =
  event.eventType in {EventKeyDown, EventKeyUp}

proc getMousePosition*(event: InputEvent): Vec2 =
  event.position

proc getModifierState*(event: InputEvent): set[ModifierKey] =
  event.modifierKeys

proc shouldReceiveEvents*(node: Node): bool =
  node.visible

proc getEventPropagationPath*(fromNode: Node): seq[Node] =
  var path: seq[Node] = @[]
  var current = fromNode.parent
  while current.isSome:
    path.add(current.get())
    current = current.get().parent
  return path

proc stopEventPropagation*(event: var InputEvent) =
  discard

proc isEventStopped*(event: InputEvent): bool =
  false
