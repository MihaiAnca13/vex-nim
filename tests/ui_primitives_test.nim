import unittest
import std/options
import vmath
import pixie
import vex

suite "ui_primitives.nim - UI Primitives":
  test "newCard creates card with title":
    let card = newCard("Test Title")
    check card.titleNode.isSome()

  test "newCard without title has no titleNode":
    let card = newCard()
    check card.titleNode.isNone()

  test "Card has VBox behavior":
    let card = newCard()
    check card of VBox

  test "newSectionHeader creates header":
    let header = newSectionHeader("SECTION")
    check header.labelNode.text == "SECTION"

  test "SectionHeader has HBox behavior":
    let header = newSectionHeader("Test")
    check header of HBox

  test "newBadge creates badge":
    let badge = newBadge("NEW", colRed)
    check badge.textNode.text == "NEW"

  test "Badge has HBox behavior":
    let badge = newBadge("Test", colBlue)
    check badge of HBox

  test "newChip creates chip":
    let chip = newChip("Label")
    check chip.textNode.text == "Label"

  test "Chip has HBox behavior":
    let chip = newChip("Test")
    check chip of HBox

  test "newLabelValueRow creates row":
    let row = newLabelValueRow("Key", "Value")
    check row.labelNode.text == "Key"
    check row.valueNode.text == "Value"

  test "LabelValueRow has HBox behavior":
    let row = newLabelValueRow("L", "V")
    check row of HBox

  test "setValue updates row value":
    let row = newLabelValueRow("Key", "Old")
    row.setValue("New")
    check row.valueNode.text == "New"

  test "newNavBar creates nav bar":
    let nav = newNavBar()
    check nav.items.len == 0

  test "NavBar has HBox behavior":
    let nav = newNavBar()
    check nav of HBox

  test "addNavItem adds item":
    let nav = newNavBar()
    let item = newNavBarItem("Home")
    nav.addNavItem(item)
    check nav.items.len == 1

  test "setActiveItem activates item":
    let nav = newNavBar()
    let item1 = newNavBarItem("Home")
    let item2 = newNavBarItem("Stats")
    nav.addNavItem(item1)
    nav.addNavItem(item2)
    nav.setActiveItem(item2)
    check nav.activeItem.get() == item2
    check item1.isActive == false
    check item2.isActive == true

  test "NavBarItem has Node behavior":
    let item = newNavBarItem("Test")
    check item of Node

  test "newNavBarItem creates item with label":
    let item = newNavBarItem("Dashboard")
    check item.label == "Dashboard"
    check item.isActive == false

  test "Badge with custom colors":
    let badge = newBadge("SALE", colGreen, color(1, 1, 1, 1))
    check badge.textNode.text == "SALE"

  test "Chip without close button":
    let chip = newChip("Tag")
    check chip.closeButton.isNone()

  test "Chip with close callback":
    var called = false
    let chip = newChip("Closeable", proc() = (called = true))
    check chip.closeButton.isSome()
