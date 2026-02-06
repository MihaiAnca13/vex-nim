import std/options
import unittest
import pixie
import vmath
import ../src/vex

const TestFontPath = "tests/data/DejaVuSans.ttf"

suite "Button":
  test "button creation":
    let btn = newButton("Test Button", TestFontPath)
    check btn.label.text == "Test Button"
    check btn.state == ButtonStateNormal
    check btn.isEnabled() == true

  test "button state transitions":
    let btn = newButton("Test", TestFontPath)
    
    btn.handleMouseEnter()
    check btn.state == ButtonStateHover
    
    btn.handleMouseDown()
    check btn.state == ButtonStateActive
    
    btn.handleMouseUp()
    check btn.state == ButtonStateHover
    
    btn.handleMouseLeave()
    check btn.state == ButtonStateNormal

  test "button disabled state":
    let btn = newButton("Test", TestFontPath)
    btn.setEnabled(false)
    check btn.state == ButtonStateDisabled
    check btn.isEnabled() == false
    
    btn.handleMouseEnter()
    check btn.state == ButtonStateDisabled
    
    btn.setEnabled(true)
    check btn.isEnabled() == true
    check btn.state == ButtonStateNormal

  test "button click callback":
    let btn = newButton("Click Me", TestFontPath)
    var clicked = false
    btn.onClick = proc() =
      clicked = true
    
    btn.handleMouseEnter()
    btn.handleMouseDown()
    btn.handleMouseUp()
    check clicked == true

  test "button text change":
    let btn = newButton("Original", TestFontPath)
    check btn.label.text == "Original"
    btn.setText("Updated")
    check btn.label.text == "Updated"

  test "button contains point":
    let btn = newButton("Test", TestFontPath, size = vec2(100, 50))
    btn.localPos = vec2(10, 20)
    btn.updateGlobalTransform()
    
    # Test points relative to button's local bounds (0,0) to (100,50)
    # Point (15, 25) in global = (5, 5) in local = inside
    check btn.contains(vec2(15, 25)) == true
    # Point (105, 65) in global = (95, 45) in local = inside
    check btn.contains(vec2(105, 65)) == true
    # Point (5, 25) in global = (-5, 5) in local = outside (x < 0)
    check btn.contains(vec2(5, 25)) == false
    # Point (115, 25) in global = (105, 5) in local = outside (x >= 100)
    check btn.contains(vec2(115, 25)) == false

  test "button visual state colors":
    let btn = newButton("Test", TestFontPath)
    
    btn.setState(ButtonStateHover)
    check btn.label.color == btn.colors.hoverText
    
    btn.setState(ButtonStateActive)
    check btn.label.color == btn.colors.activeText
    
    btn.setState(ButtonStateDisabled)
    check btn.label.color == btn.colors.disabledText

  test "button disabled prevents click":
    let btn = newButton("Test", TestFontPath)
    var clicked = false
    btn.onClick = proc() =
      clicked = true
    
    btn.setEnabled(false)
    btn.handleMouseEnter()
    btn.handleMouseDown()
    btn.handleMouseUp()
    check clicked == false
