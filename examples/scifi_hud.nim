import std/[json, options, strutils, tables]
import vex, windy, opengl, vmath, pixie

# --- Configuration ---
const
  WindowSize = ivec2(1280, 720)
  HexSize = vec2(40, 40)
  FontPath = "examples/assets/Orbitron.ttf"
  UnitPath = "examples/assets/enemyRed.png"
  UnitBluePath = "examples/assets/enemyBlue.png"

# --- Load External Data ---
type MapData = object
  name: string
  difficulty: string
  biomes: Table[string, string] # hex color strings
  tiles: seq[tuple[q, r: int, `type`: string]]

let jsonNode = parseFile("examples/assets/map_data.json")
let mapData = jsonNode.to(MapData)

# --- Window Setup ---
let window = newWindow("VEX - SciFi Tactical Interface", WindowSize)
makeContextCurrent(window)
loadExtensions()

# --- Vex Context ---
let ctx = newRenderContext(WindowSize.vec2)

# Load Resources
ctx.getFont(FontPath).size = 20
ctx.addImage("enemyRed", readImage(UnitPath))
ctx.addImage("enemyBlue", readImage(UnitBluePath))

# --- Scene Construction ---
let root = newNode()
root.size = WindowSize.vec2

# 1. Background Layer (Starfield simulation)
let bg = newRectNode(WindowSize.vec2)
bg.fill = some(solidPaint(hex"#1a1a2e")) # Using new hex macro and solidPaint
root.addChild(bg)

# 2. Hex Map Container (Centered)
let gridLayout = newHexLayout(pointyOrientation, HexSize, vec2(0,0))
let hexGrid = newHexGrid(gridLayout)

# Populate Grid from JSON
for tile in mapData.tiles:
  let coord = (tile.q, tile.r)
  let hexNode = hexGrid.addHex(coord)
  
  # Style based on JSON biome
  let colorHex = mapData.biomes[tile.`type`]
  hexNode.fill = some(solidPaint(hex(colorHex)))
  hexNode.stroke = some(solidPaint(hex"#4ecca3"))
  hexNode.strokeWidth = 2.0

  # Add Unit Sprite to the Base
  if tile.`type` == "base":
    let unit = newSpriteNode("enemyRed", vec2(48, 48))
    unit.localPos = hexNode.size / 2 - unit.size / 2 
    hexNode.addChild(unit)

hexGrid.updateGrid()

let gridRoot = newNode()
gridRoot.localPos = WindowSize.vec2 / 2
root.addChild(gridRoot)

hexGrid.localPos = -hexGrid.getLocalBoundsCenter()
gridRoot.addChild(hexGrid)

# 3. Ship (Image swap demo)
let ship2 = newSpriteNode("enemyRed", vec2(48, 48))
ship2.localPos = vec2(WindowSize.x.float32 - 140, 120)
root.addChild(ship2)

# 4. UI Layer (HUD)
let uiRoot = newRectNode(WindowSize.vec2)
uiRoot.fill = none(Paint)
root.addChild(uiRoot)

# -- Side Panel (VBox) --
let panel = newVBox(spacing = 10, padding = 20)
panel.localPos = vec2(20, 20)

# Title
let title = newTextNode(mapData.name.toUpperAscii(), FontPath, 28, hex"#e94560")
panel.addItem(title)

# Stats Block
let stats = newVBox(spacing = 5, padding = 0)
stats.addItem(newTextNode("DIFFICULTY: " & mapData.difficulty.toUpperAscii(), FontPath, 14, color(1,1,1,0.8)))
stats.addItem(newTextNode("ACTIVE UNITS: 2", FontPath, 14, color(1,1,1,0.8)))
stats.addItem(newTextNode("STATUS: ONLINE", FontPath, 14, hex"#4ecca3"))
panel.addItem(stats)

# Layout Update with new withSize helper
discard panel.withSize(300, 0, ctx) # Auto height, fixed width

let panelBg = newRectNode(panel.size)
panelBg.localPos = panel.localPos
panelBg.fill = some(solidPaint(hex"#16213e", 200.0 / 255.0))
panelBg.stroke = some(solidPaint(hex"#e94560"))
panelBg.strokeWidth = 2
panelBg.cornerRadius = 10
uiRoot.addChild(panelBg)
uiRoot.addChild(panel)

# --- Main Loop ---
var swapTimer = 0.0
var ship2IsBlue = false

window.onFrame = proc() =
  let dt = 1.0 / 60.0
  swapTimer += dt

  # Animate the grid slightly (Rotate)
  gridRoot.localRotation += 0.001
  # No markDirty needed for transform-only changes

  if swapTimer > 1.0:
    swapTimer = 0.0
    ship2IsBlue = not ship2IsBlue
    ship2.imageKey = if ship2IsBlue: "enemyBlue" else: "enemyRed"
    ship2.markDirty() # Content change: image key swap needs re-rasterization

  # Draw
  ctx.draw(root)
  
  window.swapBuffers()

while not window.closeRequested:
  pollEvents()
