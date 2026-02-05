import std/options
import unittest
import vmath
import bumpy
import pixie

import ../src/vex/core/types
import ../src/vex/core/transform
import ../src/vex/nodes/text

suite "text.nim - TextNode":
  test "newTextNode creates node with defaults":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    check node.text == "Hello"
    check node.fontPath == "/fonts/test.ttf"
    check node.fontSize == 16.0
    check node.color == color(0, 0, 0, 1)
    check node.maxWidth == 0.0
    check node.horizontalAlign == AlignLeft
    check node.verticalAlign == AlignTop

  test "newTextNode with custom fontSize":
    let node = newTextNode("Hello", "/fonts/test.ttf", 24.0)
    check node.fontSize == 24.0

  test "newTextNode with custom color":
    let node = newTextNode("Hello", "/fonts/test.ttf", 16.0, color(1, 0, 0, 1))
    check node.color == color(1, 0, 0, 1)

  test "TextNode has HorizontalAlign field":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    discard node.horizontalAlign

  test "TextNode has VerticalAlign field":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    discard node.verticalAlign

  test "TextNode.text is set correctly":
    let node = newTextNode("Hello World", "/fonts/test.ttf")
    check node.text == "Hello World"

  test "TextNode.fontPath is set correctly":
    let node = newTextNode("Hello", "/fonts/custom.ttf")
    check node.fontPath == "/fonts/custom.ttf"

  test "TextNode.maxWidth defaults to 0":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    check node.maxWidth == 0.0

  test "TextNode.maxWidth can be set":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    node.maxWidth = 100.0
    check node.maxWidth == 100.0

  test "TextNode horizontalAlign can be changed":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    node.horizontalAlign = AlignCenter
    check node.horizontalAlign == AlignCenter

    node.horizontalAlign = AlignRight
    check node.horizontalAlign == AlignRight

  test "TextNode verticalAlign can be changed":
    let node = newTextNode("Hello", "/fonts/test.ttf")
    node.verticalAlign = AlignCenter
    check node.verticalAlign == AlignCenter

    node.verticalAlign = AlignBottom
    check node.verticalAlign == AlignBottom

  test "TextNode contains works for hit testing":
    let node = newTextNode("Hello", "/fonts/test.ttf", 16.0)
    node.size = vec2(100, 20)
    check node.contains(vec2(10, 10)) == true
    check node.contains(vec2(50, 10)) == true
    check node.contains(vec2(0, 0)) == true
    check node.contains(vec2(100, 10)) == false
    check node.contains(vec2(50, 20)) == false
