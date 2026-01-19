import std/options
import std/tables
import vmath
import pixie
import ../core/types
import ../core/transform

## Hexagonal grid utilities for strategy games and hexagonal layouts.
##
## Supports both pointy-topped and flat-topped hex orientations.
## Uses axial coordinates (q, r) internally with cube coordinate conversions
## for distance and line calculations.

type
  HexOrientation* = enum
    PointyTopped
    FlatTopped

  HexCoord* = tuple[q, r: int]
  CubeCoord* = tuple[x, y, z: int]

  HexLayout* = ref object
    orientation*: HexOrientation
    size*: Vec2
    origin*: Vec2

  HexNode* = ref object of Node
    coord*: HexCoord
    layout*: HexLayout
    fill*: Option[Paint]
    stroke*: Option[Paint]
    strokeWidth*: float32

const
  pointyOrientation* = HexOrientation.PointyTopped
  flatOrientation* = HexOrientation.FlatTopped

## Converts axial coordinates to cube coordinates.
## Cube coordinates use three axes (x, y, z) that sum to zero.
proc axialToCube*(coord: HexCoord): CubeCoord =
  let x = coord.q
  let z = coord.r
  let y = -x - z
  (x, y, z)

## Converts cube coordinates to axial coordinates.
proc cubeToAxial*(coord: CubeCoord): HexCoord =
  (coord.x, coord.z)

## Rounds fractional cube coordinates to the nearest integer hex.
proc cubeRound*(x, y, z: float32): CubeCoord =
  let rx = round(x)
  let ry = round(y)
  let rz = round(z)

  let xDiff = abs(rx - x)
  let yDiff = abs(ry - y)
  let zDiff = abs(rz - z)

  if xDiff > yDiff and xDiff > zDiff:
    (int(-ry - rz), int(ry), int(rz))
  elif yDiff > zDiff:
    (int(rx), int(-rx - rz), int(rz))
  else:
    (int(rx), int(ry), int(-rx - ry))

## Rounds fractional axial coordinates to the nearest integer hex.
proc axialRound*(q, r: float32): HexCoord =
  let x = q
  let z = r
  let y = -x - z
  cubeRound(x, y, z).cubeToAxial()

