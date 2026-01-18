import std/options
import unittest
import vmath

import ../src/vex/core/types
import ../src/vex/nodes/primitive
import ../src/vex/layout/container

suite "container.nim - HBox":
  test "newHBox creates container with defaults":
    let hbox = newHBox()
    check hbox.spacing == 4.0
    check hbox.padding == 4.0
    check hbox.children.len == 0
    check hbox.visible == true
    check hbox.dirty == true

  test "newHBox with custom spacing and padding":
    let hbox = newHBox(spacing = 10.0, padding = 8.0)
    check hbox.spacing == 10.0
    check hbox.padding == 8.0

  test "HBox.addItem adds child and marks dirty":
    let hbox = newHBox()
    let child = newRectNode(vec2(50, 50))
    hbox.addItem(child)
    check hbox.children.len == 1
    check hbox.dirty == true
    check child.parent.isSome

  test "HBox.update with no children":
    let hbox = newHBox()
    hbox.update()
    check hbox.size == vec2(8.0, 8.0)

  test "HBox.update positions children horizontally":
    let hbox = newHBox(spacing = 4.0, padding = 4.0)
    let child1 = newRectNode(vec2(50, 30))
    let child2 = newRectNode(vec2(40, 60))
    hbox.addItem(child1)
    hbox.addItem(child2)
    hbox.update()
    check child1.localPos == vec2(4.0, 4.0)
    check child2.localPos == vec2(58.0, 4.0)
    check hbox.size.x == 106.0
    check hbox.size.y == 68.0

  test "HBox.update uses max child height":
    let hbox = newHBox(spacing = 4.0, padding = 4.0)
    let child1 = newRectNode(vec2(50, 30))
    let child2 = newRectNode(vec2(40, 60))
    hbox.addItem(child1)
    hbox.addItem(child2)
    hbox.update()
    check hbox.size.y == 68.0

  test "HBox inherits from Node type":
    let hbox = newHBox()
    check hbox of HBox
    check hbox of Node

suite "container.nim - VBox":
  test "newVBox creates container with defaults":
    let vbox = newVBox()
    check vbox.spacing == 4.0
    check vbox.padding == 4.0
    check vbox.children.len == 0
    check vbox.visible == true
    check vbox.dirty == true

  test "newVBox with custom spacing and padding":
    let vbox = newVBox(spacing = 10.0, padding = 8.0)
    check vbox.spacing == 10.0
    check vbox.padding == 8.0

  test "VBox.addItem adds child and marks dirty":
    let vbox = newVBox()
    let child = newRectNode(vec2(50, 50))
    vbox.addItem(child)
    check vbox.children.len == 1
    check vbox.dirty == true
    check child.parent.isSome

  test "VBox.update with no children":
    let vbox = newVBox()
    vbox.update()
    check vbox.size == vec2(8.0, 8.0)

  test "VBox.update positions children vertically":
    let vbox = newVBox(spacing = 4.0, padding = 4.0)
    let child1 = newRectNode(vec2(50, 30))
    let child2 = newRectNode(vec2(60, 40))
    vbox.addItem(child1)
    vbox.addItem(child2)
    vbox.update()
    check child1.localPos == vec2(4.0, 4.0)
    check child2.localPos == vec2(4.0, 38.0)
    check vbox.size.x == 68.0
    check vbox.size.y == 86.0

  test "VBox.update uses max child width":
    let vbox = newVBox(spacing = 4.0, padding = 4.0)
    let child1 = newRectNode(vec2(50, 30))
    let child2 = newRectNode(vec2(60, 40))
    vbox.addItem(child1)
    vbox.addItem(child2)
    vbox.update()
    check vbox.size.x == 68.0

  test "VBox inherits from Node type":
    let vbox = newVBox()
    check vbox of VBox
    check vbox of Node

suite "container.nim - Mixed layout":
  test "HBox and VBox can be nested":
    let vbox = newVBox()
    let hbox = newHBox()
    let child = newRectNode(vec2(50, 50))
    hbox.addItem(child)
    vbox.addItem(hbox)
    check vbox.children.len == 1
    check hbox.parent.isSome
    check hbox.children.len == 1
