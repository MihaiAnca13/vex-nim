import vmath
import ../core/types
import ../layout/alignment

type
  ## Grid container that places children in rows and columns.
  Grid* = ref object of Node
    columns*: int
    rows*: int
    columnSpacing*: float32
    rowSpacing*: float32
    cellWidth*: float32
    cellHeight*: float32
    fillWidth*: bool
    fillHeight*: bool

## Creates a new grid layout container.
proc newGrid*(
  columns: int = 0,
  rows: int = 0,
  columnSpacing: float32 = 4.0,
  rowSpacing: float32 = 4.0,
  cellWidth: float32 = 0.0,
  cellHeight: float32 = 0.0,
  fillWidth: bool = false,
  fillHeight: bool = false
): Grid =
  Grid(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    globalTransform: identityTransform,
    dirty: true,
    visible: true,
    name: "",
    size: vec2(0, 0),
    zIndex: 0,
    clipChildren: false,
    childrenSorted: true,
    anchor: TopLeft,
    anchorOffset: vec2(0, 0),
    pivot: TopLeft,
    sizeMode: Absolute,
    sizePercent: vec2(1, 1),
    scaleMode: Stretch,
    minSize: vec2(0, 0),
    maxSize: vec2(0, 0),
    layoutValid: false,
    autoLayout: true,
    columns: columns,
    rows: rows,
    columnSpacing: columnSpacing,
    rowSpacing: rowSpacing,
    cellWidth: cellWidth,
    cellHeight: cellHeight,
    fillWidth: fillWidth,
    fillHeight: fillHeight
  )

## Adds a child to the grid and marks layout dirty.
proc addItem*(grid: Grid, child: Node) =
  grid.addChild(child)
  child.autoLayout = false
  grid.markDirty()

## Measures children, computes cell size, and positions items.
proc update*(grid: Grid, ctx: types.RenderContext = nil) =
  for child in grid.children:
    child.measure(ctx)

  if grid.children.len == 0:
    grid.size = vec2(0, 0)
    return

  let effectiveColumns = if grid.columns > 0: grid.columns else: grid.children.len
  let effectiveRows = if grid.rows > 0: grid.rows else: ((grid.children.len + effectiveColumns - 1) div effectiveColumns)

  var maxCellWidth = 0.0
  var maxCellHeight = 0.0

  if grid.cellWidth > 0:
    maxCellWidth = grid.cellWidth
  else:
    for child in grid.children:
      if child.size.x > maxCellWidth:
        maxCellWidth = child.size.x

  if grid.cellHeight > 0:
    maxCellHeight = grid.cellHeight
  else:
    for child in grid.children:
      if child.size.y > maxCellHeight:
        maxCellHeight = child.size.y

  var childIndex = 0
  for row in 0..<effectiveRows:
    for col in 0..<effectiveColumns:
      if childIndex >= grid.children.len:
        break
      let child = grid.children[childIndex]

      let targetWidth = if grid.fillWidth and grid.cellWidth > 0: grid.cellWidth else: maxCellWidth
      let targetHeight = if grid.fillHeight and grid.cellHeight > 0: grid.cellHeight else: maxCellHeight

      if grid.fillWidth and child.size.x != targetWidth:
        child.size.x = targetWidth
        child.markDirty()
      if grid.fillHeight and child.size.y != targetHeight:
        child.size.y = targetHeight
        child.markDirty()

      let x = col.float32 * (maxCellWidth + grid.columnSpacing)
      let y = row.float32 * (maxCellHeight + grid.rowSpacing)
      child.localPos = vec2(x, y)
      child.updateGlobalTransform()

      inc childIndex

  let totalWidth = effectiveColumns.float32 * maxCellWidth + (effectiveColumns - 1).float32 * grid.columnSpacing
  let totalHeight = effectiveRows.float32 * maxCellHeight + (effectiveRows - 1).float32 * grid.rowSpacing

  grid.size = vec2(totalWidth, totalHeight)
  grid.markDirty()

method measure*(grid: Grid, ctx: types.RenderContext) =
  grid.update(ctx)