## Converts hex coordinates to pixel coordinates in screen space.
proc hexToPixel*(layout: HexLayout, coord: HexCoord): Vec2 =
  let orientation = layout.orientation
  let size = layout.size
  let origin = layout.origin

  var x, y: float32
  if orientation == PointyTopped:
    x = size.x * (sqrt(3.0'f32) * float32(coord.q) + sqrt(3.0'f32) / 2.0 * float32(coord.r))
    y = size.y * (3.0'f32 / 2.0 * float32(coord.r))
  else:
    x = size.x * (3.0'f32 / 2.0 * float32(coord.q))
    y = size.y * (sqrt(3.0'f32) / 2.0 * float32(coord.q) + sqrt(3.0'f32) * float32(coord.r))

  vec2(origin.x + x, origin.y + y)

## Converts pixel coordinates to the nearest hex coordinate.
proc pixelToHex*(layout: HexLayout, pixel: Vec2): HexCoord =
  let orientation = layout.orientation
  let size = layout.size
  let origin = layout.origin

  let pt = vec2(pixel.x - origin.x, pixel.y - origin.y)
  var q, r: float32

  if orientation == PointyTopped:
    q = (sqrt(3.0'f32) / 3.0 * pt.x - 1.0'f32 / 3.0 * pt.y) / size.x
    r = (2.0'f32 / 3.0 * pt.y) / size.y
  else:
    q = (2.0'f32 / 3.0 * pt.x) / size.x
    r = (-1.0'f32 / 3.0 * pt.x + sqrt(3.0'f32) / 3.0 * pt.y) / size.y

  axialRound(q, r)

## Returns the offset vector for a hex corner relative to the hex center.
proc hexCornerOffset*(layout: HexLayout, corner: int): Vec2 =
  let size = layout.size
  let orientation = layout.orientation
  let angle = 2.0'f32 * PI * (float32(corner) + (if orientation == PointyTopped: 0.5'f32 else: 0.0'f32)) / 6.0'f32
  vec2(size.x * cos(angle), size.y * sin(angle))

const
  hexDirections* = [
    (1, 0), (1, -1), (0, -1),
    (-1, 0), (-1, 1), (0, 1)
  ]

## Returns the neighbor coordinate in the given direction (0-5).
proc hexNeighbor*(coord: HexCoord, direction: int): HexCoord =
  let d = hexDirections[direction]
  (coord.q + d[0], coord.r + d[1])

## Calculates the distance between two hex coordinates.
## Returns the number of steps needed to move from a to b.
proc hexDistance*(a, b: HexCoord): int =
  let ac = a.axialToCube()
  let bc = b.axialToCube()
  (abs(ac.x - bc.x) + abs(ac.y - bc.y) + abs(ac.z - bc.z)) div 2

## Generates a line of hex coordinates between two points.
## Includes both endpoints. Returns a single hex when a == b.
proc hexLine*(a, b: HexCoord): seq[HexCoord] =
  let n = a.hexDistance(b)
  if n == 0:
    return @[a]

  var results: seq[HexCoord] = @[]
  for i in 0..n:
    let t = float32(i) / float32(n)
    let acube = a.axialToCube()
    let bcube = b.axialToCube()
    let interpolated = cubeRound(
      mix(float32(acube.x), float32(bcube.x), t),
      mix(float32(acube.y), float32(bcube.y), t),
      mix(float32(acube.z), float32(bcube.z), t)
    )
    results.add(interpolated.cubeToAxial())

  results

## Creates a new hex layout with the specified orientation, size, and origin.
proc newHexLayout*(orientation: HexOrientation, size, origin: Vec2): HexLayout =
  HexLayout(orientation: orientation, size: size, origin: origin)

## Creates a new hex node at the specified axial coordinates.
proc newHexNode*(coord: HexCoord, layout: HexLayout): HexNode =
  let pixelPos = layout.hexToPixel(coord)
  let hexSize = layout.size
  HexNode(
    coord: coord,
    layout: layout,
    fill: none(Paint),
    stroke: none(Paint),
    strokeWidth: 1.0,
    globalTransform: identityTransform,
    localPos: pixelPos,
    localScale: vec2(1, 1),
    localRotation: 0.0,
    dirty: true,
    visible: true,
    name: "",
    size: hexSize * 2.0,
    children: @[]
  )

proc contains*(node: HexNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  let center = node.size / 2.0
  let relX = localPoint.x - center.x
  let relY = localPoint.y - center.y

  let size = node.layout.size
  let r = if node.layout.orientation == PointyTopped: size.x else: size.y

  abs(relX) <= r and abs(relY) <= r * sqrt(3.0'f32) / 2.0 and
    abs(relX * 0.5 + relY * sqrt(3.0'f32) / 2.0) <= r and
    abs(relX * 0.5 - relY * sqrt(3.0'f32) / 2.0) <= r

## Rasterizes the hex node to an image using Pixie.
proc draw*(node: HexNode, renderCtx: RenderContext, image: Image) =
  let ctx = newContext(image)
  let center = node.size / 2.0

  if node.fill.isSome:
    try:
      ctx.fillStyle = node.fill.get()
      let path = newPath()
      for i in 0..5:
        let corner = node.layout.hexCornerOffset(i)
        let px = center.x + corner.x
        let py = center.y + corner.y
        if i == 0:
          path.moveTo(px, py)
        else:
          path.lineTo(px, py)
      path.closePath()
      ctx.fill(path)
    except PixieError:
      discard

  if node.stroke.isSome:
    try:
      ctx.strokeStyle = node.stroke.get()
      ctx.lineWidth = node.strokeWidth
      let path = newPath()
      for i in 0..5:
        let corner = node.layout.hexCornerOffset(i)
        let px = center.x + corner.x
        let py = center.y + corner.y
        if i == 0:
          path.moveTo(px, py)
        else:
          path.lineTo(px, py)
      path.closePath()
      ctx.stroke(path)
    except PixieError:
      discard

type
  HexGrid* = ref object of Node
    layout*: HexLayout
    nodes*: Table[HexCoord, HexNode]

## Creates a new empty hex grid with the specified layout.
proc newHexGrid*(layout: HexLayout): HexGrid =
  HexGrid(
    layout: layout,
    nodes: initTable[HexCoord, HexNode](),
    globalTransform: identityTransform,
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    dirty: true,
    visible: true,
    name: "",
    size: vec2(0, 0),
    children: @[]
  )

## Adds a hex at the specified coordinate to the grid.
## Returns the existing hex if one already exists at that coordinate.
proc addHex*(grid: HexGrid, coord: HexCoord): HexNode =
  if grid.nodes.hasKey(coord):
    return grid.nodes[coord]

  let node = newHexNode(coord, grid.layout)
  grid.nodes[coord] = node
  grid.addChild(node)
  grid.markDirty()
  node

## Removes a hex at the specified coordinate from the grid.
proc removeHex*(grid: HexGrid, coord: HexCoord) =
  if not grid.nodes.hasKey(coord):
    return

  let node = grid.nodes[coord]
  grid.removeChild(node)
  grid.nodes.del(coord)
  grid.markDirty()

## Gets the hex node at the specified coordinate, if it exists.
proc getHex*(grid: HexGrid, coord: HexCoord): Option[HexNode] =
  if grid.nodes.hasKey(coord):
    return some(grid.nodes[coord])
  none(HexNode)

## Finds the hex at the specified pixel position, if one exists.
proc hexAt*(grid: HexGrid, pixel: Vec2): Option[HexCoord] =
  let coord = grid.layout.pixelToHex(pixel)
  if grid.nodes.hasKey(coord):
    return some(coord)
  none(HexCoord)

## Updates the grid's bounding box based on its children.
## Call this after adding or removing hexes.
proc updateGrid*(grid: HexGrid) =
  if grid.children.len == 0:
    grid.size = vec2(0, 0)
    return

  var minX = Inf
  var minY = Inf
  var maxX = -Inf
  var maxY = -Inf

  for child in grid.children:
    if not child.visible:
      continue
    let bounds = child.getGlobalBounds()
    minX = min(minX, bounds.x)
    minY = min(minY, bounds.y)
    maxX = max(maxX, bounds.x + bounds.w)
    maxY = max(maxY, bounds.y + bounds.h)

  grid.size = vec2(maxX - minX, maxY - minY)
  grid.markDirty()
