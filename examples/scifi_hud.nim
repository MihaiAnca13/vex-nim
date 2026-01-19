import std/[json, options, tables]
import vex, windy, opengl, vmath, pixie

# --- Configuration ---
const
  WindowSize = ivec2(1280, 720)
  HexSize = vec2(40, 40)
  FontPath = "examples/assets/Orbitron.ttf"
  UnitPath = "examples/assets/enemyRed.png"

# --- Load External Data ---
type MapData = object
  name: string
  difficulty: string
  biomes: Table[string, string] # hex color strings
  tiles: seq[tuple[q, r: int, `type`: string]]

proc solidPaint(color: Color, opacity: float32 = 1.0): Paint =
  let paint = newPaint(SolidPaint)
  paint.color = color
  paint.opacity = opacity
  paint

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

# --- Scene Construction ---
let root = newNode()
root.size = WindowSize.vec2

# 1. Background Layer (Starfield simulation)
let bg = newRectNode(WindowSize.vec2)
bg.fill = some(solidPaint(parseHtmlColor("#1a1a2e"))) # Dark Navy
root.addChild(bg)

# 2. Hex Map Container (Centered)
let gridLayout = newHexLayout(pointyOrientation, HexSize, vec2(0,0))
let hexGrid = newHexGrid(gridLayout)
hexGrid.localPos = WindowSize.vec2 / 2
root.addChild(hexGrid)

# Populate Grid from JSON
for tile in mapData.tiles:
  let coord = (tile.q, tile.r)
  let hexNode = hexGrid.addHex(coord)
  
  # Style based on JSON biome
  let colorHex = mapData.biomes[tile.`type`]
  hexNode.fill = some(solidPaint(parseHtmlColor(colorHex)))
  hexNode.stroke = some(solidPaint(parseHtmlColor("#4ecca3"))) # Neon Green Borders
  hexNode.strokeWidth = 2.0

  # Add Unit Sprite to the Base
  if tile.`type` == "base":
    let unit = newSpriteNode("enemyRed", vec2(48, 48))
    # Center sprite in hex (HexNode size is roughly size * 2)
    unit.localPos = hexNode.size / 2 - unit.size / 2 
    hexNode.addChild(unit)

hexGrid.updateGrid() # Recalculate bounds

# 3. UI Layer (HUD)
let uiRoot = newRectNode(WindowSize.vec2)
uiRoot.fill = none(Paint) # Transparent container
root.addChild(uiRoot)

# -- Side Panel (VBox) --
let panel = newVBox(spacing = 10, padding = 20)
panel.localPos = vec2(20, 20)

# Title
let title = newTextNode(mapData.name, FontPath, 28, parseHtmlColor("#e94560"))
panel.addItem(title)

# Stats Block
let stats = newVBox(spacing = 5, padding = 0)
stats.addItem(newTextNode("DIFFICULTY: " & mapData.difficulty, FontPath, 14, color(1,1,1,0.8)))
stats.addItem(newTextNode("ACTIVE UNITS: 1", FontPath, 14, color(1,1,1,0.8)))
stats.addItem(newTextNode("STATUS: ONLINE", FontPath, 14, parseHtmlColor("#4ecca3")))
panel.addItem(stats)

# Layout Update
panel.update(ctx) # Calculates size based on text
panel.size = vec2(300, panel.size.y) # Force width to 300

let panelBg = newRectNode(panel.size)
panelBg.localPos = panel.localPos
panelBg.fill = some(solidPaint(parseHtmlColor("#16213e"), 200.0 / 255.0)) # Semi-transparent
panelBg.stroke = some(solidPaint(parseHtmlColor("#e94560")))
panelBg.strokeWidth = 2
panelBg.cornerRadius = 10
uiRoot.addChild(panelBg)
uiRoot.addChild(panel)

# --- Main Loop ---
window.onFrame = proc() =
  # Animate the grid slightly (Rotate)
  hexGrid.localRotation += 0.001
  # hexGrid.markDirty() # Important: Mark dirty to re-rasterize rotation

  # Draw
  ctx.draw(root)
  
  window.swapBuffers()

while not window.closeRequested:
  pollEvents()
