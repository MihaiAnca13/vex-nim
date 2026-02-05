## Headless UI Primitives Demo for Visual Testing
##
## This generates a screenshot for visual verification

import std/os
import vmath
import pixie
import bumpy
import vex

const OutputPath = "/tmp/vex_ui_primitives_test.png"

proc main() =
  let ctx = newHeadlessRenderContext(vec2(800, 600))

  let root = newVBox(spacing = 16, padding = 20)
  root.localPos = vec2(50, 50)

  let header = newSectionHeader("UI Components")
  root.addItem(header)

  let card = newCard("Player Resources")
  let content = newVBox(spacing = 4, padding = 0)
  content.addItem(newLabelValueRow("Materials", "15"))
  content.addItem(newLabelValueRow("Science", "8"))
  content.addItem(newLabelValueRow("Money", "250"))
  card.setCardContent(content)
  root.addItem(card)

  let chipRow = newHBox(spacing = 8)
  chipRow.padding = 0
  chipRow.addItem(newChip("Terraforming"))
  chipRow.addItem(newChip("Warfare"))
  chipRow.addItem(newChip("Trade"))
  root.addItem(chipRow)

  let badgeRow = newHBox(spacing = 8)
  badgeRow.padding = 0
  badgeRow.addItem(newBadge("NEW", colRed))
  badgeRow.addItem(newBadge("SALE", colGreen))
  badgeRow.addItem(newBadge("HOT", colOrange))
  root.addItem(badgeRow)

  let navBar = newNavBar()
  navBar.fillWidth = true
  navBar.addNavItem(newNavBarItem("Home"))
  navBar.addNavItem(newNavBarItem("Stats"))
  navBar.addNavItem(newNavBarItem("Settings"))
  navBar.setActiveItem(navBar.items[0])
  root.addItem(navBar)

  header.update(ctx)
  card.update(ctx)
  chipRow.update(ctx)
  badgeRow.update(ctx)
  navBar.update(ctx)

  let image = ctx.renderToImage(root)
  image.writeFile(OutputPath)
  echo "Saved UI primitives screenshot to " & OutputPath

when isMainModule:
  main()
