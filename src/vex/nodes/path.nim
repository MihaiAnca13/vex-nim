import std/options
import pixie
import vmath
import ../core/types
import ../core/transform

type
  PathNode* = ref object of Node
    pathData*: string
    fill*: Option[Paint]
    stroke*: Option[Paint]
    strokeWidth*: float32
    strokeCap*: LineCap
    strokeJoin*: LineJoin

proc newPathNode*(pathData: string): PathNode =
  PathNode(
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    dirty: true,
    visible: true,
    name: "",
    size: vec2(0, 0),
    zIndex: 0,
    clipChildren: false,
    childrenSorted: true,
    pathData: pathData,
    fill: none(Paint),
    stroke: none(Paint),
    strokeWidth: 1.0,
    strokeCap: ButtCap,
    strokeJoin: MiterJoin,
    globalTransform: identityTransform
  )

proc newHexNode*(radius: float32): PathNode =
  let points: array[6, Vec2] = [
    vec2(radius, 0),
    vec2(radius * 0.5, radius * 0.866),
    vec2(-radius * 0.5, radius * 0.866),
    vec2(-radius, 0),
    vec2(-radius * 0.5, -radius * 0.866),
    vec2(radius * 0.5, -radius * 0.866)
  ]
  var hexPath = "M " & $points[0].x & " " & $points[0].y
  for i in 1..<6:
    hexPath &= " L " & $points[i].x & " " & $points[i].y
  hexPath &= " Z"
  PathNode(
    pathData: hexPath,
    fill: none(Paint),
    stroke: none(Paint),
    strokeWidth: 1.0,
    strokeCap: ButtCap,
    strokeJoin: MiterJoin,
    children: @[],
    localPos: vec2(0, 0),
    localScale: vec2(1, 1),
    localRotation: 0.0,
    dirty: true,
    visible: true,
    name: "",
    size: vec2(radius * 2, radius * 2),
    zIndex: 0,
    clipChildren: false,
    childrenSorted: true,
    globalTransform: identityTransform
  )

proc contains*(node: PathNode, point: Vec2): bool =
  let localPoint = node.globalToLocal(point)
  localPoint.x >= 0 and localPoint.x < node.size.x and
  localPoint.y >= 0 and localPoint.y < node.size.y

method draw*(node: PathNode, renderCtx: RenderContext, image: Image) =
  try:
    let path = parsePath(node.pathData)

    let paint = if node.fill.isSome: node.fill.get() else: color(1, 1, 1, 1)

    image.fillPath(path, paint)

    if node.stroke.isSome:
      image.strokePath(
        path,
        node.stroke.get(),
        strokeWidth = node.strokeWidth,
        lineCap = node.strokeCap,
        lineJoin = node.strokeJoin
      )
  except PixieError:
    discard
