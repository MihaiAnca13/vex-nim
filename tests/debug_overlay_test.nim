import std/options
import unittest
import vmath
import pixie
import vex

suite "debug_overlay.nim - DebugOverlay":
  test "newDebugOverlay creates overlay with defaults":
    let overlay = newDebugOverlay()
    check overlay.enabled == true
    check overlay.showBounds == true
    check overlay.showAnchors == false
    check overlay.showLayoutInfo == false
    check overlay.showClipRegions == false
    check overlay.showHierarchy == false
    check overlay.targetNode.isNone()
    check overlay.name == "DebugOverlay"
    check overlay.zIndex == 99999

  test "DebugOverlay methods modify state":
    let overlay = newDebugOverlay()
    overlay.setEnabled(false)
    check overlay.enabled == false

    overlay.setShowBounds(false)
    check overlay.showBounds == false

    overlay.setShowAnchors(true)
    check overlay.showAnchors == true

    overlay.setShowLayoutInfo(true)
    check overlay.showLayoutInfo == true

    overlay.setShowClipRegions(true)
    check overlay.showClipRegions == true

    overlay.setShowHierarchy(true)
    check overlay.showHierarchy == true

  test "toggle switches enabled state":
    let overlay = newDebugOverlay()
    check overlay.enabled == true
    overlay.toggle()
    check overlay.enabled == false
    overlay.toggle()
    check overlay.enabled == true

  test "DebugOverlay can target specific node":
    let target = newNode()
    let overlay = newDebugOverlay()
    overlay.setTargetNode(target)
    check overlay.targetNode.isSome()
    check overlay.targetNode.get() == target
