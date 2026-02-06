import std/options
import unittest
import pixie
import vmath
import ../src/vex

suite "SelectionOverlay":
  test "overlay creation":
    let overlay = newSelectionOverlay()
    check overlay.style == SelectionStyleBorder
    check overlay.visible == false
    check overlay.zIndex == 500

  test "overlay style variations":
    let borderOverlay = newSelectionOverlay(SelectionStyleBorder)
    check borderOverlay.style == SelectionStyleBorder
    
    let glowOverlay = newSelectionOverlay(SelectionStyleGlow)
    check glowOverlay.style == SelectionStyleGlow
    
    let fillOverlay = newSelectionOverlay(SelectionStyleFill)
    check fillOverlay.style == SelectionStyleFill
    
    let dashedOverlay = newSelectionOverlay(SelectionStyleDashed)
    check dashedOverlay.style == SelectionStyleDashed

  test "overlay attach and show":
    let overlay = newSelectionOverlay()
    let target = newRectNode(vec2(100, 50))
    target.localPos = vec2(50, 75)
    
    overlay.attachTo(target)
    check overlay.target.isSome == true
    check overlay.size == target.size
    check overlay.localPos == target.localPos
    
    overlay.show()
    check overlay.visible == true
    check overlay.isVisible == true

  test "overlay hide":
    let overlay = newSelectionOverlay()
    let target = newRectNode(vec2(100, 50))
    
    overlay.attachTo(target)
    overlay.show()
    overlay.hide()
    check overlay.visible == false
    check overlay.isVisible == false

  test "overlay color change":
    let overlay = newSelectionOverlay()
    let newColor = color(1.0, 0.0, 0.0, 1.0)
    overlay.setColor(newColor)
    check overlay.color == newColor

  test "overlay style change":
    let overlay = newSelectionOverlay(SelectionStyleBorder)
    overlay.setStyle(SelectionStyleGlow)
    check overlay.style == SelectionStyleGlow

  test "glow style expands size":
    let overlay = newSelectionOverlay(SelectionStyleGlow, glowRadius = 10.0)
    let target = newRectNode(vec2(100, 50))
    target.localPos = vec2(0, 0)
    
    overlay.attachTo(target)
    check overlay.size.x == target.size.x + 20.0
    check overlay.size.y == target.size.y + 20.0
    check overlay.localPos.x == -10.0
    check overlay.localPos.y == -10.0
